import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Mock data — replace with Firestore StreamBuilder
  final double _todaySales = 0; // Set to 0 to trigger poka-yoke pulse
  final _currency = NumberFormat.currency(locale: 'es_SV', symbol: '\$');

  final List<_ActivityItem> _activities = [
    _ActivityItem(
      icon: Icons.shopping_bag_rounded,
      color: AppColors.success,
      title: 'Pedido #1042 completado',
      subtitle: 'Mesa 3 · Hace 5 min',
      amount: '\$28.50',
    ),
    _ActivityItem(
      icon: Icons.inventory_2_rounded,
      color: AppColors.amber,
      title: 'Stock bajo: Café Molido',
      subtitle: 'Quedan 2 unidades',
      amount: null,
    ),
    _ActivityItem(
      icon: Icons.loyalty_rounded,
      color: AppColors.gold,
      title: 'Cliente Gold: Ana Martínez',
      subtitle: 'Visita #12 registrada',
      amount: null,
    ),
    _ActivityItem(
      icon: Icons.forum_rounded,
      color: AppColors.purple,
      title: 'Nuevo mensaje · WhatsApp',
      subtitle: '¿Tienen disponible para hoy?',
      amount: null,
    ),
    _ActivityItem(
      icon: Icons.point_of_sale_rounded,
      color: AppColors.blue,
      title: 'Pedido #1041 · Delivery',
      subtitle: 'Hace 18 min',
      amount: '\$45.00',
    ),
  ];

  final List<_Reminder> _reminders = [
    _Reminder(title: 'Pago de proveedor', date: 'Hoy, 5:00 PM', urgent: true),
    _Reminder(title: 'Inventario semanal', date: 'Mañana, 8:00 AM', urgent: false),
    _Reminder(title: 'Reunión de equipo', date: 'Vie 11 Abr, 3:00 PM', urgent: false),
  ];

  @override
  Widget build(BuildContext context) {
    final bool zeroSales = _todaySales == 0;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.deepBlack, Color(0xFF0C0C18)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── SliverAppBar with Revenue Card ──────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            collapsedHeight: 70,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: _RevenueCard(
                todaySales: _todaySales,
                zeroSales: zeroSales,
                currency: _currency,
              ),
            ),
            title: Text(
              'CETI Dashboard',
              style: GoogleFonts.dmSans(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: AppColors.textPrimary),
                onPressed: () => _showAlerts(context),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppColors.goldGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, size: 18,
                      color: AppColors.deepBlack),
                ),
              ),
            ],
          ),

          // ── Quick Stats Row ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Pedidos Hoy',
                      value: '14',
                      icon: Icons.receipt_long_rounded,
                      color: AppColors.blue,
                    ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.3),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Ticket Prom.',
                      value: '\$32.80',
                      icon: Icons.trending_up_rounded,
                      color: AppColors.success,
                    ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Alertas',
                      value: '3',
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.coral,
                    ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.3),
                  ),
                ],
              ),
            ),
          ),

          // ── Section: Latest Messages ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: _SectionHeader(
                title: 'Últimos Mensajes',
                actionLabel: 'Ver todos',
                onAction: () {},
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 4,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, i) =>
                    _MessageCard(index: i)
                        .animate(delay: (i * 100).ms)
                        .fadeIn()
                        .slideX(begin: 0.2),
              ),
            ),
          ),

          // ── Section: Activity Stream ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: _SectionHeader(
                title: 'Actividad Reciente',
                actionLabel: 'Ver todo',
                onAction: () {},
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: _ActivityTile(item: _activities[i])
                    .animate(delay: (i * 80).ms)
                    .fadeIn()
                    .slideX(begin: -0.1),
              ),
              childCount: _activities.length,
            ),
          ),

          // ── Section: Reminders ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _SectionHeader(
                title: 'Recordatorios',
                actionLabel: 'Agregar',
                onAction: () {},
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: _ReminderTile(reminder: _reminders[i])
                    .animate(delay: (i * 80).ms)
                    .fadeIn(),
              ),
              childCount: _reminders.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  void _showAlerts(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _AlertsSheet(),
    );
  }
}

// ─── Revenue Card ─────────────────────────────────────────────────────────────

class _RevenueCard extends StatefulWidget {
  const _RevenueCard({
    required this.todaySales,
    required this.zeroSales,
    required this.currency,
  });
  final double todaySales;
  final bool zeroSales;
  final NumberFormat currency;

  @override
  State<_RevenueCard> createState() => _RevenueCardState();
}

