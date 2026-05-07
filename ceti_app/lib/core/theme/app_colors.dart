import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Backgrounds ──────────────────────────────────────────────────────────
  static const Color deepBlack = Color(0xFF080810);
  static const Color surfaceDark = Color(0xFF10101E);
  static const Color cardDark = Color(0xFF15151F);
  static const Color modalDark = Color(0xFF12121C);

  // ── Gold Spectrum ─────────────────────────────────────────────────────────
  static const Color gold = Color(0xFFD4A017);
  static const Color goldLight = Color(0xFFF5C842);
  static const Color goldDim = Color(0xFF8A6800);
  static const Color amber = Color(0xFFFFB300);

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color coral = Color(0xFFFF5A5A);
  static const Color success = Color(0xFF34D399);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color blue = Color(0xFF3B82F6);

  // ── Social Channel Colors ─────────────────────────────────────────────────
  static const Color whatsapp = Color(0xFF25D366);
  static const Color instagram = Color(0xFFE1306C);
  static const Color facebook = Color(0xFF1877F2);
  static const Color tiktok = Color(0xFFEE1D52);

  // ── Neutrals ─────────────────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFFF0F0F8);
  static const Color textSecondary = Color(0xFF8888AA);
  static const Color textTertiary = Color(0xFF55556A);

  // ── Glass ────────────────────────────────────────────────────────────────
  static const Color glassWhite = Color(0x0DFFFFFF); // 5% white
  static const Color glassMid = Color(0x1AFFFFFF); // 10% white
  static const Color borderWhite = Color(0x14FFFFFF); // 8% white

  // ── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient goldGradient = LinearGradient(
    colors: [gold, goldLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient goldVertical = LinearGradient(
    colors: [goldLight, gold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const RadialGradient amberGlow = RadialGradient(
    colors: [Color(0x33FFB300), Color(0x00000000)],
    radius: 0.7,
  );

  static const LinearGradient darkSurface = LinearGradient(
    colors: [Color(0xFF14141F), Color(0xFF0D0D18)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Loyalty Tiers ─────────────────────────────────────────────────────────
  static const Color bronze = Color(0xFFCD7F32);
  static const Color silver = Color(0xFFC0C0C0);
  // gold already defined above

  // ── Table Status ─────────────────────────────────────────────────────────
  static const Color tableOccupied = Color(0xFFFF5A5A);
  static const Color tableSelected = Color(0xFFD4A017);
  static const Color tableFree = Color(0xFF34D399);
}
