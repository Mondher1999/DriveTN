import 'package:flutter/material.dart';

/// DriveTN — Sunset Tunisia palette.
/// Gradient coral→amber for hero moments. Bright white app surface.
/// Coral accent on near-black ink for body / CTAs.
class AppColors {
  // Hero gradient endpoints
  static const gradientStart = Color(0xFFFF5E3A); // coral
  static const gradientEnd = Color(0xFFFFB800);   // amber

  // Primary identity
  static const accent = Color(0xFFFF5E3A);        // coral — primary accent
  static const accentSecondary = Color(0xFFFFB800); // amber
  static const ink = Color(0xFF1A1A1A);           // near-black

  // Surfaces
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFFAFAFA);
  static const softWarm = Color(0xFFFFF6E5);      // cream highlight card

  // Text
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B6B6B);
  static const textMuted = Color(0xFF9C9C9C);

  // Borders
  static const border = Color(0xFFF0F0F0);
  static const borderStrong = Color(0xFFE5E5E5);

  // Semantic
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);

  // ---- Backwards-compatibility aliases ----
  // Kept so existing screens compile without per-file edits.
  // These map old editorial tokens to closest Sunset equivalents.
  static const primary = ink;                     // was Carthage blue → now ink
  static const primaryDark = ink;
  static const primarySoft = softWarm;
  static const accentSoft = softWarm;             // was warm beige → now cream
  static const surfaceAlt = background;           // was muted card → now bg
  static const successSoft = Color(0xFFE6F9F1);   // mint tint
}
