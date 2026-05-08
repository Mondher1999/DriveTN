import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../data/mock_data.dart';
import '../../../data/models/booking.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _lang = 'FR';

  @override
  Widget build(BuildContext context) {
    final profile = MockData.profile;
    final completedTrips =
        MockData.bookings.where((b) => b.status == BookingStatus.completed).length;
    final firstName = profile.name.split(' ').first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(top: 16, bottom: 120),
          children: [
            // Hero
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '— BONJOUR',
                    style: AppTypography.caps(
                      size: 10,
                      letterSpacing: 3,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          firstName,
                          style: AppTypography.display(
                            size: 32,
                            weight: FontWeight.w900,
                            letterSpacing: -1.4,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          ", c'est vous.",
                          style: AppTypography.display(
                            size: 32,
                            weight: FontWeight.w300,
                            italic: true,
                            letterSpacing: -1.4,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.accent, width: 2),
                            ),
                            child: ClipOval(
                              child: Image.network(
                                profile.avatarUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: AppColors.softWarm,
                                  child: const Icon(LucideIcons.user,
                                      size: 28, color: AppColors.accent),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.warning.withValues(alpha: 0.6),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.star_rounded,
                                  size: 14, color: AppColors.warning),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.name,
                              style:
                                  AppTypography.h2(size: 17, weight: FontWeight.w800),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    size: 12, color: AppColors.warning),
                                const SizedBox(width: 3),
                                Text(
                                  '4.9 · Voyageur Premium',
                                  style: AppTypography.body(
                                    size: 12,
                                    weight: FontWeight.w700,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 420.ms).slideY(begin: 0.06, end: 0),

            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: _statTile(
                      value: '$completedTrips',
                      label: 'TRAJETS',
                      gradient: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: _statTile(value: '1,847', label: 'KM TOTAL')),
                  const SizedBox(width: 10),
                  Expanded(child: _statTile(value: '9', label: 'AVIS')),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 420.ms).slideY(begin: 0.06, end: 0),

            const SizedBox(height: 24),

            // Menu card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _menuRow(
                    icon: LucideIcons.shieldCheck,
                    label: 'Documents (KYC)',
                    subtitle: 'À vérifier',
                    iconBg: AppColors.accent.withValues(alpha: 0.12),
                    onTap: () => _showKycSheet(context),
                  ),
                  _divider(),
                  _menuRow(
                    icon: LucideIcons.bell,
                    label: 'Notifications',
                    subtitle: '3 nouvelles',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mode démo')),
                      );
                    },
                  ),
                  _divider(),
                  _menuRow(
                    icon: LucideIcons.globe,
                    label: 'Langue',
                    subtitle: _lang == 'FR'
                        ? 'Français'
                        : (_lang == 'AR' ? 'العربية' : 'English'),
                    onTap: () => _showLanguageDialog(context),
                  ),
                  _divider(),
                  _menuRow(
                    icon: LucideIcons.lifeBuoy,
                    label: 'Aide & support',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mode démo')),
                      );
                    },
                  ),
                  _divider(),
                  _menuRow(
                    icon: LucideIcons.info,
                    label: 'À propos',
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'DriveTN',
                        applicationVersion: '0.1.0',
                      );
                    },
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 420.ms).slideY(begin: 0.06, end: 0),

            const SizedBox(height: 16),

            // Logout
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: _menuRow(
                icon: LucideIcons.logOut,
                label: 'Se déconnecter',
                iconBg: AppColors.danger.withValues(alpha: 0.12),
                iconColor: AppColors.danger,
                destructive: true,
                onTap: () => context.go('/login'),
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 420.ms).slideY(begin: 0.06, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _statTile({
    required String value,
    required String label,
    bool gradient = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: gradient ? null : AppColors.surface,
        gradient: gradient
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
              )
            : null,
        borderRadius: BorderRadius.circular(18),
        border: gradient ? null : Border.all(color: AppColors.border),
        boxShadow: gradient
            ? [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTypography.numeric(
              size: 28,
              weight: FontWeight.w900,
              color: gradient ? AppColors.surface : AppColors.ink,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.caps(
              size: 9,
              letterSpacing: 1.6,
              color: gradient
                  ? AppColors.surface.withValues(alpha: 0.85)
                  : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuRow({
    required IconData icon,
    required String label,
    String? subtitle,
    Color? iconBg,
    Color? iconColor,
    bool destructive = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg ?? AppColors.softWarm,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 18, color: iconColor ?? AppColors.accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTypography.body(
                      size: 14,
                      weight: FontWeight.w700,
                      color: destructive ? AppColors.danger : AppColors.ink,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style:
                          AppTypography.body(size: 11, color: AppColors.textMuted),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight,
                size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Container(height: 1, color: AppColors.border),
      );

  void _showKycSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mes documents (KYC)',
              style: AppTypography.h2(size: 18, weight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              'À fournir lors de votre 1ère réservation',
              style: AppTypography.body(size: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Fermer',
              variant: ButtonVariant.light,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Langue'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['FR', 'AR', 'EN']
                .map((l) => RadioListTile<String>(
                      value: l,
                      groupValue: _lang,
                      title: Text(l),
                      onChanged: (v) {
                        setState(() => _lang = v!);
                        setSt(() {});
                        Navigator.pop(ctx);
                      },
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}
