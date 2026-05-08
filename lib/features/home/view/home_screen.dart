import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../data/models/car.dart';
import '../../../shared/widgets/car_map_marker.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../bloc/cars_cubit.dart';
import '../bloc/cars_state.dart';
import 'car_card.dart';
import 'filter_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _listController = ScrollController();
  final MapController _mapController = MapController();

  static const double _cardWidth = 260 + 12;

  @override
  void dispose() {
    _listController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Widget _filterChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppColors.ink),
            const SizedBox(width: 6),
            Text(label,
                style: AppTypography.body(
                    size: 12,
                    weight: FontWeight.w700,
                    color: AppColors.ink)),
            const SizedBox(width: 4),
            const Icon(LucideIcons.chevronDown,
                size: 12, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _filterChipAccent({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.surface),
          const SizedBox(width: 6),
          Text(label,
              style: AppTypography.body(
                  size: 12,
                  weight: FontWeight.w800,
                  color: AppColors.surface)),
        ],
      ),
    );
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<CarsCubit>(),
        child: const FilterSheet(),
      ),
    );
  }

  void _scrollToSelected(List<Car> cars, String? selectedId) {
    if (selectedId == null) return;
    final idx = cars.indexWhere((c) => c.id == selectedId);
    if (idx < 0) return;
    if (!_listController.hasClients) return;
    final target = (idx * _cardWidth).clamp(
      0.0,
      _listController.position.maxScrollExtent,
    );
    _listController.animateTo(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<CarsCubit, CarsState>(
        listenWhen: (p, c) => p.selectedCarId != c.selectedCarId,
        listener: (context, state) {
          _scrollToSelected(state.filteredCars, state.selectedCarId);
          final id = state.selectedCarId;
          if (id != null) {
            final car = state.filteredCars.firstWhere(
              (c) => c.id == id,
              orElse: () => state.filteredCars.isNotEmpty
                  ? state.filteredCars.first
                  : state.allCars.first,
            );
            _mapController.move(car.location, 14);
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // Map background
              FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: LatLng(36.8065, 10.1815),
                  initialZoom: 12,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.drivetn.app',
                  ),
                  MarkerLayer(
                    markers: state.filteredCars
                        .asMap()
                        .entries
                        .map((entry) {
                      final i = entry.key;
                      final car = entry.value;
                      final isSelected = car.id == state.selectedCarId;
                      return Marker(
                        point: car.location,
                        width: 240,
                        height: 110,
                        alignment: Alignment.bottomCenter,
                        child: GestureDetector(
                          onTap: () {
                            if (isSelected) {
                              context.push('/car/${car.id}');
                            } else {
                              context.read<CarsCubit>().selectCar(car.id);
                            }
                          },
                          child: Center(
                            child: CarMapMarker(
                              dailyPrice: car.dailyPrice.toInt(),
                              selected: isSelected,
                              bluetooth: true,
                              photoUrl: car.photoUrls.isNotEmpty
                                  ? car.photoUrls.first
                                  : null,
                              carName: car.displayName,
                              index: i,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              // Top overlay: location + dates pills, filter chips
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Row 1 — Location + Dates
                      Row(
                        children: [
                          // Location pill (left)
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Lieu — mode démo')),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.surface
                                      .withValues(alpha: 0.95),
                                  borderRadius: BorderRadius.circular(14),
                                  border:
                                      Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(LucideIcons.mapPin,
                                        size: 14, color: AppColors.accent),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('Tunis Centre',
                                              style: AppTypography.body(
                                                  size: 12,
                                                  weight: FontWeight.w800,
                                                  color: AppColors.ink),
                                              overflow:
                                                  TextOverflow.ellipsis),
                                          Text('TN',
                                              style: AppTypography.caps(
                                                  size: 9,
                                                  letterSpacing: 1.4,
                                                  color:
                                                      AppColors.textMuted)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Dates pill (right)
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Dates — mode démo')),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.surface
                                      .withValues(alpha: 0.95),
                                  borderRadius: BorderRadius.circular(14),
                                  border:
                                      Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(LucideIcons.calendar,
                                        size: 14, color: AppColors.accent),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('5 août',
                                              style: AppTypography.body(
                                                  size: 12,
                                                  weight: FontWeight.w800,
                                                  color: AppColors.ink),
                                              overflow:
                                                  TextOverflow.ellipsis),
                                          Text('13h → 14h',
                                              style: AppTypography.caps(
                                                  size: 9,
                                                  letterSpacing: 1.4,
                                                  color:
                                                      AppColors.textMuted)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Row 2 — Filter chips horizontal scroll
                      SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _filterChip(
                              icon: LucideIcons.dollarSign,
                              label: 'Prix total',
                              onTap: _openFilters,
                            ),
                            const SizedBox(width: 8),
                            _filterChip(
                              icon: LucideIcons.car,
                              label: 'Type de véhicule',
                              onTap: _openFilters,
                            ),
                            const SizedBox(width: 8),
                            _filterChipAccent(
                              icon: LucideIcons.bluetooth,
                              label: 'Sans clé',
                            ),
                            const SizedBox(width: 8),
                            _filterChip(
                              icon: LucideIcons.slidersHorizontal,
                              label: 'Plus de filtres',
                              onTap: _openFilters,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).animate().fadeIn(
                      delay: 100.ms, duration: 500.ms),
                ),
              ),

              // Bottom draggable sheet
              DraggableScrollableSheet(
                initialChildSize: 0.5,
                minChildSize: 0.12,
                maxChildSize: 0.95,
                snap: false,
                builder: (context, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          Center(
                            child: Container(
                              width: 36,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.borderStrong,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Builder(builder: (context) {
                                        final hasFilters = state
                                                .selectedCategories
                                                .isNotEmpty ||
                                            state.selectedTransmissions
                                                .isNotEmpty ||
                                            state.selectedFuels.isNotEmpty;
                                        final label = hasFilters
                                            ? '— TOP MATCH'
                                            : '— EN CE MOMENT';
                                        final captionTpl = hasFilters
                                            ? 'voitures qui matchent vos choix'
                                            : 'voitures à proximité';
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              label,
                                              style: AppTypography.caps(
                                                size: 10,
                                                letterSpacing: 2.4,
                                                color: hasFilters
                                                    ? AppColors.accent
                                                    : AppColors.textMuted,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            TweenAnimationBuilder<int>(
                                              tween: IntTween(
                                                  begin: 0,
                                                  end: state.filteredCars.length),
                                              duration: const Duration(
                                                  milliseconds: 900),
                                              curve: Curves.easeOutCubic,
                                              builder: (_, value, __) => Text(
                                                '$value $captionTpl',
                                                style: AppTypography.h1(
                                                    size: 22,
                                                    weight: FontWeight.w800),
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.ink,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                  ),
                                  child: Text(
                                    'Trier',
                                    style: AppTypography.body(
                                      size: 13,
                                      weight: FontWeight.w500,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (state.isLoading)
                            const Padding(
                              padding: EdgeInsets.all(40),
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(AppColors.ink),
                                ),
                              ),
                            )
                          else if (state.filteredCars.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 40, horizontal: 32),
                              child: Column(
                                children: [
                                  Text(
                                    '— AUCUNE TROUVÉE',
                                    style: AppTypography.caps(
                                      size: 10,
                                      letterSpacing: 3,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Aucune voiture\nne correspond.',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.display(
                                      size: 32,
                                      weight: FontWeight.w900,
                                      italic: false,
                                      letterSpacing: -1.4,
                                      height: 1.05,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextButton(
                                    onPressed: () => context
                                        .read<CarsCubit>()
                                        .resetFilters(),
                                    child: Text(
                                      'Réinitialiser les filtres',
                                      style: AppTypography.body(
                                        size: 13,
                                        weight: FontWeight.w700,
                                        color: AppColors.accent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(
                                  20, 4, 20, 24),
                              itemCount: state.filteredCars.length,
                              itemBuilder: (context, index) {
                                final car = state.filteredCars[index];
                                return CarCard(
                                  car: car,
                                  selected:
                                      car.id == state.selectedCarId,
                                  index: index,
                                  onTap: () =>
                                      context.push('/car/${car.id}'),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
