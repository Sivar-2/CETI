import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

/// ──────────────────────────────────────────────────────────────────────────────
/// InventoryProvider — Central Inventory State for Escandallo Engine
///
/// Holds the catalog (Products) and supplies (Insumos), providing:
/// - Stock validation per product
/// - Critical stock alerts
/// - Deduction preview before order confirmation
/// ──────────────────────────────────────────────────────────────────────────────

class InventoryProvider extends ChangeNotifier {
  // ── State ───────────────────────────────────────────────────────────────────

  List<Product> _catalog = [];
  Map<String, Supply> _supplies = {};

  // ── Getters ─────────────────────────────────────────────────────────────────

  List<Product> get catalog => List.unmodifiable(_catalog);
  Map<String, Supply> get supplies => Map.unmodifiable(_supplies);

  List<Supply> get criticalSupplies =>
      _supplies.values.where((s) => s.isCritical).toList();

  // ── Initialization (Mock Data for Turco's House) ────────────────────────────

  void loadMockData() {
    // ── Supplies (Insumos) ────────────────────────────────────────────────────
    _supplies = {
      'sup_cafe': const Supply(
        id: 'sup_cafe',
        name: 'Cafe Molido',
        unit: 'lb',
        costPerUnit: 3.50,
        stockActual: 12,
        stockMinimo: 3,
      ),
      'sup_agua': const Supply(
        id: 'sup_agua',
        name: 'Agua Filtrada',
        unit: 'lt',
        costPerUnit: 0.10,
        stockActual: 200,
        stockMinimo: 20,
      ),
      'sup_leche': const Supply(
        id: 'sup_leche',
        name: 'Leche Entera',
        unit: 'lt',
        costPerUnit: 1.20,
        stockActual: 15,
        stockMinimo: 3,
      ),
      'sup_mango': const Supply(
        id: 'sup_mango',
        name: 'Jugo de Mango',
        unit: '250ml',
        costPerUnit: 1.80,
        stockActual: 8,
        stockMinimo: 3,
      ),
      'sup_ginger': const Supply(
        id: 'sup_ginger',
        name: 'Mixer Ginger',
        unit: 'botella',
        costPerUnit: 2.50,
        stockActual: 6,
        stockMinimo: 2,
      ),
      'sup_hielo': const Supply(
        id: 'sup_hielo',
        name: 'Hielo',
        unit: 'bolsa',
        costPerUnit: 0.80,
        stockActual: 20,
        stockMinimo: 5,
      ),
      'sup_pan': const Supply(
        id: 'sup_pan',
        name: 'Pan de Molde',
        unit: 'rebanadas',
        costPerUnit: 0.15,
        stockActual: 40,
        stockMinimo: 10,
      ),
      'sup_pollo': const Supply(
        id: 'sup_pollo',
        name: 'Pechuga de Pollo',
        unit: 'onz',
        costPerUnit: 0.60,
        stockActual: 30,
        stockMinimo: 8,
      ),
      'sup_queso_am': const Supply(
        id: 'sup_queso_am',
        name: 'Queso Americano',
        unit: 'rebanada',
        costPerUnit: 0.25,
        stockActual: 25,
        stockMinimo: 5,
      ),
      'sup_tomate': const Supply(
        id: 'sup_tomate',
        name: 'Tomate',
        unit: 'und',
        costPerUnit: 0.30,
        stockActual: 20,
        stockMinimo: 5,
      ),
      'sup_lechuga': const Supply(
        id: 'sup_lechuga',
        name: 'Lechuga',
        unit: 'und',
        costPerUnit: 0.20,
        stockActual: 15,
        stockMinimo: 4,
      ),
      'sup_mayo': const Supply(
        id: 'sup_mayo',
        name: 'Mayonesa',
        unit: 'porcion',
        costPerUnit: 0.10,
        stockActual: 50,
        stockMinimo: 10,
      ),
      'sup_papas': const Supply(
        id: 'sup_papas',
        name: 'Papas Fritas',
        unit: 'porcion',
        costPerUnit: 0.55,
        stockActual: 18,
        stockMinimo: 5,
      ),
      'sup_granola': const Supply(
        id: 'sup_granola',
        name: 'Granola',
        unit: 'gr',
        costPerUnit: 0.08,
        stockActual: 2,
        stockMinimo: 5,
      ),
      'sup_yogurt': const Supply(
        id: 'sup_yogurt',
        name: 'Yogurt Griego',
        unit: 'gr',
        costPerUnit: 0.05,
        stockActual: 1500,
        stockMinimo: 300,
      ),
      'sup_fruta': const Supply(
        id: 'sup_fruta',
        name: 'Fruta Mixta',
        unit: 'porcion',
        costPerUnit: 1.00,
        stockActual: 10,
        stockMinimo: 3,
      ),
      'sup_galleta': const Supply(
        id: 'sup_galleta',
        name: 'Base Galleta',
        unit: 'porcion',
        costPerUnit: 0.40,
        stockActual: 12,
        stockMinimo: 4,
      ),
      'sup_queso_cr': const Supply(
        id: 'sup_queso_cr',
        name: 'Queso Crema',
        unit: 'onz',
        costPerUnit: 0.35,
        stockActual: 20,
        stockMinimo: 5,
      ),
      'sup_mermelada': const Supply(
        id: 'sup_mermelada',
        name: 'Mermelada',
        unit: 'cda',
        costPerUnit: 0.25,
        stockActual: 15,
        stockMinimo: 3,
      ),
      'sup_agua_bot': const Supply(
        id: 'sup_agua_bot',
        name: 'Botella Agua',
        unit: 'und',
        costPerUnit: 0.40,
        stockActual: 50,
        stockMinimo: 10,
      ),
      'sup_naranja': const Supply(
        id: 'sup_naranja',
        name: 'Naranjas',
        unit: 'und',
        costPerUnit: 0.30,
        stockActual: 30,
        stockMinimo: 8,
      ),
    };

    // ── Products (Productos de Venta) ────────────────────────────────────────
    _catalog = [
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
        id: 'prod_cappuccino',
        name: 'Cappuccino',
        emoji: '🍵',
        price: 4.50,
        category: 'Bebidas Calientes',
        recipe: [
          const RecipeComponent(supplyId: 'sup_cafe', supplyName: 'Cafe Molido', quantityRequired: 0.04, unit: 'lb', unitCost: 3.50),
          const RecipeComponent(supplyId: 'sup_leche', supplyName: 'Leche Entera', quantityRequired: 0.20, unit: 'lt', unitCost: 1.20),
          const RecipeComponent(supplyId: 'sup_agua', supplyName: 'Agua Filtrada', quantityRequired: 0.06, unit: 'lt', unitCost: 0.10),
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
          const RecipeComponent(supplyId: 'sup_ginger', supplyName: 'Mixer Ginger', quantityRequired: 0.25, unit: 'botella', unitCost: 2.50),
          const RecipeComponent(supplyId: 'sup_hielo', supplyName: 'Hielo', quantityRequired: 0.5, unit: 'bolsa', unitCost: 0.80),
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
          const RecipeComponent(supplyId: 'sup_tomate', supplyName: 'Tomate', quantityRequired: 1, unit: 'und', unitCost: 0.30),
          const RecipeComponent(supplyId: 'sup_lechuga', supplyName: 'Lechuga', quantityRequired: 1, unit: 'und', unitCost: 0.20),
          const RecipeComponent(supplyId: 'sup_mayo', supplyName: 'Mayonesa', quantityRequired: 1, unit: 'porcion', unitCost: 0.10),
          const RecipeComponent(supplyId: 'sup_papas', supplyName: 'Papas Fritas', quantityRequired: 1, unit: 'porcion', unitCost: 0.55),
        ],
      ),
      Product(
        id: 'prod_granola',
        name: 'Granola Bowl',
        emoji: '🥣',
        price: 7.00,
        category: 'Comida',
        recipe: [
          const RecipeComponent(supplyId: 'sup_granola', supplyName: 'Granola', quantityRequired: 80, unit: 'gr', unitCost: 0.08),
          const RecipeComponent(supplyId: 'sup_yogurt', supplyName: 'Yogurt Griego', quantityRequired: 150, unit: 'gr', unitCost: 0.05),
          const RecipeComponent(supplyId: 'sup_fruta', supplyName: 'Fruta Mixta', quantityRequired: 1, unit: 'porcion', unitCost: 1.00),
        ],
      ),
      Product(
        id: 'prod_cheesecake',
        name: 'Cheesecake',
        emoji: '🍰',
        price: 5.50,
        category: 'Postres',
        recipe: [
          const RecipeComponent(supplyId: 'sup_galleta', supplyName: 'Base Galleta', quantityRequired: 1, unit: 'porcion', unitCost: 0.40),
          const RecipeComponent(supplyId: 'sup_queso_cr', supplyName: 'Queso Crema', quantityRequired: 3, unit: 'onz', unitCost: 0.35),
          const RecipeComponent(supplyId: 'sup_mermelada', supplyName: 'Mermelada', quantityRequired: 1, unit: 'cda', unitCost: 0.25),
        ],
      ),
      Product(
        id: 'prod_agua',
        name: 'Agua Natural',
        emoji: '💧',
        price: 1.50,
        category: 'Bebidas Frias',
        isComposite: false,
        recipe: [
          const RecipeComponent(supplyId: 'sup_agua_bot', supplyName: 'Botella Agua', quantityRequired: 1, unit: 'und', unitCost: 0.40),
        ],
      ),
      Product(
        id: 'prod_jugo',
        name: 'Jugo Natural',
        emoji: '🍊',
        price: 4.00,
        category: 'Bebidas Frias',
        recipe: [
          const RecipeComponent(supplyId: 'sup_naranja', supplyName: 'Naranjas', quantityRequired: 4, unit: 'und', unitCost: 0.30),
        ],
      ),
    ];

