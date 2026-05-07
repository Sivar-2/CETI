import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Backgrounds ──────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF7F8FA); // Soft Light Gray
  static const Color surface = Color(0xFFFFFFFF);    // Pure White
  static const Color card = Color(0xFFFFFFFF);       // Pure White
  static const Color modal = Color(0xFFFFFFFF);      // Pure White

  // ── Brand Spectrum (Vibrant & Addictive) ──────────────────────────────────
  static const Color primary = Color(0xFFFF4757);    // Vibrant Coral Red (Urgency/Appetite)
  static const Color primaryLight = Color(0xFFFF6B81); 
  static const Color primaryDim = Color(0xFFFFEAA7); 
  static const Color accent = Color(0xFF2ED573);     // Vibrant Green
  
  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color coral = Color(0xFFFF4757);      // Error / Alert
  static const Color success = Color(0xFF2ED573);    // Success Green
  static const Color warning = Color(0xFFFFA502);    // Warning Orange
  static const Color purple = Color(0xFF7047EB);     // Deep Purple
  static const Color blue = Color(0xFF1E90FF);       // Dodger Blue

  // ── Social Channel Colors ─────────────────────────────────────────────────
  static const Color whatsapp = Color(0xFF25D366);
  static const Color instagram = Color(0xFFE1306C);
  static const Color facebook = Color(0xFF1877F2);
  static const Color tiktok = Color(0xFF000000);

  // ── Neutrals ─────────────────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2F3542); // Dark Slate
  static const Color textSecondary = Color(0xFF747D8C); // Medium Gray
  static const Color textTertiary = Color(0xFFA4B0BE);  // Light Gray
  static const Color border = Color(0xFFDFE4EA);        // Soft Border

  // ── Soft Effects ─────────────────────────────────────────────────────────
  static const Color glassWhite = Color(0xFFF1F2F6);    // Input background
  static const Color highlight = Color(0x1AFF4757);     // 10% Primary

  // ── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, Color(0xFF7BED9F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkSurface = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF1F2F6)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Table Status ─────────────────────────────────────────────────────────
  static const Color tableOccupied = Color(0xFFFF4757);
  static const Color tableSelected = Color(0xFF7047EB);
  static const Color tableFree = Color(0xFF2ED573);

  // ── Loyalty Tiers ─────────────────────────────────────────────────────────
  static const Color silver = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD7F32);
}
