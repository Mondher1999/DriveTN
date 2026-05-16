import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../shared/widgets/primary_button.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

/// Combined Location → Date flow sheet with smooth horizontal transition.
/// Step 1: Pick location
/// Step 2: Pick dates (auto-advances after location selection)
class LocationDateFlowSheet extends StatefulWidget {
  final String? initialLocation;
  final (DateTime, DateTime)? initialDates;
  final int initialStep; // 0 = location, 1 = date

  const LocationDateFlowSheet({
    super.key,
    this.initialLocation,
    this.initialDates,
    this.initialStep = 0,
  });

  static Future<({String location, DateTime start, DateTime end})?> show(
    BuildContext context, {
    String? initialLocation,
    (DateTime, DateTime)? initialDates,
    int initialStep = 0,
  }) {
    return showModalBottomSheet<({String location, DateTime start, DateTime end})>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => LocationDateFlowSheet(
        initialLocation: initialLocation,
        initialDates: initialDates,
        initialStep: initialStep,
      ),
    );
  }

  @override
  State<LocationDateFlowSheet> createState() => _LocationDateFlowSheetState();
}

class _LocationDateFlowSheetState extends State<LocationDateFlowSheet> {
  late int _step; // 0 = location, 1 = date
  String? _selectedLocation;

  late DateTime _start;
  late DateTime _end;
  int _activeTab = 0; // 0 = début, 1 = fin

  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  late final PageController _pageController;

  static const _popularLocations = [
    'Aéroport Tunis-Carthage (TUN)',
    'Aéroport Djerba-Zarzis (DJE)',
    'Aéroport Monastir (MIR)',
    'Aéroport Sfax (SFA)',
    'Tunis Centre',
    'La Marsa',
    'Lac 1 — Berges du Lac',
    'Lac 2',
    'Ariana — Centre',
    'Carthage',
    'Sidi Bou Saïd',
    'Sfax Centre',
    'Sousse — Kantaoui',
    'Monastir — Skanès',
    'Hammamet — Nord',
    'Mahdia',
    'Djerba — Houmt Souk',
    'Djerba — Midoun',
    'Djerba — Zone Touristique',
    'Nabeul — Centre',
    'Bizerte — Port',
    'Gabès — Centre',
    'Tozeur — Palmeraie',
    'Soukra',
  ];

