import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../data/mock_data.dart';
import '../../../data/models/booking.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../booking/view/pre_rental_unlock_modal.dart';

class MyRentalsScreen extends StatefulWidget {
  const MyRentalsScreen({super.key});

  @override
  State<MyRentalsScreen> createState() => _MyRentalsScreenState();
}

class _MyRentalsScreenState extends State<MyRentalsScreen> {
  bool _modalShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPreRentalModalIfNeeded();
    });
  }

  void _showPreRentalModalIfNeeded() {
    if (_modalShown) return;
    final now = DateTime.now();
    final upcoming = MockData.bookings.where(
      (b) =>
          b.status == BookingStatus.confirmed &&
          b.startDate.isAfter(now) &&
          b.startDate.difference(now).inMinutes <= 15,
    );
    if (upcoming.isNotEmpty && mounted) {
      _modalShown = true;
      PreRentalUnlockModal.show(context);
    }
  }

  bool _isWithin15Min(Booking booking) {
    final now = DateTime.now();
    return booking.status == BookingStatus.confirmed &&
        booking.startDate.isAfter(now) &&
        booking.startDate.difference(now).inMinutes <= 15;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final upcoming = MockData.bookings
        .where((b) => b.status == BookingStatus.confirmed && b.startDate.isAfter(now))
        .toList();
    final inProgress =
        MockData.bookings.where((b) => b.status == BookingStatus.inProgress).toList();
    final past = MockData.bookings
        .where((b) => b.status == BookingStatus.completed || b.status == BookingStatus.cancelled)
        .toList();

    final totalCount = MockData.bookings.length;
    final completedCount =
        MockData.bookings.where((b) => b.status == BookingStatus.completed).length;
    final upcomingCount =
        MockData.bookings.where((b) => b.status == BookingStatus.confirmed).length;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Hero header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '— VOS COURSES',
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
                        Text(
                          'Mes',
                          style: AppTypography.display(
                            size: 36,
                            weight: FontWeight.w900,
                            letterSpacing: -1.4,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'locations.',
                          style: AppTypography.display(
                            size: 36,
                            weight: FontWeight.w300,
                            italic: true,
                            letterSpacing: -1.4,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Tout l'historique de vos trajets.",
                      style: AppTypography.body(size: 13, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 420.ms).slideY(begin: 0.06, end: 0),

              // Stats row
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _statTile(
                          value: '$totalCount', label: 'TOTAL', gradient: true),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _statTile(value: '$completedCount', label: 'PASSÉES'),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _statTile(value: '$upcomingCount', label: 'À VENIR'),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 420.ms).slideY(begin: 0.06, end: 0),

              const SizedBox(height: 16),

              // TabBar pill
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: AppColors.surface,
                    unselectedLabelColor: AppColors.textMuted,
                    labelStyle: AppTypography.body(
                        size: 12, weight: FontWeight.w800, letterSpacing: 0.2),
                    unselectedLabelStyle:
                        AppTypography.body(size: 12, weight: FontWeight.w600),
                    dividerColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    tabs: const [
                      Tab(text: 'À venir'),
                      Tab(text: 'En cours'),
                      Tab(text: 'Passées'),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 420.ms),

              const SizedBox(height: 8),

              Expanded(
                child: TabBarView(
                  children: [
                    _buildList(context, upcoming),
                    _buildList(context, inProgress),
                    _buildList(context, past),
                  ],
                ),
              ),
            ],
          ),
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

  Widget _buildList(BuildContext context, List<Booking> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.softWarm,
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.calendar, size: 40, color: AppColors.accent),
              ),
              const SizedBox(height: 18),
              Text(
                'Rien ici.',
                style: AppTypography.display(
                  size: 22,
                  weight: FontWeight.w300,
                  italic: true,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Vos prochaines courses apparaîtront ici.',
                textAlign: TextAlign.center,
                style: AppTypography.body(size: 13, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 420.ms);
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
      itemCount: bookings.length,
      itemBuilder: (_, i) => _bookingCard(context, bookings[i], i),
    );
  }

  Widget _bookingCard(BuildContext context, Booking booking, int index) {
    final car = MockData.carById(booking.carId);
    final df = DateFormat('d MMM', 'fr_FR');
    final dates = 'Du ${df.format(booking.startDate)} au ${df.format(booking.endDate)}';
    final showUnlock = _isWithin15Min(booking);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _PressableCard(
        onTap: () {
          HapticFeedback.lightImpact();
          if (showUnlock) {
            PreRentalUnlockModal.show(context);
          } else if (booking.status == BookingStatus.inProgress) {
            context.push('/rental/${booking.id}');
          } else {
            context.push('/booking-detail/${booking.id}');
          }
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: showUnlock ? AppColors.gradientStart.withValues(alpha: 0.40) : AppColors.border,
              width: showUnlock ? 1.5 : 1,
            ),
            boxShadow: showUnlock
                ? [
                    BoxShadow(
                      color: AppColors.gradientStart.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: car != null && car.photoUrls.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: car.photoUrls.first,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(
                                  color: AppColors.border,
                                  child: const Icon(LucideIcons.car)),
                            )
                          : Container(
                              color: AppColors.border,
                              child: const Icon(LucideIcons.car)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          car?.displayName ?? 'Véhicule',
                          style: AppTypography.h2(size: 15, weight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          car?.plate ?? '',
                          style: AppTypography.caps(
                            size: 10,
                            letterSpacing: 1.4,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          dates,
                          style: AppTypography.body(
                              size: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        _statusBadge(booking.status, showUnlock),
                      ],
                    ),
                  ),
                  Icon(
                    showUnlock ? LucideIcons.unlock : LucideIcons.chevronRight,
                    size: 18,
                    color: showUnlock ? AppColors.gradientStart : AppColors.textMuted,
                  ),
                ],
              ),
              if (showUnlock) ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    PreRentalUnlockModal.show(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.gradientStart, AppColors.gradientEnd],
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.unlock, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Déverrouiller ma voiture',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (60 * index).ms, duration: 380.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _statusBadge(BookingStatus status, bool readyToUnlock) {
    String label;
    Color color;
    bool pulse = false;
    if (readyToUnlock) {
      label = 'Prête — 15 min';
      color = AppColors.gradientStart;
      pulse = true;
    } else {
      switch (status) {
        case BookingStatus.pending:
          label = 'En attente';
          color = AppColors.warning;
          break;
        case BookingStatus.confirmed:
          label = 'Confirmée';
          color = AppColors.accent;
          break;
        case BookingStatus.inProgress:
          label = 'En cours';
          color = AppColors.success;
          pulse = true;
          break;
        case BookingStatus.completed:
          label = 'Terminée';
          color = AppColors.textMuted;
          break;
        case BookingStatus.cancelled:
          label = 'Annulée';
          color = AppColors.danger;
          break;
      }
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pulse) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fadeIn(duration: 700.ms)
                .then()
                .fadeOut(duration: 700.ms),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: AppTypography.caps(
              size: 10,
              letterSpacing: 1.2,
              color: color,
              weight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tap-down scale wrapper for cards.
class _PressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _PressableCard({required this.child, this.onTap});

  @override
  State<_PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<_PressableCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap == null ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.onTap == null ? null : (_) => setState(() => _pressed = false),
      onTapCancel: widget.onTap == null ? null : () => setState(() => _pressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
