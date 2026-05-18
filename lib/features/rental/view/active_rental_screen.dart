import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../data/mock_data.dart';
import '../../../data/models/agency.dart';
import '../../../data/models/booking.dart';
import '../../../data/models/car.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../bloc/rental_cubit.dart';
import '../bloc/rental_state.dart';

/// Course active — redesigned as a "Trip Card".
/// No telemetry, no live tracking. Just what the driver actually needs.
class ActiveRentalScreen extends StatefulWidget {
  final String bookingId;
  const ActiveRentalScreen({super.key, required this.bookingId});

  @override
  State<ActiveRentalScreen> createState() => _ActiveRentalScreenState();
}

class _ActiveRentalScreenState extends State<ActiveRentalScreen> {
  RentalCubit? _rentalCubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RentalCubit>().start(widget.bookingId);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rentalCubit ??= context.read<RentalCubit>();
  }

  @override
  void dispose() {
    _rentalCubit?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final booking = MockData.bookingById(widget.bookingId);
    if (booking == null) {
      return const Scaffold(body: Center(child: Text('Location introuvable')));
    }
    final car = MockData.carById(booking.carId);
    final agency = MockData.agencyById(car?.agencyId ?? '');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<RentalCubit, RentalState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              _appBar(),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _tripIdentityCard(booking, car, agency)
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),
                    const SizedBox(height: 24),
                    _timeLeftCard(booking)
                        .animate()
                        .fadeIn(delay: 80.ms, duration: 400.ms)
                        .slideY(begin: 0.06, end: 0),
                    const SizedBox(height: 24),
                    _whatsIncludedCard()
                        .animate()
                        .fadeIn(delay: 140.ms, duration: 400.ms)
                        .slideY(begin: 0.06, end: 0),
                    const SizedBox(height: 24),
                    _returnLocationCard(agency)
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 400.ms)
                        .slideY(begin: 0.06, end: 0),
                    const SizedBox(height: 24),
                    _helpActions(context, state)
                        .animate()
                        .fadeIn(delay: 260.ms, duration: 400.ms)
                        .slideY(begin: 0.06, end: 0),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _bottomReturnBar(context, booking),
    );
  }

  // ─────────────────────────── app bar ───────────────────────────

  Widget _appBar() {
    return SliverAppBar(
      backgroundColor: AppColors.background,
      surfaceTintColor: AppColors.background,
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
        'VOTRE LOCATION',
        style: AppTypography.caps(
          size: 11,
          letterSpacing: 2.4,
          color: AppColors.textMuted,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
          child: GestureDetector(
            onTap: () => context.go('/home/rentals'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                'Quitter',
                style: AppTypography.caps(
                  size: 10,
                  letterSpacing: 0.5,
                  color: AppColors.textSecondary,
                  weight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────── trip identity ───────────────────────────

  Widget _tripIdentityCard(Booking booking, Car? car, Agency? agency) {
    final fmt = DateFormat('d MMM', 'fr_FR');
    final timeFmt = DateFormat('HH:mm', 'fr_FR');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.borderStrong.withValues(alpha: 0.6),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successSoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat())
                        .fadeOut(duration: 1200.ms, curve: Curves.easeInOut),
                    const SizedBox(width: 6),
                    Text(
                      'LOCATION ACTIVE',
                      style: AppTypography.caps(
                        size: 9,
                        letterSpacing: 1.6,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (car != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: CachedNetworkImage(
                      imageUrl: car.photoUrls.first,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.softWarm,
                        child: const Icon(LucideIcons.car,
                            size: 32, color: AppColors.textMuted),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${car?.brand ?? ''} ${car?.model ?? 'Véhicule'}',
                      style: AppTypography.display(
                        size: 22,
                        weight: FontWeight.w900,
                        color: AppColors.ink,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      car?.plate ?? '',
                      style: AppTypography.body(
                        size: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${fmt.format(booking.startDate)} à ${timeFmt.format(booking.startDate)} — ${fmt.format(booking.endDate)} à ${timeFmt.format(booking.endDate)}',
                      style: AppTypography.body(
                        size: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (agency != null) ...[
            const SizedBox(height: 14),
            Container(height: 1, color: AppColors.border),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(LucideIcons.building,
                    size: 14, color: AppColors.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Avec ${agency.name}',
                    style: AppTypography.body(
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────── time left ───────────────────────────

  Widget _timeLeftCard(Booking booking) {
    final now = DateTime.now();
    final remaining = booking.endDate.difference(now);
    final daysLeft = remaining.inDays;
    final hoursLeft = remaining.inHours;
    final isOverdue = remaining.isNegative;

    String headline;
    String sub;
    if (isOverdue) {
      headline = 'Retard de ${remaining.abs().inHours}h';
      sub = 'Contactez l\'agence rapidement';
    } else if (daysLeft > 1) {
      headline = '$daysLeft jours restants';
      sub = 'Retour le ${DateFormat('d MMMM à HH:mm', 'fr_FR').format(booking.endDate)}';
    } else if (hoursLeft > 1) {
      headline = '$hoursLeft heures restantes';
      sub = 'Retour prévu à ${DateFormat('HH:mm', 'fr_FR').format(booking.endDate)}';
    } else {
      headline = 'Retour dans ${remaining.inMinutes} min';
      sub = 'Dirigez-vous vers le point de restitution';
    }

    return Container(
      padding: const EdgeInsets.all(20),
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
                  color: isOverdue
                      ? AppColors.danger.withValues(alpha: 0.12)
                      : AppColors.softWarm,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isOverdue ? LucideIcons.alertTriangle : LucideIcons.hourglass,
                  size: 14,
                  color: isOverdue ? AppColors.danger : AppColors.accent,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'DURÉE RESTANTE',
                style: AppTypography.caps(
                    size: 9, letterSpacing: 1.6, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            headline,
            style: AppTypography.h2(
              size: 20,
              weight: FontWeight.w900,
              color: isOverdue ? AppColors.danger : AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: AppTypography.body(
              size: 14,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────── what's included ───────────────────────────

  Widget _whatsIncludedCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(LucideIcons.shieldCheck, 'INCLUS DANS VOTRE LOCATION'),
          const SizedBox(height: 14),
          _includedRow(LucideIcons.shield, 'Assurance tous risques active'),
          _includedRow(LucideIcons.truck, 'Assistance routière 24/7'),
          _includedRow(LucideIcons.milestone, '200 km inclus'),
          _includedRow(LucideIcons.droplets, 'Carburant plein/plein'),
        ],
      ),
    );
  }

  Widget _includedRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.success),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTypography.body(
                size: 14,
                color: AppColors.ink,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────── return location ───────────────────────────

  Widget _returnLocationCard(Agency? agency) {
    if (agency == null) return const SizedBox.shrink();

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
            child: _cardHeader(LucideIcons.mapPin, 'POINT DE RESTITUTION'),
          ),
          SizedBox(
            height: 140,
            child: AbsorbPointer(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: MockData.tunisCenter,
                  initialZoom: 13,
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
                        agency.name,
                        style: AppTypography.body(
                            size: 15, weight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        agency.address,
                        style: AppTypography.body(
                            size: 13, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.softWarm,
                    foregroundColor: AppColors.accent,
                    elevation: 0,
                    minimumSize: Size.zero,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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

  // ─────────────────────────── help actions ───────────────────────────

  Widget _helpActions(BuildContext context, RentalState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _actionChip(
          icon: state.isLocked ? LucideIcons.lock : LucideIcons.unlock,
          label: state.isLocked ? 'Verrouillée' : 'Déverrouillée',
          onTap: () {
            HapticFeedback.lightImpact();
            context.read<RentalCubit>().toggleLock();
          },
        ),
        _actionChip(
          icon: LucideIcons.messageCircle,
          label: 'Messagerie',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Messagerie — mode démo')),
            );
          },
        ),
        _actionChip(
          icon: LucideIcons.phone,
          label: 'Assistance',
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: AppColors.surface,
                title: Text('Assistance',
                    style: AppTypography.h2(size: 18)),
                content: Text(
                  'Appelez votre agence partenaire',
                  style: AppTypography.body(size: 14),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _actionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 92,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.ink, size: 22),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.caps(
                size: 9,
                letterSpacing: 0.5,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────── bottom bar ───────────────────────────

  Widget _bottomReturnBar(BuildContext context, Booking booking) {
    final now = DateTime.now();
    final isNearReturn = booking.endDate.difference(now).inHours <= 2;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isNearReturn)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'Votre location se termine bientôt',
                  style: AppTypography.body(
                    size: 13,
                    color: AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            PrimaryButton(
              label: 'Rendre le véhicule',
              icon: LucideIcons.arrowRight,
              variant: ButtonVariant.gradient,
              height: 48,
              onPressed: () {
                context.read<RentalCubit>().stop();
                context.push('/inspection/return/${widget.bookingId}');
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────── helpers ───────────────────────────

  Widget _cardHeader(IconData icon, String label) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.softWarm,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: AppColors.accent),
        ),
        const SizedBox(width: 10),
        Text(label,
            style: AppTypography.caps(
                size: 9, letterSpacing: 1.6, color: AppColors.textMuted)),
      ],
    );
  }
}
