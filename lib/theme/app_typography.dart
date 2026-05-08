import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// DriveTN typographic system — Sunset Tunisia.
///
/// One family: Manrope (variable, weights 200–900). No serif.
/// Italic via FontStyle.italic on Manrope's italic axis.
class AppTypography {
  // ---- Hero / display ----
  static TextStyle display({
    double size = 48,
    FontWeight weight = FontWeight.w900,
    Color? color,
    bool italic = false,
    double letterSpacing = -2,
    double height = 0.95,
  }) {
    return GoogleFonts.manrope(
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppColors.ink,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // ---- Page titles ----
  static TextStyle h1({
    double size = 28,
    FontWeight weight = FontWeight.w800,
    Color? color,
    double letterSpacing = -1,
    double height = 1.05,
  }) {
    return GoogleFonts.manrope(
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppColors.ink,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // ---- Section / subtitles ----
  static TextStyle h2({
    double size = 18,
    FontWeight weight = FontWeight.w700,
    Color? color,
    double letterSpacing = -0.4,
    double height = 1.2,
  }) {
    return GoogleFonts.manrope(
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppColors.ink,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // ---- Body / running text ----
  static TextStyle body({
    double size = 14,
    FontWeight weight = FontWeight.w500,
    Color? color,
    double letterSpacing = 0,
    double height = 1.5,
    bool italic = false,
  }) {
    return GoogleFonts.manrope(
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppColors.textPrimary,
      letterSpacing: letterSpacing,
      height: height,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    );
  }

  // ---- Small caps labels ----
  static TextStyle caps({
    double size = 11,
    FontWeight weight = FontWeight.w700,
    Color? color,
    double letterSpacing = 2.5,
  }) {
    return GoogleFonts.manrope(
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppColors.textMuted,
      letterSpacing: letterSpacing,
      height: 1,
    );
  }

  // ---- Numerals (prices, timers) ----
  static TextStyle numeric({
    double size = 32,
    FontWeight weight = FontWeight.w800,
    Color? color,
    bool italic = false,
    double letterSpacing = -1.2,
  }) {
    return GoogleFonts.manrope(
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppColors.accent,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      letterSpacing: letterSpacing,
      height: 1,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  // ---- Backwards-compat aliases (forward to new methods) ----
  /// Deprecated — was Fraunces serif. Now forwards to `body()`.
  /// Kept so existing screens compile during refactor.
  static TextStyle serif({
    double size = 16,
    FontWeight weight = FontWeight.w500,
    Color? color,
    bool italic = false,
    double letterSpacing = -0.2,
    double height = 1.2,
  }) =>
      body(
        size: size,
        weight: weight,
        color: color,
        italic: italic,
        letterSpacing: letterSpacing,
        height: height,
      );

  /// Alias forwarding to `caps(...)`.
  static TextStyle label({
    double size = 11,
    FontWeight weight = FontWeight.w700,
    Color? color,
    double letterSpacing = 2.5,
  }) =>
      caps(
        size: size,
        weight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );
}
