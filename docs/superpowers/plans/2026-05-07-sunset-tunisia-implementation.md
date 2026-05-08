# Sunset Tunisia Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace DriveTN's Mediterranean Editorial visual system (parchment + Fraunces serif) with Sunset Tunisia (gradient coral→amber + Manrope) across 11 hero screens, with theme inheritance carrying the rest.

**Architecture:** Foundation-first refactor. Layer 1 swaps `AppColors` and `AppTypography` while keeping all existing API method names as aliases — every screen keeps compiling between commits. Layer 2 replaces shared widgets (`PrimaryButton`, `PriceTag`, new `SunsetGradient`, delete `ZelligePattern`). Layer 3 rewrites the 9 hero screens that need explicit gradient/typography treatment. Layer 4 spot-fixes any inheriting screen broken by removed tokens.

**Tech Stack:** Flutter 3.41, Dart 3.11, `google_fonts` (Manrope), `flutter_animate`, `flutter_bloc`, `go_router`. No new dependencies.

**Verification cadence:** No unit tests for visual changes. Each task ends with `flutter analyze` (must report 0 errors) and a commit. Hero screens have a manual visual checkpoint before commit.

---

## Pre-flight inventory (already gathered)

The codebase currently references these `AppColors` tokens (every one must keep resolving after Task 1):
`accent, accentSoft, background, border, borderStrong, danger, ink, primary, success, successSoft, surface, surfaceAlt, textMuted, textPrimary, textSecondary, warning, zellige`.

`AppTypography.serif(...)` is called from 16 files. Plan keeps it as a thin alias to avoid touching every file.

`ZelligePattern` is referenced in: `splash_screen.dart`, `login_screen.dart`, `bluetooth_unlock_screen.dart`, `bluetooth_lock_screen.dart`, `return_success_screen.dart`, `booking_success_screen.dart`. Each is rewritten in Layer 3 and the import is removed there; the file is finally deleted in Task 18.

---

## Task 1: Foundation — Rewrite AppColors

**Files:**
- Modify: `lib/theme/app_colors.dart` (full rewrite)

- [ ] **Step 1: Replace the entire contents of `lib/theme/app_colors.dart` with:**

```dart
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
  static const zellige = accent;                  // any leftover ZelligePattern arg
}
```

- [ ] **Step 2: Run `flutter analyze` from project root.**

```powershell
cd "C:\Users\Mondh\Desktop\Dossie squellte Web-Mobile\DriveTN"; flutter analyze
```

Expected: 0 errors, 0 warnings. (Some `prefer_const` infos OK.)

- [ ] **Step 3: Commit.**

```bash
git add lib/theme/app_colors.dart && git commit -m "feat(theme): swap palette to Sunset Tunisia (coral + amber + ink)"
```

If the project isn't a git repo yet, run `git init && git add . && git commit -m "chore: snapshot before sunset refactor"` once at the very start, then continue normally.

---

## Task 2: Foundation — Rewrite AppTypography

**Files:**
- Modify: `lib/theme/app_typography.dart` (full rewrite)

- [ ] **Step 1: Replace the entire contents of `lib/theme/app_typography.dart` with:**

```dart
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
```

- [ ] **Step 2: Run `flutter analyze`.**

Expected: 0 errors. Existing `serif(...)` and `label(...)` call sites resolve via aliases.

- [ ] **Step 3: Commit.**

```bash
git add lib/theme/app_typography.dart && git commit -m "feat(theme): switch typography to Manrope (one family, no serif)"
```

---

## Task 3: Foundation — Update AppTheme

**Files:**
- Modify: `lib/theme/app_theme.dart` (full rewrite)

