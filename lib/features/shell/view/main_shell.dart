import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

/// Modern floating bottom tab bar.
/// - Frosted-glass white capsule, detached with margin.
/// - Subtle light pill behind the active tab.
/// - 4 tabs: icon + label, horizontal layout.
/// - Coral accent for active; muted grey for inactive.
class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _tabs = [
    ('/home/explorer', LucideIcons.search, 'Recherche'),
    ('/home/rentals', LucideIcons.key, 'Locations'),
    ('/home/messages', LucideIcons.messageSquare, 'Messagerie'),
    ('/home/profile', LucideIcons.user, 'Compte'),
  ];

  int _indexOfLocation(String location) {
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].$1)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexOfLocation(location);

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.ink.withValues(alpha: 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final tabWidth = constraints.maxWidth / _tabs.length;
                    return Stack(
                      children: [
                        // Subtle pill behind active tab
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic,
                          left: tabWidth * currentIndex + 4,
                          top: 4,
                          bottom: 4,
                          width: tabWidth - 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.border),
                            ),
                          ),
                        ),
                        // Tab buttons
                        Row(
                          children: [
                            for (int i = 0; i < _tabs.length; i++)
                              Expanded(
                                child: _TabButton(
                                  icon: _tabs[i].$2,
                                  label: _tabs[i].$3,
                                  active: i == currentIndex,
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    context.go(_tabs[i].$1);
                                  },
                                ),
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.accent : AppColors.textMuted;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutBack,
              scale: active ? 1.05 : 0.92,
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTypography.body(
                size: 11,
                weight: active ? FontWeight.w700 : FontWeight.w500,
                color: color,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
