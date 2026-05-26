import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/auth_provider.dart';

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
      if (mounted) {
        final auth = context.read<AuthProvider>();
        switch (auth.status) {
          case AuthStatus.authenticated:
            context.go('/home');
            break;
          case AuthStatus.pinRequired:
          case AuthStatus.pinSetup:
            context.go('/pin');
            break;
          case AuthStatus.unauthenticated:
            context.go('/login');
            break;
        }
      }
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
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // Radial amethyst glow background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.1),
                  radius: 0.75,
                  colors: [
                    AppColors.accent.withValues(alpha: 0.3),
                    AppColors.accent.withValues(alpha: 0.1),
                    Colors.transparent,
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
                          color: AppColors.white.withValues(alpha: 0.1),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                      child: Image.asset(
                        'assets/images/jaguar.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.primaryGradient,
                          ),
                          child: const Icon(
                            Icons.pets,
                            color: AppColors.white,
                            size: 60,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // CETI Wordmark
                Text(
                  'C E T I',
                  style: GoogleFonts.inter(
                    color: AppColors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 12,
                  ),
                )
                    .animate(delay: 600.ms)
                    .fadeIn(duration: 800.ms)
                    .slideY(
                        begin: 0.3,
                        end: 0,
                        duration: 800.ms,
                        curve: Curves.easeOut),

                const SizedBox(height: 6),

                Text(
                  'Gestión inteligente para tu negocio',
                  style: GoogleFonts.inter(
                    color: AppColors.white.withValues(alpha: 0.7),
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
              style: GoogleFonts.inter(
                color: AppColors.white.withValues(alpha: 0.5),
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
            color: AppColors.accent.withValues(alpha: 0.2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: controller.value,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                    ),
                  ),
                ),
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
                            AppColors.white.withValues(alpha: 0.6),
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
      ..color = AppColors.white.withValues(alpha: 0.05)
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
