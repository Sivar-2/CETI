import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gold_button.dart';
import '../../core/models/product_model.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/inventory_provider.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> with TickerProviderStateMixin {
  late AnimationController _pillCtrl;
  final _currency = NumberFormat.currency(locale: 'es_SV', symbol: '\$');

  static const _modes = ['🥡 Para Llevar', '🪑 Mesa', '🛵 Delivery'];

  static const _tableStatus = [
    0, 1, 0, 2, 0, 0, 1, 0, // 0=libre, 1=ocupada, 2=selected
    0, 0, 1, 0, 0, 1, 0, 0,
  ];

  @override
  void initState() {
    super.initState();
    _pillCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _pillCtrl.dispose();
    super.dispose();
  }

  void _showCheckout() {
    final cart = context.read<CartProvider>();
    if (cart.isEmpty) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CheckoutModal(currency: _currency),
    );
  }

  void _showCustomProductModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CustomProductModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    final cart = context.watch<CartProvider>();
    
    final currentModeIndex = cart.mode == OrderMode.takeaway ? 0 
                           : cart.mode == OrderMode.dineIn ? 1 : 2;

    return Container(
      color: AppColors.deepBlack,
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Text(
                    'Nuevo Pedido',
                    style: GoogleFonts.dmSans(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  if (cart.isNotEmpty)
                    GestureDetector(
                      onTap: _showCheckout,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: AppColors.goldGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.3),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.shopping_cart_rounded, color: AppColors.deepBlack, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '${cart.itemCount} · ${_currency.format(cart.subtotal)}',
                              style: GoogleFonts.dmSans(
                                color: AppColors.deepBlack,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Mode Toggle Pill ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: GlassCard(
              padding: const EdgeInsets.all(4),
              borderRadius: 16,
              child: Row(
                children: List.generate(_modes.length, (i) {
                  final active = currentModeIndex == i;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        final mode = i == 0 ? OrderMode.takeaway 
                                   : i == 1 ? OrderMode.dineIn 
                                   : OrderMode.delivery;
                        cart.setMode(mode);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: active ? AppColors.goldGradient : null,
                          boxShadow: active
                              ? [BoxShadow(color: AppColors.gold.withValues(alpha: 0.25), blurRadius: 10)]
                              : null,
                        ),
                        child: Text(
                          _modes[i],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            color: active ? AppColors.deepBlack : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ).animate().fadeIn(duration: 400.ms),

          // ── Dine-in Table Picker ──────────────────────────────────────────
          if (cart.mode == OrderMode.dineIn) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Selecciona una Mesa',
                        style: GoogleFonts.dmSans(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      _LegendDot(color: AppColors.tableFree, label: 'Libre'),
                      const SizedBox(width: 8),
                      _LegendDot(color: AppColors.tableOccupied, label: 'Ocupada'),
                      const SizedBox(width: 8),
                      _LegendDot(color: AppColors.tableSelected, label: 'Selec.'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: 16,
                    itemBuilder: (context, i) {
                      final status = i == cart.selectedTable ? 2 : _tableStatus[i];
                      final color = status == 0 ? AppColors.tableFree
                                  : status == 1 ? AppColors.tableOccupied
                                  : AppColors.tableSelected;
                      return GestureDetector(
                        onTap: status == 1 ? null : () {
                          HapticFeedback.selectionClick();
                          cart.setSelectedTable(cart.selectedTable == i ? null : i);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: color.withValues(alpha: 0.12),
                            border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.table_restaurant_rounded, color: color, size: 20),
                              Text(
                                '${i + 1}',
                                style: GoogleFonts.dmSans(
                                  color: color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),
          ],

          // ── Menu Grid ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Text(
                  'Menú',
                  style: GoogleFonts.dmSans(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _showCustomProductModal,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      border: Border.all(color: AppColors.borderWhite),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.add_circle_outline, color: AppColors.textSecondary, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Otro',
                          style: GoogleFonts.dmSans(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.35,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: inventory.catalog.length,
              itemBuilder: (context, i) {
                final product = inventory.catalog[i];
                final qtyInCart = cart.quantityOf(product.id);
                final canSell = inventory.canSell(product, quantity: qtyInCart + 1);
                final critical = inventory.hasCriticalStock(product);
                
                return _ProductCard(
                  product: product,
                  qty: qtyInCart,
                  canSell: canSell,
                  isCritical: critical,
                  onAdd: () {
                    if (canSell) {
                      HapticFeedback.selectionClick();
                      cart.addItem(product);
                    } else {
                      HapticFeedback.heavyImpact();
                      _showInsufficientStockAlert(context, product, inventory.insufficientIngredients(product, quantity: qtyInCart + 1));
                    }
                  },
                  currency: _currency,
                )
                    .animate(delay: (i * 20).ms)
                    .fadeIn(duration: 300.ms)
                    .scale(begin: const Offset(0.9, 0.9));
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showInsufficientStockAlert(BuildContext context, Product product, List<String> reasons) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.coral, size: 28),
            const SizedBox(width: 12),
            Text('Stock Insuficiente', style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('No hay suficientes insumos para preparar "${product.name}".', style: GoogleFonts.dmSans(color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 12),
            ...reasons.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $r', style: GoogleFonts.dmSans(color: AppColors.coral, fontSize: 13, fontWeight: FontWeight.w600)),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar', style: GoogleFonts.dmSans(color: AppColors.textTertiary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement POS Manager Authorization logic
            },
            child: Text('Autorizar', style: GoogleFonts.dmSans(color: AppColors.gold, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ─── Custom Product Modal ("Otro") ──────────────────────────────────────────

class _CustomProductModal extends StatefulWidget {
  const _CustomProductModal();

  @override
  State<_CustomProductModal> createState() => _CustomProductModalState();
}

class _CustomProductModalState extends State<_CustomProductModal> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  
  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: AppColors.borderWhite, width: 0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Agregar Producto Libre', style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              style: GoogleFonts.dmSans(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Descripción del producto',
                labelStyle: GoogleFonts.dmSans(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.cardDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                labelText: 'Precio',
                labelStyle: GoogleFonts.dmSans(color: AppColors.textSecondary, fontSize: 14),
                prefixText: '\$ ',
                prefixStyle: GoogleFonts.dmSans(color: AppColors.gold, fontSize: 20, fontWeight: FontWeight.w700),
                filled: true,
                fillColor: AppColors.cardDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            GoldButton(
              label: 'Agregar al Pedido',
              icon: Icons.add_shopping_cart,
              onPressed: () {
                final name = _nameCtrl.text.trim();
                final price = double.tryParse(_priceCtrl.text.replaceAll(',', '.')) ?? 0.0;
                
                if (name.isNotEmpty && price > 0) {
                  final customProduct = Product(
                    id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                    name: name,
                    emoji: '📝',
                    price: price,
                    category: 'Otro',
                    recipe: [], // No recipe for custom product
                    isComposite: false,
                  );
                  context.read<CartProvider>().addItem(customProduct, customNotes: 'Producto libre');
                  Navigator.pop(context);
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ─── Product Card ─────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.qty,
    required this.onAdd,
    required this.currency,
    required this.canSell,
    required this.isCritical,
  });
  final Product product;
  final int qty;
  final VoidCallback onAdd;
  final NumberFormat currency;
  final bool canSell;
  final bool isCritical;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: 18,
      borderColor: !canSell 
          ? AppColors.coral.withValues(alpha: 0.5) 
          : qty > 0
            ? AppColors.gold.withValues(alpha: 0.5)
            : AppColors.borderWhite,
      onTap: onAdd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.emoji, style: const TextStyle(fontSize: 26)),
              const Spacer(),
              if (qty > 0)
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    gradient: AppColors.goldGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$qty',
                      style: GoogleFonts.dmSans(
                        color: AppColors.deepBlack,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                )
              else if (!canSell)
                const Icon(Icons.block, color: AppColors.coral, size: 16)
              else if (isCritical)
                const Icon(Icons.warning_rounded, color: AppColors.coral, size: 16)
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  color: canSell ? AppColors.textPrimary : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  decoration: canSell ? null : TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                currency.format(product.price),
                style: GoogleFonts.dmSans(
                  color: canSell ? AppColors.gold : AppColors.textTertiary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Checkout Modal ───────────────────────────────────────────────────────────

class _CheckoutModal extends StatefulWidget {
  const _CheckoutModal({required this.currency});
  final NumberFormat currency;

  @override
  State<_CheckoutModal> createState() => _CheckoutModalState();
}

class _CheckoutModalState extends State<_CheckoutModal> with TickerProviderStateMixin {
  late TabController _tabCtrl;
  final _cashCtrl = TextEditingController();
  double _splitPct = 50;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        final pm = _tabCtrl.index == 0 ? PaymentMethod.cash 
                 : _tabCtrl.index == 1 ? PaymentMethod.transfer 
                 : PaymentMethod.split;
        context.read<CartProvider>().setPaymentMethod(pm);
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _cashCtrl.dispose();
    super.dispose();
  }

  void _confirmPayment(BuildContext context, CartProvider cart, double total) {
    if (cart.paymentMethod == PaymentMethod.cash) {
      final cashGiven = double.tryParse(_cashCtrl.text.replaceAll(',', '.')) ?? 0;
      if (cashGiven < total) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Monto insuficiente', style: GoogleFonts.dmSans()), backgroundColor: AppColors.coral),
        );
        return;
      }
      cart.setCashReceived(cashGiven);
    }

    // Trigger inventory deduction (Poka-yoke)
    context.read<InventoryProvider>().deductForOrder(cart.items);
    
    // Create the order via CartProvider (in a real app, send to OrderService)
    // final order = cart.buildOrder(orderId: 'ORD-${DateTime.now().millisecondsSinceEpoch}');
    // OrderService().submitOrder(...)

    cart.clear(); // Clear cart after successful transaction
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Pago confirmado · ${widget.currency.format(total)}', style: GoogleFonts.dmSans(color: AppColors.textPrimary)),
        backgroundColor: AppColors.cardDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final subtotal = cart.subtotal;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: AppColors.borderWhite, width: 0.5)),
        ),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          children: [
            Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.borderWhite, borderRadius: BorderRadius.circular(4)))),
            const SizedBox(height: 20),

            Text('Cobrar Pedido', style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Total: ${widget.currency.format(subtotal)}', style: GoogleFonts.dmSans(color: AppColors.gold, fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),

            // Order summary (editable quantities)
            ...List.generate(cart.items.length, (i) {
              final item = cart.items[i];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 16, color: AppColors.textSecondary),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            onPressed: () => cart.decrementItem(i),
                          ),
                          Text('${item.quantity}', style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add, size: 16, color: AppColors.textSecondary),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            onPressed: () => cart.incrementItem(i),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.productName, style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 14)),
                          if (item.customNotes != null && item.customNotes!.isNotEmpty)
                            Text(item.customNotes!, style: GoogleFonts.dmSans(color: AppColors.textTertiary, fontSize: 11)),
                        ],
                      ),
                    ),
                    Text(widget.currency.format(item.lineTotal), style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),
            const Divider(color: AppColors.borderWhite, thickness: 0.5),
            const SizedBox(height: 16),

            // Payment method tabs
            GlassCard(
              padding: const EdgeInsets.all(4),
              borderRadius: 14,
              child: TabBar(
                controller: _tabCtrl,
                tabs: const [
                  Tab(text: '💵 Efectivo'),
                  Tab(text: '📲 Transfer'),
                  Tab(text: '✂️ Dividir'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Efectivo Tab ─────────────────────────────────────────────
            if (cart.paymentMethod == PaymentMethod.cash) ...[
              Text('Monto recibido', style: GoogleFonts.dmSans(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: _cashCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
                decoration: const InputDecoration(hintText: '0.00', prefixText: '\$  '),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              Builder(
                builder: (context) {
                  final cashGiven = double.tryParse(_cashCtrl.text.replaceAll(',', '.')) ?? 0;
                  final change = (cashGiven - subtotal).clamp(0.0, double.infinity);
                  final isSufficient = cashGiven >= subtotal;
                  
                  return GlassCard(
                    padding: const EdgeInsets.all(20),
                    borderRadius: 18,
                    gradient: LinearGradient(
                      colors: isSufficient 
                          ? [AppColors.success.withValues(alpha: 0.15), AppColors.success.withValues(alpha: 0.05)]
                          : [AppColors.coral.withValues(alpha: 0.15), AppColors.coral.withValues(alpha: 0.05)],
                    ),
                    borderColor: isSufficient ? AppColors.success.withValues(alpha: 0.3) : AppColors.coral.withValues(alpha: 0.3),
                    child: Row(
                      children: [
                        Icon(isSufficient ? Icons.change_circle_rounded : Icons.warning_rounded, 
                             color: isSufficient ? AppColors.success : AppColors.coral, size: 28),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(isSufficient ? 'Cambio a entregar' : 'Faltante', style: GoogleFonts.dmSans(color: AppColors.textSecondary, fontSize: 12)),
                            Text(
                              isSufficient ? widget.currency.format(change) : widget.currency.format(subtotal - cashGiven),
                              style: GoogleFonts.dmSans(color: isSufficient ? AppColors.success : AppColors.coral, fontSize: 26, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
              ),
            ],

            // ── Transferencia Tab ────────────────────────────────────────
            if (cart.paymentMethod == PaymentMethod.transfer) ...[
              Center(
                child: Column(
                  children: [
                    Text('Escanea para transferir', style: GoogleFonts.dmSans(color: AppColors.textSecondary, fontSize: 14)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.2), blurRadius: 20)],
                      ),
                      child: QrImageView(
                        data: 'pagos://ceti?monto=${subtotal.toStringAsFixed(2)}&ref=CETI${DateTime.now().millisecondsSinceEpoch}',
                        version: QrVersions.auto,
                        size: 200,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(widget.currency.format(subtotal), style: GoogleFonts.dmSans(color: AppColors.gold, fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('Banco: CETI Pagos · Cuenta: 1234-5678-9012', style: GoogleFonts.dmSans(color: AppColors.textTertiary, fontSize: 11), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ],

            // ── Dividir Tab ────────────────────────────────────────────────
            if (cart.paymentMethod == PaymentMethod.split) ...[
              Text('Dividir la cuenta', style: GoogleFonts.dmSans(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 16),
              GlassCard(
                padding: const EdgeInsets.all(20),
                borderRadius: 18,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SplitAmount(label: 'Persona A', amount: subtotal * (_splitPct / 100), currency: widget.currency, color: AppColors.gold),
                        _SplitAmount(label: 'Persona B', amount: subtotal * (1 - _splitPct / 100), currency: widget.currency, color: AppColors.blue),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.gold,
                        inactiveTrackColor: AppColors.blue,
                        thumbColor: AppColors.white,
                        trackHeight: 6,
                      ),
                      child: Slider(
                        value: _splitPct,
                        min: 10,
                        max: 90,
                        divisions: 16,
                        onChanged: (v) => setState(() => _splitPct = v),
                      ),
                    ),
                    Text('${_splitPct.toStringAsFixed(0)}% / ${(100 - _splitPct).toStringAsFixed(0)}%', style: GoogleFonts.dmSans(color: AppColors.textTertiary, fontSize: 12)),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            GoldButton(
              label: 'Confirmar Pago',
              icon: Icons.check_circle_rounded,
              onPressed: () => _confirmPayment(context, cart, subtotal),
              color: const Color(0xFFE53935), // Turco Red implementation required by spec
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Split Amount Widget ──────────────────────────────────────────────────────

class _SplitAmount extends StatelessWidget {
  const _SplitAmount({required this.label, required this.amount, required this.currency, required this.color});
  final String label;
  final double amount;
  final NumberFormat currency;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.dmSans(color: AppColors.textSecondary, fontSize: 12)),
        Text(currency.format(amount), style: GoogleFonts.dmSans(color: color, fontSize: 22, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

// ─── Legend Dot ───────────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.dmSans(color: AppColors.textTertiary, fontSize: 10)),
      ],
    );
  }
}
