import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gold_button.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _currency = NumberFormat.currency(locale: 'es_SV', symbol: '\$');
  int _touchedIndex = -1;

  final List<_Product> _products = [
    _Product(
      name: 'Espresso Doble',
      emoji: '☕',
      price: 3.50,
      cost: 0.70,
      stock: 150,
      unit: 'tazas',
      ingredients: [
        _Ingredient('Café Molido', 0.25, 'libra'),
        _Ingredient('Agua', 0.10, 'lt'),
      ],
    ),
    _Product(
      name: 'Mocktail Mango',
      emoji: '🥭',
      price: 6.00,
      cost: 1.80,
      stock: 40,
      unit: 'und',
      ingredients: [
        _Ingredient('Jugo de Mango', 0.50, '250ml'),
        _Ingredient('Mixer Ginger', 0.30, 'botella'),
        _Ingredient('Hielo', 0.10, 'bolsa'),
        _Ingredient('Vaso Alto', 0.15, 'und'),
        _Ingredient('Popote/Pajilla', 0.05, 'und'),
        _Ingredient('Servilleta', 0.03, 'und'),
        _Ingredient('Rodaja Limón', 0.12, 'und'),
      ],
    ),
    _Product(
      name: 'Club Sándwich',
      emoji: '🥪',
      price: 8.50,
      cost: 2.80,
      stock: 25,
      unit: 'und',
      ingredients: [
        _Ingredient('Pan de Molde', 0.40, 'rebanadas'),
        _Ingredient('Pechuga de Pollo', 1.20, 'onz'),
        _Ingredient('Queso Americano', 0.30, 'rebanada'),
        _Ingredient('Tomate', 0.20, 'und'),
        _Ingredient('Lechuga', 0.10, 'und'),
        _Ingredient('Mayonesa', 0.05, 'porciones'),
        _Ingredient('Papas Fritas', 0.55, 'porciones'),
      ],
    ),
    _Product(
      name: 'Cheesecake',
      emoji: '🍰',
      price: 5.50,
      cost: 1.60,
      stock: 12,
      unit: 'porciones',
      ingredients: [
        _Ingredient('Base Galleta', 0.40, 'porción'),
        _Ingredient('Queso Crema', 0.80, 'onz'),
        _Ingredient('Azúcar', 0.05, 'onz'),
        _Ingredient('Mermelada', 0.20, 'cda'),
        _Ingredient('Crema Chantilly', 0.15, 'porciones'),
      ],
    ),
    _Product(
      name: 'Granola Bowl',
      emoji: '🥣',
      price: 7.00,
      cost: 2.10,
      stock: 5,
      unit: 'und',
      ingredients: [
        _Ingredient('Granola', 0.60, 'gr'),
        _Ingredient('Yogurt Griego', 0.80, 'gr'),
        _Ingredient('Fruta Mixta', 0.50, 'porciones'),
        _Ingredient('Miel', 0.10, 'cda'),
        _Ingredient('Tazón', 0.10, 'und'),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  double _margin(_Product p) => ((p.price - p.cost) / p.price) * 100;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
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
                    'Escandallo',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.primary.withValues(alpha: 0.12),
                    ),
                    child: Text(
                      'Motor de Costos',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GoldOutlineButton(
                    label: '+ Producto',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),

          // ── Tabs ──────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: GlassCard(
              padding: const EdgeInsets.all(4),
              borderRadius: 14,
              child: TabBar(
                controller: _tabCtrl,
                tabs: const [
                  Tab(text: '📦 Productos'),
                  Tab(text: '📊 Top Ventas'),
                ],
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                // Products Tab
                ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: _products.length,
                  itemBuilder: (context, i) {
                    final p = _products[i];
                    final m = _margin(p);
                    final lowMargin = m < 20;
                    return GestureDetector(
                      onTap: () => _showProductDetail(context, p),
                      child: GlassCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        borderRadius: 20,
                        borderColor: lowMargin
                            ? AppColors.coral.withValues(alpha: 0.5)
                            : AppColors.border,
                        child: Row(
                          children: [
                            Text(p.emoji,
                                style: const TextStyle(fontSize: 32)),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: AppColors.textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      _InfoChip(
                                        label:
                                            'Costo: ${_currency.format(p.cost)}',
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      _InfoChip(
                                        label:
                                            'Precio: ${_currency.format(p.price)}',
                                        color: AppColors.success,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: lowMargin
                                        ? AppColors.coral.withValues(alpha: 0.15)
                                        : AppColors.success
                                            .withValues(alpha: 0.12),
                                  ),
                                  child: Text(
                                    '${m.toStringAsFixed(0)}%',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: lowMargin
                                          ? AppColors.coral
                                          : AppColors.success,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Stock: ${p.stock}',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: p.stock < 10
                                        ? AppColors.warning
                                        : AppColors.textTertiary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right_rounded,
                                color: AppColors.textTertiary, size: 18),
                          ],
                        ),
                      ),
                    ).animate(delay: (i * 60).ms).fadeIn().slideX(begin: -0.1);
                  },
                ),

                // Top Sales Chart Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  child: Column(
                    children: [
                      GlassCard(
                        borderRadius: 24,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Top Vendidos — Esta Semana',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 220,
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: 150,
                                  barTouchData: BarTouchData(
                                    touchCallback: (evt, resp) {
                                      setState(() {
                                        if (resp?.spot == null ||
                                            evt
                                                is FlPointerExitEvent) {
                                          _touchedIndex = -1;
                                        } else {
                                          _touchedIndex = resp!
                                              .spot!.touchedBarGroupIndex;
                                        }
                                      });
                                    },
                                    touchTooltipData: BarTouchTooltipData(
                                      getTooltipColor: (_) =>
                                          AppColors.card,
                                      getTooltipItem: (g, gi, rod, ri) =>
                                          BarTooltipItem(
                                        '${rod.toY.toInt()} uds',
                                        GoogleFonts.plusJakartaSans(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ),
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (v, meta) {
                                          const labels = [
                                            '☕', '🥭', '🥪', '🍰', '🥣'
                                          ];
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Text(
                                              labels[v.toInt()],
                                              style: const TextStyle(
                                                  fontSize: 18),
                                            ),
                                          );
                                        },
                                        reservedSize: 40,
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 32,
                                          getTitlesWidget: (v, m) => Text(
                                                '${v.toInt()}',
                                                style: GoogleFonts.plusJakartaSans(
                                                    color: AppColors.textTertiary,
                                                    fontSize: 10),
                                              )),
                                    ),
                                    topTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                  ),
                                  gridData: FlGridData(
                                    drawVerticalLine: false,
                                    getDrawingHorizontalLine: (_) => FlLine(
                                      color: AppColors.border,
                                      strokeWidth: 0.5,
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  barGroups: [
                                    _bar(0, 120, _touchedIndex == 0),
                                    _bar(1, 85, _touchedIndex == 1),
                                    _bar(2, 60, _touchedIndex == 2),
                                    _bar(3, 45, _touchedIndex == 3),
                                    _bar(4, 30, _touchedIndex == 4),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 600.ms),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _bar(int x, double y, bool touched) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: touched
              ? AppColors.primaryGradient
              : LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.5),
                    AppColors.primary.withValues(alpha: 0.2),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
          width: 32,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        ),
      ],
    );
  }

  void _showProductDetail(BuildContext context, _Product p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EscandalloSheet(product: p, currency: _currency),
    );
  }
}

