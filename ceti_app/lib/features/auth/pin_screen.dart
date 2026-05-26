import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_strings.dart';
import '../../core/providers/auth_provider.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  late AnimationController _shakeCtrl;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onNumTap(String num) {
    if (_pin.length < 6) {
      HapticFeedback.lightImpact();
      setState(() => _pin += num);
      if (_pin.length == 6) {
        _submitPin();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      HapticFeedback.lightImpact();
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  void _showError() {
    HapticFeedback.heavyImpact();
    _shakeCtrl.forward(from: 0.0);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _pin = '');
      }
    });
  }

  Future<void> _submitPin() async {
    final auth = context.read<AuthProvider>();
    if (auth.hasPin) {
      // Verify
      final ok = await auth.verifyPin(_pin);
      if (ok && mounted) {
        context.go('/home');
      } else {
        _showError();
      }
    } else {
      // Setup
      if (_pin.length >= 4) {
        await auth.setPin(_pin);
        if (mounted) context.go('/home');
      }
    }
  }

  Future<void> _onBiometric() async {
    HapticFeedback.lightImpact();
    final auth = context.read<AuthProvider>();
    final ok = await auth.checkBiometric();
    if (ok && mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isSetup = !auth.hasPin;
    final isError = _shakeCtrl.isAnimating;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _shakeCtrl,
          builder: (context, child) {
            final offset = isError ? (4 * (0.5 - (0.5 - _shakeCtrl.value).abs())) : 0.0;
            return Transform.translate(
              offset: Offset(offset * 10, 0),
              child: child,
            );
          },
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Small logo
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  child: Image.asset(
                    'assets/images/jaguar.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                isSetup ? S.pinSetup : S.pinTitle,
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isSetup ? S.pinSetupSubtitle : S.pinSubtitle,
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 60),

              // PIN dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  final filled = index < _pin.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isError 
                          ? AppColors.coral 
                          : (filled ? AppColors.primary : Colors.transparent),
                      border: Border.all(
                        color: isError 
                            ? AppColors.coral 
                            : (filled ? AppColors.primary : AppColors.border),
                        width: 1.5,
                      ),
                    ),
                  );
                }),
              ),
              
              if (isError)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    S.pinError,
                    style: GoogleFonts.inter(
                      color: AppColors.coral,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              const Spacer(),

              // Custom Numpad
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 24,
                  childAspectRatio: 1,
                  children: [
                    for (int i = 1; i <= 9; i++)
                      _NumBtn(text: '$i', onTap: () => _onNumTap('$i')),
                    
                    if (!isSetup && auth.hasBiometric)
                      _BioBtn(onTap: _onBiometric)
                    else
                      const SizedBox(),
                      
                    _NumBtn(text: '0', onTap: () => _onNumTap('0')),
                    _BackBtn(onTap: _onBackspace),
                  ],
                ),
              ),

              const SizedBox(height: 48),
              
              if (isSetup && _pin.length >= 4)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  child: ElevatedButton(
                    onPressed: _submitPin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      S.pinConfirm,
                      style: GoogleFonts.inter(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              else if (!isSetup)
                TextButton(
                  onPressed: () {
                    auth.logout();
                    context.go('/login');
                  },
                  child: Text(
                    S.pinForgot,
                    style: GoogleFonts.inter(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumBtn extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _NumBtn({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.glassWhite,
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _BioBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _BioBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(shape: BoxShape.circle),
        alignment: Alignment.center,
        child: const Icon(Icons.face, color: AppColors.primary, size: 32),
      ),
    );
  }
}

class _BackBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _BackBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(shape: BoxShape.circle),
        alignment: Alignment.center,
        child: const Icon(Icons.backspace_outlined, color: AppColors.textSecondary, size: 28),
      ),
    );
  }
}
