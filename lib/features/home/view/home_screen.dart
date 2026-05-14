import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../data/models/car.dart';
import '../../../shared/widgets/car_map_marker.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../bloc/cars_cubit.dart';
import '../bloc/cars_state.dart';
import '../../favorites/bloc/favorites_cubit.dart';
import '../../favorites/bloc/favorites_state.dart';
import '../../favorites/view/favorite_car_card.dart';
import 'filter_sheet.dart';
import 'location_date_flow_sheet.dart';

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

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
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

  Widget _buildMapView(CarsState state) {
    return FlutterMap(
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
    );
  }

  Widget _buildListHeader(CarsState state) {
    final hasFilters = state.selectedCategories.isNotEmpty ||
        state.selectedTransmissions.isNotEmpty ||
        state.selectedFuels.isNotEmpty;
    final label = hasFilters ? '— TOP MATCH' : '— EN CE MOMENT';
    final caption = hasFilters
        ? 'voitures qui matchent vos choix'
        : 'voitures à proximité';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.caps(
                    size: 10,
                    letterSpacing: 2.4,
                    color: hasFilters ? AppColors.accent : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                TweenAnimationBuilder<int>(
                  tween: IntTween(
                      begin: 0, end: state.filteredCars.length),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (_, value, __) => Text(
                    '$value $caption',
                    style: AppTypography.h1(
                        size: 22, weight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _openFilters,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.slidersHorizontal,
                      size: 13, color: AppColors.ink),
                  const SizedBox(width: 6),
                  Text(
                    'Filtres',
                    style: AppTypography.body(
                      size: 12,
                      weight: FontWeight.w700,
                      color: AppColors.ink,
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

  Widget _buildListView(CarsState state) {
    final mq = MediaQuery.of(context);
    final topSafe = mq.viewPadding.top;
    const barHeight = 56.0; // location/date bar approx
    const margin = 24.0;
    const safePadding = 16.0;
    const headerBottomPad = 16.0;
    final topPad = topSafe + safePadding + barHeight + headerBottomPad + margin;

    if (state.isLoading) {
      return Padding(
        padding: EdgeInsets.only(top: topPad),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.ink),
          ),
        ),
      );
    }
    if (state.filteredCars.isEmpty) {
      return Padding(
        padding: EdgeInsets.fromLTRB(32, topPad, 32, 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              onPressed: () => context.read<CarsCubit>().resetFilters(),
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
      );
    }
    return ListView.builder(
      controller: _listController,
      padding: EdgeInsets.fromLTRB(16, topPad, 16, 100),
      itemCount: state.filteredCars.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildListHeader(state);
        }
        final car = state.filteredCars[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: BlocBuilder<FavoritesCubit, FavoritesState>(
            builder: (context, favState) {
              return FavoriteCarCard(
                car: car,
                index: index - 1,
                liked: favState.favoriteIds.contains(car.id),
                onLikeTap: () {
                  HapticFeedback.lightImpact();
                  context.read<FavoritesCubit>().toggle(car.id);
                },
                onTap: () => context.push('/car/${car.id}'),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildToggleButton(BuildContext context, CarsState state) {
    final isMap = state.viewMode == ViewMode.map;
    return GestureDetector(
      onTap: () => context.read<CarsCubit>().toggleViewMode(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.surface.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.45),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isMap ? LucideIcons.list : LucideIcons.map,
              size: 16,
              color: AppColors.surface,
            ),
            const SizedBox(width: 8),
            Text(
              isMap ? 'Liste' : 'Carte',
              style: AppTypography.body(
                size: 14,
                weight: FontWeight.w800,
                color: AppColors.surface,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: 200.ms)
        .slideY(begin: 0.3, end: 0, duration: 300.ms, delay: 200.ms);
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
              // Active view
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: state.viewMode == ViewMode.map
                    ? _buildMapView(state)
                    : _buildListView(state),
              ),

              // Top overlay: location + dates pills, filter chips
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.border.withValues(alpha: 0.5),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                           // Back button (only when search is active) with small left margin
                           if (state.searchLocation != null && state.searchDates != null) ...[
                             GestureDetector(
                               onTap: () {
                                 HapticFeedback.lightImpact();
                                 context.read<CarsCubit>().setSearchLocation(null);
                                 context.read<CarsCubit>().setSearchDates(null);
                                 context.go('/discovery');
                               },
                               child: Container(
                                 margin: const EdgeInsets.only(left: 2),
                                 width: 40,
                                 height: 40,
                                 decoration: BoxDecoration(
                                   color: AppColors.surface,
                                   borderRadius: BorderRadius.circular(12),
                                   border: Border.all(color: AppColors.border),
                                 ),
                                 child: const Center(
                                   child: Icon(
                                     LucideIcons.arrowLeft,
                                     size: 20,
                                     color: AppColors.ink,
                                   ),
                                 ),
                               ),
                             ),
                             const SizedBox(width: 10),
                           ],
                             // Location + Dates bar (centered, wider)
                           Expanded(
                             child: Center(
                               child: Container(
                                 constraints: const BoxConstraints(minWidth: 300, maxWidth: 320),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.border),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.ink.withValues(alpha: 0.06),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () async {
                                  final result = await LocationDateFlowSheet.show(
                                    context,
                                    initialLocation: state.searchLocation,
                                    initialDates: state.searchDates,
                                    initialStep: state.searchLocation != null ? 1 : 0,
                                  );
                                  if (result != null && context.mounted) {
                                    context.read<CarsCubit>().setSearchLocation(result.location);
                                    context.read<CarsCubit>().setSearchDates((result.start, result.end));
                                  }
                                },
                                child: (state.searchLocation != null && state.searchDates != null)
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Row 1 — Location
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(LucideIcons.mapPin,
                                                size: 14, color: AppColors.accent),
                                            const SizedBox(width: 8),
                                            Text(
                                              state.searchLocation!,
                                              style: AppTypography.body(
                                                size: 13,
                                                weight: FontWeight.w700,
                                                color: AppColors.ink,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        // Row 2 — Dates
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(LucideIcons.calendarClock,
                                                size: 13, color: AppColors.accent),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${DateFormat('d MMM', 'fr_FR').format(state.searchDates!.$1)} — ${DateFormat('d MMM', 'fr_FR').format(state.searchDates!.$2)}',
                                              style: AppTypography.body(
                                                size: 12,
                                                weight: FontWeight.w500,
                                                color: AppColors.ink,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(LucideIcons.search,
                                              size: 18, color: AppColors.accent),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Commencer ma recherche',
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
                             ),
                           ),
                         ),
                           // Filter icon (only when search is active)
                          if (state.searchLocation != null && state.searchDates != null) ...[
                            const SizedBox(width: 10),
                             GestureDetector(
                               onTap: _openFilters,
                               child: Container(
                                 margin: const EdgeInsets.only(right: 2),
                                 width: 40,
                                 height: 40,
                                 decoration: BoxDecoration(
                                   color: AppColors.surface,
                                   borderRadius: BorderRadius.circular(12),
                                   border: Border.all(color: AppColors.border),
                                 ),
                                 child: const Center(
                                   child: Icon(
                                     LucideIcons.slidersHorizontal,
                                     size: 20,
                                     color: AppColors.ink,
                                   ),
                                 ),
                               ),
                             ),
                          ],
                        ],
                      ),
                    ],
                  ).animate().fadeIn(
                      delay: 100.ms, duration: 500.ms),
                    ),
                  ),
                ),
              ),

              // Toggle button
              Positioned(
                bottom: MediaQuery.of(context).viewPadding.bottom + 124,
                left: 0,
                right: 0,
                child: Center(
                  child: _buildToggleButton(context, state),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
