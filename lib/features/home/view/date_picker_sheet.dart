import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
      barrierColor: Colors.black.withValues(alpha: 0.5),
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
    final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final defaultStart = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10, 0);
    _start = widget.initialStart ?? defaultStart;
    final defaultEnd = DateTime(tomorrow.year, tomorrow.month, tomorrow.day + 1, 18, 0);
    _end = widget.initialEnd ?? defaultEnd;
  }

  Duration get _duration => _end.difference(_start);
  int get _durationDays => _duration.inDays.clamp(1, 365);
  String get _durationLabel => '$_durationDays jour${_durationDays > 1 ? 's' : ''}';

  void _setActive(DateTime newDate) {
    setState(() {
      if (_activeTab == 0) {
        _start = newDate;
        if (!_end.isAfter(_start)) {
          _end = _start.add(const Duration(hours: 1));
        }
      } else {
        if (newDate.isAfter(_start)) {
          _end = newDate;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.72,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            // Poignée
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderStrong,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 20),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Période de location',
                            style: AppTypography.h1(
                              size: 20,
                              weight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sélectionnez vos dates',
                            style: AppTypography.body(
                              size: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.ink.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(LucideIcons.x,
                          size: 18, color: AppColors.ink),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 24),
            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(child: _tab(0, 'Début', _start)),
                  const SizedBox(width: 12),
                  Expanded(child: _tab(1, 'Fin', _end)),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 100.ms)
                .slideY(begin: 0.1, end: 0, delay: 100.ms),
            const SizedBox(height: 16),
            // Wheel picker
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _activeTab == 0
                      ? AppColors.accent.withValues(alpha: 0.25)
                      : AppColors.border,
                  width: _activeTab == 0 ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: -2,
                  ),
                  if (_activeTab == 0)
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 6),
                    ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: CupertinoTheme(
                  data: const CupertinoThemeData(
                    brightness: Brightness.light,
                    primaryColor: AppColors.accent,
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        color: AppColors.ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    key: ValueKey(_activeTab),
                    mode: CupertinoDatePickerMode.dateAndTime,
                    initialDateTime: _activeTab == 0 ? _start : _end,
                    minimumDate: _activeTab == 0
                        ? DateTime(DateTime.now().year, DateTime.now().month,
                            DateTime.now().day)
                        : _start,
                    maximumDate: DateTime.now().add(const Duration(days: 90)),
                    onDateTimeChanged: _setActive,
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 150.ms)
                .slideY(begin: 0.15, end: 0, delay: 150.ms),
            const SizedBox(height: 16),
            // Duration badge
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.softWarm,
                      AppColors.softWarm.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.gradientStart, AppColors.gradientEnd],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        LucideIcons.clock,
                        size: 16,
                        color: AppColors.surface,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'DURÉE DE LOCATION',
                          style: AppTypography.caps(
                            size: 9,
                            letterSpacing: 1.6,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _durationLabel,
                          style: AppTypography.numeric(
                            size: 20,
                            weight: FontWeight.w900,
                            color: AppColors.accent,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    _miniCalendar(_start, _end),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 200.ms)
                .slideY(begin: 0.1, end: 0, delay: 200.ms),
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
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 250.ms)
                .slideY(begin: 0.1, end: 0, delay: 250.ms),
          ],
        ),
      ),
    );
  }

  Widget _tab(int index, String label, DateTime date) {
    final isActive = _activeTab == index;
    final fmt = DateFormat('d MMM yyyy', 'fr_FR');
    final fmtTime = DateFormat('HH:mm', 'fr_FR');

    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.gradientStart,
                    AppColors.gradientEnd,
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.surface,
                    AppColors.softWarm.withValues(alpha: 0.3),
                  ],
                ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive ? Colors.transparent : AppColors.border,
            width: isActive ? 0 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: AppTypography.caps(
                    size: 9,
                    letterSpacing: 1.8,
                    color: isActive
                        ? AppColors.surface.withValues(alpha: 0.9)
                        : AppColors.textMuted,
                  ),
                ),
                if (isActive) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.surface.withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .fadeIn(duration: 1000.ms, curve: Curves.easeInOut),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              fmt.format(date),
              style: AppTypography.h2(
                size: 15,
                weight: FontWeight.w800,
                color: isActive ? AppColors.surface : AppColors.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              fmtTime.format(date),
              style: AppTypography.body(
                size: 12,
                weight: FontWeight.w600,
                color: isActive
                    ? AppColors.surface.withValues(alpha: 0.85)
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniCalendar(DateTime start, DateTime end) {
    final startMonth = DateFormat('MMM', 'fr_FR').format(start).toUpperCase();
    final endMonth = DateFormat('MMM', 'fr_FR').format(end).toUpperCase();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _calBox(start.day.toString(), startMonth),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Container(
            width: 16, height: 2,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
              ),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        _calBox(end.day.toString(), endMonth),
      ],
    );
  }

  Widget _calBox(String day, String month) {
    return Container(
      width: 42, height: 46,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            month,
            style: AppTypography.caps(
              size: 7,
              letterSpacing: 1,
              color: AppColors.textMuted,
            ),
          ),
          Text(
            day,
            style: AppTypography.numeric(
              size: 16,
              weight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
