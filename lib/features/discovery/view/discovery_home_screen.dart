import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../data/mock_data.dart';
import '../../../data/models/agency.dart';
import '../../../data/models/car.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../favorites/bloc/favorites_cubit.dart';
import '../../home/bloc/cars_cubit.dart';
import '../../home/view/location_date_flow_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DiscoveryHomeScreen extends StatelessWidget {
  const DiscoveryHomeScreen({super.key});

  static const List<_ExperienceItem> _experiences = [
    _ExperienceItem(
      label: 'Visite & Vacances',
      sub: 'Tourisme & détente',
      icon: LucideIcons.umbrella,
      bg: Color(0xFFFFE4D6),
      iconColor: Color(0xFFFF5E3A),
      categories: {CarCategory.city, CarCategory.sedan, CarCategory.suv},
    ),
    _ExperienceItem(
      label: 'Événement',
      sub: 'Mariage & cérémonie',
      icon: LucideIcons.sparkles,
      bg: Color(0xFFFFF1B8),
      iconColor: Color(0xFFF59E0B),
      categories: {CarCategory.sedan, CarCategory.collection, CarCategory.coupe},
    ),
    _ExperienceItem(
      label: 'Business',
      sub: 'Élégance & professionnel',
      icon: LucideIcons.briefcase,
      bg: Color(0xFFE6F3FF),
      iconColor: Color(0xFF3B82F6),
      categories: {CarCategory.sedan, CarCategory.coupe},
    ),
    _ExperienceItem(
      label: 'Longue durée',
      sub: 'Séjour prolongé',
      icon: LucideIcons.calendar,
      bg: Color(0xFFE6F9F1),
      iconColor: Color(0xFF10B981),
      categories: {CarCategory.city, CarCategory.sedan, CarCategory.suv, CarCategory.family},
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final topPicks = MockData.cars
        .where((c) => c.rating >= 4.8 && c.reviewsCount > 80)
        .toList();

    final topPickIds = topPicks.map((c) => c.id).toSet();

    final budgetCars = MockData.cars
        .where((c) => c.dailyPrice < 100 && !topPickIds.contains(c.id))
        .toList();

    final offers = MockData.cars
        .where((c) => c.rating >= 4.5 && c.dailyPrice <= 150 && !topPickIds.contains(c.id))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenue 👋',
                      style: AppTypography.body(
                        size: 15, color: AppColors.textMuted, weight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "La Tunisie\nt'attend",
                            style: AppTypography.display(
                              size: 34, weight: FontWeight.w900, letterSpacing: -1.3, height: 1.08, color: AppColors.ink,
                            ),
                          ),
                          TextSpan(
                            text: ' 🌊',
                            style: AppTypography.display(
                              size: 32, weight: FontWeight.w900, letterSpacing: -0.5, height: 1.05, color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () async {
                        final result = await LocationDateFlowSheet.show(
                          context,
                          initialStep: 0,
                        );
                        if (result != null && context.mounted) {
                          context.read<CarsCubit>().setSearchLocation(result.location);
                          context.read<CarsCubit>().setSearchDates((result.start, result.end));
                          context.go('/home/explorer');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.ink.withValues(alpha: 0.06),
                              blurRadius: 12, offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.search, size: 18, color: AppColors.accent),
                            const SizedBox(width: 10),
                            Text(
                              'Quelle voiture cherchez-vous ?',
                              style: AppTypography.body(
                                size: 14,
                                weight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Expériences ──
            _sectionTitle('Expériences', top: 24, bottom: 12, subtitle: 'Choisissez votre expérience de conduite'),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _experiences.length,
                  itemBuilder: (context, index) {
                    final exp = _experiences[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _ExperienceCard(
                        item: exp,
                        onTap: () => _onExperienceTap(context, exp.categories),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ── Meilleures offres ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Meilleures offres',
                                style: AppTypography.h1(
                                  size: 18, weight: FontWeight.w800, letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.danger.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'Cette semaine',
                                  style: AppTypography.caps(
                                    size: 9, letterSpacing: 1.2, color: AppColors.danger,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${offers.length} voitures à prix réduit',
                            style: AppTypography.body(size: 13, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _onVoirToutTap(context, offersFilter: true),
                      child: Text(
                        'Voir tout',
                        style: AppTypography.body(size: 13, weight: FontWeight.w700, color: AppColors.accent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildCarCarousel(offers, context),

            // ── Top choix ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Top choix',
                            style: AppTypography.h1(size: 18, weight: FontWeight.w800, letterSpacing: -0.5),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Les mieux notées par nos clients',
                            style: AppTypography.body(size: 13, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _onVoirToutTap(context, topPicksFilter: true),
                      child: Text(
                        'Voir tout',
                        style: AppTypography.body(size: 13, weight: FontWeight.w700, color: AppColors.accent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildCarCarousel(topPicks, context),

            // ── Petits budgets ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Petits budgets',
                            style: AppTypography.h1(size: 18, weight: FontWeight.w800, letterSpacing: -0.5),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Moins de 100 DT par jour',
                            style: AppTypography.body(size: 13, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _onVoirToutTap(context, budgetFilter: true),
                      child: Text(
                        'Voir tout',
                        style: AppTypography.body(size: 13, weight: FontWeight.w700, color: AppColors.accent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildCarCarousel(budgetCars, context),

            // ── Agences de confiance ──
            _sectionTitle('Agences de confiance', top: 20, bottom: 10, subtitle: 'Partenaires vérifiés et bien notés'),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: MockData.agencies.length,
                  itemBuilder: (context, index) {
                    final agency = MockData.agencies[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _AgencyCard(
                        agency: agency,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.go('/home/explorer');
                        },
                      ),
                    );
                  },
                ),
              ),
            ),

            // ── Guided wizard CTA ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: GestureDetector(
                  onTap: () => context.go('/wizard'),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [AppColors.gradientStart, AppColors.gradientEnd],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Row(
                      children: [
                        Icon(LucideIcons.sparkles, size: 22, color: AppColors.surface),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Trouvez votre voiture',
                                style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.surface,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Notre assistant trouve pour vous en 1 min',
                                style: TextStyle(
                                  fontSize: 13, color: AppColors.surface, height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(LucideIcons.arrowRight, size: 20, color: AppColors.surface),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, {double top = 28, double bottom = 6, String? subtitle}) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, top, 20, bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: AppTypography.h1(size: 18, weight: FontWeight.w800, letterSpacing: -0.5),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: AppTypography.body(size: 13, color: AppColors.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCarCarousel(List<Car> cars, BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 270,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: cars.length,
          itemBuilder: (context, index) {
            final car = cars[index];
            return Builder(
              builder: (itemContext) {
                final liked = itemContext.select<FavoritesCubit, bool>(
                  (c) => c.state.favoriteIds.contains(car.id),
                );
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 230,
                    child: _CompactCarCard(
                      car: car,
                      liked: liked,
                      onLikeTap: () {
                        HapticFeedback.lightImpact();
                        itemContext.read<FavoritesCubit>().toggle(car.id);
                      },
                      onTap: () => itemContext.push('/car/${car.id}'),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _onExperienceTap(BuildContext context, Set<CarCategory> categories) async {
    HapticFeedback.lightImpact();
    final result = await LocationDateFlowSheet.show(
      context,
      initialStep: 0,
    );
    if (result != null && context.mounted) {
      context.read<CarsCubit>().resetFilters();
      context.read<CarsCubit>().setSearchLocation(result.location);
      context.read<CarsCubit>().setSearchDates((result.start, result.end));
      context.read<CarsCubit>().applyFilters(categories: categories);
      context.go('/home/explorer');
    }
  }

  Future<void> _onVoirToutTap(
    BuildContext context, {
    bool offersFilter = false,
    bool topPicksFilter = false,
    bool budgetFilter = false,
  }) async {
    HapticFeedback.lightImpact();
    final result = await LocationDateFlowSheet.show(
      context,
      initialStep: 0,
    );
    if (result != null && context.mounted) {
      context.read<CarsCubit>().resetFilters();
      context.read<CarsCubit>().setSearchLocation(result.location);
      context.read<CarsCubit>().setSearchDates((result.start, result.end));
      if (offersFilter) {
        context.read<CarsCubit>().applyFilters(priceRange: const RangeValues(0, 150));
      } else if (budgetFilter) {
        context.read<CarsCubit>().applyFilters(priceRange: const RangeValues(0, 99));
      }
      context.go('/home/explorer');
    }
  }
}

// ── Models ──
class _ExperienceItem {
  final String label;
  final String sub;
  final IconData icon;
  final Color bg;
  final Color iconColor;
  final Set<CarCategory> categories;
  const _ExperienceItem({required this.label, required this.sub, required this.icon, required this.bg, required this.iconColor, required this.categories});
}

// ── Widgets ──
class _CompactCarCard extends StatelessWidget {
  final Car car;
  final bool liked;
  final VoidCallback onLikeTap;
  final VoidCallback onTap;

  const _CompactCarCard({
    required this.car,
    required this.liked,
    required this.onLikeTap,
    required this.onTap,
  });

  String get _categoryLabel {
    switch (car.category) {
      case CarCategory.city: return 'Citadine';
      case CarCategory.sedan: return 'Berline';
      case CarCategory.suv: return 'SUV';
      case CarCategory.utility: return 'Utilitaire';
      case CarCategory.electric: return 'Électrique';
      case CarCategory.family: return 'Familiale';
      case CarCategory.minibus: return 'Minibus';
      case CarCategory.fourByFour: return '4x4';
      case CarCategory.convertible: return 'Cabriolet';
      case CarCategory.coupe: return 'Coupé';
      case CarCategory.collection: return 'Collection';
      case CarCategory.camperVan: return 'Camping-car';
    }
  }

  String get _transmissionLabel {
    switch (car.transmission) {
      case Transmission.manual: return 'Manuelle';
      case Transmission.automatic: return 'Auto';
    }
  }

  String _agencyName(String agencyId) {
    return MockData.agencies.firstWhere(
      (a) => a.id == agencyId,
      orElse: () => MockData.agencies.first,
    ).name;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image with fixed height
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 150,
              width: double.infinity,
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
                    placeholder: (_, __) => const SizedBox.shrink(),
                    errorWidget: (_, __, ___) => const Center(
                      child: Icon(LucideIcons.car, size: 32, color: AppColors.textMuted),
                    ),
                  ),
                  // Heart
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onLikeTap,
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 200),
                        scale: liked ? 1.15 : 1.0,
                        curve: Curves.easeOutBack,
                        child: Icon(
                          liked ? Icons.favorite : Icons.favorite_border,
                          size: 22,
                          color: liked ? AppColors.danger : AppColors.surface,
                        ),
                      ),
                    ),
                  ),
                  // Category chip on image
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _categoryLabel,
                        style: AppTypography.caps(size: 9, letterSpacing: 0.8, color: AppColors.ink),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Brand + Model
          Text(
            '${car.brand} ${car.model}',
            style: AppTypography.body(
              size: 15, weight: FontWeight.w800, color: AppColors.ink,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 2),
          // Agency
          Text(
            _agencyName(car.agencyId),
            style: AppTypography.body(
              size: 12, weight: FontWeight.w500, color: AppColors.textMuted,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 4),
          // Row: rating + specs
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 13, color: AppColors.warning),
              const SizedBox(width: 2),
              Text(
                car.rating.toStringAsFixed(1),
                style: AppTypography.body(size: 12, weight: FontWeight.w700, color: AppColors.ink),
              ),
              Text(
                ' (${car.reviewsCount})',
                style: AppTypography.body(size: 11, color: AppColors.textMuted),
              ),
              const SizedBox(width: 8),
              Container(
                width: 3, height: 3,
                decoration: const BoxDecoration(color: AppColors.borderStrong, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              const Icon(LucideIcons.users, size: 11, color: AppColors.textMuted),
              const SizedBox(width: 2),
              Text(
                '${car.seats}',
                style: AppTypography.body(size: 11, color: AppColors.textMuted),
              ),
              const SizedBox(width: 8),
              Container(
                width: 3, height: 3,
                decoration: const BoxDecoration(color: AppColors.borderStrong, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                _transmissionLabel,
                style: AppTypography.body(size: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${car.dailyPrice.toInt()} DT',
                style: AppTypography.numeric(
                  size: 17, weight: FontWeight.w900, color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '/jour',
                style: AppTypography.body(size: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  final _ExperienceItem item;
  final VoidCallback onTap;
  const _ExperienceCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: item.bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 24, color: item.iconColor),
            const Spacer(),
            Text(
              item.label,
              style: AppTypography.body(size: 13, weight: FontWeight.w800, color: AppColors.ink),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 1),
            Text(
              item.sub,
              style: AppTypography.body(size: 10, weight: FontWeight.w500, color: AppColors.textMuted),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _AgencyCard extends StatelessWidget {
  final Agency agency;
  final VoidCallback onTap;

  const _AgencyCard({required this.agency, required this.onTap});

  (Color bg, Color accent) get _gradientColors {
    if (agency.rating >= 4.7) {
      return (const Color(0xFFFFF8E7), const Color(0xFFF59E0B));
    } else if (agency.rating >= 4.5) {
      return (const Color(0xFFE6F3FF), const Color(0xFF3B82F6));
    } else {
      return (const Color(0xFFF0FDF4), const Color(0xFF10B981));
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bgColor, accentColor) = _gradientColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [bgColor, AppColors.surface],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accentColor.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentColor, accentColor.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      agency.name.substring(0, 1).toUpperCase(),
                      style: AppTypography.h1(
                        size: 18,
                        weight: FontWeight.w900,
                        color: AppColors.surface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              agency.name,
                              style: AppTypography.body(
                                size: 14,
                                weight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              LucideIcons.badgeCheck,
                              size: 12,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Agence partenaire',
                        style: AppTypography.caps(
                          size: 8,
                          letterSpacing: 1,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
                  const SizedBox(width: 4),
                  Text(
                    agency.rating.toStringAsFixed(1),
                    style: AppTypography.body(
                      size: 13,
                      weight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 3,
                    height: 3,
                    decoration: const BoxDecoration(
                      color: AppColors.borderStrong,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Icon(
                    LucideIcons.car,
                    size: 12,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${agency.totalRentals}',
                    style: AppTypography.body(
                      size: 12,
                      weight: FontWeight.w700,
                      color: AppColors.textMuted,
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
