import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/product_model.dart';

class InventoryProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  StreamSubscription? _suppliesSub;
  StreamSubscription? _catalogSub;

  List<Product> _catalog = [];
  Map<String, Supply> _supplies = {};

  List<Product> get catalog => List.unmodifiable(_catalog);
  Map<String, Supply> get supplies => Map.unmodifiable(_supplies);

  List<Supply> get criticalSupplies =>
      _supplies.values.where((s) => s.isCritical).toList();

  Future<void> init() async {
    // Listen to Supplies
    _suppliesSub = _db.collection('supplies').snapshots().listen((snapshot) {
      final newSupplies = <String, Supply>{};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        newSupplies[doc.id] = Supply.fromMap(data);
      }
      _supplies = newSupplies;
      notifyListeners();

      // Seed if empty
      if (_supplies.isEmpty && snapshot.metadata.isFromCache == false) {
        _uploadMockSupplies();
      }
    });

    // Listen to Catalog
    _catalogSub = _db.collection('catalog').snapshots().listen((snapshot) {
      _catalog = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Product.fromMap(data);
      }).toList();
      notifyListeners();

      // Seed if empty
      if (_catalog.isEmpty && snapshot.metadata.isFromCache == false) {
        _uploadMockCatalog();
      }
    });
  }

  bool hasSufficientStock(Product product, int quantity) {
    for (final comp in product.recipe) {
      final supply = _supplies[comp.supplyId];
      if (supply == null) return false;
      if (supply.stockActual < comp.quantityRequired * quantity) return false;
    }
    return true;
  }

  List<String> insufficientIngredients(Product product, {int quantity = 1}) {
    final result = <String>[];
    for (final comp in product.recipe) {
      final supply = _supplies[comp.supplyId];
      if (supply == null) {
        result.add(comp.supplyName);
        continue;
      }
      final required = comp.quantityRequired * quantity;
      if (supply.stockActual < required) {
        result.add('${comp.supplyName} (hay ${supply.stockActual.toStringAsFixed(1)}, necesita ${required.toStringAsFixed(1)})');
      }
    }
    return result;
  }

  bool hasCriticalStock(Product product) {
    for (final comp in product.recipe) {
      final supply = _supplies[comp.supplyId];
      if (supply == null || supply.isCritical) return true;
    }
    return false;
  }

  void deductForOrder(Order order) {
    final batch = _db.batch();

    for (final item in order.items) {
      final product = _catalog.where((p) => p.id == item.productId).firstOrNull;
      if (product == null) continue;

      for (final comp in product.recipe) {
        final supply = _supplies[comp.supplyId];
        if (supply == null) continue;

        final deduction = comp.quantityRequired * item.quantity;
        final newStock = (supply.stockActual - deduction).clamp(0.0, double.infinity);

        final docRef = _db.collection('supplies').doc(comp.supplyId);
        batch.update(docRef, {'stockActual': newStock});
      }
    }

    batch.commit().catchError((e) {
      if (kDebugMode) print('Error in deductForOrder batch: $e');
    });
  }

  void _uploadMockSupplies() {
    final initial = {
      'sup_cafe': const Supply(id: 'sup_cafe', name: 'Cafe Molido', unit: 'lb', costPerUnit: 3.50, stockActual: 12, stockMinimo: 3),
      'sup_agua': const Supply(id: 'sup_agua', name: 'Agua Filtrada', unit: 'lt', costPerUnit: 0.10, stockActual: 200, stockMinimo: 20),
      'sup_leche': const Supply(id: 'sup_leche', name: 'Leche Entera', unit: 'lt', costPerUnit: 1.20, stockActual: 15, stockMinimo: 3),
      'sup_mango': const Supply(id: 'sup_mango', name: 'Jugo de Mango', unit: '250ml', costPerUnit: 1.80, stockActual: 8, stockMinimo: 3),
      'sup_pan': const Supply(id: 'sup_pan', name: 'Pan de Molde', unit: 'rebanadas', costPerUnit: 0.15, stockActual: 40, stockMinimo: 10),
      'sup_pollo': const Supply(id: 'sup_pollo', name: 'Pechuga de Pollo', unit: 'onz', costPerUnit: 0.60, stockActual: 30, stockMinimo: 8),
      'sup_queso_am': const Supply(id: 'sup_queso_am', name: 'Queso Americano', unit: 'rebanada', costPerUnit: 0.25, stockActual: 25, stockMinimo: 5),
    };

    final batch = _db.batch();
    initial.forEach((key, value) {
      batch.set(_db.collection('supplies').doc(key), value.toMap());
    });
    batch.commit();
  }

  void _uploadMockCatalog() {
    final initial = [
      Product(
        id: 'prod_espresso',
        name: 'Espresso Doble',
        emoji: '☕',
        price: 3.50,
        category: 'Bebidas Calientes',
        recipe: [
          const RecipeComponent(supplyId: 'sup_cafe', supplyName: 'Cafe Molido', quantityRequired: 0.05, unit: 'lb', unitCost: 3.50),
          const RecipeComponent(supplyId: 'sup_agua', supplyName: 'Agua Filtrada', quantityRequired: 0.10, unit: 'lt', unitCost: 0.10),
        ],
      ),
      Product(
        id: 'prod_mocktail',
        name: 'Mocktail Mango',
        emoji: '🥭',
        price: 6.00,
        category: 'Bebidas Frias',
        recipe: [
          const RecipeComponent(supplyId: 'sup_mango', supplyName: 'Jugo de Mango', quantityRequired: 1, unit: '250ml', unitCost: 1.80),
        ],
      ),
      Product(
        id: 'prod_sandwich',
        name: 'Club Sandwich',
        emoji: '🥪',
        price: 8.50,
        category: 'Comida',
        recipe: [
          const RecipeComponent(supplyId: 'sup_pan', supplyName: 'Pan de Molde', quantityRequired: 3, unit: 'rebanadas', unitCost: 0.15),
          const RecipeComponent(supplyId: 'sup_pollo', supplyName: 'Pechuga de Pollo', quantityRequired: 2, unit: 'onz', unitCost: 0.60),
          const RecipeComponent(supplyId: 'sup_queso_am', supplyName: 'Queso Americano', quantityRequired: 2, unit: 'rebanada', unitCost: 0.25),
        ],
      ),
    ];

    final batch = _db.batch();
    for (var p in initial) {
      batch.set(_db.collection('catalog').doc(p.id), p.toMap());
    }
    batch.commit();
  }

  @override
  void dispose() {
    _suppliesSub?.cancel();
    _catalogSub?.cancel();
    super.dispose();
  }
}
