import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

enum AuthStatus { unauthenticated, authenticated, pinRequired, pinSetup }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unauthenticated;
  String? _currentUserName;
  String? _currentUserEmail;
  bool _isRemembered = false;
  bool _hasBiometric = false;
  String? _pin; // In a real app, this should be hashed/encrypted securely

  AuthStatus get status => _status;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String? get currentUserName => _currentUserName;
  String? get currentUserEmail => _currentUserEmail;
  bool get isRemembered => _isRemembered;
  bool get hasBiometric => _hasBiometric;
  bool get hasPin => _pin != null && _pin!.isNotEmpty;

  static const _keyActive = 'ceti_session_active';
  static const _keyName = 'ceti_user_name';
  static const _keyEmail = 'ceti_user_email';
  static const _keyPin = 'ceti_pin';
  static const _keyRememberMe = 'ceti_remember_me';
  static const _keyBiometric = 'ceti_has_biometric';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    _isRemembered = prefs.getBool(_keyRememberMe) ?? false;
    _hasBiometric = prefs.getBool(_keyBiometric) ?? true; // Default to true for demo
    _pin = prefs.getString(_keyPin);
    
    final isActive = prefs.getBool(_keyActive) ?? false;
    
    if (isActive && _isRemembered) {
      _currentUserName = prefs.getString(_keyName);
      _currentUserEmail = prefs.getString(_keyEmail);
      _status = AuthStatus.pinRequired;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final prefs = await SharedPreferences.getInstance();
      
      _currentUserName = userCredential.user?.displayName ?? 'Usuario Demo';
      _currentUserEmail = userCredential.user?.email ?? email;
      
      await prefs.setBool(_keyActive, true);
      await prefs.setString(_keyName, _currentUserName!);
      await prefs.setString(_keyEmail, _currentUserEmail!);
      await prefs.setBool(_keyRememberMe, _isRemembered);
      
      if (!hasPin) {
        _status = AuthStatus.pinSetup;
      } else {
        _status = AuthStatus.authenticated;
      }
      
      // Log authentication telemetry
      try {
        await FirebaseAnalytics.instance.logEvent(
          name: 'login_event',
          parameters: {
            'role': 'cashier', // Defaulting to cashier for POS context
            'method': 'email_password',
          },
        );
      } catch (_) {}

      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error al iniciar sesión';
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Usuario no encontrado';
          break;
        case 'wrong-password':
          errorMessage = 'Contraseña incorrecta';
          break;
        case 'network-request-failed':
          errorMessage = 'Error de red. Revisa tu conexión';
          break;
        case 'invalid-email':
          errorMessage = 'Formato de correo inválido';
          break;
        case 'user-disabled':
          errorMessage = 'La cuenta de usuario ha sido deshabilitada';
          break;
        case 'too-many-requests':
          errorMessage = 'Demasiados intentos fallidos. Intenta más tarde';
          break;
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Ocurrió un error inesperado');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyActive, false);
    
    if (!_isRemembered) {
      await prefs.remove(_keyName);
      await prefs.remove(_keyEmail);
      _currentUserName = null;
      _currentUserEmail = null;
    }
    
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> verifyPin(String pin) async {
    if (_pin == pin) {
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPin, pin);
    _pin = pin;
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<bool> checkBiometric() async {
    // Simulate biometric check
    await Future.delayed(const Duration(seconds: 1));
    _status = AuthStatus.authenticated;
    notifyListeners();
    return true;
  }

  void toggleRememberMe(bool value) {
    _isRemembered = value;
    notifyListeners();
  }
}
