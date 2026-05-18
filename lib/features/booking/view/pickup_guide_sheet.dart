import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

/// Slide-based onboarding guide shown when the user wants to understand
/// the pickup flow, or when the app opens near rental time.
/// Optimized for Gestalt clarity: proximity, continuity, similarity, hierarchy.
class PickupGuideSheet extends StatefulWidget {
  final VoidCallback? onComplete;
  const PickupGuideSheet({super.key, this.onComplete});

  static Future<void> show(BuildContext context, {VoidCallback? onComplete}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PickupGuideSheet(onComplete: onComplete),
    );
  }

  @override
  State<PickupGuideSheet> createState() => _PickupGuideSheetState();
}

class _PickupGuideSheetState extends State<PickupGuideSheet> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  static const int _pageCount = 7;

  void _next() {
    HapticFeedback.lightImpact();
    if (_currentPage < _pageCount - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      widget.onComplete?.call();
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 14, bottom: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            // Skip
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 24),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text(
                    'Passer',
                    style: AppTypography.body(
                      size: 14,
                      weight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pageCount,
                itemBuilder: (context, index) {
                  return _SlideContent(
                    index: index,
                  );
                },
              ),
            ),
            // Bottom: step label + dots + button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Étape ${_currentPage + 1} / $_pageCount',
                    style: AppTypography.body(
                      size: 13,
                      weight: FontWeight.w700,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      children: List.generate(_pageCount, (i) {
                        final active = i == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.only(right: 8),
                          width: active ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: active
                                ? const LinearGradient(
                                    colors: [
                                      AppColors.gradientStart,
                                      AppColors.gradientEnd,
                                    ],
                                  )
                                : null,
                            color: active ? null : AppColors.border,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        );
                      }),
                    ),
                  ),
                  InkWell(
                    onTap: _next,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.gradientStart,
                            AppColors.gradientEnd,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.30),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentPage == _pageCount - 1
                                ? "C'est parti"
                                : 'Suivant',
                            style: AppTypography.body(
                              size: 14,
                              weight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            _currentPage == _pageCount - 1
                                ? LucideIcons.arrowRight
                                : LucideIcons.chevronRight,
                            size: 18,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideContent extends StatelessWidget {
  final int index;

  const _SlideContent({required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 4),
          _stepBadge(index),
          const SizedBox(height: 16),
          Text(
            _titles[index],
            textAlign: TextAlign.center,
            style: AppTypography.display(
              size: 24,
              weight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 80.ms)
              .slideY(begin: 0.08, end: 0, delay: 80.ms),
          const SizedBox(height: 10),
          Text(
            _descriptions[index],
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 14,
              color: AppColors.textSecondary,
              height: 1.55,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 160.ms)
              .slideY(begin: 0.08, end: 0, delay: 160.ms),
          const SizedBox(height: 28),
          Expanded(
            child: _buildMockup(context),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _stepBadge(int idx) {
    final numbers = ['01', '02', '03', '04', '05', '06', '07'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Étape ${numbers[idx]}',
        style: AppTypography.body(
          size: 12,
          weight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.1, end: 0, duration: 350.ms);
  }

  Widget _buildMockup(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final mockWidth = size.width * 0.70;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Container(
          width: mockWidth,
          height: mockWidth * 1.85,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: _mockScreenFor(index, mockWidth),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 200.ms)
        .slideY(
          begin: 0.12,
          end: 0,
          duration: 500.ms,
          delay: 200.ms,
          curve: Curves.easeOutBack,
        )
        .scale(
          begin: const Offset(0.94, 0.94),
          end: const Offset(1, 1),
          duration: 500.ms,
          delay: 200.ms,
          curve: Curves.easeOutBack,
        );
  }

  static const List<String> _titles = [
    'Comment récupérer votre voiture',
    'C\'est l\'heure de partir !',
    'Rendez-vous au point de retrait',
    'Déverrouillez à l\'arrivée',
    'Inspectez le véhicule',
    'Récupérez les clés',
    'En attendant le départ',
  ];

  static const List<String> _descriptions = [
    'Suivez ces étapes simples pour récupérer votre véhicule en toute sérénité.',
    '15 minutes avant le départ, une fenêtre s\'affiche automatiquement. Appuyez sur « Localiser ma voiture » pour voir le chemin.',
    'Suivez le trajet indiqué jusqu\'au parking ou à l\'adresse choisie. Le véhicule vous y attend.',
    'Une fois devant le véhicule, appuyez sur « Déverrouiller » pour lancer la vérification vidéo.',
    'Filmez l\'extérieur sous plusieurs angles pour valider l\'état du véhicule avant de partir.',
    'Après la vidéo, le véhicule se déverrouille automatiquement. Les clés sont à l\'intérieur.',
    'Retrouvez votre réservation à tout moment dans l\'application. Vous pouvez lancer une simulation avant le jour J pour tester le retrait. Nous vous enverrons aussi une notification 15 minutes avant l\'heure de retrait.',
  ];

  Widget _mockScreenFor(int idx, double width) {
    switch (idx) {
      case 0:
        return _mockWelcomeScreen(width);
      case 1:
        return _mockModalScreen(width);
      case 2:
        return _mockMapScreen(width);
      case 3:
        return _mockArrivalModalScreen(width);
      case 4:
        return _mockVideo360Screen(width);
      case 5:
        return _mockKeysScreen(width);
      case 6:
        return _mockWaitingScreen(width);
      default:
        return const SizedBox.shrink();
    }
  }

  // 0. Welcome screen — guide overview (compact, no overflow)
  Widget _mockWelcomeScreen(double width) {
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.bookOpen, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            'Guide complet',
            style: AppTypography.display(
                size: 16, weight: FontWeight.w800, letterSpacing: -0.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            'Les étapes après votre réservation',
            style: AppTypography.body(
                size: 11, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _overviewRow(icon: LucideIcons.navigation, label: 'Localiser la voiture', step: '1'),
                const SizedBox(height: 6),
                _overviewRow(icon: LucideIcons.mapPin, label: 'Aller au point de retrait', step: '2'),
                const SizedBox(height: 6),
                _overviewRow(icon: LucideIcons.unlock, label: 'Déverrouiller', step: '3'),
                const SizedBox(height: 6),
                _overviewRow(icon: LucideIcons.video, label: 'Inspecter le véhicule', step: '4'),
                const SizedBox(height: 6),
                _overviewRow(icon: LucideIcons.keyRound, label: 'Récupérer les clés', step: '5'),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // 1. Pre-rental modal — locate button
  Widget _mockModalScreen(double width) {
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                'Passer',
                style: AppTypography.body(
                    size: 12,
                    color: AppColors.textMuted,
                    weight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.car, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            'Votre Peugeot 208 est prête',
            style: AppTypography.display(
                size: 16, weight: FontWeight.w800, letterSpacing: -0.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          Text(
            'Votre location commence dans 15 minutes',
            style: AppTypography.body(
                size: 11, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _miniRow(
                    icon: LucideIcons.calendar, label: '21 mai → 24 mai'),
                const SizedBox(height: 6),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 6),
                _miniRow(
                    icon: LucideIcons.mapPin,
                    label: 'Point de retrait'),
                const SizedBox(height: 6),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 6),
                _miniRow(
                    icon: LucideIcons.clock,
                    label: 'Récupération : 09:00'),
              ],
            ),
          ),
          const Spacer(),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
              ),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gradientStart.withValues(alpha: 0.55),
                  blurRadius: 22,
                  spreadRadius: 3,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.navigation,
                    color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Localiser ma voiture',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Voir l\'itinéraire',
            style: AppTypography.body(
                size: 11,
                color: AppColors.gradientStart,
                weight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // 2. Map with route line
  Widget _mockMapScreen(double width) {
    return Stack(
      children: [
        // Map grid
        Container(
          color: const Color(0xFFE5E7EB),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5),
            itemCount: 80,
            itemBuilder: (_, __) => Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.50),
                    width: 0.5),
              ),
            ),
          ),
        ),
        // Search bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _statusBar(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Container(
                    height: 40,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.ink.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(LucideIcons.search,
                            size: 16, color: AppColors.textMuted),
                        SizedBox(width: 8),
                        Text('Point de retrait',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary)),
                        Spacer(),
                        Icon(LucideIcons.navigation,
                            size: 16, color: AppColors.gradientStart),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Route line
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          top: 80,
          child: Center(
            child: Container(
              width: 3,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.gradientStart,
                    AppColors.gradientEnd,
                  ],
                ),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
        // User dot (bottom)
        Positioned(
          bottom: 90,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.gradientStart,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gradientStart.withValues(alpha: 0.40),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
        // Car pin (top)
        Positioned(
          top: 100,
          left: 0,
          right: 0,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.gradientStart,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gradientStart.withValues(
                            alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Text('Votre Peugeot',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 2),
                const Icon(LucideIcons.mapPin,
                    color: AppColors.gradientStart, size: 30),
              ],
            ),
          ),
        ),
        // Bottom card
        Positioned(
          bottom: 14,
          left: 14,
          right: 14,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.10),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.gradientStart,
                            AppColors.gradientEnd,
                          ],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: const Icon(LucideIcons.car,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Peugeot 208',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink)),
                          SizedBox(height: 2),
                          Text('Parking A · Place 12',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.navigation,
                        size: 14, color: AppColors.gradientStart),
                    const SizedBox(width: 6),
                    Text('5 min · 1,2 km',
                        style: AppTypography.body(
                            size: 12,
                            weight: FontWeight.w800,
                            color: AppColors.ink)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 3. Arrival modal — unlock button
  Widget _mockArrivalModalScreen(double width) {
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                'Passer',
                style: AppTypography.body(
                    size: 12,
                    color: AppColors.textMuted,
                    weight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.car, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            'Vous êtes arrivé',
            style: AppTypography.display(
                size: 16, weight: FontWeight.w800, letterSpacing: -0.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          Text(
            'Votre Peugeot 208 est devant vous',
            style: AppTypography.body(
                size: 11, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _miniRow(
                    icon: LucideIcons.mapPin, label: 'Point de retrait'),
                const SizedBox(height: 6),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 6),
                _miniRow(
                    icon: LucideIcons.calendar, label: '21 mai → 24 mai'),
              ],
            ),
          ),
          const Spacer(),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
              ),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gradientStart.withValues(alpha: 0.55),
                  blurRadius: 22,
                  spreadRadius: 3,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.unlock, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Déverrouiller ma voiture',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Prochaine étape : inspection vidéo',
            style: AppTypography.body(
                size: 11,
                color: AppColors.textSecondary,
                weight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // 4. Video 360 — camera interface
  Widget _mockVideo360Screen(double width) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: const Color(0xFF111827)),
        Positioned(
          top: 14,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.ink.withValues(alpha: 0.60),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('1 / 5',
                      style: AppTypography.caps(
                          size: 10, letterSpacing: 1.2, color: AppColors.surface)),
                  const SizedBox(width: 10),
                  Container(
                      width: 1, height: 12, color: AppColors.surface.withValues(alpha: 0.3)),
                  const SizedBox(width: 10),
                  Text('Avant',
                      style: AppTypography.caps(
                          size: 10, letterSpacing: 1.2, color: AppColors.accent)),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 58,
          left: 14,
          right: 14,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.40)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.softWarm,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.gradientStart, AppColors.gradientEnd],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.car,
                              color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 8),
                        Text('Avant',
                            style: AppTypography.caps(
                                size: 10, letterSpacing: 1.4, color: AppColors.ink)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.eye, size: 12, color: AppColors.accent),
                    const SizedBox(width: 4),
                    Text('Cadrez le devant du véhicule',
                        style: AppTypography.body(
                            size: 10, color: AppColors.accent, weight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
        ),
        Center(
          child: Container(
            width: 160,
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.80), width: 2),
            ),
            child: Center(
              child: Text('Cadrer ici',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.80),
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
          )
              .animate()
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.04, 1.04),
                duration: 1500.ms,
                curve: Curves.easeInOut,
              )
              .then()
              .scale(
                begin: const Offset(1.04, 1.04),
                end: const Offset(1, 1),
                duration: 1500.ms,
                curve: Curves.easeInOut,
              ),
        ),
        Positioned(
          bottom: 120,
          left: 14,
          right: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.ink.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Filmez l\'avant du véhicule en mouvement lent pour valider l\'inspection',
              textAlign: TextAlign.center,
              style: AppTypography.body(
                  size: 11, weight: FontWeight.w800, color: AppColors.surface),
            ),
          ),
        ),
        Positioned(
          bottom: 108,
          left: 14,
          right: 14,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.2,
              minHeight: 4,
              backgroundColor: Colors.white.withValues(alpha: 0.20),
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
        ),
        Positioned(
          bottom: 72,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('● REC 2s',
                  style: AppTypography.body(
                      size: 10, weight: FontWeight.w700, color: AppColors.surface)),
            ),
          ),
        ),
        Positioned(
          bottom: 12,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Center(
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 5. Keys — unlocked success (compact, no overflow)
  Widget _mockKeysScreen(double width) {
    return Column(
      children: [
        _statusBar(),
        _appHeader(title: 'Déverrouillage'),
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 14),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.gradientStart.withValues(alpha: 0.25),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(LucideIcons.unlock, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Expanded(
                  child: Text('Véhicule déverrouillé',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800))),
              Icon(LucideIcons.checkCircle2, color: Colors.white, size: 16),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 14),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.softWarm,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.keyRound,
                    color: AppColors.gradientStart, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Clés à l\'intérieur',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink)),
                    SizedBox(height: 2),
                    Text('Dans le vide-poches côté conducteur',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 14),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _checkRow('Voiture trouvée', done: true)
                  .animate()
                  .fadeIn(delay: 100.ms, duration: 400.ms),
              const SizedBox(height: 6),
              _checkRow('Vidéo enregistrée', done: true)
                  .animate()
                  .fadeIn(delay: 250.ms, duration: 400.ms),
              const SizedBox(height: 6),
              _checkRow('Véhicule déverrouillé', done: true)
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 400.ms),
            ],
          ),
        ),
        const Spacer(),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          height: 42,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
            ),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.car, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text('Démarrer le trajet',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusBar() {
    return Container(
      height: 22,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('09:41',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink)),
          Row(
            children: [
              const Icon(LucideIcons.signal,
                  size: 10, color: AppColors.ink),
              const SizedBox(width: 3),
              const Icon(LucideIcons.wifi, size: 10, color: AppColors.ink),
              const SizedBox(width: 3),
              Container(
                  width: 14,
                  height: 7,
                  decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(2))),
            ],
          ),
        ],
      ),
    );
  }

  // 5. Waiting — real "Mes locations" interface mockup (compact)
  Widget _mockWaitingScreen(double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _statusBar(),
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('VOS COURSES',
                  style: AppTypography.caps(
                      size: 9, letterSpacing: 1.4, color: AppColors.textMuted)),
              const SizedBox(height: 1),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text('Mes ',
                              style: AppTypography.display(
                                  size: 16, weight: FontWeight.w800, letterSpacing: -0.4)),
                          const Text('locations.',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.ink,
                                  letterSpacing: -0.4)),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.softWarm,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.borderStrong),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.flaskConical,
                                size: 8, color: AppColors.gradientStart),
                            const SizedBox(width: 2),
                        Text('Tester mon retrait',
                            style: AppTypography.caps(
                                size: 7,
                                letterSpacing: 0.5,
                                color: AppColors.gradientStart,
                                weight: FontWeight.w800)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.arrowUp,
                            size: 16,
                            color: AppColors.gradientStart,
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.gradientStart,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                          'Testez votre retrait',
                          style: AppTypography.caps(
                            size: 8,
                            letterSpacing: 0.5,
                            color: AppColors.surface,
                            weight: FontWeight.w800,
                          ),
                            ),
                          ),
                        ],
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .fadeOut(duration: 700.ms, curve: Curves.easeInOut),
                    ],
                  )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 500.ms)
                      .slideY(begin: -0.1, end: 0, duration: 500.ms, delay: 600.ms),
                ],
              ),
              const SizedBox(height: 0),
              Text('Tout l\'historique de vos trajets.',
                  style: AppTypography.body(
                      size: 9, color: AppColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Stats pills
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.gradientStart, AppColors.gradientEnd],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Column(
                    children: [
                      Text('9',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                      Text('TOTAL',
                          style: TextStyle(
                              fontSize: 7,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.8)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Column(
                    children: [
                      Text('2',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink)),
                      Text('PASSÉES',
                          style: TextStyle(
                              fontSize: 7,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                              letterSpacing: 0.8)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Column(
                    children: [
                      Text('6',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink)),
                      Text('À VENIR',
                          style: TextStyle(
                              fontSize: 7,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                              letterSpacing: 0.8)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Tab bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Center(
                    child: Text('À venir',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Text('En cours',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted)),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Text('Passées',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        // Rental card — Peugeot 208
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 14),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Car image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/cars/p208_1.jpg',
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Peugeot 208',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink)),
                    const SizedBox(height: 0),
                    Text('234 TN 5678',
                        style: AppTypography.body(
                            size: 8, color: AppColors.textMuted)),
                    const SizedBox(height: 1),
                    Text('Du 21 mai au 24 mai',
                        style: AppTypography.body(
                            size: 8, color: AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.softWarm,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Confirmée',
                          style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: AppColors.gradientStart)),
                    ),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronRight,
                  size: 14, color: AppColors.textMuted),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Second card — Renault Clio
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 14),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/cars/clio_1.jpg',
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Renault Clio',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink)),
                    const SizedBox(height: 0),
                    Text('156 TN 4321',
                        style: AppTypography.body(
                            size: 8, color: AppColors.textMuted)),
                    const SizedBox(height: 1),
                    Text('Du 10 mars au 12 mars',
                        style: AppTypography.body(
                            size: 8, color: AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.softWarm,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Confirmée',
                          style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: AppColors.gradientStart)),
                    ),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronRight,
                  size: 14, color: AppColors.textMuted),
            ],
          ),
        ),
      ],
    );
  }

  Widget _appHeader({required String title}) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: AppColors.surface,
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(LucideIcons.chevronLeft,
                size: 15, color: AppColors.ink),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink)),
          ),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(LucideIcons.moreHorizontal,
                size: 15, color: AppColors.ink),
          ),
        ],
      ),
    );
  }

  Widget _overviewRow({required IconData icon, required String label, required String step}) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
        ),
      ],
    );
  }

  Widget _miniRow({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
        ),
      ],
    );
  }

  Widget _checkRow(String label, {required bool done}) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            gradient: done
                ? const LinearGradient(
                    colors: [
                      AppColors.gradientStart,
                      AppColors.gradientEnd,
                    ],
                  )
                : null,
            color: done ? null : AppColors.background,
            shape: BoxShape.circle,
            border: Border.all(
                color: done ? Colors.transparent : AppColors.border),
          ),
          child: done
              ? const Icon(LucideIcons.check,
                  size: 11, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: done ? FontWeight.w700 : FontWeight.w500,
                color: done ? AppColors.ink : AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}
