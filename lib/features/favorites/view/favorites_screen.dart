import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../data/mock_data.dart';
import '../../../data/models/car.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../bloc/favorites_cubit.dart';
import '../bloc/favorites_state.dart';
import 'favorite_car_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final d = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (d == today) return 'Aujourd\'hui';
    if (d == yesterday) return 'Hier';
    return DateFormat('EEEE d MMMM', 'fr_FR').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          final cars = state.favoriteIds
              .map((id) => MockData.carById(id))
              .whereType<Car>()
              .toList();

          // Group by date label
          final Map<String, List<({Car car, DateTime? date})>> groups = {};
          for (final car in cars) {
            final date = state.favoriteDates[car.id];
            final label = date != null ? _formatDateLabel(date) : '';
            groups.putIfAbsent(label, () => []).add((car: car, date: date));
          }

          // Sort groups by the first date descending
          final sortedEntries = groups.entries.toList()
            ..sort((a, b) {
              final aDate = a.value.first.date ?? DateTime(2000);
              final bDate = b.value.first.date ?? DateTime(2000);
              return bDate.compareTo(aDate);
            });

          return CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '— MES COUPS DE CŒUR',
                        style: AppTypography.caps(
                          size: 10,
                          letterSpacing: 2.4,
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
                              size: 32,
                              weight: FontWeight.w900,
                              letterSpacing: -1.2,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'favoris.',
                            style: AppTypography.display(
                              size: 32,
                              weight: FontWeight.w300,
                              italic: true,
                              letterSpacing: -1.2,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${cars.length} voiture${cars.length > 1 ? 's' : ''} sauvegardée${cars.length > 1 ? 's' : ''}',
                        style: AppTypography.body(
                          size: 14,
                          color: AppColors.textMuted,
                          weight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 420.ms).slideY(begin: 0.06, end: 0),
              ),
            ),

              // Content
              if (state.isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(AppColors.ink),
                    ),
                  ),
                )
              else if (cars.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(
                    onExplore: () => context.go('/home/explorer'),
                  ),
                )
              else
                for (var i = 0; i < sortedEntries.length; i++) ...[
                  // Date label
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(28, 12, 28, 14),
                      child: Text(
                        sortedEntries[i].key,
                        style: AppTypography.h1(
                          size: 15,
                          weight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                  // Grid of cars for this date
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 4),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.62,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = sortedEntries[i].value[index];
                          return FavoriteCarCard(
                            car: item.car,
                            index: index,
                            liked: true,
                            compact: true,
                            likedDate: item.date,
                            onLikeTap: () {
                              HapticFeedback.lightImpact();
                              context.read<FavoritesCubit>().remove(item.car.id);
                            },
                            onTap: () => context.push('/car/${item.car.id}'),
                          );
                        },
                        childCount: sortedEntries[i].value.length,
                      ),
                    ),
                  ),
                ],

              // Bottom safe area padding
              const SliverPadding(
                padding: EdgeInsets.only(bottom: 100),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onExplore;
  const _EmptyState({required this.onExplore});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.heart,
            size: 64,
            color: AppColors.borderStrong,
          ),
          const SizedBox(height: 20),
          Text(
            'Aucun favori',
            textAlign: TextAlign.center,
            style: AppTypography.display(
              size: 28,
              weight: FontWeight.w900,
              letterSpacing: -1,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Explorez les voitures disponibles et ajoutez celles qui vous plaisent à vos favoris.',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              size: 14,
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: onExplore,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Découvrir des voitures',
                style: AppTypography.body(
                  size: 14,
                  weight: FontWeight.w800,
                  color: AppColors.surface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
