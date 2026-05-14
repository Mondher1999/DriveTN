import 'package:flutter_bloc/flutter_bloc.dart';

import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit() : super(const FavoritesState(isLoading: true)) {
    _load();
  }

  void _load() async {
    // Simulate tiny network delay then show seeded favorites
    await Future.delayed(const Duration(milliseconds: 400));
    final now = DateTime.now();
    final may12 = now.subtract(const Duration(days: 2));
    emit(FavoritesState(
      favoriteIds: const ['c4', 'c7', 'c10', 'c2'],
      favoriteDates: {
        'c4': may12,
        'c7': may12,
        'c10': may12,
        'c2': now,
      },
      isLoading: false,
    ));
  }

  void toggle(String carId) {
    final currentIds = List<String>.from(state.favoriteIds);
    final currentDates = Map<String, DateTime>.from(state.favoriteDates);
    if (currentIds.contains(carId)) {
      currentIds.remove(carId);
      currentDates.remove(carId);
    } else {
      currentIds.add(carId);
      currentDates[carId] = DateTime.now();
    }
    emit(state.copyWith(
      favoriteIds: currentIds,
      favoriteDates: currentDates,
    ));
  }

  void remove(String carId) {
    final currentIds = List<String>.from(state.favoriteIds);
    final currentDates = Map<String, DateTime>.from(state.favoriteDates);
    currentIds.remove(carId);
    currentDates.remove(carId);
    emit(state.copyWith(
      favoriteIds: currentIds,
      favoriteDates: currentDates,
    ));
  }

  bool isFavorite(String carId) => state.favoriteIds.contains(carId);

  DateTime? favoriteDate(String carId) => state.favoriteDates[carId];
}
