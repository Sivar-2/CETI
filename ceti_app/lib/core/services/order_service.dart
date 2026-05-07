import '../models/product_model.dart';

/// ──────────────────────────────────────────────────────────────────────────────
/// OrderService — Firestore Integration Layer
///
/// Handles all persistence logic for orders, inventory deduction, loyalty
/// point accrual, and cash register operations.
///
/// NOTE: Firebase calls are stubbed behind TODO comments. Uncomment and
/// provide a Firestore instance when Firebase is configured.
/// ──────────────────────────────────────────────────────────────────────────────

class OrderService {
  // TODO: CONNECT — Inject FirebaseFirestore instance
  // final FirebaseFirestore _db;
  // OrderService(this._db);
  OrderService();

  // ── Submit Order ──────────────────────────────────────────────────────────

  /// Persists the order to Firestore, triggers inventory deduction, and
  /// accrues loyalty points if a phone number is provided.
  ///
  /// Returns the generated order ID.
  Future<String> submitOrder({
    required Order order,
    required List<Product> catalog,
    required Map<String, Supply> supplies,
  }) async {
    // 1. Write order document
    // TODO: CONNECT — await _db.collection('orders').doc(order.id).set(order.toMap());

    // 2. Trigger escandallo deduction for composite products
    if (order.status == OrderStatus.confirmed) {
      await _deductInventory(order, catalog, supplies);
    }

    // 3. Accrue loyalty points
    if (order.customerPhone != null &&
        order.customerPhone!.isNotEmpty &&
        order.status == OrderStatus.confirmed) {
      await _accrueLoyalty(order);
    }

    return order.id;
  }

  // ── Inventory Deduction (Escandallo Trigger) ───────────────────────────────

  /// For each confirmed OrderItem, look up the Product recipe and deduct
  /// the required quantities from the supplies collection.
  Future<void> _deductInventory(
    Order order,
    List<Product> catalog,
    Map<String, Supply> supplies,
  ) async {
    for (final item in order.items) {
      final product = catalog.where((p) => p.id == item.productId).firstOrNull;
      if (product == null || !product.isComposite) continue;

      for (final component in product.recipe) {
        final totalDeduction = component.quantityRequired * item.quantity;
        final supply = supplies[component.supplyId];
        if (supply == null) continue;

        final newStock = (supply.stockActual - totalDeduction).clamp(0.0, double.infinity);

        // TODO: CONNECT — Firestore batch update
        // await _db.collection('supplies').doc(component.supplyId).update({
        //   'stockActual': newStock,
        // });

        // Update local reference
        supplies[component.supplyId] = supply.copyWith(stockActual: newStock);
      }
    }
  }

  // ── Stock Validation (Poka-yoke) ───────────────────────────────────────────

  /// Checks whether all ingredients for a product are available.
  /// Returns a list of supply names that are insufficient.
  static List<String> validateStock(
    Product product,
    Map<String, Supply> supplies, {
    int quantity = 1,
  }) {
    final insufficient = <String>[];

    for (final component in product.recipe) {
      final supply = supplies[component.supplyId];
      if (supply == null) {
        insufficient.add(component.supplyName);
        continue;
      }

      final required = component.quantityRequired * quantity;
      if (supply.stockActual < required) {
        insufficient.add('${component.supplyName} (necesita $required ${component.unit}, hay ${supply.stockActual})');
      }
    }

    return insufficient;
  }

  /// Checks if a product has critical stock (any ingredient below minimum).
  static bool hasCriticalStock(
    Product product,
    Map<String, Supply> supplies,
  ) {
    for (final component in product.recipe) {
      final supply = supplies[component.supplyId];
      if (supply == null || supply.isCritical) return true;
    }
    return false;
  }

  // ── Loyalty Points ─────────────────────────────────────────────────────────

  /// 1 USD = 1 Point. Accrues to the customer phone ledger.
  Future<void> _accrueLoyalty(Order order) async {
    final points = order.subtotal.truncate();
    if (points <= 0) return;

    final tx = LoyaltyTransaction(
      id: 'lty_${order.id}',
      phone: order.customerPhone!,
      orderId: order.id,
      pointsEarned: points,
      totalPoints: points, // Updated via Firestore increment
      createdAt: DateTime.now(),
    );

    // TODO: CONNECT — Write loyalty transaction & increment counter
    // final batch = _db.batch();
    // batch.set(_db.collection('loyalty_transactions').doc(tx.id), tx.toMap());
    // batch.update(_db.collection('loyalty_accounts').doc(order.customerPhone!), {
    //   'totalPoints': FieldValue.increment(points),
    //   'lastVisit': FieldValue.serverTimestamp(),
    // });
    // await batch.commit();

    // Suppress unused variable warning in stub mode
    tx.toMap();
  }

  // ── Confirm AI Order (Double-Check Humano) ─────────────────────────────────

  /// Transitions an AI-generated order from [pending] to [confirmed]
  /// after a human validates the payment.
  Future<void> confirmPendingOrder({
    required String orderId,
    required PaymentMethod paymentMethod,
    double? cashReceived,
    required List<Product> catalog,
    required Map<String, Supply> supplies,
  }) async {
    // TODO: CONNECT — Update status in Firestore
    // await _db.collection('orders').doc(orderId).update({
    //   'status': OrderStatus.confirmed.name,
    //   'paymentMethod': paymentMethod.name,
    //   'cashReceived': cashReceived,
    //   'closedAt': FieldValue.serverTimestamp(),
    // });

    // Trigger deduction after human confirmation
    // Re-fetch the order from Firestore and run _deductInventory
  }

  // ── Cash Register Close (Cierre Ciego) ─────────────────────────────────────

  /// Performs a blind cash register close:
  /// 1. Operator inputs physical count
  /// 2. System calculates expected balance
  /// 3. Discrepancy is logged as an adjustment
  Future<CashRegisterClose> closeCashRegister({
    required double physicalCount,
    required double expectedBalance,
    required String operatorId,
    String? note,
  }) async {
    final discrepancy = physicalCount - expectedBalance;

    final close = CashRegisterClose(
      id: 'close_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      operatorId: operatorId,
      physicalCount: physicalCount,
      expectedBalance: expectedBalance,
      discrepancy: discrepancy,
      adjustmentNote: discrepancy != 0
          ? (note ?? 'Ajuste de caja: \$${discrepancy.toStringAsFixed(2)}')
          : null,
    );

    // TODO: CONNECT — Persist close record
    // await _db.collection('cash_closes').doc(close.id).set(close.toMap());

    return close;
  }

  // ── Generate Order ID ──────────────────────────────────────────────────────

  /// Creates a sequential order ID based on timestamp.
  static String generateOrderId() {
    final now = DateTime.now();
    return 'ORD-${now.year}${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}-'
        '${now.millisecondsSinceEpoch % 100000}';
  }
}
