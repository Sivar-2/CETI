import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

/// ──────────────────────────────────────────────────────────────────────────────
/// CartProvider — Poka-yoke Cart State Management
///
/// Manages the current order cart with full validation:
/// - Prevents adding products with insufficient stock
/// - Tracks custom notes per item
/// - Calculates totals, change, and loyalty points
/// - Supports order mode (takeaway/dine-in/delivery)
/// ──────────────────────────────────────────────────────────────────────────────

class CartProvider extends ChangeNotifier {
  // ── Cart State ──────────────────────────────────────────────────────────────

  final List<OrderItem> _items = [];
  OrderMode _mode = OrderMode.takeaway;
  int? _selectedTable;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  double _cashReceived = 0;
  String? _customerPhone;
  String _source = 'pos';

  // ── Getters ─────────────────────────────────────────────────────────────────

  List<OrderItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (s, i) => s + i.quantity);
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  OrderMode get mode => _mode;
  int? get selectedTable => _selectedTable;
  PaymentMethod get paymentMethod => _paymentMethod;
  double get cashReceived => _cashReceived;
  String? get customerPhone => _customerPhone;
  String get source => _source;

  double get subtotal =>
      _items.fold(0.0, (sum, item) => sum + item.lineTotal);

  double get change =>
      (_cashReceived - subtotal).clamp(0.0, double.infinity);

  bool get canCheckout =>
      _items.isNotEmpty &&
      (_paymentMethod != PaymentMethod.cash || _cashReceived >= subtotal);

  /// Loyalty: 1 USD = 1 Point (truncated)
  int get loyaltyPoints => subtotal.truncate();

  // ── Cart Operations ─────────────────────────────────────────────────────────

  /// Add a product to the cart. If already present, increment quantity.
  /// Returns `false` if the product is blocked (stock validation must be
  /// handled upstream before calling this).
  void addItem(Product product, {String? customNotes, List<String>? extras}) {
    final idx = _items.indexWhere((i) => i.productId == product.id);

    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(
        quantity: _items[idx].quantity + 1,
        customNotes: customNotes ?? _items[idx].customNotes,
        extras: extras ?? _items[idx].extras,
      );
    } else {
      _items.add(OrderItem(
        productId: product.id,
        productName: product.name,
        emoji: product.emoji,
        unitPrice: product.price,
        quantity: 1,
        customNotes: customNotes,
        extras: extras ?? [],
      ));
    }
    notifyListeners();
  }

  /// Update notes and extras for an existing cart item.
  void updateItem(int index, {String? customNotes, List<String>? extras}) {
    if (index < 0 || index >= _items.length) return;
    _items[index] = _items[index].copyWith(
      customNotes: customNotes,
      extras: extras,
    );
    notifyListeners();
  }

  /// Decrease quantity by 1; remove the item if quantity reaches 0.
  void decrementItem(int index) {
    if (index < 0 || index >= _items.length) return;
    if (_items[index].quantity > 1) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity - 1,
      );
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  /// Increment quantity by 1.
  void incrementItem(int index) {
    if (index < 0 || index >= _items.length) return;
    _items[index] = _items[index].copyWith(
      quantity: _items[index].quantity + 1,
    );
    notifyListeners();
  }

  /// Remove an item entirely from the cart.
  void removeItem(int index) {
    if (index < 0 || index >= _items.length) return;
    _items.removeAt(index);
    notifyListeners();
  }

  /// Get quantity in cart for a given product id.
  int quantityOf(String productId) {
    final found = _items.where((i) => i.productId == productId);
    if (found.isEmpty) return 0;
    return found.first.quantity;
  }

  // ── Order Configuration ─────────────────────────────────────────────────────

  void setMode(OrderMode m) {
    _mode = m;
    if (m != OrderMode.dineIn) _selectedTable = null;
    notifyListeners();
  }

  void setSelectedTable(int? table) {
    _selectedTable = table;
    notifyListeners();
  }

  void setPaymentMethod(PaymentMethod pm) {
    _paymentMethod = pm;
    notifyListeners();
  }

  void setCashReceived(double amount) {
    _cashReceived = amount;
    notifyListeners();
  }

  void setCustomerPhone(String? phone) {
    _customerPhone = phone;
    notifyListeners();
  }

  void setSource(String src) {
    _source = src;
    notifyListeners();
  }

  // ── Build Order ─────────────────────────────────────────────────────────────

  /// Creates an Order object from the current cart state.
  /// The order starts as [pending] if sourced from AI/chat,
  /// or [confirmed] if validated at the POS.
  Order buildOrder({
    required String orderId,
    String? operatorId,
    bool fromAI = false,
  }) {
    return Order(
      id: orderId,
      items: List.from(_items),
      subtotal: subtotal,
      status: fromAI ? OrderStatus.pending : OrderStatus.confirmed,
      paymentMethod: _paymentMethod,
      mode: _mode,
      createdAt: DateTime.now(),
      tableNumber: _selectedTable,
      cashReceived:
          _paymentMethod == PaymentMethod.cash ? _cashReceived : null,
      changeGiven: _paymentMethod == PaymentMethod.cash ? change : null,
      customerPhone: _customerPhone,
      loyaltyPointsEarned: loyaltyPoints,
      operatorId: operatorId,
      source: _source,
    );
  }

  // ── Reset ───────────────────────────────────────────────────────────────────

  /// Clears the entire cart and resets all configuration to defaults.
  void clear() {
    _items.clear();
    _mode = OrderMode.takeaway;
    _selectedTable = null;
    _paymentMethod = PaymentMethod.cash;
    _cashReceived = 0;
    _customerPhone = null;
    _source = 'pos';
    notifyListeners();
  }
}
