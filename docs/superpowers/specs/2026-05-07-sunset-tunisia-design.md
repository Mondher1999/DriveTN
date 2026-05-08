# DriveTN — Sunset Tunisia Design System

**Date**: 2026-05-07
**Status**: Approved by user, ready for implementation
**Supersedes**: Mediterranean Editorial direction (parchment + Fraunces serif), rejected by user as "not bright/wow enough"

## Goal

Pivot DriveTN's visual identity to a **bright, modern, eye-friendly, "wow"** aesthetic suitable for an investor and agency-owner demo in Tunisia. Replace the current parchment + serif system with a vibrant sunset-inspired palette, geometric sans-serif type, and gradient hero moments that make the app instantly screenshot-worthy.

References: Bolt, Yango, Lyft (transport apps that work in MENA), Cash App (numeric punch), Apple Maps (clarity).

## Non-goals

- Not a new feature or screen — this is a visual refactor of the existing 17-screen prototype.
- No backend changes, no Cubit logic changes, no routing changes.
- No new screens. No new flows.
- Wallet code stays deleted.

## Color system

All values are exact hex; no "primary brand color" abstraction layer — these are literal values used across the app.

### Hero (gradient — only on wow moments)

| Token | Value | Where it appears |
|---|---|---|
| `gradientStart` | `#FF5E3A` | Coral — top-left of hero gradient |
| `gradientEnd` | `#FFB800` | Amber — bottom-right of hero gradient |
| `sunsetGradient` | `LinearGradient(135°, #FF5E3A → #FFB800)` | Splash, Login hero, Booking Success, Return Success, Bluetooth Unlock/Lock |

### Primary palette

| Token | Value | Role |
|---|---|---|
| `accent` | `#FF5E3A` | Coral — primary CTA color (when light variant), prices, highlights |
| `accentSecondary` | `#FFB800` | Amber — secondary highlights, ratings, badges |
| `ink` | `#1A1A1A` | Near-black — body text, headlines, primary button background |
| `surface` | `#FFFFFF` | Cards, sheets |
| `background` | `#FAFAFA` | App scaffold background |
| `softWarm` | `#FFF6E5` | Warmth-tinted card background (for special highlights) |

### Supporting

| Token | Value | Role |
|---|---|---|
| `success` | `#10B981` | Modern emerald (replaces previous olive) |
| `textSecondary` | `#6B6B6B` | Secondary body text |
| `textMuted` | `#9C9C9C` | Tertiary / placeholder text |
| `border` | `#F0F0F0` | Subtle 1px lines |
| `borderStrong` | `#E5E5E5` | Stronger dividers |
| `danger` | `#EF4444` | Errors |
| `warning` | `#F59E0B` | Cautions, low fuel |

### Color usage rules

- **Gradient is reserved**: only splash, login hero, success states, and bluetooth screens. Using it elsewhere kills its impact.
- **Coral as the only accent on white screens**: prices, primary CTAs (when not ink), filter pills, ratings.
- **Ink is the workhorse for contrast**: button backgrounds, headlines, body text. Avoid pure `#000000`.
- **No parchment**: `#FAFAFA` is the only allowed off-white background. All cards are `#FFFFFF`.
- **Cards on `softWarm` (`#FFF6E5`)** are for a single moment per screen max — they signal "highlight, look here".

## Typography system

**Single family**: **Manrope** (variable, weights 200–900). Loaded via `google_fonts` (`GoogleFonts.manrope`). Applied via `MaterialApp.textTheme` so all default Material widgets inherit.

No serif. No second font family. Italic comes from `FontStyle.italic` on Manrope itself (it has true italics in variable axis).

### Scale

