import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../data/mock_data.dart';
import '../../../data/models/booking.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

class RentalDetailScreen extends StatelessWidget {
  final String bookingId;
  const RentalDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    final booking = MockData.bookingById(bookingId);
    if (booking == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(),
        body: const Center(child: Text('Réservation introuvable')),
      );
    }
    final car = MockData.carById(booking.carId)!;
    final agency = MockData.agencyById(car.agencyId);
    final status = booking.status;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              pinned: true,
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(LucideIcons.arrowLeft,
                        size: 18, color: AppColors.ink),
                  ),
                ),
              ),
              centerTitle: true,
              title: Text(
                '— DÉTAIL DE LA COURSE',
                style: AppTypography.caps(
                  size: 11,
                  letterSpacing: 2.4,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _statusHero(status, booking)
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),
                  const SizedBox(height: 16),
                  _vehicleCard(car, booking)
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 400.ms)
                      .slideY(begin: 0.06, end: 0),
                  const SizedBox(height: 16),
                  _datesCard(booking)
                      .animate()
                      .fadeIn(delay: 150.ms, duration: 400.ms)
                      .slideY(begin: 0.06, end: 0),
                  const SizedBox(height: 16),
                  _timelineCard(status, booking)
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 400.ms)
                      .slideY(begin: 0.06, end: 0),
                  if (status != BookingStatus.cancelled) ...[
                    const SizedBox(height: 16),
                    _pickupLocationCard(context, car, status)
                        .animate()
                        .fadeIn(delay: 250.ms, duration: 400.ms)
                        .slideY(begin: 0.06, end: 0),
                  ],
                  if (agency != null) ...[
                    const SizedBox(height: 16),
                    _agencyCard(agency, context)
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 400.ms)
                        .slideY(begin: 0.06, end: 0),
                  ],
                  const SizedBox(height: 16),
                  _depositCard(status, booking)
                      .animate()
                      .fadeIn(delay: 350.ms, duration: 400.ms)
                      .slideY(begin: 0.06, end: 0),
                  const SizedBox(height: 16),
                  _totalCard(booking)
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 400.ms)
                      .slideY(begin: 0.06, end: 0),
                  const SizedBox(height: 24),
                  _actionsForStatus(context, status, booking)
                      .animate()
                      .fadeIn(delay: 450.ms, duration: 400.ms),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusHero(BookingStatus status, Booking booking) {
    late final IconData icon;
    late final String topLabel;
    late final String title;
    late final String subtitle;
    late final List<Color> gradientColors;
    late final Color iconBg;

    switch (status) {
      case BookingStatus.pending:
        icon = LucideIcons.clock;
        topLabel = '— EN ATTENTE';
        title = "Confirmation\nde l'agence";
        subtitle = "L'agence valide votre demande sous 2h.";
        gradientColors = [
          AppColors.warning.withValues(alpha: 0.18),
          AppColors.softWarm,
        ];
        iconBg = AppColors.warning;
        break;
      case BookingStatus.confirmed:
        final daysUntil = booking.startDate.difference(DateTime.now()).inDays;
        icon = LucideIcons.check;
        topLabel = '— CONFIRMÉE';
        title = "C'est parti dans\n${daysUntil > 0 ? '$daysUntil jour${daysUntil > 1 ? "s" : ""}' : 'quelques heures'}.";
        subtitle = 'Votre voiture vous attend.';
        gradientColors = [
          AppColors.gradientStart,
          AppColors.gradientEnd,
        ];
        iconBg = AppColors.surface;
        break;
      case BookingStatus.inProgress:
        icon = LucideIcons.car;
        topLabel = '— EN COURS';
        title = 'Course active.';
        subtitle = 'Profitez du voyage.';
        gradientColors = [
          AppColors.success.withValues(alpha: 0.18),
          AppColors.softWarm,
        ];
        iconBg = AppColors.success;
        break;
      case BookingStatus.completed:
        icon = LucideIcons.checkCircle2;
        topLabel = '— TERMINÉE';
        title = 'Course\ncomplétée.';
        subtitle = 'Merci pour votre voyage avec DriveTN.';
        gradientColors = [
          AppColors.success.withValues(alpha: 0.18),
          AppColors.successSoft,
        ];
        iconBg = AppColors.success;
        break;
      case BookingStatus.cancelled:
        icon = LucideIcons.x;
        topLabel = '— ANNULÉE';
        title = 'Course\nannulée.';
        subtitle = 'Votre caution a été restituée.';
        gradientColors = [
          AppColors.danger.withValues(alpha: 0.14),
          AppColors.softWarm,
        ];
        iconBg = AppColors.danger;
        break;
    }

    final isConfirmed = status == BookingStatus.confirmed;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isConfirmed ? Colors.transparent : AppColors.border,
        ),
        boxShadow: isConfirmed
            ? [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.32),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isConfirmed
                  ? AppColors.surface
                  : iconBg.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 22,
              color: isConfirmed ? AppColors.accent : iconBg,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topLabel,
                  style: AppTypography.caps(
                    size: 10,
                    letterSpacing: 2.4,
                    color: isConfirmed
                        ? AppColors.surface.withValues(alpha: 0.85)
                        : iconBg,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: AppTypography.display(
                    size: 24,
                    weight: FontWeight.w900,
                    color: isConfirmed ? AppColors.surface : AppColors.ink,
                    letterSpacing: -1,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.body(
                    size: 13,
                    color: isConfirmed
                        ? AppColors.surface.withValues(alpha: 0.85)
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _vehicleCard(car, Booking booking) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 72,
              height: 72,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFE4D6), Color(0xFFFFF1B8)],
                      ),
                    ),
                  ),
                  CachedNetworkImage(
                    imageUrl: car.photoUrls.first,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const Icon(
                      LucideIcons.car,
                      size: 32,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  car.brand.toUpperCase(),
                  style: AppTypography.caps(
                    size: 9,
                    letterSpacing: 1.6,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  car.model,
                  style: AppTypography.h2(size: 18, weight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  car.plate,
                  style: AppTypography.body(
                    size: 11,
                    color: AppColors.textMuted,
                    weight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _datesCard(Booking booking) {
    final fmt = DateFormat('d MMM yyyy', 'fr_FR');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.softWarm,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(LucideIcons.calendar,
                    size: 14, color: AppColors.accent),
              ),
              const SizedBox(width: 10),
              Text('PÉRIODE',
                  style: AppTypography.caps(
                      size: 9,
                      letterSpacing: 1.6,
                      color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DÉBUT',
                        style: AppTypography.caps(
                            size: 8,
                            letterSpacing: 1.2,
                            color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(fmt.format(booking.startDate),
                        style: AppTypography.body(
                            size: 13, weight: FontWeight.w800)),
                  ],
                ),
              ),
              const Icon(LucideIcons.arrowRight,
                  size: 14, color: AppColors.textMuted),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('FIN',
                        style: AppTypography.caps(
                            size: 8,
                            letterSpacing: 1.2,
                            color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(fmt.format(booking.endDate),
                        style: AppTypography.body(
                            size: 13, weight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('DURÉE TOTALE',
                  style: AppTypography.caps(
                      size: 9,
                      letterSpacing: 1.6,
                      color: AppColors.textMuted)),
              const Spacer(),
              Text(
                '${booking.durationDays} jour${booking.durationDays > 1 ? 's' : ''}',
                style: AppTypography.body(
                  size: 13,
                  weight: FontWeight.w800,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timelineCard(BookingStatus status, Booking booking) {
    final steps = [
      ('Réservation', LucideIcons.fileText),
      ("Confirmée par l'agence", LucideIcons.checkCircle),
      ('Voiture prête', LucideIcons.key),
      ('Course en cours', LucideIcons.car),
      ('Course terminée', LucideIcons.flag),
    ];

    int reachedStep;
    switch (status) {
      case BookingStatus.pending:
        reachedStep = 0;
        break;
      case BookingStatus.confirmed:
        reachedStep = 2;
        break;
      case BookingStatus.inProgress:
        reachedStep = 3;
        break;
      case BookingStatus.completed:
        reachedStep = 4;
        break;
      case BookingStatus.cancelled:
        reachedStep = 0;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.softWarm,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(LucideIcons.timer,
                    size: 14, color: AppColors.accent),
              ),
              const SizedBox(width: 10),
              Text('SUIVI DE LA COURSE',
                  style: AppTypography.caps(
                      size: 9,
                      letterSpacing: 1.6,
                      color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < steps.length; i++)
            _timelineRow(
              icon: steps[i].$2,
              label: steps[i].$1,
              isReached: i <= reachedStep,
              isCurrent: i == reachedStep && status != BookingStatus.completed,
              isLast: i == steps.length - 1,
            ),
        ],
      ),
    );
  }

  Widget _timelineRow({
    required IconData icon,
    required String label,
    required bool isReached,
    required bool isCurrent,
    required bool isLast,
  }) {
    final dotColor = isReached ? AppColors.accent : AppColors.border;
    final textColor = isReached ? AppColors.ink : AppColors.textMuted;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  gradient: isCurrent
                      ? const LinearGradient(
                          colors: [
                            AppColors.gradientStart,
                            AppColors.gradientEnd,
                          ],
                        )
                      : null,
                  color: isCurrent ? null : dotColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 12,
                  color: isReached ? AppColors.surface : AppColors.textMuted,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isReached ? AppColors.accent : AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 3, bottom: isLast ? 0 : 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: AppTypography.body(
                        size: 13,
                        weight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                  if (isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'EN COURS',
                        style: AppTypography.caps(
                          size: 8,
                          letterSpacing: 1.2,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pickupLocationCard(BuildContext context, car, BookingStatus status) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.softWarm,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(LucideIcons.mapPin,
                      size: 14, color: AppColors.accent),
                ),
                const SizedBox(width: 10),
                Text(
                  status == BookingStatus.completed
                      ? 'POINT DE RETRAIT'
                      : 'OÙ RETIRER LA VOITURE',
                  style: AppTypography.caps(
                      size: 9,
                      letterSpacing: 1.6,
                      color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 160,
            child: AbsorbPointer(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: car.location,
                  initialZoom: 14,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.drivetn.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: car.location,
                        width: 56,
                        height: 56,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.gradientStart,
                                    AppColors.gradientEnd,
                                  ],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.surface, width: 2.5),
                              ),
                              child: const Icon(LucideIcons.car,
                                  size: 14, color: AppColors.surface),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lat ${car.location.latitude.toStringAsFixed(4)}, Lng ${car.location.longitude.toStringAsFixed(4)}',
                        style: AppTypography.body(
                            size: 11, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tunis · ~2.4 km de vous',
                        style: AppTypography.body(
                            size: 13, weight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                if (status == BookingStatus.confirmed)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.softWarm,
                      foregroundColor: AppColors.accent,
                      elevation: 0,
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Itinéraire — mode démo')),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.navigation, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          'GO',
                          style: AppTypography.caps(
                              size: 9,
                              letterSpacing: 1.2,
                              color: AppColors.accent),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _agencyCard(agency, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.building,
                color: AppColors.surface, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('AGENCE PARTENAIRE',
                    style: AppTypography.caps(
                        size: 9,
                        letterSpacing: 1.6,
                        color: AppColors.textMuted)),
                const SizedBox(height: 2),
                Text(agency.name,
                    style: AppTypography.h2(size: 16, weight: FontWeight.w800)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 11, color: AppColors.warning),
                    const SizedBox(width: 2),
                    Text(
                      '${agency.rating} · ${agency.totalRentals} locations',
                      style: AppTypography.body(
                          size: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Appel — mode démo')),
              );
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.phone,
                  size: 16, color: AppColors.surface),
            ),
          ),
        ],
      ),
    );
  }

  Widget _depositCard(BookingStatus status, Booking booking) {
    String depositLabel;
    String depositDetail;
    Color depositColor;
    IconData depositIcon;

    switch (status) {
      case BookingStatus.pending:
        depositLabel = 'En attente de pré-autorisation';
        depositDetail = 'Sera bloquée à la confirmation';
        depositColor = AppColors.warning;
        depositIcon = LucideIcons.clock;
        break;
      case BookingStatus.confirmed:
        depositLabel = 'Pré-autorisée';
        depositDetail = "Bloquée jusqu'à la fin de la course";
        depositColor = AppColors.accent;
        depositIcon = LucideIcons.shield;
        break;
      case BookingStatus.inProgress:
        depositLabel = 'Bloquée';
        depositDetail = 'Sera libérée à la restitution';
        depositColor = AppColors.accent;
        depositIcon = LucideIcons.shieldCheck;
        break;
      case BookingStatus.completed:
        depositLabel = 'Remboursée';
        depositDetail =
            "Libérée le ${DateFormat('d MMM', 'fr_FR').format(booking.endDate.add(const Duration(days: 1)))}";
        depositColor = AppColors.success;
        depositIcon = LucideIcons.checkCircle2;
        break;
      case BookingStatus.cancelled:
        depositLabel = 'Restituée';
        depositDetail = 'Annulation gratuite — 0 DT retenu';
        depositColor = AppColors.success;
        depositIcon = LucideIcons.checkCircle2;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: depositColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(depositIcon, size: 16, color: depositColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'CAUTION',
                      style: AppTypography.caps(
                          size: 9,
                          letterSpacing: 1.6,
                          color: AppColors.textMuted),
                    ),
                    Text(depositLabel,
                        style: AppTypography.body(
                            size: 13,
                            weight: FontWeight.w800,
                            color: depositColor)),
                  ],
                ),
              ),
              Text(
                '${booking.depositAmount.toInt()} DT',
                style: AppTypography.numeric(
                    size: 22,
                    weight: FontWeight.w900,
                    color: depositColor,
                    letterSpacing: -0.6),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: 8),
          Text(depositDetail,
              style:
                  AppTypography.body(size: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _totalCard(Booking booking) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.softWarm,
            AppColors.softWarm.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('TOTAL PAYÉ',
                  style: AppTypography.caps(
                      size: 10,
                      letterSpacing: 2,
                      color: AppColors.textMuted)),
              const SizedBox(height: 2),
              Text('Inclus, taxes comprises',
                  style: AppTypography.body(
                      size: 11, color: AppColors.textMuted)),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${booking.totalPrice.toInt()}',
                style: AppTypography.numeric(
                    size: 36,
                    weight: FontWeight.w900,
                    color: AppColors.accent,
                    letterSpacing: -1.4),
              ),
              const SizedBox(width: 4),
              Text('DT',
                  style: AppTypography.caps(
                      size: 12, letterSpacing: 1.4, color: AppColors.accent)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionsForStatus(
      BuildContext context, BookingStatus status, Booking booking) {
    switch (status) {
      case BookingStatus.pending:
      case BookingStatus.confirmed:
        return Column(
          children: [
            PrimaryButton(
              label: "Contacter l'agence",
              icon: LucideIcons.messageCircle,
              variant: ButtonVariant.gradient,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Messagerie — mode démo')),
                );
              },
            ),
            const SizedBox(height: 10),
            PrimaryButton(
              label: 'Annuler la réservation',
              icon: LucideIcons.x,
              variant: ButtonVariant.light,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Annuler la réservation ?'),
                    content: const Text(
                        "Annulation gratuite jusqu'à 24h avant le départ."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Non'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Confirmer'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      case BookingStatus.completed:
        return Column(
          children: [
            PrimaryButton(
              label: 'Télécharger la facture',
              icon: LucideIcons.download,
              variant: ButtonVariant.gradient,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Facture — mode démo')),
                );
              },
            ),
            const SizedBox(height: 10),
            PrimaryButton(
              label: 'Réserver à nouveau',
              icon: LucideIcons.refreshCw,
              variant: ButtonVariant.light,
              onPressed: () => context.go('/car/${booking.carId}'),
            ),
          ],
        );
      case BookingStatus.cancelled:
        return PrimaryButton(
          label: 'Réserver une autre voiture',
          icon: LucideIcons.search,
          variant: ButtonVariant.gradient,
          onPressed: () => context.go('/home/explorer'),
        );
      case BookingStatus.inProgress:
        return PrimaryButton(
          label: 'Voir le tableau de bord',
          icon: LucideIcons.gauge,
          variant: ButtonVariant.gradient,
          onPressed: () => context.go('/rental/${booking.id}'),
        );
    }
  }
}
