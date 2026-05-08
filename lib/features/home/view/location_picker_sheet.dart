import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class LocationPickerSheet extends StatefulWidget {
  const LocationPickerSheet({super.key});

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LocationPickerSheet(),
    );
  }

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  final TextEditingController _searchCtrl = TextEditingController();

  static const _recentLocations = [
    'Tunis Centre',
    'La Marsa',
    'Lac 1 — Berges du Lac',
    'Ariana — Centre',
    'Carthage',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
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
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: Row(
                    children: [
                      const SizedBox(width: 40),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Adresse de location',
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
                // Search field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.search,
                            size: 18, color: AppColors.textMuted),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            autofocus: true,
                            cursorColor: AppColors.accent,
                            style: AppTypography.body(
                              size: 14,
                              weight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Quartier, gare, hôtel...',
                              hintStyle: AppTypography.body(
                                size: 14,
                                color: AppColors.textMuted,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        if (_searchCtrl.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchCtrl.clear();
                              setState(() {});
                            },
                            child: const Icon(LucideIcons.x,
                                size: 16, color: AppColors.textMuted),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // List
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _row(
                        icon: LucideIcons.navigation,
                        iconColor: AppColors.accent,
                        title: 'Position actuelle',
                        subtitle: 'Utiliser le GPS',
                        gradient: true,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop('Position actuelle');
                        },
                      ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.06, end: 0),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                        child: Text(
                          '— RÉCENTS',
                          style: AppTypography.caps(
                            size: 10,
                            letterSpacing: 2.4,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      for (int i = 0; i < _recentLocations.length; i++)
                        _row(
                          icon: LucideIcons.history,
                          iconColor: AppColors.textMuted,
                          title: _recentLocations[i],
                          subtitle: 'Tunis, TN',
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).pop(_recentLocations[i]);
                          },
                        )
                            .animate()
                            .fadeIn(
                                delay: (80 + 60 * i).ms,
                                duration: 350.ms)
                            .slideY(begin: 0.06, end: 0),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _row({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    bool gradient = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: gradient
                    ? const LinearGradient(
                        colors: [
                          AppColors.gradientStart,
                          AppColors.gradientEnd,
                        ],
                      )
                    : null,
                color: gradient ? null : AppColors.softWarm,
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
            const Icon(LucideIcons.chevronRight,
                size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
