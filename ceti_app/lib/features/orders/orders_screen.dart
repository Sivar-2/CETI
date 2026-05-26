import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/providers/orders_provider.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/inventory_provider.dart';
import '../../core/providers/dashboard_provider.dart';
import '../../core/providers/loyalty_provider.dart';
import '../../core/models/product_model.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int _selectedIndex = 0; // 0: Pendientes, 1: Próximas, 2: Nueva Órden
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, Color(0xFF1E1B24)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Custom Segmented Control
              _buildSegmentedControl(),
              const SizedBox(height: 16),
              
              // Pages
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (idx) => setState(() => _selectedIndex = idx),
                  children: const [
                    _PendingOrdersView(),
                    _UpcomingOrdersView(),
                    _NewOrderPosView(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Stack(
        children: [
          // Animated Selection Pill
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            left: _selectedIndex * ((MediaQuery.of(context).size.width - 32) / 3),
            top: 4,
            bottom: 4,
            width: (MediaQuery.of(context).size.width - 32) / 3,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          // Tab Items
          Row(
            children: [
              _buildTabItem(0, 'Pendientes'),
              _buildTabItem(1, 'Próximas'),
              _buildTabItem(2, 'Nueva Órden'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String title) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabChanged(index),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: GoogleFonts.inter(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
            child: Text(title),
          ),
        ),
      ),
    );
  }
}

// ─── Pending Orders View (Kanban) ──────────────────────────────────────────

class _PendingOrdersView extends StatelessWidget {
  const _PendingOrdersView();

  @override
  Widget build(BuildContext context) {
    final ordersProv = context.watch<OrdersProvider>();
    final pending = ordersProv.pendingOrders;

    if (pending.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 64, color: AppColors.success.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              'No hay órdenes pendientes',
              style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ).animate().fadeIn(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 120),
      itemCount: pending.length,
      itemBuilder: (context, i) {
        final order = pending[i];
        final isConfirmed = order.status == OrderStatus.confirmed;
        
        return GlassCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          borderRadius: 20,
          borderColor: isConfirmed ? AppColors.primary : AppColors.warning,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isConfirmed ? AppColors.primary.withValues(alpha: 0.15) : AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#${order.id.substring(0, 5).toUpperCase()}',
                      style: GoogleFonts.inter(
                        color: isConfirmed ? AppColors.primary : AppColors.warning,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    order.mode.name.toUpperCase(),
                    style: GoogleFonts.inter(color: AppColors.textTertiary, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Text('${item.quantity}x', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(width: 8),
                    Text('${item.emoji} ${item.productName}', style: GoogleFonts.inter(color: AppColors.textSecondary)),
                  ],
                ),
              )),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isConfirmed ? AppColors.success : AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    final nextStatus = isConfirmed ? OrderStatus.completed : OrderStatus.confirmed;
                    context.read<OrdersProvider>().updateOrderStatus(
                      order.id, 
                      nextStatus,
                      context.read<InventoryProvider>(),
                      context.read<DashboardProvider>(),
                      context.read<LoyaltyProvider>(),
                    );
                  },
                  child: Text(
                    isConfirmed ? 'MARCAR COMPLETADA' : 'INICIAR PREPARACIÓN',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn().slideX(begin: 0.1);
      },
    );
  }
}

// ─── Upcoming Orders View ──────────────────────────────────────────────────

class _UpcomingOrdersView extends StatelessWidget {
  const _UpcomingOrdersView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month_rounded, size: 64, color: AppColors.textTertiary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'No hay órdenes programadas',
            style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ).animate().fadeIn(),
    );
  }
}

// ─── New Order POS View (3-way routing) ────────────────────────────────────

class _NewOrderPosView extends StatefulWidget {
  const _NewOrderPosView();

  @override
  State<_NewOrderPosView> createState() => _NewOrderPosViewState();
}

class _NewOrderPosViewState extends State<_NewOrderPosView> {
  OrderMode _mode = OrderMode.takeaway;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().setMode(_mode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _PosModeSelector(
                  title: 'Para Llevar',
                  icon: Icons.directions_walk_rounded,
                  isSelected: _mode == OrderMode.takeaway,
                  onTap: () => _updateMode(OrderMode.takeaway),
                ),
                const SizedBox(width: 8),
                _PosModeSelector(
                  title: 'Mesas',
                  icon: Icons.table_restaurant_rounded,
                  isSelected: _mode == OrderMode.dineIn,
                  onTap: () => _updateMode(OrderMode.dineIn),
                ),
                const SizedBox(width: 8),
                _PosModeSelector(
                  title: 'Domicilio',
                  icon: Icons.two_wheeler_rounded,
                  isSelected: _mode == OrderMode.delivery,
                  onTap: () => _updateMode(OrderMode.delivery),
                ),
              ],
            ),
          ),
        ),
        
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildFlowForm(),
          ),
        ),

        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: _CartAndCheckoutSection(),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  void _updateMode(OrderMode mode) {
    setState(() => _mode = mode);
    context.read<CartProvider>().setMode(mode);
  }

  Widget _buildFlowForm() {
    switch (_mode) {
      case OrderMode.takeaway:
        return _TakeawayForm().animate().fadeIn();
      case OrderMode.dineIn:
        return _TableServiceForm().animate().fadeIn();
      case OrderMode.delivery:
        return _DeliveryForm().animate().fadeIn();
    }
  }
}