- [ ] **Step 1: Replace the entire contents of `lib/theme/app_theme.dart` with:**

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.ink,
        onPrimary: AppColors.surface,
        secondary: AppColors.accent,
        onSecondary: AppColors.surface,
        surface: AppColors.surface,
        onSurface: AppColors.ink,
        error: AppColors.danger,
      ),
      textTheme: GoogleFonts.manropeTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.ink,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        titleTextStyle: AppTypography.h2(size: 17, weight: FontWeight.w700),
        iconTheme: const IconThemeData(color: AppColors.ink, size: 22),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.surface,
          minimumSize: const Size.fromHeight(56),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: AppTypography.body(
            size: 14,
            weight: FontWeight.w700,
            color: AppColors.surface,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          minimumSize: const Size.fromHeight(54),
          side: const BorderSide(color: AppColors.borderStrong, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: AppTypography.body(size: 14, weight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.ink,
          textStyle: AppTypography.body(size: 14, weight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: AppTypography.body(size: 14, color: AppColors.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.ink,
        unselectedItemColor: AppColors.textMuted,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTypography.caps(
            size: 10, letterSpacing: 1.2, color: AppColors.ink),
        unselectedLabelStyle: AppTypography.caps(
            size: 10, letterSpacing: 1.2, color: AppColors.textMuted),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: AppTypography.body(
            size: 13, color: AppColors.surface, weight: FontWeight.w500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.ink,
        side: const BorderSide(color: AppColors.border),
        labelStyle: AppTypography.body(size: 13, weight: FontWeight.w500),
        secondaryLabelStyle: AppTypography.body(
            size: 13, color: AppColors.surface, weight: FontWeight.w500),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.accent,
        inactiveTrackColor: AppColors.border,
        thumbColor: AppColors.ink,
        overlayColor: AppColors.accent.withValues(alpha: 0.12),
        valueIndicatorColor: AppColors.ink,
        valueIndicatorTextStyle:
            AppTypography.body(size: 12, color: AppColors.surface),
        trackHeight: 3,
      ),
    );
  }
}
```

- [ ] **Step 2: Run `flutter analyze`.**

Expected: 0 errors.

- [ ] **Step 3: Visual smoke check.**

Run `flutter run` on emulator/device. Walk: splash (still old) → login (still old) → home → any screen. App should open without crash. Material widgets (snackbars, dialogs, buttons) should now use Manrope; coral should appear on focus borders, slider, etc.

- [ ] **Step 4: Commit.**

```bash
git add lib/theme/app_theme.dart && git commit -m "feat(theme): wire ThemeData to Sunset palette + Manrope"
```

---

## Task 4: New shared widget — SunsetGradient

**Files:**
- Create: `lib/shared/widgets/sunset_gradient.dart`

- [ ] **Step 1: Create `lib/shared/widgets/sunset_gradient.dart` with:**

```dart
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// The signature DriveTN hero gradient: coral → amber, 135°.
/// Wraps a child with the gradient as a background.
/// Optional radial glow overlay (top-right) adds depth.
class SunsetGradient extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final bool radialGlow;
  final double? height;

  const SunsetGradient({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.radialGlow = true,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
      ),
      clipBehavior:
          borderRadius == null ? Clip.none : Clip.antiAlias,
      child: radialGlow
          ? Stack(
              fit: StackFit.passthrough,
              children: [
                Positioned(
                  top: -60,
                  right: -40,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.25),
                          Colors.white.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
                child,
              ],
            )
          : child,
    );
  }
}
```

- [ ] **Step 2: Run `flutter analyze`.**

Expected: 0 errors.

- [ ] **Step 3: Commit.**

```bash
git add lib/shared/widgets/sunset_gradient.dart && git commit -m "feat(widget): add SunsetGradient hero widget"
```

---

## Task 5: Rewrite PrimaryButton with gradient variant

**Files:**
- Modify: `lib/shared/widgets/primary_button.dart` (full rewrite)

- [ ] **Step 1: Replace the entire contents of `lib/shared/widgets/primary_button.dart` with:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

enum ButtonVariant { ink, light, ghost, gradient, accent }

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final ButtonVariant variant;
  final Color? color;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
    this.variant = ButtonVariant.ink,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = loading || onPressed == null;

    Color? bg;
    Gradient? gradient;
    Color fg;
    Color borderColor;
    switch (variant) {
      case ButtonVariant.ink:
        bg = color ?? AppColors.ink;
        fg = AppColors.surface;
        borderColor = bg;
        break;
      case ButtonVariant.accent:
        bg = AppColors.accent;
        fg = AppColors.surface;
        borderColor = bg;
        break;
      case ButtonVariant.light:
        bg = AppColors.surface;
        fg = AppColors.ink;
        borderColor = AppColors.borderStrong;
        break;
      case ButtonVariant.ghost:
        bg = Colors.transparent;
        fg = AppColors.ink;
        borderColor = Colors.transparent;
        break;
      case ButtonVariant.gradient:
        gradient = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        );
        fg = AppColors.surface;
        borderColor = Colors.transparent;
        bg = null;
        break;
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: AnimatedOpacity(
        opacity: disabled ? 0.55 : 1,
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: disabled ? AppColors.borderStrong : bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: BorderSide(
              color: disabled ? AppColors.border : borderColor,
              width: 1,
            ),
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: disabled ? null : gradient,
              borderRadius: BorderRadius.circular(999),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: disabled
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      onPressed!();
                    },
              child: Center(
                child: loading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(fg),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            style: AppTypography.body(
                              size: 15,
                              weight: FontWeight.w700,
                              color: fg,
                              letterSpacing: 0.2,
                            ),
                          ),
                          if (icon != null) ...[
                            const SizedBox(width: 10),
                            Icon(icon, size: 18, color: fg),
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Run `flutter analyze`.**

Expected: 0 errors.

- [ ] **Step 3: Commit.**

```bash
git add lib/shared/widgets/primary_button.dart && git commit -m "feat(widget): PrimaryButton with gradient + accent variants"
```

---

## Task 6: Rewrite PriceTag — coral Manrope punch

**Files:**
- Modify: `lib/shared/widgets/price_tag.dart` (full rewrite)

- [ ] **Step 1: Replace the entire contents of `lib/shared/widgets/price_tag.dart` with:**

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Coral Manrope 800 numerals with subtle "DT / jour" tail.
class PriceTag extends StatelessWidget {
  final double price;
  final bool perDay;
  final double size;
  final Color? color;

  const PriceTag({
    super.key,
    required this.price,
    this.perDay = true,
    this.size = 28,
    this.color,
  });

  static String _num(double v) =>
      NumberFormat('#,##0', 'fr_FR').format(v);

  /// "1,200 DT" — kept for backward compat with existing call sites.
  static String format(double v) => '${_num(v)} DT';

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.accent;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          _num(price),
          style: AppTypography.numeric(
            size: size,
            weight: FontWeight.w800,
            color: c,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          perDay ? 'DT / jour' : 'DT',
          style: AppTypography.body(
            size: size * 0.4,
            weight: FontWeight.w600,
            color: c.withValues(alpha: 0.65),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Run `flutter analyze`.**

Expected: 0 errors.

- [ ] **Step 3: Commit.**

```bash
git add lib/shared/widgets/price_tag.dart && git commit -m "feat(widget): PriceTag coral Manrope punch"
```

---

## Task 7: Rewrite Splash — gradient + typewriter logo

**Files:**
- Modify: `lib/features/splash/view/splash_screen.dart` (full rewrite)

- [ ] **Step 1: Replace the entire contents of `lib/features/splash/view/splash_screen.dart` with:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/sunset_gradient.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) context.go('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SunsetGradient(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DRIVETN  ·  TUNIS  ·  2026',
                  style: AppTypography.caps(
                    size: 10,
                    color: AppColors.surface.withValues(alpha: 0.7),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 200.ms),
                const Spacer(),
                Text(
                  'Drive,',
                  style: AppTypography.display(
                    size: 64,
                    weight: FontWeight.w900,
                    color: AppColors.surface,
                    letterSpacing: -2.4,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 300.ms)
                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
                Text(
                  'differently.',
                  style: AppTypography.display(
                    size: 64,
                    weight: FontWeight.w300,
                    italic: true,
                    color: AppColors.surface.withValues(alpha: 0.92),
                    letterSpacing: -2.4,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 600.ms)
                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
                const SizedBox(height: 24),
                Container(
                  width: 36,
                  height: 2,
                  color: AppColors.surface.withValues(alpha: 0.6),
                )
                    .animate()
                    .scaleX(
                      begin: 0,
                      end: 1,
                      delay: 900.ms,
                      duration: 500.ms,
                      alignment: Alignment.centerLeft,
                    ),
                const SizedBox(height: 16),
                Text(
                  'La voiture, sans friction.',
                  style: AppTypography.body(
                    size: 14,
                    color: AppColors.surface.withValues(alpha: 0.85),
                    weight: FontWeight.w500,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 1100.ms, duration: 500.ms),
                const Spacer(),
                Text(
                  'CARTHAGE  ·  LA MARSA  ·  LAC  ·  ARIANA',
                  style: AppTypography.caps(
                    size: 9,
                    letterSpacing: 3,
                    color: AppColors.surface.withValues(alpha: 0.5),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 1400.ms, duration: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: `flutter analyze`. Expected: 0 errors.**

- [ ] **Step 3: Visual check.**

Run app. Splash should now be coral→amber gradient full-bleed with white "Drive, *differently.*" + caps tagline + bottom city list. After ~2.2s redirect to login.

- [ ] **Step 4: Commit.**

```bash
git add lib/features/splash/view/splash_screen.dart && git commit -m "feat(splash): Sunset gradient + Manrope display reveal"
```

---

## Task 8: Rewrite Login — gradient hero card

**Files:**
- Modify: `lib/features/auth/view/login_screen.dart` (full rewrite)

- [ ] **Step 1: Replace contents with:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/sunset_gradient.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: SunsetGradient(
                  borderRadius: BorderRadius.circular(28),
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '— 01',
                            style: AppTypography.caps(
                              size: 10,
                              letterSpacing: 3,
                              color: AppColors.surface,
                            ),
                          ),
                          Text(
                            'TUNIS · 2026',
                            style: AppTypography.caps(
                              size: 9,
                              letterSpacing: 2.4,
                              color: AppColors.surface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        'Drive,',
                        style: AppTypography.display(
                          size: 56,
                          color: AppColors.surface,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .slideY(begin: 0.1, end: 0),
                      Text(
                        'differently.',
                        style: AppTypography.display(
                          size: 56,
                          weight: FontWeight.w300,
                          italic: true,
                          color: AppColors.surface
                              .withValues(alpha: 0.95),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 200.ms)
                          .slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 24),
                      Container(
                        width: 36,
                        height: 1,
                        color: AppColors.surface
                            .withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 280,
                        child: Text(
                          'La marketplace tunisienne pour louer, '
                          'conduire, et profiter — sans friction.',
                          style: AppTypography.body(
                            size: 15,
                            weight: FontWeight.w500,
                            color: AppColors.surface
                                .withValues(alpha: 0.92),
                            height: 1.5,
                          ),
                        ),
                      ).animate().fadeIn(delay: 500.ms),
                      const Spacer(),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'DriveTN',
                            style: AppTypography.h2(
                              size: 18,
                              weight: FontWeight.w800,
                              color: AppColors.surface,
                            ),
                          ),
                          Text(
                            '↗',
                            style: AppTypography.display(
                              size: 22,
                              color: AppColors.surface,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'BIENVENUE',
                      style: AppTypography.caps(
                        size: 10,
                        letterSpacing: 3,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Prêt à prendre la route ?',
                      style: AppTypography.h1(
                        size: 22,
                        weight: FontWeight.w800,
                      ),
                    ).animate().fadeIn(delay: 700.ms),
                    const Spacer(),
                    PrimaryButton(
                      label: 'Continuer en démo',
                      icon: LucideIcons.arrowRight,
                      variant: ButtonVariant.gradient,
                      onPressed: () => context.go('/home/explorer'),
                    )
                        .animate()
                        .fadeIn(delay: 800.ms)
                        .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 14),
                    Center(
                      child: Text(
                        'Mode démonstration · aucun compte requis',
                        style: AppTypography.body(
                          size: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: `flutter analyze`. Expected: 0 errors.**

- [ ] **Step 3: Visual check.** Splash → Login. Hero card should be gradient with white "Drive, *differently.*". Bottom action panel white with gradient CTA.

- [ ] **Step 4: Commit.**

```bash
git add lib/features/auth/view/login_screen.dart && git commit -m "feat(login): gradient hero card + gradient CTA"
```

---

## Task 9: Rewrite BookingSuccess — gradient circle + irradiating

**Files:**
- Modify: `lib/features/booking/view/booking_success_screen.dart` (full rewrite)

- [ ] **Step 1: Replace contents with:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../data/mock_data.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../bloc/booking_cubit.dart';
import '../bloc/booking_state.dart';

class BookingSuccessScreen extends StatelessWidget {
  final String carId;
  const BookingSuccessScreen({super.key, required this.carId});

  String _fmt(DateTime d) => DateFormat('d MMM', 'fr_FR').format(d);

  @override
  Widget build(BuildContext context) {
    final state = context.read<BookingCubit>().state;
    final booking = state.confirmedBooking ??
        (MockData.bookings.isNotEmpty ? MockData.bookings.last : null);
    final car = booking != null ? MockData.carById(booking.carId) : null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/home/rentals');
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Center(
                  child: SizedBox(
                    width: 180,
                    height: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ..._irradiate(),
                        Container(
                          width: 96,
                          height: 96,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.gradientStart,
                                AppColors.gradientEnd,
                              ],
                            ),
                          ),
                          child: const Icon(
                            LucideIcons.check,
                            color: AppColors.surface,
                            size: 48,
                          ),
                        )
                            .animate()
                            .scale(
                              begin: const Offset(0.4, 0.4),
                              end: const Offset(1, 1),
                              curve: Curves.easeOutBack,
                              duration: 600.ms,
                            ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    '— RÉSERVATION CONFIRMÉE',
                    style: AppTypography.caps(
                      size: 10,
                      letterSpacing: 3,
                      color: AppColors.accent,
                    ),
                  ).animate().fadeIn(delay: 600.ms),
                ),
                const SizedBox(height: 14),
                Center(
                  child: Text(
                    "C'est parti.",
                    style: AppTypography.display(size: 40),
                  ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1, end: 0),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    car == null
                        ? 'Votre véhicule vous attend.'
                        : 'Votre ${car.brand} ${car.model} vous attend.',
                    style: AppTypography.body(
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fadeIn(delay: 800.ms),
                ),
                const SizedBox(height: 28),
                if (booking != null && car != null)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _row('VÉHICULE', '${car.brand} ${car.model}'),
                        _divider(),
                        _row('DATES',
                            '${_fmt(booking.startDate)} → ${_fmt(booking.endDate)}'),
                        _divider(),
                        _row(
                          'RÉFÉRENCE',
                          'DT-${booking.id.toUpperCase().substring(0, booking.id.length > 6 ? 6 : booking.id.length)}',
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 900.ms),
                const Spacer(),
                if (booking != null)
                  PrimaryButton(
                    label: "Démarrer l'inspection",
                    icon: LucideIcons.video,
                    variant: ButtonVariant.gradient,
                    onPressed: () =>
                        context.push('/inspection/pickup/${booking.id}'),
                  ).animate().fadeIn(delay: 1100.ms),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/home/rentals'),
                  child: Text(
                    'Plus tard',
                    style: AppTypography.body(
                      size: 14,
                      color: AppColors.textMuted,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: AppTypography.caps(size: 10, color: AppColors.textMuted)),
          ),
          Text(value, style: AppTypography.body(size: 14, weight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _divider() => Container(height: 1, color: AppColors.border);

  List<Widget> _irradiate() {
    return List.generate(3, (i) {
      final delay = (i * 280).ms;
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
      )
          .animate(onPlay: (c) => c.repeat())
          .scale(
            begin: const Offset(0.5, 0.5),
            end: const Offset(1.6, 1.6),
            duration: 1800.ms,
            delay: delay,
            curve: Curves.easeOut,
          )
          .fadeOut(duration: 1800.ms, delay: delay);
    });
  }
}
```

