import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gold_button.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen>
    with TickerProviderStateMixin {
  bool _nfcScanning = false;
  bool _celebrated = false;
  late AnimationController _pulseCtrl;
  late AnimationController _celebCtrl;

  // Mock selected customer
  _Customer? _customer = const _Customer(
    name: 'Ana Martínez',
    visits: 11,
    level: 'Silver',
    nextLevelVisits: 15,
  );

  final List<_Customer> _topCustomers = const [
    _Customer(name: 'Ana Martínez', visits: 11, level: 'Silver', nextLevelVisits: 15),
    _Customer(name: 'Roberto Cruz', visits: 22, level: 'Gold', nextLevelVisits: 30),
    _Customer(name: 'Lucía Herrera', visits: 5, level: 'Bronze', nextLevelVisits: 10),
    _Customer(name: 'Diego Flores', visits: 18, level: 'Gold', nextLevelVisits: 30),
    _Customer(name: 'Karla Vásquez', visits: 8, level: 'Bronze', nextLevelVisits: 10),
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _celebCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _celebCtrl.dispose();
    super.dispose();
  }

  void _simulateNfcTap() async {
    setState(() => _nfcScanning = true);
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() {
      _nfcScanning = false;
      _celebrated = false;
      if (_customer != null) {
        final newVisits = _customer!.visits + 1;
        final newLevel = _levelFromVisits(newVisits);
        final leveledUp = newLevel != _customer!.level;
        _customer = _Customer(
          name: _customer!.name,
          visits: newVisits,
          level: newLevel,
          nextLevelVisits: _nextLevelVisits(newVisits),
        );
        if (leveledUp) {
          _celebrated = true;
          _celebCtrl.forward(from: 0);
        }
      }
    });
    HapticFeedback.mediumImpact();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🐆 ¡Visita registrada! ${_customer?.name} → Visita #${_customer?.visits}',
            style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.card,
        ),
      );
    }
  }

  String _levelFromVisits(int visits) {
    if (visits >= 20) return 'Gold';
    if (visits >= 10) return 'Silver';
    return 'Bronze';
  }

  int _nextLevelVisits(int visits) {
    if (visits >= 20) return 30;
    if (visits >= 10) return 20;
    return 10;
  }

  Color _levelColor(String level) {
    switch (level) {
      case 'Gold':
        return AppColors.primary;
      case 'Silver':
        return AppColors.silver;
      default:
        return AppColors.bronze;
    }
  }

  String _levelEmoji(String level) {
    switch (level) {
      case 'Gold':
        return '🥇';
      case 'Silver':
        return '🥈';
      default:
        return '🥉';
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _customer;
    final progress = c != null
        ? c.visits / c.nextLevelVisits
        : 0.0;

    return Container(
      color: AppColors.background,
      child: Stack(
        children: [
          // Glow background
          if (c != null)
            Positioned(
              top: -80,
              left: 0,
              right: 0,
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      _levelColor(c.level).withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                    radius: 0.8,
                  ),
                ),
              ),
            ),

          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            child: Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Club Jaguar 🐆',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                // ── NFC Tap Card ───────────────────────────────────────────
                GlassCard(
                  borderRadius: 28,
                  child: Column(
                    children: [
                      Text(
                        'Registrar Visita por NFC',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Acerca el teléfono del cliente al POS',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // NFC animation circle
                      GestureDetector(
                        onTap: _nfcScanning ? null : _simulateNfcTap,
                        child: AnimatedBuilder(
                          animation: _pulseCtrl,
                          builder: (context, child) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer glow rings
                                ...List.generate(3, (i) {
                                  final scale = 1.0 +
                                      (i * 0.3) +
                                      (_nfcScanning
                                          ? _pulseCtrl.value * 0.2
                                          : 0);
                                  final opacity = _nfcScanning
                                      ? (1.0 - i * 0.3) *
                                          (0.5 + _pulseCtrl.value * 0.5)
                                      : 0.0;
                                  return Transform.scale(
                                    scale: scale,
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.primary
                                              .withValues(alpha: opacity),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                                // Main circle
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primary.withValues(alpha: 0.2),
                                        AppColors.primary.withValues(alpha: 0.05),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    border: Border.all(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.4),
                                      width: 1,
                                    ),
                                    boxShadow: _nfcScanning
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.3),
                                              blurRadius: 30,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.nfc_rounded,
                                        color: AppColors.primary,
                                        size: 36,
                                      ),
                                      if (_nfcScanning)
                                        Text(
                                          'Leyendo...',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: AppColors.primary,
                                            fontSize: 9,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),
                      Text(
                        _nfcScanning ? 'Escaneando NFC...' : 'Toca para simular escaneo',
                        style: GoogleFonts.plusJakartaSans(
                          color: _nfcScanning
                              ? AppColors.primary
                              : AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms),

                const SizedBox(height: 16),

                // ── Customer Card ──────────────────────────────────────────
                if (c != null) ...[
                  GlassCard(
                    borderRadius: 24,
                    borderColor:
                        _levelColor(c.level).withValues(alpha: 0.4),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _levelColor(c.level)
                                    .withValues(alpha: 0.15),
                              ),
                              child: Center(
                                child: Text(
                                  c.name[0],
                                  style: GoogleFonts.plusJakartaSans(
                                    color: _levelColor(c.level),
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.name,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(_levelEmoji(c.level),
                                          style:
                                              const TextStyle(fontSize: 14)),
                                      const SizedBox(width: 4),
                                      Text(
                                        c.level,
                                        style: GoogleFonts.plusJakartaSans(
                                          color: _levelColor(c.level),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${c.visits}',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: _levelColor(c.level),
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'Visitas',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.textTertiary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Progress ring bar
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progreso al siguiente nivel',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${c.visits}/${c.nextLevelVisits}',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: _levelColor(c.level),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progress.clamp(0.0, 1.0),
                                backgroundColor:
                                    AppColors.border.withValues(alpha: 0.3),
                                valueColor: AlwaysStoppedAnimation(
                                    _levelColor(c.level)),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Wallet buttons
                        Row(
                          children: [
                            Expanded(
                              child: GoldOutlineButton(
                                label: '🍎 Apple Wallet',
                                onPressed: () {},
                                fullWidth: true,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GoldOutlineButton(
                                label: 'G Pay',
                                icon: Icons.credit_card_rounded,
                                onPressed: () {},
                                fullWidth: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                  const SizedBox(height: 16),

                  // Level tiers reference
                  GlassCard(
                    borderRadius: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Niveles del Club',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _LevelRow(
                          emoji: '🥉',
                          level: 'Bronze',
                          color: AppColors.bronze,
                          description: '0–9 visitas',
                          perks: '5% descuento',
                          active: c.level == 'Bronze',
                        ),
                        const SizedBox(height: 8),
                        _LevelRow(
                          emoji: '🥈',
                          level: 'Silver',
                          color: AppColors.silver,
                          description: '10–19 visitas',
                          perks: '10% descuento + Bebida gratis',
                          active: c.level == 'Silver',
                        ),
                        const SizedBox(height: 8),
                        _LevelRow(
                          emoji: '🥇',
                          level: 'Gold',
                          color: AppColors.primary,
                          description: '20+ visitas',
                          perks: '15% desc + Postres + Prioridad',
                          active: c.level == 'Gold',
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 16),
                ],

                // ── Top Customers Table ────────────────────────────────────
                GlassCard(
                  borderRadius: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Top Clientes',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ..._topCustomers.asMap().entries.map((e) {
                        final i = e.key;
                        final cust = e.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Text(
                                '${i + 1}',
                                style: GoogleFonts.plusJakartaSans(
                                  color: i == 0
                                      ? AppColors.primary
                                      : AppColors.textTertiary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _levelEmoji(cust.level),
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  cust.name,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Text(
                                '${cust.visits} vis.',
                                style: GoogleFonts.plusJakartaSans(
                                  color: _levelColor(cust.level),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms),
              ],
            ),
          ),

          // ── Level-Up Celebration Overlay ──────────────────────────────────
          if (_celebrated)
            _CelebrationOverlay(
              ctrl: _celebCtrl,
              onDone: () => setState(() => _celebrated = false),
            ),
        ],
      ),
    );
  }
}

// ─── Level Row ────────────────────────────────────────────────────────────────

class _LevelRow extends StatelessWidget {
  const _LevelRow({
    required this.emoji,
    required this.level,
    required this.color,
    required this.description,
    required this.perks,
    required this.active,
  });
  final String emoji;
  final String level;
  final Color color;
  final String description;
  final String perks;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: active ? color.withValues(alpha: 0.08) : Colors.transparent,
        border: Border.all(
          color: active ? color.withValues(alpha: 0.3) : Colors.transparent,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      level,
                      style: GoogleFonts.plusJakartaSans(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      description,
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                Text(
                  perks,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (active)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: color.withValues(alpha: 0.15),
              ),
              child: Text(
                'Actual',
                style: GoogleFonts.plusJakartaSans(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Celebration Overlay ─────────────────────────────────────────────────────

class _CelebrationOverlay extends StatefulWidget {
  const _CelebrationOverlay({required this.ctrl, required this.onDone});
  final AnimationController ctrl;
  final VoidCallback onDone;

  @override
  State<_CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<_CelebrationOverlay> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) widget.onDone();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        child: Center(
          child: GlassCard(
            padding: const EdgeInsets.all(32),
            borderRadius: 28,
            borderColor: AppColors.primary.withValues(alpha: 0.5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🎉', style: const TextStyle(fontSize: 60))
                    .animate()
                    .scale(begin: const Offset(0.3, 0.3))
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 16),
                Text(
                  '¡Nivel Alcanzado!',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ).animate(delay: 300.ms).fadeIn(),
                const SizedBox(height: 8),
                Text(
                  'El cliente subió al siguiente nivel del Club Jaguar',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ).animate(delay: 400.ms).fadeIn(),
              ],
            ),
          ).animate().scale(begin: const Offset(0.8, 0.8)).fadeIn(duration: 400.ms),
        ),
      ),
    );
  }
}

// ─── Data Models ─────────────────────────────────────────────────────────────

class _Customer {
  const _Customer({
    required this.name,
    required this.visits,
    required this.level,
    required this.nextLevelVisits,
  });
  final String name;
  final int visits;
  final String level;
  final int nextLevelVisits;
}
