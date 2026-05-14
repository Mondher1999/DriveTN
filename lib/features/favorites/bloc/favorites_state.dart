import 'package:equatable/equatable.dart';

class FavoritesState extends Equatable {
  final List<String> favoriteIds;
  final Map<String, DateTime> favoriteDates;
  final bool isLoading;

  const FavoritesState({
    this.favoriteIds = const [],
    this.favoriteDates = const {},
    this.isLoading = false,
  });

  FavoritesState copyWith({
    List<String>? favoriteIds,
    Map<String, DateTime>? favoriteDates,
    bool? isLoading,
  }) {
    return FavoritesState(
      favoriteIds: favoriteIds ?? this.favoriteIds,
      favoriteDates: favoriteDates ?? this.favoriteDates,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [favoriteIds, favoriteDates, isLoading];
}