- [ ] **Step 2: `flutter analyze`. Expected: 0 errors.**

- [ ] **Step 3: Visual check.** Run flow Login → Home → pick a car → reserve → pay → land on success. Should see gradient check + 3 expanding coral rings + récap card + gradient CTA.

- [ ] **Step 4: Commit.**

```bash
git add lib/features/booking/view/booking_success_screen.dart && git commit -m "feat(booking): success with gradient check + irradiating rings"
```

---

## Task 10: Rewrite ReturnSuccess — same pattern

**Files:**
- Modify: `lib/features/return/view/return_success_screen.dart` (full rewrite)

- [ ] **Step 1: Replace contents with:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../data/mock_data.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class ReturnSuccessScreen extends StatefulWidget {
  final String bookingId;
  const ReturnSuccessScreen({super.key, required this.bookingId});

  @override
  State<ReturnSuccessScreen> createState() =>
      _ReturnSuccessScreenState();
}

class _ReturnSuccessScreenState extends State<ReturnSuccessScreen> {
  int _rating = 0;
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final booking = MockData.bookingById(widget.bookingId);
    final car = booking != null ? MockData.carById(booking.carId) : null;
    final days = booking?.durationDays ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 8),
            Center(
              child: SizedBox(
                width: 180,
                height: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ..._irradiate(),
                    Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.gradientStart,
                            AppColors.gradientEnd,
                          ],
                        ),
                      ),
                      child: const Icon(LucideIcons.check,
                          color: AppColors.surface, size: 48),
                    )
                        .animate()
                        .scale(
                          begin: const Offset(0.4, 0.4),
                          end: const Offset(1, 1),
                          curve: Curves.easeOutBack,
                          duration: 600.ms,
                        ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Text(
                '— LOCATION TERMINÉE',
                style: AppTypography.caps(
                  size: 10,
                  letterSpacing: 3,
                  color: AppColors.accent,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: Text('Bonne route.',
                  style: AppTypography.display(size: 40)),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                car == null
                    ? 'Merci pour votre voyage.'
                    : 'Merci pour votre voyage avec la ${car.model}.',
                style: AppTypography.body(
                    size: 14, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _row('DURÉE TOTALE',
                      '$days jour${days > 1 ? 's' : ''}'),
                  _divider(),
                  _row('KM PARCOURUS', '142'),
                  _divider(),
                  _stateRow(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '— VOTRE EXPÉRIENCE',
                    style: AppTypography.caps(
                      size: 10,
                      letterSpacing: 3,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Comment s'est passée la course ?",
                    style: AppTypography.h2(size: 18),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      for (int i = 1; i <= 5; i++)
                        GestureDetector(
                          onTap: () => setState(() => _rating = i),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(
                              i <= _rating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 38,
                              color: i <= _rating
                                  ? AppColors.accent
                                  : AppColors.borderStrong,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _commentCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Un mot à laisser ?',
                    ),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Envoyer',
                    variant: ButtonVariant.light,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Merci pour votre avis')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: "Retour à l'accueil",
              icon: LucideIcons.arrowRight,
              variant: ButtonVariant.gradient,
              onPressed: () => context.go('/home/explorer'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: AppTypography.caps(size: 10, color: AppColors.textMuted)),
          ),
          Text(value, style: AppTypography.body(size: 14, weight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _stateRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text('ÉTAT',
                style: AppTypography.caps(size: 10, color: AppColors.textMuted)),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text('Aucun dégât détecté',
              style: AppTypography.body(
                  size: 14,
                  weight: FontWeight.w700,
                  color: AppColors.success)),
        ],
      ),
    );
  }

  Widget _divider() => Container(height: 1, color: AppColors.border);

  List<Widget> _irradiate() {
    return List.generate(3, (i) {
      final delay = (i * 280).ms;
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
      )
          .animate(onPlay: (c) => c.repeat())
          .scale(
            begin: const Offset(0.5, 0.5),
            end: const Offset(1.6, 1.6),
            duration: 1800.ms,
            delay: delay,
            curve: Curves.easeOut,
          )
          .fadeOut(duration: 1800.ms, delay: delay);
    });
  }
}
```

- [ ] **Step 2: `flutter analyze`. Expected: 0 errors.**

- [ ] **Step 3: Commit.**

```bash
git add lib/features/return/view/return_success_screen.dart && git commit -m "feat(return): success with gradient check + irradiating rings"
```

---

## Task 11: Rewrite BluetoothUnlock — gradient bg

**Files:**
- Modify: `lib/features/unlock/view/bluetooth_unlock_screen.dart` (full rewrite)

- [ ] **Step 1: Replace contents with:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/sunset_gradient.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class BluetoothUnlockScreen extends StatefulWidget {
  final String bookingId;
  const BluetoothUnlockScreen({super.key, required this.bookingId});

  @override
  State<BluetoothUnlockScreen> createState() =>
      _BluetoothUnlockScreenState();
}

class _BluetoothUnlockScreenState extends State<BluetoothUnlockScreen> {
  int _step = 0;
  static const _labels = [
    'Recherche du véhicule',
    'Véhicule détecté',
    'Connexion établie',
    'Déverrouillage',
    'Voiture déverrouillée',
  ];

  @override
  void initState() {
    super.initState();
    _runSequence();
  }

  Future<void> _runSequence() async {
    for (var i = 1; i < _labels.length; i++) {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      setState(() => _step = i);
      if (i == _labels.length - 1) HapticFeedback.heavyImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDone = _step == _labels.length - 1;
    return Scaffold(
      body: SunsetGradient(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '— DÉVERROUILLAGE',
                      style: AppTypography.caps(
                        size: 10,
                        letterSpacing: 3,
                        color: AppColors.surface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      '${_step + 1} / ${_labels.length}',
                      style: AppTypography.caps(
                        size: 10,
                        letterSpacing: 2,
                        color: AppColors.surface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 240,
                          height: 240,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (!isDone) ..._pulses(),
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: AppColors.surface
                                      .withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.surface
                                        .withValues(alpha: 0.35),
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  isDone
                                      ? LucideIcons.unlock
                                      : LucideIcons.bluetooth,
                                  size: 48,
                                  color: AppColors.surface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          child: Text(
                            _labels[_step],
                            key: ValueKey(_step),
                            style: AppTypography.display(
                              size: 28,
                              weight: FontWeight.w800,
                              color: AppColors.surface,
                              letterSpacing: -1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isDone)
                  PrimaryButton(
                    label: 'Entrer dans la voiture',
                    icon: LucideIcons.arrowRight,
                    variant: ButtonVariant.light,
                    onPressed: () =>
                        context.go('/rental/${widget.bookingId}'),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .slideY(begin: 0.2, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _pulses() {
    return [240, 180, 130].asMap().entries.map((e) {
      final size = e.value.toDouble();
      final delay = (e.key * 400).ms;
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
      )
          .animate(onPlay: (c) => c.repeat())
          .scale(
            begin: const Offset(0.7, 0.7),
            end: const Offset(1.2, 1.2),
            duration: 1500.ms,
            delay: delay,
            curve: Curves.easeOut,
          )
          .fadeOut(duration: 1500.ms, delay: delay);
    }).toList();
  }
}
```

- [ ] **Step 2: `flutter analyze`. Expected: 0 errors.**

- [ ] **Step 3: Commit.**

```bash
git add lib/features/unlock/view/bluetooth_unlock_screen.dart && git commit -m "feat(unlock): bluetooth unlock on Sunset gradient"
```

---

## Task 12: Rewrite BluetoothLock — same pattern reversed

**Files:**
- Modify: `lib/features/unlock/view/bluetooth_lock_screen.dart` (full rewrite)

- [ ] **Step 1: Replace contents with:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/sunset_gradient.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class BluetoothLockScreen extends StatefulWidget {
  final String bookingId;
  const BluetoothLockScreen({super.key, required this.bookingId});

  @override
  State<BluetoothLockScreen> createState() =>
      _BluetoothLockScreenState();
}

class _BluetoothLockScreenState extends State<BluetoothLockScreen> {
  int _step = 0;
  static const _labels = [
    'Connexion au véhicule',
    'Verrouillage en cours',
    'Voiture verrouillée',
  ];

  @override
  void initState() {
    super.initState();
    _runSequence();
  }

  Future<void> _runSequence() async {
    for (var i = 1; i < _labels.length; i++) {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      setState(() => _step = i);
      if (i == _labels.length - 1) HapticFeedback.heavyImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDone = _step == _labels.length - 1;
    return Scaffold(
      body: SunsetGradient(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '— RESTITUTION',
                      style: AppTypography.caps(
                        size: 10,
                        letterSpacing: 3,
                        color: AppColors.surface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      '${_step + 1} / ${_labels.length}',
                      style: AppTypography.caps(
                        size: 10,
                        letterSpacing: 2,
                        color: AppColors.surface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 240,
                          height: 240,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (!isDone) ..._pulses(),
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: AppColors.surface
                                      .withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.surface
                                        .withValues(alpha: 0.35),
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  isDone
                                      ? LucideIcons.lock
                                      : LucideIcons.bluetooth,
                                  size: 48,
                                  color: AppColors.surface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          child: Text(
                            _labels[_step],
                            key: ValueKey(_step),
                            style: AppTypography.display(
                              size: 28,
                              weight: FontWeight.w800,
                              color: AppColors.surface,
                              letterSpacing: -1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isDone)
                  PrimaryButton(
                    label: 'Voir le récapitulatif',
                    icon: LucideIcons.arrowRight,
                    variant: ButtonVariant.light,
                    onPressed: () => context
                        .go('/return/success/${widget.bookingId}'),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .slideY(begin: 0.2, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _pulses() {
    return [240, 180, 130].asMap().entries.map((e) {
      final size = e.value.toDouble();
      final delay = (e.key * 400).ms;
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
      )
          .animate(onPlay: (c) => c.repeat())
          .scale(
            begin: const Offset(0.7, 0.7),
            end: const Offset(1.2, 1.2),
            duration: 1500.ms,
            delay: delay,
            curve: Curves.easeOut,
          )
          .fadeOut(duration: 1500.ms, delay: delay);
    }).toList();
  }
}
```

- [ ] **Step 2: `flutter analyze`. Expected: 0 errors.**

- [ ] **Step 3: Commit.**

```bash
git add lib/features/unlock/view/bluetooth_lock_screen.dart && git commit -m "feat(lock): bluetooth lock on Sunset gradient"
```

---

## Task 13: Rewrite CarCard — coral price punch

**Files:**
- Modify: `lib/features/home/view/car_card.dart` (full rewrite)

- [ ] **Step 1: Replace contents with:**

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../data/models/car.dart';
import '../../../shared/widgets/price_tag.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class CarCard extends StatelessWidget {
  final Car car;
  final VoidCallback onTap;
  final bool selected;
  final double distanceKm;

  const CarCard({
    super.key,
    required this.car,
    required this.onTap,
    this.selected = false,
    this.distanceKm = 2.4,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 270,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFFFE4D6),
                              Color(0xFFFFF1B8),
                            ],
                          ),
                        ),
                      ),
                      CachedNetworkImage(
                        imageUrl: car.photoUrls.first,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const SizedBox.shrink(),
                        errorWidget: (_, __, ___) => const Center(
                          child: Icon(LucideIcons.car,
                              size: 40, color: AppColors.textMuted),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 12, color: AppColors.accent),
                              const SizedBox(width: 2),
                              Text(
                                car.rating.toStringAsFixed(1),
                                style: AppTypography.body(
                                    size: 11, weight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                car.brand.toUpperCase(),
                style: AppTypography.caps(
                  size: 9,
                  letterSpacing: 1.6,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                car.model,
                style: AppTypography.h2(
                    size: 18, weight: FontWeight.w800),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${car.categoryLabel} · ${car.transmissionLabel} · ${car.fuelLabel}',
                style: AppTypography.body(
                    size: 11, color: AppColors.textMuted),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Container(height: 1, color: AppColors.border),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PriceTag(price: car.dailyPrice, size: 22),
                  const Spacer(),
                  Icon(LucideIcons.mapPin,
                      size: 11, color: AppColors.textMuted),
                  const SizedBox(width: 3),
                  Text(
                    '${distanceKm.toStringAsFixed(1)} km',
                    style: AppTypography.body(
                      size: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: `flutter analyze`. Expected: 0 errors.**

- [ ] **Step 3: Commit.**

```bash
git add lib/features/home/view/car_card.dart && git commit -m "feat(carcard): coral PriceTag + warm gradient placeholder"
```

---

## Task 14: Update HomeScreen — search bar + filter button restyle

**Files:**
- Modify: `lib/features/home/view/home_screen.dart`

This is a targeted edit, not a full rewrite, because the map / sheet layout from the previous editorial version is still good — only the surface chrome (search pill, filter button, header label) changes color tokens and copy.

- [ ] **Step 1: Read the current file.**

```bash
cat "lib/features/home/view/home_screen.dart"
```

- [ ] **Step 2: Locate the top overlay pill (the "EXPLORER · TUNIS / Trouvez votre voiture" pill).**

In the existing file, find the Container that wraps the column with the small caps label "EXPLORER · TUNIS" and the title "Trouvez votre voiture". Replace its child column with:

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  mainAxisSize: MainAxisSize.min,
  children: [
    Text(
      'BONJOUR',
      style: AppTypography.caps(
        size: 9,
        letterSpacing: 2.4,
        color: AppColors.textMuted,
      ),
    ),
    const SizedBox(height: 2),
    Text(
      'Trouvons la bonne.',
      style: AppTypography.h1(size: 18, weight: FontWeight.w800),
    ),
  ],
),
```

- [ ] **Step 3: Replace the filter button.**

Find the filter button (square 52×52, ink background, `LucideIcons.slidersHorizontal`). Replace its decoration block with:

```dart
decoration: const BoxDecoration(
  shape: BoxShape.circle,
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.gradientStart, AppColors.gradientEnd],
  ),
),
```

Keep the icon and tap behavior. The icon color should be `AppColors.surface`.

- [ ] **Step 4: Replace map markers.**

Find the `MarkerLayer` in the FlutterMap. Replace each marker child with:

```dart
Container(
  width: 32,
  height: 32,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: selected ? AppColors.accent : AppColors.ink,
    border: Border.all(color: AppColors.surface, width: 2),
  ),
  child: const Icon(
    LucideIcons.car,
    color: AppColors.surface,
    size: 14,
  ),
),
```

Where `selected` is the existing boolean already in scope (compare to `state.selectedCarId == car.id`).

- [ ] **Step 5: Update sheet header.**

Find the bottom DraggableScrollableSheet header (currently with "EN CE MOMENT" label + count). Replace the label and title with:

```dart
Text(
  '— EN CE MOMENT',
  style: AppTypography.caps(
    size: 10,
    letterSpacing: 2.4,
    color: AppColors.textMuted,
  ),
),
const SizedBox(height: 4),
Text(
  '${state.filteredCars.length} voitures à proximité',
  style: AppTypography.h1(size: 22, weight: FontWeight.w800),
),
```

- [ ] **Step 6: `flutter analyze`. Expected: 0 errors.**

- [ ] **Step 7: Visual check.** Login → Home. Top pill should show "BONJOUR / Trouvons la bonne." Filter button should be a coral→amber gradient circle. Map pins ink with white ring; selected pin coral.

- [ ] **Step 8: Commit.**

```bash
git add lib/features/home/view/home_screen.dart && git commit -m "feat(home): gradient filter button + Sunset chrome"
```

---

## Task 15: Update CarDetailScreen — gradient placeholder + coral CTA

**Files:**
- Modify: `lib/features/car_detail/view/car_detail_screen.dart`

- [ ] **Step 1: Read the current file.**

```bash
cat "lib/features/car_detail/view/car_detail_screen.dart"
```

- [ ] **Step 2: Add a coral-amber gradient behind the photo PageView.**

Find the PageView (or PhotoView) inside the SliverAppBar's `FlexibleSpaceBar`. Wrap each `CachedNetworkImage` with a `Stack` that has a gradient backdrop:

```dart
Stack(
  fit: StackFit.expand,
  children: [
    Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE4D6), Color(0xFFFFF1B8)],
        ),
      ),
    ),
    CachedNetworkImage(
      imageUrl: photoUrl,
      fit: BoxFit.cover,
      // existing placeholder/errorWidget
    ),
  ],
),
```

- [ ] **Step 3: Update bottom Reserve CTA.**

Find the `PrimaryButton(label: 'Réserver', ...)` at the bottom of the screen. Change its variant to `ButtonVariant.gradient`:

```dart
PrimaryButton(
  label: 'Réserver',
  icon: LucideIcons.arrowRight,
  variant: ButtonVariant.gradient,
  onPressed: () => context.push('/booking/${car.id}'),
),
```

- [ ] **Step 4: Update agency avatar.**

Find the agency Row's CircleAvatar (or Container) with `AppColors.primary` background. The bg now resolves to ink — keep it. Verify the icon is `AppColors.surface` (was: `Colors.white`). If it's still hardcoded `Colors.white`, replace with `AppColors.surface`.

- [ ] **Step 5: `flutter analyze`. Expected: 0 errors.**

- [ ] **Step 6: Visual check.** Tap a car on the home screen → CarDetail. Photo area should have a soft warm gradient behind images. Reserve button should be the full Sunset gradient.

- [ ] **Step 7: Commit.**

```bash
git add lib/features/car_detail/view/car_detail_screen.dart && git commit -m "feat(detail): warm gradient backdrop + Sunset CTA"
```

---

## Task 16: Spot-fix inheriting screens for new tokens

**Files:**
- Touch as needed: `lib/features/booking/view/booking_screen.dart`, `lib/features/booking/view/payment_screen.dart`, `lib/features/inspection/view/video_360_screen.dart`, `lib/features/rental/view/active_rental_screen.dart`, `lib/features/my_rentals/view/my_rentals_screen.dart`, `lib/features/profile/view/profile_screen.dart`, `lib/features/home/view/filter_sheet.dart`

These should mostly look fine after the foundation swap. Spot-fix only what's visibly broken.

- [ ] **Step 1: Run `flutter run` and walk the demo flow:**

Splash → Login → Home → tap car → CarDetail → Réserver → Booking dates → Payment → Pay → Success → Démarrer inspection → Video 360 (use Simuler la vidéo button) → Bluetooth Unlock → Active rental → Terminer → Inspection retour → Bluetooth Lock → Return success → Retour à l'accueil → Mes locations → Profil.

- [ ] **Step 2: For each screen that has a primary CTA at the bottom**, change its `PrimaryButton` variant to `ButtonVariant.gradient` to match the new wow language. Specifically:
  - `payment_screen.dart` — "Payer" CTA → `variant: ButtonVariant.gradient`
  - `booking_screen.dart` — "Continuer" CTA → keep `ButtonVariant.ink` (gradient is reserved for terminal/positive moments)
  - `active_rental_screen.dart` — "Terminer la location" CTA → `variant: ButtonVariant.gradient`

- [ ] **Step 3: For each screen showing a price**, ensure `PriceTag` resolves to coral. Default color is now `AppColors.accent` so most call sites need no change. If a screen passes an explicit `color:` argument that was `AppColors.ink`, remove the override unless the price is on a colored hero (then explicit white is correct).

- [ ] **Step 4: Replace any leftover hardcoded `Colors.white` and `Colors.black`** in the inheriting screens (excluding intentional camera viewport in `video_360_screen.dart`) with `AppColors.surface` / `AppColors.ink` respectively.

```bash
# discover leftovers
grep -rn "Colors\.white\|Colors\.black" lib/features/booking lib/features/rental lib/features/my_rentals lib/features/profile lib/features/home/view/filter_sheet.dart 2>&1 | head -20
```

For each match: replace with the AppColors equivalent.

- [ ] **Step 5: `flutter analyze`. Expected: 0 errors.**

- [ ] **Step 6: Commit.**

```bash
git add lib/features/ && git commit -m "polish: align inheriting screens to Sunset tokens"
```

---

## Task 17: Update MainShell bottom nav and AppBar styling

**Files:**
- Verify `lib/features/shell/view/main_shell.dart` is already using `AppTypography.label` / `caps` — no change expected.
- Verify `app_theme.dart` BottomNavigationBar theme is the source of truth.

- [ ] **Step 1: Open `main_shell.dart` and confirm tab labels render via theme**

If the file passes `selectedLabelStyle:` / `unselectedLabelStyle:` explicitly to `BottomNavigationBar`, that's fine — the theme is a fallback. No edit required.

- [ ] **Step 2: Walk the bottom nav.**

Run app, switch tabs Explorer / Mes locations / Profil. Selected label should be ink; unselected muted gray. No layout regressions.

- [ ] **Step 3: Skip commit if no edits were needed.**

---

## Task 18: Delete ZelligePattern and remove dead imports

**Files:**
- Delete: `lib/shared/widgets/zellige_pattern.dart`

- [ ] **Step 1: Confirm no remaining imports.**

```bash
grep -rn "ZelligePattern\|zellige_pattern" lib/
```

Expected: no matches (Tasks 7–12 already replaced all usages with `SunsetGradient` or removed the widget). If any remain, fix the importing file before deleting.

- [ ] **Step 2: Delete the file.**

```bash
rm "lib/shared/widgets/zellige_pattern.dart"
```

- [ ] **Step 3: Remove the `zellige` alias in `app_colors.dart`.**

In `lib/theme/app_colors.dart`, delete the line:
```dart
static const zellige = accent;                  // any leftover ZelligePattern arg
```

- [ ] **Step 4: `flutter analyze`. Expected: 0 errors.**

- [ ] **Step 5: Commit.**

```bash
git add lib/ && git commit -m "chore: remove obsolete ZelligePattern widget"
```

---

## Task 19: Final verification

- [ ] **Step 1: Final `flutter analyze`.**

```powershell
flutter analyze
```

Expected: 0 errors, 0 warnings. Info-level `prefer_const` lints are acceptable.

- [ ] **Step 2: Run the full demo flow on a device or emulator.**

```powershell
flutter run
```

Walk the entire flow described in Task 16 Step 1. Verify each of the 5 hero gradient moments shows the coral→amber gradient:
1. Splash full-bleed
2. Login hero card (top portion)
3. Booking Success (gradient check + irradiating coral rings)
4. Bluetooth Unlock + Lock screens
5. Return Success (gradient check + irradiating coral rings)

Other screens should be bright #FAFAFA backgrounds with coral accents on prices, CTAs, and selected states.

- [ ] **Step 3: Verify Manrope is loading.**

On the splash screen, the "Drive, *differently.*" should be Manrope 900/300 italic — geometric and clean. If it falls back to a system font, run `flutter clean && flutter run` once.

- [ ] **Step 4: Tag the milestone.**

```bash
git tag v0.2.0-sunset
```

---

## Completion criteria

- ✅ `flutter analyze` reports 0 errors, 0 warnings.
- ✅ App launches and the full demo flow plays through without crash.
- ✅ The 5 hero moments all display the Sunset gradient.
- ✅ No `Fraunces` references remain in code.
- ✅ `ZelligePattern` widget is deleted.
- ✅ All screens render Manrope (no system font fallback visible).
- ✅ Coral `#FF5E3A` appears on prices, primary CTAs (where gradient isn't appropriate), filter chips, focused inputs.
