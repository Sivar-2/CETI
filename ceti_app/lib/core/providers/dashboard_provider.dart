import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/product_model.dart'; // To access OrderStatus

class OperationalReminder {
  final String id;
  final String title;
  bool isCompleted;

  OperationalReminder({required this.id, required this.title, this.isCompleted = false});

  Map<String, dynamic> toMap() => {'id': id, 'title': title, 'isCompleted': isCompleted};
  factory OperationalReminder.fromMap(Map<String, dynamic> m) => OperationalReminder(
    id: m['id'] ?? '', title: m['title'] ?? '', isCompleted: m['isCompleted'] ?? false,
  );
}

class DashboardProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  StreamSubscription? _remindersSub;
  StreamSubscription? _ordersSub;

  double _todaySales = 0.0;
  int _pendingOrders = 0;
  int _completedOrders = 0;
  
  List<FlSpot> _salesDataPoints = [];
  List<OperationalReminder> _reminders = [];

  double get todaySales => _todaySales;
  int get pendingOrders => _pendingOrders;
  int get completedOrders => _completedOrders;
  List<FlSpot> get salesDataPoints => _salesDataPoints;
  List<OperationalReminder> get activeReminders => _reminders.where((r) => !r.isCompleted).toList();

  Future<void> init() async {
    // 1. Reminders Stream
    _remindersSub = _db.collection('reminders').snapshots().listen((snapshot) {
      _reminders = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return OperationalReminder.fromMap(data);
      }).toList();
      notifyListeners();

      if (_reminders.isEmpty && snapshot.metadata.isFromCache == false) {
        _uploadMockReminders();
      }
    });

    // 2. Orders Stream for LIVE Analytics (Deriving Dashboard from Orders collection)
    // We get today's orders using a simple timestamp filter on the client side for now.
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    _ordersSub = _db.collection('orders')
       .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
       .snapshots()
       .listen((snapshot) {
      
      double calcSales = 0.0;
      int calcPending = 0;
      int calcCompleted = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final statusStr = data['status'] as String?;
        final subtotal = (data['subtotal'] as num?)?.toDouble() ?? 0.0;

        if (statusStr == OrderStatus.completed.name) {
          calcCompleted++;
          calcSales += subtotal;
        } else if (statusStr == OrderStatus.pending.name || statusStr == OrderStatus.confirmed.name) {
          calcPending++;
        }
      }

      _todaySales = calcSales;
      _pendingOrders = calcPending;
      _completedOrders = calcCompleted;

      // Mock real-time trend for UI
      if (_salesDataPoints.isEmpty) {
        _salesDataPoints = [const FlSpot(0, 0)];
      }
      double lastX = _salesDataPoints.last.x;
      _salesDataPoints.add(FlSpot(lastX + 1, _todaySales));
      if (_salesDataPoints.length > 7) _salesDataPoints.removeAt(0);

      notifyListeners();
    });
  }

  Future<void> completeReminder(String id) async {
    await _db.collection('reminders').doc(id).update({'isCompleted': true});
  }

  // Since analytics are derived from Orders snapshot now, these methods are essentially no-ops 
  // but kept for API compatibility with orders_provider.dart side effects, or we can just let stream handle it.
  void addSales(double amount) {}
  void incrementPending() {}
  void completeOrder() {}

  void _uploadMockReminders() {
    final batch = _db.batch();
    final list = [
      OperationalReminder(id: 'rem_1', title: 'Verificar efectivo en caja'),
      OperationalReminder(id: 'rem_2', title: 'Limpiar estación de café'),
      OperationalReminder(id: 'rem_3', title: 'Revisar stock de hielo'),
    ];
    for (var r in list) {
      batch.set(_db.collection('reminders').doc(r.id), r.toMap());
    }
    batch.commit();
  }

  @override
  void dispose() {
    _remindersSub?.cancel();
    _ordersSub?.cancel();
    super.dispose();
  }
}
