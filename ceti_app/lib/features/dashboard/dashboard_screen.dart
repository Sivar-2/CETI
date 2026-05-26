import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/providers/dashboard_provider.dart';
import '../../core/providers/inventory_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _currency = NumberFormat.currency(locale: 'es_SV', symbol: '\$');

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<DashboardProvider>();
    final inventory = context.watch<InventoryProvider>();
    
    final bool zeroSales = dash.todaySales == 0;
    final criticalSupplies = inventory.criticalSupplies;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.background, Color(0xFF1E1B24)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── SliverAppBar with Revenue Card ──────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            collapsedHeight: 70,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: _RevenueCard(
                    todaySales: dash.todaySales,
                    zeroSales: zeroSales,
                    currency: _currency,
                    dataPoints: dash.salesDataPoints,
                  ),
                ),
              ),
            ),
            title: Text(
              'CETI Analytics',
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, size: 18,
                      color: AppColors.background),
                ),
              ),
            ],
          ),

          // ── Critical Stock Marquee ────────────────────────────────────────
          if (criticalSupplies.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                height: 40,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: criticalSupplies.length,
                  itemBuilder: (context, i) {
                    final sup = criticalSupplies[i];
                    return Container(
                      margin: EdgeInsets.only(left: 16, right: i == criticalSupplies.length - 1 ? 16 : 0),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.coral.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.coral.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: AppColors.coral, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Stock crítico: ${sup.name} (${sup.stockActual} ${sup.unit})',
                            style: GoogleFonts.inter(
                              color: AppColors.coral,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 2.seconds, color: AppColors.coral.withValues(alpha: 0.2));
                  },
                ),
              ),
            ),

          // ── Quick Stats Row ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Pendientes',
                      value: '${dash.pendingOrders}',
                      icon: Icons.hourglass_empty_rounded,
                      color: AppColors.warning,
                    ).animate().fadeIn().slideY(begin: 0.3),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Completadas',
                      value: '${dash.completedOrders}',
                      icon: Icons.check_circle_outline_rounded,
                      color: AppColors.success,
                    ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.3),
                  ),
                ],
              ),
            ),
          ),

          // ── Orders Ratio Donut Chart ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: GlassCard(
                padding: const EdgeInsets.all(20),
                borderRadius: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Eficiencia Operativa',
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 180,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 50,
                          sections: [
                            PieChartSectionData(
                              color: AppColors.success,
                              value: dash.completedOrders.toDouble() == 0 && dash.pendingOrders.toDouble() == 0 ? 1 : dash.completedOrders.toDouble(),
                              title: '${dash.completedOrders}',
                              radius: 30,
                              titleStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            PieChartSectionData(
                              color: AppColors.warning,
                              value: dash.pendingOrders.toDouble(),
                              title: '${dash.pendingOrders}',
                              radius: 25,
                              titleStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LegendIndicator(color: AppColors.success, text: 'Completadas'),
                        const SizedBox(width: 24),
                        _LegendIndicator(color: AppColors.warning, text: 'Pendientes'),
                      ],
                    ),
                  ],
                ),
              ).animate(delay: 200.ms).fadeIn().slideX(begin: 0.1),
            ),
          ),

          // ── Operational Reminders Checklist ───────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                'Recordatorios Operativos',
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          if (dash.activeReminders.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        '¡Todo al día!',
                        style: GoogleFonts.inter(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final reminder = dash.activeReminders[i];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Dismissible(
                      key: Key(reminder.id),
                      direction: DismissDirection.startToEnd,
                      onDismissed: (direction) {
                        dash.completeReminder(reminder.id);
                      },
                      background: Container(
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 24),
                        child: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                      ),
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        borderRadius: 16,
                        child: Row(
                          children: [
                            const Icon(Icons.swipe_right_rounded, color: AppColors.textTertiary, size: 18),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                reminder.title,
                                style: GoogleFonts.inter(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate(delay: (i * 100).ms).fadeIn(),
                  );
                },
                childCount: dash.activeReminders.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}

// ─── Revenue Card with Area Chart ─────────────────────────────────────────────

class _RevenueCard extends StatelessWidget {
  const _RevenueCard({
    required this.todaySales,
    required this.zeroSales,
    required this.currency,
    required this.dataPoints,
  });
  final double todaySales;
  final bool zeroSales;
  final NumberFormat currency;
  final List<FlSpot> dataPoints;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        borderRadius: 28,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ventas de Hoy',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              zeroSales ? '\$0.00' : currency.format(todaySales),
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: dataPoints,
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.3),
                            AppColors.primary.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: color.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              color: AppColors.textTertiary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Legend Indicator ────────────────────────────────────────────────────────

class _LegendIndicator extends StatelessWidget {
  const _LegendIndicator({required this.color, required this.text});
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(text, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}
