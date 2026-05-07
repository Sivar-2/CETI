import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  int _tab = 0;

  static const _channels = [
    _Channel('WhatsApp', AppColors.whatsapp, '💬'),
    _Channel('Instagram', AppColors.instagram, '📷'),
    _Channel('Facebook', AppColors.facebook, '👥'),
    _Channel('TikTok', AppColors.tiktok, '🎵'),
  ];

  final List<List<_Message>> _messages = [
    // WhatsApp
    [
      _Message(
          name: 'Carlos Ramos',
          text: '¿Tienen disponible para mañana a las 7pm?',
          time: '10:24',
          isBot: false,
          unread: 2),
      _Message(
          name: 'María López',
          text: 'Quiero reservar mesa para 4 personas',
          time: '09:15',
          isBot: false,
          unread: 0),
      _Message(
          name: 'Bot CETI ✦',
          text: 'Hola! Gracias por contactarnos. Tenemos disponibilidad...',
          time: '08:30',
          isBot: true,
          unread: 0),
    ],
    // Instagram
    [
      _Message(
          name: 'foodie_sv',
          text: '¡Ese café se ve delicioso! ¿Cuál es la dirección?',
          time: 'Ayer',
          isBot: false,
          unread: 1),
      _Message(
          name: 'Bot IA ✦',
          text: 'Estamos ubicados en Colonia Escalón, San Salvador...',
          time: 'Ayer',
          isBot: true,
          unread: 0),
    ],
    // Facebook
    [
      _Message(
          name: 'José Alfaro',
          text: '¿Tienen delivery disponible los domingos?',
          time: 'Lun',
          isBot: false,
          unread: 0),
    ],
    // TikTok
    [
      _Message(
          name: 'user_tiktok99',
          text: 'Vi su video y quiero ir! ¿Cuál es el horario?',
          time: 'Dom',
          isBot: false,
          unread: 3),
    ],
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _tabCtrl.addListener(() => setState(() => _tab = _tabCtrl.index));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    'Bandeja Omnicanal',
                    style: GoogleFonts.dmSans(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.purple.withValues(alpha: 0.15),
                      border: Border.all(
                          color: AppColors.purple.withValues(alpha: 0.3),
                          width: 0.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome_rounded,
                            color: AppColors.purple, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          'IA Activa',
                          style: GoogleFonts.dmSans(
                            color: AppColors.purple,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Channel Tabs ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: List.generate(_channels.length, (i) {
                final ch = _channels[i];
                final active = _tab == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      _tabCtrl.animateTo(i);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: active
                            ? ch.color.withValues(alpha: 0.15)
                            : AppColors.glassWhite,
                        border: Border.all(
                          color: active
                              ? ch.color.withValues(alpha: 0.5)
                              : AppColors.borderWhite,
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(ch.emoji,
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 2),
                          if (_messages[i].any((m) => m.unread > 0))
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ch.color,
                              ),
                            )
                          else
                            const SizedBox(height: 6),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // ── Messages List ─────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: List.generate(4, (tabIdx) {
                final msgs = _messages[tabIdx];
                final ch = _channels[tabIdx];
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: msgs.length,
                  itemBuilder: (context, i) {
                    final msg = msgs[i];
                    return GestureDetector(
                      onLongPress: () {
                        HapticFeedback.mediumImpact();
                        _showConvertToOrder(context, msg);
                      },
                      child: GlassCard(
                        margin: const EdgeInsets.only(bottom: 10),
                        borderRadius: 18,
                        borderColor: msg.isBot
                            ? AppColors.purple.withValues(alpha: 0.3)
                            : ch.color.withValues(alpha: 0.2),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: msg.isBot
                                    ? AppColors.purple.withValues(alpha: 0.15)
                                    : ch.color.withValues(alpha: 0.12),
                              ),
                              child: Center(
                                child: Text(
                                  msg.isBot ? '🤖' : msg.name[0],
                                  style: TextStyle(
                                    fontSize: msg.isBot ? 20 : 18,
                                    color: msg.isBot
                                        ? null
                                        : ch.color,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          msg.name,
                                          style: GoogleFonts.dmSans(
                                            color: AppColors.textPrimary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (msg.isBot) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            color: AppColors.purple
                                                .withValues(alpha: 0.2),
                                          ),
                                          child: Text(
                                            'IA ✦',
                                            style: GoogleFonts.dmSans(
                                              color: AppColors.purple,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    msg.text,
                                    style: GoogleFonts.dmSans(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  msg.time,
                                  style: GoogleFonts.dmSans(
                                    color: AppColors.textTertiary,
                                    fontSize: 10,
                                  ),
                                ),
                                if (msg.unread > 0) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: ch.color,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${msg.unread}',
                                        style: GoogleFonts.dmSans(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ).animate(delay: (i * 60).ms).fadeIn().slideX(begin: 0.1),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _showConvertToOrder(BuildContext context, _Message msg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderWhite, width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              'Convertir a Pedido',
              style: GoogleFonts.dmSans(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            GlassCard(
              padding: const EdgeInsets.all(16),
              borderRadius: 16,
              child: Text(
                '"${msg.text}"',
                style: GoogleFonts.dmSans(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Se creará un nuevo pedido con el texto del mensaje y se abrirá el POS.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                color: AppColors.textTertiary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: AppColors.borderWhite, width: 0.5),
                      ),
                      child: Text(
                        'Cancelar',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                            color: AppColors.textSecondary, fontSize: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '🛒 Pedido creado desde ${msg.name}',
                            style: GoogleFonts.dmSans(
                                color: AppColors.textPrimary),
                          ),
                          backgroundColor: AppColors.cardDark,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: AppColors.goldGradient,
                      ),
                      child: Text(
                        'Crear Pedido',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          color: AppColors.deepBlack,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Data Models ─────────────────────────────────────────────────────────────

class _Channel {
  const _Channel(this.name, this.color, this.emoji);
  final String name;
  final Color color;
  final String emoji;
}

class _Message {
  const _Message({
    required this.name,
    required this.text,
    required this.time,
    required this.isBot,
    required this.unread,
  });
  final String name;
  final String text;
  final String time;
  final bool isBot;
  final int unread;
}