class _PosModeSelector extends StatelessWidget {
  const _PosModeSelector({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : AppColors.textSecondary),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Pos Sub-Forms ─────────────────────────────────────────────────────────

class _TakeawayForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Datos del Cliente', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Nombre',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Teléfono',
              prefixIcon: const Icon(Icons.phone_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Hora de Retiro',
              prefixIcon: const Icon(Icons.schedule_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableServiceForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona la Mesa',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 16),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: 9, // 9 Tables
          itemBuilder: (context, i) {
            final tableNum = i + 1;
            final cart = context.watch<CartProvider>();
            final isSelected = cart.selectedTable == tableNum;
            // Mock occupied tables for Poka-Yoke demo
            final isOccupied = tableNum == 2 || tableNum == 5;
            
            return GestureDetector(
              onTap: () {
                if (!isOccupied) {
                  context.read<CartProvider>().setSelectedTable(tableNum);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isOccupied 
                      ? AppColors.coral.withValues(alpha: 0.1) 
                      : isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isOccupied 
                        ? AppColors.coral.withValues(alpha: 0.5) 
                        : isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$tableNum',
                        style: GoogleFonts.inter(
                          color: isOccupied ? AppColors.coral : isSelected ? Colors.white : AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        isOccupied ? 'Ocupada' : 'Libre',
                        style: GoogleFonts.inter(
                          color: isOccupied ? AppColors.coral : isSelected ? Colors.white70 : AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _DeliveryForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dirección de Entrega', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Buscar Dirección...',
              prefixIcon: const Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Notas Adicionales (Ej. Casa amarilla)',
              prefixIcon: const Icon(Icons.note_alt_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          TextFormField(
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Teléfono Contacto',
              prefixIcon: const Icon(Icons.phone_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Cart and Checkout Section (Poka-Yoke validation) ──────────────────────

class _CartAndCheckoutSection extends StatelessWidget {
  const _CartAndCheckoutSection();

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final inventory = context.watch<InventoryProvider>();
    
    // For Demo: Auto-add an item if empty, so the user can test the POS.
    if (cart.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (inventory.catalog.isNotEmpty) {
           context.read<CartProvider>().addItem(inventory.catalog.first);
        }
      });
    }

    // Poka-Yoke Validation
    bool canCheckout = cart.isNotEmpty;
    for (final item in cart.items) {
      final product = inventory.catalog.firstWhere((p) => p.id == item.productId);
      if (!inventory.hasSufficientStock(product, item.quantity)) {
        canCheckout = false;
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Text(
          'Resumen de Órden',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 16),
        ),
        const SizedBox(height: 12),
        
        ...cart.items.map((item) {
          final product = inventory.catalog.firstWhere((p) => p.id == item.productId);
          final hasStock = inventory.hasSufficientStock(product, item.quantity);
          
          return GlassCard(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            borderRadius: 16,
            borderColor: hasStock ? AppColors.border : AppColors.coral,
            child: Row(
              children: [
                Text(item.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.productName, style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      Text(
                        hasStock ? 'Disponible' : 'Sin inventario suficiente',
                        style: GoogleFonts.inter(
                          color: hasStock ? AppColors.success : AppColors.coral,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text('${item.quantity}x', style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: AppColors.primary)),
                const SizedBox(width: 16),
                Text('\$${item.lineTotal.toStringAsFixed(2)}', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              ],
            ),
          );
        }),
        
        const SizedBox(height: 24),
        GlassCard(
          padding: const EdgeInsets.all(20),
          borderRadius: 24,
          color: AppColors.textPrimary,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total a Pagar', style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
                  Text('\$${cart.subtotal.toStringAsFixed(2)}', style: GoogleFonts.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: canCheckout ? AppColors.primary : AppColors.border,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: canCheckout ? () async {
                  final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
                  final order = cart.buildOrder(orderId: orderId);
                  
                  await context.read<OrdersProvider>().createOrder(order, context.read<DashboardProvider>());
                  
                  if (context.mounted) {
                    context.read<CartProvider>().clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Órden Creada: $orderId'), backgroundColor: AppColors.success),
                    );
                    // Reset to "Pendientes"
                    final state = context.findAncestorStateOfType<_OrdersScreenState>();
                    state?._onTabChanged(0);
                  }
                } : null,
                child: Text(
                  'CONFIRMAR ÓRDEN',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
