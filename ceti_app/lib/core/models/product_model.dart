// ──────────────────────────────────────────────────────────────────────────────
// CETI — Data Models for Turco's House POS
//
// Design principle: every model serializes to a flat `Map<String, dynamic>`
// suitable for Firestore documents, facilitating analytics pipelines and
// avoiding nested sub-collections for transactional data.
// ──────────────────────────────────────────────────────────────────────────────

// ─── Supply / Insumo ─────────────────────────────────────────────────────────

/// Represents a raw material tracked in inventory.
/// This is the source-of-truth for stock deduction (escandallo trigger).
class Supply {
  const Supply({
    required this.id,
    required this.name,
    required this.unit,
    required this.costPerUnit,
    required this.stockActual,
    this.stockMinimo = 5,
  });

  final String id;
  final String name;
  final String unit;
  final double costPerUnit;
  final double stockActual;
  final double stockMinimo;

  bool get isCritical => stockActual <= stockMinimo;
  bool get canFulfill => stockActual > 0;

  Supply copyWith({
    String? id,
    String? name,
    String? unit,
    double? costPerUnit,
    double? stockActual,
    double? stockMinimo,
  }) {
    return Supply(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      costPerUnit: costPerUnit ?? this.costPerUnit,
      stockActual: stockActual ?? this.stockActual,
      stockMinimo: stockMinimo ?? this.stockMinimo,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'unit': unit,
        'costPerUnit': costPerUnit,
        'stockActual': stockActual,
        'stockMinimo': stockMinimo,
      };

  factory Supply.fromMap(Map<String, dynamic> m) => Supply(
        id: m['id'] as String,
        name: m['name'] as String,
        unit: m['unit'] as String,
        costPerUnit: (m['costPerUnit'] as num).toDouble(),
        stockActual: (m['stockActual'] as num).toDouble(),
        stockMinimo: (m['stockMinimo'] as num?)?.toDouble() ?? 5,
      );
}

// ─── Recipe Component (Escandallo Line) ──────────────────────────────────────

/// A single line in a product's recipe: which supply and how much is needed.
class RecipeComponent {
  const RecipeComponent({
    required this.supplyId,
    required this.supplyName,
    required this.quantityRequired,
    required this.unit,
    required this.unitCost,
  });

  final String supplyId;
  final String supplyName;
  final double quantityRequired;
  final String unit;
  final double unitCost;

  double get lineCost => quantityRequired * unitCost;

  Map<String, dynamic> toMap() => {
        'supplyId': supplyId,
        'supplyName': supplyName,
        'quantityRequired': quantityRequired,
        'unit': unit,
        'unitCost': unitCost,
      };

  factory RecipeComponent.fromMap(Map<String, dynamic> m) => RecipeComponent(
        supplyId: m['supplyId'] as String,
        supplyName: m['supplyName'] as String,
        quantityRequired: (m['quantityRequired'] as num).toDouble(),
        unit: m['unit'] as String,
        unitCost: (m['unitCost'] as num).toDouble(),
      );
}

// ─── Product (Producto de Venta) ─────────────────────────────────────────────

/// A sellable item on the POS menu. Contains its recipe for escandallo.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.emoji,
    required this.price,
    required this.category,
    required this.recipe,
    this.isAvailable = true,
    this.isComposite = true,
  });

  final String id;
  final String name;
  final String emoji;
  final double price;
  final String category;
  final List<RecipeComponent> recipe;
  final bool isAvailable;
  final bool isComposite;

  double get totalCost => recipe.fold(0, (s, r) => s + r.lineCost);
  double get margin => price > 0 ? ((price - totalCost) / price) * 100 : 0;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'price': price,
        'category': category,
        'recipe': recipe.map((r) => r.toMap()).toList(),
        'isAvailable': isAvailable,
        'isComposite': isComposite,
        'totalCost': totalCost,
        'margin': margin,
      };

  factory Product.fromMap(Map<String, dynamic> m) => Product(
        id: m['id'] as String,
        name: m['name'] as String,
        emoji: m['emoji'] as String,
        price: (m['price'] as num).toDouble(),
        category: m['category'] as String,
        recipe: (m['recipe'] as List)
            .map((r) => RecipeComponent.fromMap(r as Map<String, dynamic>))
            .toList(),
        isAvailable: m['isAvailable'] as bool? ?? true,
        isComposite: m['isComposite'] as bool? ?? true,
      );
}

// ─── Order Item ──────────────────────────────────────────────────────────────

/// A single line in a customer order.
class OrderItem {
  const OrderItem({
    required this.productId,
    required this.productName,
    required this.emoji,
    required this.unitPrice,
    required this.quantity,
    this.customNotes,
    this.extras = const [],
  });

  final String productId;
  final String productName;
  final String emoji;
  final double unitPrice;
  final int quantity;
  final String? customNotes;
  final List<String> extras;

  double get lineTotal => unitPrice * quantity;

