import 'package:flutter_bloc/flutter_bloc.dart';

import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit() : super(const FavoritesState(isLoading: true)) {
    _load();
  }

  void _load() async {
    // Simulate tiny network delay then show seeded favorites
    await Future.delayed(const Duration(milliseconds: 400));
    emit(const FavoritesState(
      favoriteIds: ['c4', 'c7', 'c10'],
      isLoading: false,
    ));
  }

  void toggle(String carId) {
    final current = List<String>.from(state.favoriteIds);
    if (current.contains(carId)) {
      current.remove(carId);
    } else {
      current.add(carId);
    }
    emit(state.copyWith(favoriteIds: current));
  }

  void remove(String carId) {
    final current = List<String>.from(state.favoriteIds);
    current.remove(carId);
    emit(state.copyWith(favoriteIds: current));
  }

  bool isFavorite(String carId) => state.favoriteIds.contains(carId);
}