  @override
  void initState() {
    super.initState();
    _step = widget.initialStep;
    _pageController = PageController(initialPage: widget.initialStep);
    _selectedLocation = widget.initialLocation;

    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final defaultStart = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10, 0);
    _start = widget.initialDates?.$1 ?? defaultStart;
    final defaultEnd = DateTime(tomorrow.year, tomorrow.month, tomorrow.day + 1, 18, 0);
    _end = widget.initialDates?.$2 ?? defaultEnd;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    if (_step == step) return;
    setState(() => _step = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutQuart,
    );
  }

  void _selectLocation(String location) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedLocation = location;
    });
    // Smooth auto-advance to date step after a brief delay
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _goToStep(1);
    });
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom +
            (bottomInset > 0 ? bottomInset - 20 : 0),
      ),
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
            // Header with back button when on step 2
            _header(),
            const SizedBox(height: 20),
            // Progress indicator
            _progressBar(),
            const SizedBox(height: 20),
            // Content with smooth page transition
            Expanded(
              child: _buildSmoothTransition(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmoothTransition() {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _locationStep(key: const ValueKey(0)),
        _dateStep(key: const ValueKey(1)),
      ],
    );
  }

  Widget _header() {
    final title = _step == 0 ? 'Adresse de location' : 'Période de location';
    final subtitle = _step == 0
        ? 'Où voulez-vous récupérer la voiture ?'
        : 'Quand voulez-vous partir ?';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _step == 1
                ? GestureDetector(
                    key: const ValueKey('back'),
                    onTap: () => _goToStep(0),
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
                      child: const Icon(LucideIcons.arrowLeft,
                          size: 18, color: AppColors.ink),
                    ),
                  )
                : const SizedBox(width: 40, key: ValueKey('empty')),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.h1(
                      size: 20,
                      weight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
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
    );
  }

  Widget _progressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          height: 4,
          child: Stack(
            children: [
              Container(color: AppColors.border),
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                widthFactor: _step == 0 ? 0.5 : 1.0,
                heightFactor: 1,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.gradientStart,
                        AppColors.gradientEnd,
                      ],
                    ),
                  ),
                ),
              ),
              // Step dots
              Row(
                children: [
                  Expanded(
                    child: _stepDot(0, 'Lieu'),
                  ),
                  Expanded(
                    child: _stepDot(1, 'Dates'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepDot(int stepIndex, String label) {
    final isActive = _step == stepIndex;
    final isDone = _step > stepIndex;
    return Align(
      alignment: stepIndex == 0 ? Alignment.centerLeft : Alignment.centerRight,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isActive ? 24 : 16,
        height: isActive ? 24 : 16,
        decoration: BoxDecoration(
          gradient: isDone || isActive
              ? const LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                )
              : null,
          color: isDone || isActive ? null : AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDone || isActive ? Colors.transparent : AppColors.border,
            width: 2,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: isDone
            ? const Icon(Icons.check, size: 10, color: AppColors.surface)
            : isActive
                ? Container(
                    margin: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
      ),
    );
  }

  Widget _locationStep({required Key key}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Search field
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(LucideIcons.search,
                    size: 18, color: AppColors.textMuted),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    focusNode: _searchFocus,
                    autofocus: false,
                    cursorColor: AppColors.accent,
                    style: AppTypography.body(
                      size: 15,
                      weight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Quartier, gare, hôtel...',
                      hintStyle: TextStyle(
                        fontSize: 15,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isCollapsed: true,
                      filled: false,
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) {
                      _searchFocus.unfocus();
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                if (_searchCtrl.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchCtrl.clear();
                      setState(() {});
                    },
                    child: const Icon(LucideIcons.xCircle,
                        size: 18, color: AppColors.textMuted),
                  ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.06, end: 0),
          const SizedBox(height: 8),
          // List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 8),
              children: [
                const SizedBox(height: 8),
                const SizedBox(height: 4),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                  child: Row(
                    children: [
                      Container(width: 16, height: 2, decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(1))),
                      const SizedBox(width: 8),
                      Text(
                        'ENDROITS POPULAIRES',
                        style: AppTypography.caps(
                          size: 10,
                          letterSpacing: 1.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                for (int i = 0; i < _popularLocations.length; i++)
                  _locationRow(
                    icon: LucideIcons.mapPin,
                    iconColor: AppColors.textMuted,
                    title: _popularLocations[i],
                    subtitle: 'Tunisie',
                    onTap: () => _selectLocation(_popularLocations[i]),
                  )
                      .animate()
                      .fadeIn(
                          delay: (80 + 60 * i).ms, duration: 350.ms)
                      .slideY(begin: 0.06, end: 0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    bool gradient = false,
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedLocation == title;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.softWarm.withValues(alpha: 0.5)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.accent.withValues(alpha: 0.2)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: gradient
                    ? const LinearGradient(
                        colors: [
                          AppColors.gradientStart,
                          AppColors.gradientEnd,
                        ],
                      )
                    : null,
                color: gradient ? null : AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 18,
                color: gradient ? AppColors.surface : iconColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.body(
                      size: 15,
                      weight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.body(
                      size: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 12,
                  color: AppColors.surface,
                ),
              )
                  .animate()
                  .scale(begin: const Offset(0, 0), end: const Offset(1, 1))
                  .fadeIn(),
            if (!isSelected)
              const Icon(LucideIcons.chevronRight,
                  size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _dateStep({required Key key}) {
    final fmt = DateFormat('d MMM yyyy', 'fr_FR');
    final fmtTime = DateFormat('HH:mm', 'fr_FR');
    final today = DateTime.now();
    final minDate = _activeTab == 0
        ? DateTime(today.year, today.month, today.day)
        : _start;
    final maxDate = today.add(const Duration(days: 90));

    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Selected location recap — clearer UX
          GestureDetector(
            onTap: () => _goToStep(0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.gradientStart,
                          AppColors.gradientEnd,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.mapPin,
                      size: 16,
                      color: AppColors.surface,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lieu de prise en charge',
                          style: AppTypography.caps(
                            size: 10,
                            letterSpacing: 1.2,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _selectedLocation ?? 'Lieu inconnu',
                          style: AppTypography.body(
                            size: 14,
                            weight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.pencil,
                          size: 12,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Modifier',
                          style: AppTypography.body(
                            size: 11,
                            weight: FontWeight.w800,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.06, end: 0),
          const SizedBox(height: 16),
          // Date tabs
          Row(
            children: [
              Expanded(
                  child: _dateTab(0, 'Début', _start, fmt, fmtTime)),
              const SizedBox(width: 12),
              Expanded(child: _dateTab(1, 'Fin', _end, fmt, fmtTime)),
            ],
          )
              .animate()
              .fadeIn(duration: 350.ms, delay: 50.ms)
              .slideY(begin: 0.06, end: 0, delay: 50.ms),
          const SizedBox(height: 14),
          // Picker
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
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
                  minimumDate: minDate,
                  maximumDate: maxDate,
                  onDateTimeChanged: _setActive,
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 350.ms, delay: 100.ms)
              .slideY(begin: 0.1, end: 0, delay: 100.ms),
          const SizedBox(height: 14),
          // Duration badge
          Container(
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
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.gradientStart, AppColors.gradientEnd],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
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
          )
              .animate()
              .fadeIn(duration: 350.ms, delay: 150.ms)
              .slideY(begin: 0.06, end: 0, delay: 150.ms),
          const SizedBox(height: 16),
          // CTA: switch to Fin tab when on Début, then search.
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: _activeTab == 0
                ? PrimaryButton(
                    key: const ValueKey('continue_btn'),
                    label: 'Choisir la date de fin',
                    icon: LucideIcons.calendarDays,
                    variant: ButtonVariant.gradient,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() => _activeTab = 1);
                    },
                  )
                : PrimaryButton(
                    key: const ValueKey('search_btn'),
                    label: 'Rechercher pour $_durationLabel',
                    icon: LucideIcons.search,
                    variant: ButtonVariant.gradient,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop((
                        location: _selectedLocation!,
                        start: _start,
                        end: _end,
                      ));
                    },
                  ),
          )
              .animate()
              .fadeIn(duration: 350.ms, delay: 200.ms)
              .slideY(begin: 0.06, end: 0, delay: 200.ms),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _dateTab(int index, String label, DateTime date,
      DateFormat fmt, DateFormat fmtTime) {
    final isActive = _activeTab == index;
    final needsAttention = index == 1 && _activeTab == 0;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _activeTab = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? Colors.transparent
                : needsAttention
                    ? AppColors.accent.withValues(alpha: 0.5)
                    : AppColors.border,
            width: isActive ? 0 : (needsAttention ? 1.5 : 1),
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : needsAttention
                  ? [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: AppColors.ink.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
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
                    letterSpacing: 1.6,
                    color: isActive
                        ? AppColors.surface.withValues(alpha: 0.9)
                        : needsAttention
                            ? AppColors.accent
                            : AppColors.textMuted,
                  ),
                ),
                if (needsAttention) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(0.6, 0.6),
                        end: const Offset(1.2, 1.2),
                        duration: 800.ms,
                        curve: Curves.easeInOut,
                      ),
                ],
              ],
            ),
            const SizedBox(height: 3),
            Text(
              fmt.format(date),
              style: AppTypography.h2(
                size: 14,
                weight: FontWeight.w800,
                color: isActive ? AppColors.surface : AppColors.ink,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              fmtTime.format(date),
              style: AppTypography.body(
                size: 11,
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
            width: 14, height: 2,
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
      width: 38, height: 42,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            month,
            style: AppTypography.caps(
              size: 6,
              letterSpacing: 1,
              color: AppColors.textMuted,
            ),
          ),
          Text(
            day,
            style: AppTypography.numeric(
              size: 15,
              weight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