  OrderItem copyWith({
    int? quantity,
    String? customNotes,
    List<String>? extras,
  }) {
    return OrderItem(
      productId: productId,
      productName: productName,
      emoji: emoji,
      unitPrice: unitPrice,
      quantity: quantity ?? this.quantity,
      customNotes: customNotes ?? this.customNotes,
      extras: extras ?? this.extras,
    );
  }

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'productName': productName,
        'emoji': emoji,
        'unitPrice': unitPrice,
        'quantity': quantity,
        'lineTotal': lineTotal,
        'customNotes': customNotes ?? '',
        'extras': extras,
      };

  factory OrderItem.fromMap(Map<String, dynamic> m) => OrderItem(
        productId: m['productId'] as String,
        productName: m['productName'] as String,
        emoji: m['emoji'] as String,
        unitPrice: (m['unitPrice'] as num).toDouble(),
        quantity: m['quantity'] as int,
        customNotes: m['customNotes'] as String?,
        extras: List<String>.from(m['extras'] ?? []),
      );
}

// ─── Order Status ────────────────────────────────────────────────────────────

enum OrderStatus {
  pending,    // Created by AI or user, awaiting human validation
  confirmed,  // Payment validated by human operator
  completed,  // Order delivered / closed
  cancelled,
}

// ─── Payment Method ──────────────────────────────────────────────────────────

enum PaymentMethod {
  cash,
  transfer,
  split,
}

// ─── Order Mode ──────────────────────────────────────────────────────────────

enum OrderMode {
  takeaway,
  dineIn,
  delivery,
}

// ─── Order ────────────────────────────────────────────────────────────────────

/// Complete order document as persisted in Firestore.
class Order {
  const Order({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.status,
    required this.paymentMethod,
    required this.mode,
    required this.createdAt,
    this.tableNumber,
    this.cashReceived,
    this.changeGiven,
    this.customerPhone,
    this.loyaltyPointsEarned = 0,
    this.operatorId,
    this.source = 'pos',
    this.closedAt,
  });

  final String id;
  final List<OrderItem> items;
  final double subtotal;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final OrderMode mode;
  final DateTime createdAt;
  final int? tableNumber;
  final double? cashReceived;
  final double? changeGiven;
  final String? customerPhone;
  final int loyaltyPointsEarned;
  final String? operatorId;
  final String source; // 'pos', 'whatsapp', 'instagram', 'ai'
  final DateTime? closedAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'items': items.map((i) => i.toMap()).toList(),
        'subtotal': subtotal,
        'status': status.name,
        'paymentMethod': paymentMethod.name,
        'mode': mode.name,
        'createdAt': createdAt.toIso8601String(),
        'tableNumber': tableNumber,
        'cashReceived': cashReceived,
        'changeGiven': changeGiven,
        'customerPhone': customerPhone,
        'loyaltyPointsEarned': loyaltyPointsEarned,
        'operatorId': operatorId,
        'source': source,
        'closedAt': closedAt?.toIso8601String(),
      };

  factory Order.fromMap(Map<String, dynamic> m) => Order(
        id: m['id'] as String,
        items: (m['items'] as List)
            .map((i) => OrderItem.fromMap(i as Map<String, dynamic>))
            .toList(),
        subtotal: (m['subtotal'] as num).toDouble(),
        status: OrderStatus.values.byName(m['status'] as String),
        paymentMethod:
            PaymentMethod.values.byName(m['paymentMethod'] as String),
        mode: OrderMode.values.byName(m['mode'] as String),
        createdAt: DateTime.parse(m['createdAt'] as String),
        tableNumber: m['tableNumber'] as int?,
        cashReceived: (m['cashReceived'] as num?)?.toDouble(),
        changeGiven: (m['changeGiven'] as num?)?.toDouble(),
        customerPhone: m['customerPhone'] as String?,
        loyaltyPointsEarned: m['loyaltyPointsEarned'] as int? ?? 0,
        operatorId: m['operatorId'] as String?,
        source: m['source'] as String? ?? 'pos',
        closedAt: m['closedAt'] != null
            ? DateTime.parse(m['closedAt'] as String)
            : null,
      );
}

// ─── Cash Register Close ─────────────────────────────────────────────────────

/// Blind cash register close: operator counts physical cash first,
/// then the system reveals the expected balance.
class CashRegisterClose {
  const CashRegisterClose({
    required this.id,
    required this.date,
    required this.operatorId,
    required this.physicalCount,
    required this.expectedBalance,
    required this.discrepancy,
    this.adjustmentNote,
  });

  final String id;
  final DateTime date;
  final String operatorId;
  final double physicalCount;
  final double expectedBalance;
  final double discrepancy;
  final String? adjustmentNote;

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'operatorId': operatorId,
        'physicalCount': physicalCount,
        'expectedBalance': expectedBalance,
        'discrepancy': discrepancy,
        'adjustmentNote': adjustmentNote ?? '',
      };
}

// ─── Loyalty Transaction ─────────────────────────────────────────────────────

/// Points ledger entry, linked by phone number.
class LoyaltyTransaction {
  const LoyaltyTransaction({
    required this.id,
    required this.phone,
    required this.orderId,
    required this.pointsEarned,
    required this.totalPoints,
    required this.createdAt,
  });

  final String id;
  final String phone;
  final String orderId;
  final int pointsEarned;
  final int totalPoints;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'phone': phone,
        'orderId': orderId,
        'pointsEarned': pointsEarned,
        'totalPoints': totalPoints,
        'createdAt': createdAt.toIso8601String(),
      };
}
