import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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

          return CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '— MES COUPS DE CŒUR',
                          style: AppTypography.caps(
                            size: 10,
                            letterSpacing: 2.4,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Favoris',
                          style: AppTypography.h1(
                            size: 28,
                            weight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 4),
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
                  ),
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
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final car = cars[index];
                        return FavoriteCarCard(
                          car: car,
                          index: index,
                          liked: true,
                          onLikeTap: () {
                            HapticFeedback.lightImpact();
                            context.read<FavoritesCubit>().remove(car.id);
                          },
                          onTap: () => context.push('/car/${car.id}'),
                        );
                      },
                      childCount: cars.length,
                    ),
                  ),
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