// ─── Escandallo Detail Sheet ──────────────────────────────────────────────────

class _EscandalloSheet extends StatelessWidget {
  const _EscandalloSheet(
      {required this.product, required this.currency});
  final _Product product;
  final NumberFormat currency;

  double get _margin =>
      ((product.price - product.cost) / product.price) * 100;

  @override
  Widget build(BuildContext context) {
    final low = _margin < 20;
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, ctrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
              top: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Text(product.emoji,
                    style: const TextStyle(fontSize: 40)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Costo total · ${currency.format(product.cost)}',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: low
                        ? AppColors.coral.withValues(alpha: 0.15)
                        : AppColors.success.withValues(alpha: 0.12),
                    border: Border.all(
                      color: low
                          ? AppColors.coral.withValues(alpha: 0.4)
                          : AppColors.success.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${_margin.toStringAsFixed(1)}%',
                        style: GoogleFonts.plusJakartaSans(
                          color: low ? AppColors.coral : AppColors.success,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Margen',
                        style: GoogleFonts.plusJakartaSans(
                          color: low ? AppColors.coral : AppColors.success,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (low) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.coral.withValues(alpha: 0.08),
                  border: Border.all(
                      color: AppColors.coral.withValues(alpha: 0.3), width: 0.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_rounded,
                        color: AppColors.coral, size: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '⚠️ Margen por debajo del 20%. Considera ajustar el precio de venta.',
                        style: GoogleFonts.plusJakartaSans(
                            color: AppColors.coral, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Price vs Cost summary
            Row(
              children: [
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    borderRadius: 16,
                    child: Column(
                      children: [
                        Text('Precio Venta',
                            style: GoogleFonts.plusJakartaSans(
                                color: AppColors.textTertiary, fontSize: 11)),
                        Text(currency.format(product.price),
                            style: GoogleFonts.plusJakartaSans(
                                color: AppColors.primary,
                                fontSize: 20,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    borderRadius: 16,
                    child: Column(
                      children: [
                        Text('Costo Total',
                            style: GoogleFonts.plusJakartaSans(
                                color: AppColors.textTertiary, fontSize: 11)),
                        Text(currency.format(product.cost),
                            style: GoogleFonts.plusJakartaSans(
                                color: AppColors.textSecondary,
                                fontSize: 20,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    borderRadius: 16,
                    child: Column(
                      children: [
                        Text('Ganancia',
                            style: GoogleFonts.plusJakartaSans(
                                color: AppColors.textTertiary, fontSize: 11)),
                        Text(
                            currency.format(product.price - product.cost),
                            style: GoogleFonts.plusJakartaSans(
                                color: AppColors.success,
                                fontSize: 20,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Text(
              'Ingredientes / Insumos',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            ...product.ingredients.asMap().entries.map((e) {
              final ing = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  borderRadius: 14,
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          ing.name,
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Text(
                        ing.unit,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        currency.format(ing.cost),
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─── Info Chip ────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: color.withValues(alpha: 0.1),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(color: color, fontSize: 10),
      ),
    );
  }
}

// ─── Data Models ─────────────────────────────────────────────────────────────

class _Product {
  const _Product({
    required this.name,
    required this.emoji,
    required this.price,
    required this.cost,
    required this.stock,
    required this.unit,
    required this.ingredients,
  });
  final String name;
  final String emoji;
  final double price;
  final double cost;
  final int stock;
  final String unit;
  final List<_Ingredient> ingredients;
}

class _Ingredient {
  const _Ingredient(this.name, this.cost, this.unit);
  final String name;
  final double cost;
  final String unit;
}
