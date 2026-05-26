import 'package:flutter/material.dart';

/// CETI "Modern Earth & Amethyst" Design Palette
///
/// Deep, rich purples (Aubergine) for primary actions, grounded by
/// warm earthy tones (Terracotta, Sand, Slate) for backgrounds.
/// Glassmorphism used sparingly for depth.
class AppColors {
  AppColors._();

  // ── Backgrounds ──────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF9F8F6); // Warm Slate
  static const Color surface = Color(0xFFFFFFFF);     // Pure White
  static const Color card = Color(0xFFFFFFFF);        // Card Surface
  static const Color modal = Color(0xFFFFFFFF);       // Modal Surface

  // ── Brand Spectrum (Modern Earth & Amethyst) ──────────────────────────────
  static const Color primary = Color(0xFF4A2E80);      // Aubergine (Primary Actions)
  static const Color primaryLight = Color(0xFF5C3D99); // Lighter Aubergine
  static const Color primaryDim = Color(0xFFEDE8F5);   // Very light purple tint
  static const Color accent = Color(0xFF7B5EB6);       // Soft Amethyst

  // ── Secondary (Earthy) ───────────────────────────────────────────────────
  static const Color secondary = Color(0xFFD98A6C);      // Soft Terracotta
  static const Color secondaryLight = Color(0xFFE8A88E); // Light Terracotta

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color coral = Color(0xFFE53935);    // Error / Alert
  static const Color success = Color(0xFF4CAF50);  // Success Green
  static const Color warning = Color(0xFFF9A825);  // Warning Amber
  static const Color purple = Color(0xFF7B5EB6);   // Deep Purple (= Accent)
  static const Color blue = Color(0xFF1E90FF);     // Info Blue

  // ── Social Channel Colors ─────────────────────────────────────────────────
  static const Color whatsapp = Color(0xFF25D366);
  static const Color instagram = Color(0xFFE1306C);
  static const Color facebook = Color(0xFF1877F2);
  static const Color tiktok = Color(0xFF000000);

  // ── Neutrals ─────────────────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E1B24);   // Deep Slate
  static const Color textSecondary = Color(0xFF6E6A75); // Muted Taupe
  static const Color textTertiary = Color(0xFF9E99A5);  // Light Taupe
  static const Color border = Color(0xFFE8E6E1);       // Warm Border
  static const Color borderLight = Color(0xFFF0EEEB);  // Very Light Border

  // ── Soft Effects ─────────────────────────────────────────────────────────
  static const Color glassWhite = Color(0xFFF3F1EE);  // Input background
  static const Color highlight = Color(0x1A4A2E80);   // 10% Primary

  // ── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, Color(0xFF9B82CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkSurface = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF3F1EE)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Table Status ─────────────────────────────────────────────────────────
  static const Color tableOccupied = Color(0xFFE53935);
  static const Color tableSelected = Color(0xFF4A2E80);
  static const Color tableFree = Color(0xFF4CAF50);

  // ── Loyalty Tiers ─────────────────────────────────────────────────────────
  static const Color silver = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD7F32);
  static const Color gold = Color(0xFFFFD700);
}