| Style | Method | Size | Weight | LetterSpacing | Use |
|---|---|---|---|---|---|
| `display` | `display(...)` | 48–56 | 900 | -2 to -2.4 | Hero only (splash, success, login) |
| `displayItalic` | `display(italic: true)` | same | 300 | same | Pairs with display for "Drive, *differently.*" |
| `h1` | `h1(...)` | 28 | 800 | -1 | Page titles ("12 voitures à Tunis") |
| `h2` | `h2(...)` | 18 | 700 | -0.4 | Section titles |
| `body` | `body(...)` | 14 | 500 | 0 | Default running text |
| `bodyStrong` | `body(weight: w700)` | 14 | 700 | 0 | Emphasized body |
| `numeric` | `numeric(...)` | 32 | 800 | -1.2 | Prices in coral, timer in ink |
| `numericSmall` | `numeric(size: 16)` | 16 | 800 | -0.4 | Inline prices in lists |
| `caps` | `caps(...)` | 11 | 700 | 2.5 | "DRIVETN · 2026", section labels |
| `capsSmall` | `caps(size: 9)` | 9 | 700 | 2 | Tiny pills |

### Implementation

`lib/theme/app_typography.dart` rewrites the existing `AppTypography` class. All `Fraunces` references are removed; all `dmSans` references are removed. New methods added: `h1`, `h2`, `numeric` (no longer italic by default), `caps` (replaces `label`).

**Backward compatibility** (transitional, kept to avoid touching every screen):
- Keep `display(...)`, `body(...)`, `label(...)` method names so screens that already use them keep compiling.
- `label(...)` becomes a thin alias for `caps(...)` with the same defaults.
- `serif(...)` is removed — every call site is migrated to `body(...)`, `h2(...)`, or `h1(...)` based on context. This is a hard cutover, not an alias, because the editorial italic-serif look is exactly what we're killing.
- `numeric(...)` no longer defaults to italic. The new default is `italic: false`. Existing call sites that want italic must pass `italic: true` explicitly.

## Component shape language

| Component | Old | New |
|---|---|---|
| Card radius | 20–24 | **20** (uniform) |
| Button (primary CTA) | 999 pill | **999 pill** (kept) |
| Input field radius | 16 | **14** |
| Map marker | pill | **circle 32×32** (ink bg, 2px white border) |
| Gradient hero rect | 28 | **24** |
| Soft card highlight | n/a | **18** |

Borders: 1px `#F0F0F0`. No drop shadows except where they earn it (gradient CTA halo, success check halo).

## Hero gradient widget

New shared widget: `lib/shared/widgets/sunset_gradient.dart`

```dart
class SunsetGradient extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final bool fullBleed;
  // ... renders LinearGradient(begin: topLeft, end: bottomRight,
  //     colors: [AppColors.gradientStart, AppColors.gradientEnd])
  // with optional radial-glow overlay (top-right, white at 25% alpha → transparent)
}
```

Replaces the `ZelligePattern` widget on hero screens. The `ZelligePattern` widget is **deleted** — it was tied to the editorial direction.

## Motion / animation philosophy

| Moment | Animation |
|---|---|
| Splash entry | Logo "DriveTN" letter-by-letter typewriter reveal (~500ms total), then a coral underline expanding from center, then tagline fade-in. Total 1.6s before route to login. |
| Card list appearance | Scale 0.96→1 + fade-in, staggered 60ms per item, ease-out 350ms. |
| Primary CTA tap | Ripple coral 200ms + `HapticFeedback.lightImpact()`. Ink button: brief gradient halo glow on press (scale 1→1.05→1, 250ms). |
| Booking success | Check icon pops with spring (Curves.easeOutBack, 600ms), three concentric coral circles irradiate outward and fade (1.5s, staggered 200ms). |
| Page transitions | Default Material slide; no custom transitions for now (keep scope tight). |
| Bluetooth pulses | Same concentric pulse pattern as today, but coral color now (was Carthage blue). |

`flutter_animate` already in deps — use it.

## Screens — refactor scope

### Full refactor (visual rewrite)

These screens are touched directly because they contain hero gradient moments or unique editorial flourishes that don't auto-translate from theme changes:

1. `lib/features/splash/view/splash_screen.dart` — gradient full-bleed, typewriter logo
2. `lib/features/auth/view/login_screen.dart` — gradient hero card replaces editorial card
3. `lib/features/home/view/home_screen.dart` — pill removal, coral-centered CarCard treatment, search bar restyle
4. `lib/features/home/view/car_card.dart` — coral price punch, image gradient placeholder, restyled badges
5. `lib/features/car_detail/view/car_detail_screen.dart` — gradient placeholder behind photos, coral CTA
6. `lib/features/booking/view/booking_success_screen.dart` — gradient circle check, irradiating animation
7. `lib/features/return/view/return_success_screen.dart` — same success pattern
8. `lib/features/unlock/view/bluetooth_unlock_screen.dart` — gradient bg
9. `lib/features/unlock/view/bluetooth_lock_screen.dart` — gradient bg
10. `lib/shared/widgets/primary_button.dart` — add `gradient` variant
11. `lib/shared/widgets/price_tag.dart` — Manrope 800 italic-light coral

### Inherits via theme (no direct edits expected)

These should look correct after `AppColors` and `AppTheme` are updated, with at most cosmetic tweaks:

- `lib/features/booking/view/booking_screen.dart`
- `lib/features/booking/view/payment_screen.dart`
- `lib/features/inspection/view/video_360_screen.dart`
- `lib/features/rental/view/active_rental_screen.dart`
- `lib/features/my_rentals/view/my_rentals_screen.dart`
- `lib/features/profile/view/profile_screen.dart`
- `lib/features/shell/view/main_shell.dart`
- `lib/features/home/view/filter_sheet.dart`

Spot-check each post-refactor and adjust only if visibly broken (e.g. text becomes unreadable, hardcoded coral references that should now be ink).

### Deletions

- `lib/shared/widgets/zellige_pattern.dart` — was editorial-only.

## Foundation files

### `lib/theme/app_colors.dart`

Complete rewrite. Old palette (Carthage / saffron / parchment) replaced with the table above. Add `gradientStart`, `gradientEnd`, `softWarm`.

### `lib/theme/app_typography.dart`

Complete rewrite. Single Manrope family. Methods: `display`, `h1`, `h2`, `body`, `numeric`, `caps`, plus aliases for backward compat (`label`, `serif` → both forward to `caps` and `body` respectively).

### `lib/theme/app_theme.dart`

Updates:
- `MaterialApp` `textTheme: GoogleFonts.manropeTextTheme(...)`.
- `ElevatedButtonThemeData` keeps pill 999, default bg = `AppColors.ink`.
- `InputDecorationTheme` radius 14, fill `AppColors.surface`, focused border 1.5px coral.
- `CardThemeData` radius 20, white surface, 1px `border`.
- `BottomNavigationBarTheme` already correct (selected ink, unselected muted).

## Acceptance criteria

The refactor is done when:

1. `flutter analyze` reports 0 errors, 0 warnings.
2. App launches without crash.
3. Splash → Login → Home → Car Detail → Booking → Payment → Inspection → Bluetooth → Active Rental → Inspection Return → Bluetooth Lock → Return Success — full flow plays through. The sunset gradient appears on **5 hero moments**: splash full-bleed, login hero card, booking success, return success, both bluetooth screens.
4. No leftover `Fraunces` font references in code.
5. No leftover `ZelligePattern` references.
6. No leftover `parchment` / `surfaceAlt` muted-warm references in screens (they should resolve to white now or `softWarm`).
7. Manrope font loads visibly on first launch (no system fallback).
8. `flutter_animate` typewriter splash animation completes in <2s before navigation.

## Out of scope (deferred)

- Dark mode.
- Tablet / landscape layouts.
- AR locale support.
- Real Lottie integration (already optional).
- Custom page transition animations (rely on Material defaults).

## Implementation sequencing

The implementation plan (next step, via `writing-plans` skill) will sequence the work to keep the build green at each checkpoint:

1. Foundation (colors, typography, theme) — single commit, must keep app compiling.
2. Shared widgets (PrimaryButton gradient variant, PriceTag, SunsetGradient widget). Delete ZelligePattern.
3. Hero screens (splash → login → success states → bluetooth) — gradient moments first because they're the most visible wow.
4. Home + CarCard + CarDetail — most-used screens.
5. Spot-fix any inheriting screen that looks broken.
6. `flutter analyze` final + manual demo run.