    notifyListeners();
  }

  // ── Stock Validation ────────────────────────────────────────────────────────

  /// Check if a product can be sold (all ingredients available).
  bool canSell(Product product, {int quantity = 1}) {
    if (!product.isComposite) {
      // Simple product: check direct supply
      for (final comp in product.recipe) {
        final supply = _supplies[comp.supplyId];
        if (supply == null) return false;
        if (supply.stockActual < comp.quantityRequired * quantity) return false;
      }
      return true;
    }

    // Composite product: check all recipe components
    for (final comp in product.recipe) {
      final supply = _supplies[comp.supplyId];
      if (supply == null) return false;
      if (supply.stockActual < comp.quantityRequired * quantity) return false;
    }
    return true;
  }

  /// Returns ingredient names that are insufficient for a product.
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

  /// Check if any ingredient is at critical level.
  bool hasCriticalStock(Product product) {
    for (final comp in product.recipe) {
      final supply = _supplies[comp.supplyId];
      if (supply == null || supply.isCritical) return true;
    }
    return false;
  }

  // ── Deduction (called after order confirmation) ────────────────────────────

  /// Deducts supplies based on the sold order items.
  void deductForOrder(List<OrderItem> items) {
    for (final item in items) {
      final product = _catalog.where((p) => p.id == item.productId).firstOrNull;
      if (product == null) continue;

      for (final comp in product.recipe) {
        final supply = _supplies[comp.supplyId];
        if (supply == null) continue;

        final deduction = comp.quantityRequired * item.quantity;
        final newStock = (supply.stockActual - deduction).clamp(0.0, double.infinity);

        _supplies[comp.supplyId] = supply.copyWith(stockActual: newStock);
      }
    }
    notifyListeners();
  }
}
