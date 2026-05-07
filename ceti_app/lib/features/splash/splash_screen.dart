import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _jaguarCtrl;
  late AnimationController _shimmerCtrl;
  late Animation<double> _jaguarScale;
  late Animation<double> _jaguarFade;

  @override
  void initState() {
    super.initState();

    _jaguarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _jaguarScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _jaguarCtrl, curve: Curves.elasticOut),
    );
    _jaguarFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _jaguarCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _jaguarCtrl.forward();
    });

    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) context.go('/login');
    });
  }

  @override
  void dispose() {
    _jaguarCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Radial amber glow background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.1),
                  radius: 0.75,
                  colors: [
                    Color(0x33D4A017),
                    Color(0x14D4A017),
                    Color(0x00000000),
                  ],
                ),
              ),
            ),
          ),

          // Subtle grid overlay
          Positioned.fill(
            child: CustomPaint(painter: _GridPainter()),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Jaguar mascot
                AnimatedBuilder(
                  animation: _jaguarCtrl,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _jaguarScale.value,
                      child: Opacity(
                        opacity: _jaguarFade.value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/jaguar.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.primaryGradient,
                        ),
                        child: const Icon(
                          Icons.pets,
                          color: AppColors.background,
                          size: 60,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // CETI Wordmark
                Text(
                  'C E T I',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textPrimary,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 12,
                  ),
                )
                    .animate(delay: 600.ms)
                    .fadeIn(duration: 800.ms)
                    .slideY(begin: 0.3, end: 0, duration: 800.ms,
                        curve: Curves.easeOut),

                const SizedBox(height: 6),

                Text(
                  'Gestión inteligente para tu negocio',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                )
                    .animate(delay: 900.ms)
                    .fadeIn(duration: 600.ms),

                const SizedBox(height: 60),

                // Shimmer gold loading bar
                SizedBox(
                  width: size.width * 0.5,
                  child: _ShimmerBar(controller: _shimmerCtrl),
                ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
              ],
            ),
          ),

          // Version watermark
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Text(
              'v1.0.0 · CETI SuperApp',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textTertiary,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ).animate(delay: 1200.ms).fadeIn(duration: 500.ms),
          ),
        ],
      ),
    );
  }
}

// ─── Shimmer Bar ─────────────────────────────────────────────────────────────

class _ShimmerBar extends StatelessWidget {
  const _ShimmerBar({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Container(
          height: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: AppColors.primary.withValues(alpha: 0.15),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                // Progress bar fill
                FractionallySizedBox(
                  widthFactor: controller.value,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                    ),
                  ),
                ),
                // Shimmer sweep
                Positioned.fill(
                  child: Transform.translate(
                    offset: Offset(
                      (controller.value * 2 - 0.5) * 300,
                      0,
                    ),
                    child: Container(
                      width: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Grid Painter ─────────────────────────────────────────────────────────────

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x05FFFFFF)
      ..strokeWidth = 0.5;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
