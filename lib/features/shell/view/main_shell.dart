import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

/// Fixed bottom tab bar (Airbnb style).
/// - Full-width, pinned to the bottom with a top border.
/// - Opaque surface background (no blur, no float).
/// - 5 tabs: icon + label.
/// - Coral accent for active; muted grey for inactive.
class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _tabs = [
    ('/discovery', LucideIcons.search, 'Recherche'),
    ('/home/favorites', LucideIcons.heart, 'Favoris'),
    ('/home/rentals', LucideIcons.key, 'Locations'),
    ('/home/messages', LucideIcons.messageSquare, 'Messagerie'),
    ('/home/profile', LucideIcons.user, 'Compte'),
  ];

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _indexOfLocation(String location) {
    if (location == '/discovery' || location.startsWith('/home/explorer')) return 0;
    for (int i = 0; i < MainShell._tabs.length; i++) {
      if (location.startsWith(MainShell._tabs[i].$1)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexOfLocation(location);

    return Scaffold(
      extendBody: true,
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.border),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                for (int i = 0; i < MainShell._tabs.length; i++)
                  Expanded(
                    child: _TabButton(
                      icon: MainShell._tabs[i].$2,
                      label: MainShell._tabs[i].$3,
                      active: i == currentIndex,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.go(MainShell._tabs[i].$1);
                      },
                    ),
                  ),
              ],
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
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.body(
                size: 11,
                weight: active ? FontWeight.w600 : FontWeight.w500,
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
