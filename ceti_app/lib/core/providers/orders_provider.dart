import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/product_model.dart';
import 'inventory_provider.dart';
import 'dashboard_provider.dart';
import 'loyalty_provider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class OrdersProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  StreamSubscription? _ordersSub;
  List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders);
  List<Order> get pendingOrders => _orders.where((o) => o.status == OrderStatus.pending || o.status == OrderStatus.confirmed).toList();
  List<Order> get upcomingOrders => _orders.where((o) => o.mode == OrderMode.delivery || o.mode == OrderMode.takeaway).toList();

  Future<void> init() async {
    _ordersSub = _db.collection('orders').orderBy('createdAt', descending: true).snapshots().listen((snapshot) {
      _orders = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        
        // Handle Firestore Timestamp parsing inside the model if needed,
        // or parse directly here. Our model likely expects DateTime string from JSON.
        // If fromMap expects String, we convert Timestamp -> isoString.
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }
        if (data['closedAt'] is Timestamp) {
          data['closedAt'] = (data['closedAt'] as Timestamp).toDate().toIso8601String();
        }

        return Order.fromMap(data);
      }).toList();
      notifyListeners();
    });
  }

  Future<void> createOrder(Order order, DashboardProvider dash) async {
    final data = order.toMap();
    // Use Firestore Timestamps
    data['createdAt'] = FieldValue.serverTimestamp();
    
    await _db.collection('orders').doc(order.id).set(data);
    // Note: Local _orders array is updated via stream automatically, zero lag.
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus, InventoryProvider inventory, DashboardProvider dash, LoyaltyProvider loyalty) async {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      final oldOrder = _orders[idx];
      
      final Map<String, dynamic> updates = {
        'status': newStatus.name,
      };

      if (newStatus == OrderStatus.completed) {
        updates['closedAt'] = FieldValue.serverTimestamp();
      }

      await _db.collection('orders').doc(orderId).update(updates);

      // Trigger automatic inventory deduction and metrics if completed
      // Since this triggers side effects, we only do it once per order transition
      if (newStatus == OrderStatus.completed && oldOrder.status != OrderStatus.completed) {
        inventory.deductForOrder(oldOrder);
        loyalty.addPointsForOrder(oldOrder.customerPhone, oldOrder.subtotal);
        
        // Log transaction telemetry silently
        try {
          await FirebaseAnalytics.instance.logEvent(
            name: 'transaction_completed_event',
            parameters: {
              'value': oldOrder.subtotal,
              'currency': 'USD',
              'item_count': oldOrder.items.length,
              'order_mode': oldOrder.mode.name,
            },
          );
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    _ordersSub?.cancel();
    super.dispose();
  }
}