class _RevenueCardState extends State<_RevenueCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    if (widget.zeroSales) {
      _pulseCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      )..repeat(reverse: true);
      _pulse = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
      );
    } else {
      _pulseCtrl = AnimationController(vsync: this);
      _pulse = const AlwaysStoppedAnimation(1.0);
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: GlassCard(
        borderRadius: 28,
        padding: const EdgeInsets.all(24),
        gradient: LinearGradient(
          colors: widget.zeroSales
              ? [const Color(0x22FFB300), const Color(0x0AFFFFFF)]
              : [const Color(0x22D4A017), const Color(0x0AFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                Text(
                  'Ventas de Hoy',
                  style: GoogleFonts.dmSans(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.success.withValues(alpha: 0.15),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_upward_rounded,
                          color: AppColors.success, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        '+12%',
                        style: GoogleFonts.dmSans(
                          color: AppColors.success,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AnimatedBuilder(
              animation: _pulse,
              builder: (context, child) {
                return Opacity(
                  opacity: widget.zeroSales ? _pulse.value : 1.0,
                  child: child,
                );
              },
              child: Text(
                widget.zeroSales
                    ? '\$0.00'
                    : widget.currency.format(widget.todaySales),
                style: GoogleFonts.dmSans(
                  color: widget.zeroSales ? AppColors.amber : AppColors.textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
            ),
            if (widget.zeroSales) ...[
              const SizedBox(height: 6),
              Text(
                '¿Registraste tu primera venta? 🐆',
                style: GoogleFonts.dmSans(
                  color: AppColors.amber,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ] else ...[
              const SizedBox(height: 6),
              Text(
                'de \$500.00 meta diaria',
                style: GoogleFonts.dmSans(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
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
      padding: const EdgeInsets.all(14),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: color.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.dmSans(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.dmSans(
              color: AppColors.textTertiary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.dmSans(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onAction,
          child: Text(
            actionLabel,
            style: GoogleFonts.dmSans(
              color: AppColors.gold,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Message Card ─────────────────────────────────────────────────────────────

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.index});
  final int index;

  static const _data = [
    {'name': 'Carlos R.', 'msg': '¿Tienen disponible?', 'channel': '📱', 'time': '10:24'},
    {'name': 'María L.', 'msg': 'Quiero reservar para 4', 'channel': '📷', 'time': '09:15'},
    {'name': 'José A.', 'msg': '¿Delivery disponible?', 'channel': '💬', 'time': 'Ayer'},
    {'name': 'Bot IA', 'msg': 'Respuesta automática...', 'channel': '🤖', 'time': '08:00'},
  ];

  @override
  Widget build(BuildContext context) {
    final d = _data[index];
    final isBot = d['channel'] == '🤖';
    return GlassCard(
      width: 190,
      padding: const EdgeInsets.all(14),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(d['channel']!, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  d['name']!,
                  style: GoogleFonts.dmSans(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isBot)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: AppColors.purple.withValues(alpha: 0.2),
                  ),
                  child: Text(
                    'IA ✦',
                    style: GoogleFonts.dmSans(
                      color: AppColors.purple,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          Text(
            d['msg']!,
            style: GoogleFonts.dmSans(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            d['time']!,
            style: GoogleFonts.dmSans(
              color: AppColors.textTertiary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Activity Tile ────────────────────────────────────────────────────────────

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.item});
  final _ActivityItem item;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 16,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: item.color.withValues(alpha: 0.12),
            ),
            child: Icon(item.icon, color: item.color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.dmSans(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  item.subtitle,
                  style: GoogleFonts.dmSans(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (item.amount != null)
            Text(
              item.amount!,
              style: GoogleFonts.dmSans(
                color: AppColors.success,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Reminder Tile ────────────────────────────────────────────────────────────

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({required this.reminder});
  final _Reminder reminder;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: 16,
      borderColor: reminder.urgent
          ? AppColors.amber.withValues(alpha: 0.4)
          : AppColors.borderWhite,
      child: Row(
        children: [
          Icon(
            reminder.urgent
                ? Icons.alarm_on_rounded
                : Icons.calendar_today_rounded,
            color: reminder.urgent ? AppColors.amber : AppColors.textTertiary,
            size: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              reminder.title,
              style: GoogleFonts.dmSans(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            reminder.date,
            style: GoogleFonts.dmSans(
              color: reminder.urgent
                  ? AppColors.amber
                  : AppColors.textTertiary,
              fontSize: 11,
              fontWeight:
                  reminder.urgent ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Alerts Sheet ─────────────────────────────────────────────────────────────

class _AlertsSheet extends StatelessWidget {
  const _AlertsSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderWhite, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderWhite,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Alertas del Sistema',
            style: GoogleFonts.dmSans(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _AlertRow(
            icon: Icons.inventory_2_rounded,
            color: AppColors.coral,
            title: 'Stock crítico: Café Molido',
            subtitle: '2 unidades restantes',
          ),
          _AlertRow(
            icon: Icons.warning_amber_rounded,
            color: AppColors.amber,
            title: 'Margen bajo: Espresso Doble',
            subtitle: 'Margen actual 15%',
          ),
          _AlertRow(
            icon: Icons.payment_rounded,
            color: AppColors.blue,
            title: 'Pago pendiente de proveedor',
            subtitle: 'Vence hoy',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: color.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.dmSans(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.dmSans(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Data Models ─────────────────────────────────────────────────────────────

class _ActivityItem {
  const _ActivityItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.amount,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String? amount;
}

class _Reminder {
  const _Reminder({
    required this.title,
    required this.date,
    required this.urgent,
  });
  final String title;
  final String date;
  final bool urgent;
}
