import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../bloc/game_cubit.dart';
import '../bloc/game_state.dart';

/// 🏆 Game Leaderboard — Endless Drive Tunisia stats screen.
/// Premium glassmorphism UI with sunset gradient background.
class GameLeaderboardScreen extends StatelessWidget {
  const GameLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF9A76),
              Color(0xFFFF6B6B),
              Color(0xFF4A1C40),
              Color(0xFF1A1A2E),
            ],
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<GameCubit, GameState>(
            builder: (context, state) {
              return Column(
                children: [
                  const SizedBox(height: 24),
                  // Header
                  Text(
                    'Tableau des scores',
                    style: AppTypography.h1(
                      size: 28,
                      weight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: -0.2, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    'Vos performances Endless Drive',
                    style: AppTypography.body(
                      size: 14,
                      color: Colors.white70,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 100.ms),
                  const SizedBox(height: 40),
                  // Stats cards
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          _buildStatCard(
                            icon: LucideIcons.trophy,
                            iconColor: Colors.amber,
                            gradient: const [
                              Color(0xFFFFD700),
                              Color(0xFFFFA500),
                            ],
                            label: 'Meilleure distance',
                            value: '${state.bestDistance} m',
                            delay: 200.ms,
                          ),
                          const SizedBox(height: 16),
                          _buildStatCard(
                            icon: LucideIcons.coins,
                            iconColor: AppColors.accentSecondary,
                            gradient: const [
                              AppColors.gradientStart,
                              AppColors.gradientEnd,
                            ],
                            label: 'Total de pièces',
                            value: '${state.totalCoins}',
                            delay: 350.ms,
                          ),
                          const SizedBox(height: 16),
                          _buildStatCard(
                            icon: LucideIcons.gamepad2,
                            iconColor: Colors.white,
                            gradient: const [
                              Color(0xFF7C3AED),
                              Color(0xFFEC4899),
                            ],
                            label: 'Parties jouées',
                            value: '${state.gamesPlayed}',
                            delay: 500.ms,
                          ),
                          const Spacer(),
                          // Rejouer button
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.gradientStart,
                                    AppColors.gradientEnd,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accent.withValues(alpha: 0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Rejouer',
                                textAlign: TextAlign.center,
                                style: AppTypography.body(
                                  size: 16,
                                  weight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 650.ms)
                              .slideY(begin: 0.3, end: 0, delay: 650.ms),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required List<Color> gradient,
    required String label,
    required String value,
    required Duration delay,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: gradient.last.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.caps(
                    size: 11,
                    letterSpacing: 1.5,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: AppTypography.numeric(
                    size: 32,
                    weight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: delay)
        .slideY(begin: 0.2, end: 0, delay: delay);
  }
}
