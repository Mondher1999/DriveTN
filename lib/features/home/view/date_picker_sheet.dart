import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../shared/widgets/primary_button.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class DatePickerSheet extends StatefulWidget {
  final DateTime? initialStart;
  final DateTime? initialEnd;
  const DatePickerSheet({super.key, this.initialStart, this.initialEnd});

  static Future<(DateTime, DateTime)?> show(
    BuildContext context, {
    DateTime? initialStart,
    DateTime? initialEnd,
  }) {
    return showModalBottomSheet<(DateTime, DateTime)>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => DatePickerSheet(
        initialStart: initialStart,
        initialEnd: initialEnd,
      ),
    );
  }

  @override
  State<DatePickerSheet> createState() => _DatePickerSheetState();
}

class _DatePickerSheetState extends State<DatePickerSheet> {
  late DateTime _start;
  late DateTime _end;
  int _activeTab = 0; // 0 = début, 1 = fin

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final defaultStart = DateTime(now.year, now.month, now.day)
        .add(const Duration(days: 1));
    _start = widget.initialStart ?? defaultStart;
    // Minimum 1 day reservation
    _end = widget.initialEnd ?? defaultStart.add(const Duration(days: 1));
  }

  Duration get _duration => _end.difference(_start);

  int get _durationDays {
    return _duration.inDays.clamp(1, 365);
  }

  String get _durationLabel {
    final d = _durationDays;
    return '$d jour${d > 1 ? 's' : ''}';
  }

  void _setActive(DateTime newDate) {
    setState(() {
      if (_activeTab == 0) {
        _start = DateTime(newDate.year, newDate.month, newDate.day);
        // Enforce min 1 day end after start
        if (_end.difference(_start).inDays < 1) {
          _end = _start.add(const Duration(days: 1));
        }
      } else {
        final candidate =
            DateTime(newDate.year, newDate.month, newDate.day);
        if (candidate.difference(_start).inDays >= 1) {
          _end = candidate;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.borderStrong,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Période de location',
                        style: AppTypography.h2(
                          size: 17,
                          weight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(LucideIcons.x,
                          size: 18, color: AppColors.ink),
                    ),
                  ),
                ],
              ),
            ),
            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(child: _tab(0, 'Début', _start)),
                    Expanded(child: _tab(1, 'Fin', _end)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Wheel picker (iOS style) — date only, min 1 day
            SizedBox(
              height: 150,
              child: CupertinoTheme(
                data: const CupertinoThemeData(
                  brightness: Brightness.light,
                  primaryColor: AppColors.accent,
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(
                      color: AppColors.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                child: CupertinoDatePicker(
                  key: ValueKey(_activeTab),
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _activeTab == 0 ? _start : _end,
                  minimumDate: _activeTab == 0
                      ? DateTime(DateTime.now().year, DateTime.now().month,
                          DateTime.now().day)
                      : _start.add(const Duration(days: 1)),
                  maximumDate: DateTime.now().add(const Duration(days: 90)),
                  onDateTimeChanged: _setActive,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Duration chip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.softWarm,
                      AppColors.softWarm.withValues(alpha: 0.4),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.18)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.clock,
                        size: 16, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Text(
                      'DURÉE',
                      style: AppTypography.caps(
                        size: 10,
                        letterSpacing: 1.6,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _durationLabel,
                      style: AppTypography.numeric(
                        size: 18,
                        weight: FontWeight.w900,
                        color: AppColors.accent,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: PrimaryButton(
                label: 'Rechercher pour $_durationLabel',
                icon: LucideIcons.search,
                variant: ButtonVariant.gradient,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop((_start, _end));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tab(int index, String label, DateTime date) {
    final fmt = DateFormat('d MMM · HH:mm', 'fr_FR');
    final isActive = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd])
              : null,
          borderRadius: BorderRadius.circular(999),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.caps(
                size: 10,
                letterSpacing: 1.6,
                color: isActive
                    ? AppColors.surface
                    : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              fmt.format(date),
              style: AppTypography.body(
                size: 13,
                weight: FontWeight.w800,
                color: isActive ? AppColors.surface : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
