import 'package:equatable/equatable.dart';

class FavoritesState extends Equatable {
  final List<String> favoriteIds;
  final bool isLoading;

  const FavoritesState({
    this.favoriteIds = const [],
    this.isLoading = false,
  });

  FavoritesState copyWith({
    List<String>? favoriteIds,
    bool? isLoading,
  }) {
    return FavoritesState(
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [favoriteIds, isLoading];
}
