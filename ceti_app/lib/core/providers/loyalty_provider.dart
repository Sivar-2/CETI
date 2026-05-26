import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final DateTime birthDate;
  final int points;
  final String tier; // Bronce, Plata, Oro
  final String? nfcTagId;
  final String walletPassId; // Unique Apple/Google Wallet token linked to Firestore ID
  final Map<String, dynamic> customFields; // Dynamic fields requested by the business

  Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.birthDate,
    required this.points,
    required this.tier,
    this.nfcTagId,
    required this.walletPassId,
    this.customFields = const {},
  });

  factory Customer.fromFirestore(Map<String, dynamic> data, String docId) {
    return Customer(
      id: docId,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      birthDate: (data['birthDate'] as Timestamp).toDate(),
      points: data['points'] ?? 0,
      tier: data['tier'] ?? 'Bronce',
      nfcTagId: data['nfcTagId'],
      walletPassId: data['walletPassId'] ?? docId,
      customFields: data['customFields'] ?? {},
    );
  }
}

class LoyaltyProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Customer? _selectedCustomer;
  bool _isScanningQr = false;

  Customer? get selectedCustomer => _selectedCustomer;
  bool get isScanningQr => _isScanningQr;

  // Generates the cloud link embedded in the static store counter QR for Apple/Google Wallet registration
  String generateWalletRegistrationUrl(String businessId) {
    return "https://api.ceti.app/v1/business/$businessId/wallet-register?platform=hybrid";
  }

  // Scans the barcode/QR code presented on the client's Apple or Google Wallet app
  Future<bool> loadCustomerFromWalletPass(String scannedWalletPassId) async {
    _isScanningQr = true;
    notifyListeners();

    try {
      final query = await _db
          .collection('customers')
          .where('walletPassId', isEqualTo: scannedWalletPassId)
          .limit(1)
          .get(const GetOptions(source: Source.serverAndCache)); // Poka-Yoke offline resilient query

      if (query.docs.isNotEmpty) {
        _selectedCustomer = Customer.fromFirestore(query.docs.first.data(), query.docs.first.id);
        _isScanningQr = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Error loading wallet pass profile: $e");
    }

    _isScanningQr = false;
    notifyListeners();
    return false;
  }

  void clearSelection() {
    _selectedCustomer = null;
    notifyListeners();
  }

  // Restoring essential backwards compatibility methods for OrdersProvider and NfcProvider
  Future<void> addPointsForOrder(String? customerPhone, double orderTotal) async {
    if (customerPhone == null || customerPhone.isEmpty) return;
    final pointsEarned = orderTotal.floor();
    if (pointsEarned <= 0) return;

    final query = await _db.collection('customers').where('phone', isEqualTo: customerPhone).limit(1).get();
    if (query.docs.isNotEmpty) {
      final docRef = query.docs.first.reference;
      await _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;
        final currentPoints = (snapshot.data()?['points'] as num?)?.toInt() ?? 0;
        final newPoints = currentPoints + pointsEarned;
        transaction.update(docRef, {'points': newPoints});
      });
    }
  }

  Future<void> linkNfcToCustomer(String customerId, String nfcTagId) async {
    await _db.collection('customers').doc(customerId).update({'nfcTagId': nfcTagId});
  }

  Future<Customer?> getCustomerByNfc(String nfcTagId) async {
    final query = await _db.collection('customers').where('nfcTagId', isEqualTo: nfcTagId).limit(1).get();
    if (query.docs.isNotEmpty) {
      return Customer.fromFirestore(query.docs.first.data(), query.docs.first.id);
    }
    return null;
  }
}
