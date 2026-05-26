
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_strings.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gold_button.dart';
import '../../core/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  
  bool _obscure = true;
  bool _loading = false;
  
  // Poka-Yoke states
  bool _isEmailValid = false;
  bool _isEmailDirty = false;
  bool _isPassValid = false;
  bool _isPassDirty = false;

  late AnimationController _bioPulseCtrl;

  @override
  void initState() {
    super.initState();
    _bioPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _emailCtrl.addListener(_validateEmailRealtime);
    _passCtrl.addListener(_validatePassRealtime);
  }

  void _validateEmailRealtime() {
    if (!_isEmailDirty) setState(() => _isEmailDirty = true);
    final text = _emailCtrl.text;
    final valid = text.isNotEmpty && text.contains('@');
    if (_isEmailValid != valid) {
      setState(() => _isEmailValid = valid);
    }
  }
  
  void _validatePassRealtime() {
    if (!_isPassDirty) setState(() => _isPassDirty = true);
    final valid = _passCtrl.text.length >= 6;
    if (_isPassValid != valid) {
      setState(() => _isPassValid = valid);
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    
    final auth = context.read<AuthProvider>();
    await auth.login(_emailCtrl.text, _passCtrl.text);
    
    if (mounted) {
      setState(() => _loading = false);
      if (auth.status == AuthStatus.pinSetup) {
        context.go('/pin');
      } else {
        context.go('/home');
      }
    }
  }

  Future<void> _loginBiometric() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.checkBiometric();
    if (success && mounted) {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _bioPulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // Header Row: Logo and Language Switcher
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ColorFiltered(
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                          child: Image.asset(
                            'assets/images/jaguar.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.pets,
                              color: AppColors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        S.appName,
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                  _LanguageDropdown(),
                ],
              ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),

              const SizedBox(height: 48),

              Text(
                S.loginTitle,
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ).animate(delay: 200.ms).fadeIn(duration: 500.ms),

              const SizedBox(height: 4),
              Text(
                S.loginSubtitle,
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ).animate(delay: 300.ms).fadeIn(duration: 500.ms),

              const SizedBox(height: 40),

              // Glass form card
              GlassCard(
                padding: const EdgeInsets.all(24),
                borderRadius: 24,
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      // Email with Poka-Yoke borders
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.inter(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: S.loginEmail,
                          prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textTertiary),
                          filled: true,
                          fillColor: AppColors.glassWhite,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: _isEmailDirty 
                                  ? (_isEmailValid ? AppColors.success : AppColors.coral) 
                                  : AppColors.border,
                              width: _isEmailDirty && _isEmailValid ? 2 : 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: _isEmailDirty && !_isEmailValid ? AppColors.coral : AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return S.validationEmailRequired;
                          if (!v.contains('@')) return S.validationEmailInvalid;
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Password with Poka-Yoke borders
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        style: GoogleFonts.inter(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: S.loginPassword,
                          prefixIcon: const Icon(Icons.lock_outlined, color: AppColors.textTertiary),
                          filled: true,
                          fillColor: AppColors.glassWhite,
                          suffixIcon: GestureDetector(
                            onTap: () => setState(() => _obscure = !_obscure),
                            child: Icon(
                              _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: _isPassDirty 
                                  ? (_isPassValid ? AppColors.success : AppColors.coral) 
                                  : AppColors.border,
                              width: _isPassDirty && _isPassValid ? 2 : 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: _isPassDirty && !_isPassValid ? AppColors.coral : AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return S.validationPasswordRequired;
                          if (v.length < 6) return S.validationPasswordShort;
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Switch.adaptive(
                                value: auth.isRemembered,
                                onChanged: auth.toggleRememberMe,
                                activeTrackColor: AppColors.primary,
                              ),
                              Text(
                                S.loginRemember,
                                style: GoogleFonts.inter(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              S.loginForgot,
                              style: GoogleFonts.inter(
                                color: AppColors.primary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      GoldButton(
                        label: S.loginButton,
                        onPressed: _login,
                        loading: _loading,
                      ),
                    ],
                  ),
                ),
              ).animate(delay: 400.ms).fadeIn(duration: 600.ms).slideY(
                  begin: 0.2, end: 0, duration: 600.ms),

              const SizedBox(height: 24),

              // Biometric Pulse Button
              if (auth.hasBiometric)
                Center(
                  child: AnimatedBuilder(
                    animation: _bioPulseCtrl,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_bioPulseCtrl.value * 0.05),
                        child: child,
                      );
                    },
                    child: ElevatedButton.icon(
                      onPressed: _loginBiometric,
                      icon: const Icon(Icons.face, color: AppColors.primary),
                      label: Text(
                        S.loginBiometric,
                        style: GoogleFonts.inter(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDim,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ).animate(delay: 500.ms).fadeIn(),

              const SizedBox(height: 32),

              Center(
                child: Text(
                  S.loginSocialHeader,
                  style: GoogleFonts.inter(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ).animate(delay: 600.ms).fadeIn(),
              
              const SizedBox(height: 16),

              // Social login row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SocialBtn(icon: Icons.facebook, color: AppColors.facebook),
                  const SizedBox(width: 16),
                  _SocialBtn(icon: Icons.camera_alt, color: AppColors.instagram), // Insta-like icon
                  const SizedBox(width: 16),
                  _SocialBtn(icon: Icons.alternate_email, color: AppColors.textPrimary), // X/Twitter
                  const SizedBox(width: 16),
                  _SocialBtn(icon: Icons.music_note, color: AppColors.tiktok),
                ],
              ).animate(delay: 700.ms).fadeIn(),

              const SizedBox(height: 48),

              // Bottom Support Links
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text(S.loginContactAdvisor, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                  ),
                  Container(width: 1, height: 12, color: AppColors.border),
                  TextButton(
                    onPressed: () {},
                    child: Text(S.loginContactSupport, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                  ),
                ],
              ).animate(delay: 800.ms).fadeIn(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.glassWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🇸🇻', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text('ES', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  const _SocialBtn({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.glassWhite,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
