import 'package:flutter/foundation.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'loyalty_provider.dart';

enum NfcStatus { idle, scanning, success, error }

class NfcProvider extends ChangeNotifier {
  NfcStatus _status = NfcStatus.idle;
  String _message = '';

  NfcStatus get status => _status;
  String get message => _message;

  Future<void> startNfcSession(LoyaltyProvider loyaltyProvider, {String? linkToCustomerId}) async {
    try {
      bool isAvailable = await NfcManager.instance.isAvailable();
      if (!isAvailable) {
        _setStatus(NfcStatus.error, 'NFC no disponible en este dispositivo');
        return;
      }

      _setStatus(NfcStatus.scanning, 'Acerca la tarjeta del cliente al sensor...');

      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          // Extract unique ID from tag
          // For Mifare/NfcA it's often in tag.data['nfca']['identifier'] or similar
          // We will extract a hex string of the ID as a safe fallback
          String nfcTagId = _extractTagId(tag.data);

          if (linkToCustomerId != null) {
            // Link mode: Bind this new card to an existing user
            await loyaltyProvider.linkNfcToCustomer(linkToCustomerId, nfcTagId);
            _setStatus(NfcStatus.success, '¡Tarjeta vinculada con éxito!');
          } else {
            // Scan mode: Find customer by this card
            final customer = await loyaltyProvider.getCustomerByNfc(nfcTagId);
            if (customer != null) {
              _setStatus(NfcStatus.success, '¡Hola, ${customer.firstName}!');
            } else {
              _setStatus(NfcStatus.error, 'Tarjeta no registrada en el sistema');
            }
          }

          NfcManager.instance.stopSession();
          _resetAfterDelay();
        },
      );
    } catch (e) {
      _setStatus(NfcStatus.error, 'Error de lectura. Por favor, intenta de nuevo.');
      try {
        NfcManager.instance.stopSession();
      } catch (_) {}
      _resetAfterDelay();
    }
  }

  void stopNfcSession() {
    if (_status == NfcStatus.scanning) {
      try {
        NfcManager.instance.stopSession();
      } catch (_) {}
      _setStatus(NfcStatus.idle, '');
    }
  }

  String _extractTagId(Map<String, dynamic> tagData) {
    // Attempt to extract raw identifier array
    List<int>? idBytes;
    if (tagData.containsKey('nfca')) {
      idBytes = tagData['nfca']['identifier'];
    } else if (tagData.containsKey('mifareclassic')) {
      idBytes = tagData['mifareclassic']['identifier'];
    } else if (tagData.containsKey('mifareultralight')) {
      idBytes = tagData['mifareultralight']['identifier'];
    } else if (tagData.containsKey('ndef')) {
      // ndef tag identifier might not always be directly available this way
    }
    
    if (idBytes != null) {
      return idBytes.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
    }
    
    // Fallback: hash the entire data structure
    return tagData.toString().hashCode.toString();
  }

  void _setStatus(NfcStatus newStatus, String msg) {
    _status = newStatus;
    _message = msg;
    notifyListeners();
  }

  void _resetAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_status == NfcStatus.success || _status == NfcStatus.error) {
        _setStatus(NfcStatus.idle, '');
      }
    });
  }
}
