import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class RentalState extends Equatable {
  final String? bookingId;
  final DateTime? startedAt;
  final Duration elapsed;
  final int kilometers;
  final int fuelPercent;
  final bool isLocked;
  final LatLng currentPosition;

  const RentalState({
    this.bookingId,
    this.startedAt,
    this.elapsed = Duration.zero,
    this.kilometers = 0,
    this.fuelPercent = 100,
    this.isLocked = false,
    this.currentPosition = const LatLng(36.8065, 10.1815),
  });

  RentalState copyWith({
    String? bookingId,
    DateTime? startedAt,
    Duration? elapsed,
    int? kilometers,
    int? fuelPercent,
    bool? isLocked,
    LatLng? currentPosition,
  }) {
    return RentalState(
      bookingId: bookingId ?? this.bookingId,
      startedAt: startedAt ?? this.startedAt,
      elapsed: elapsed ?? this.elapsed,
      kilometers: kilometers ?? this.kilometers,
      fuelPercent: fuelPercent ?? this.fuelPercent,
      isLocked: isLocked ?? this.isLocked,
      currentPosition: currentPosition ?? this.currentPosition,
    );
  }

  @override
  List<Object?> get props => [
        bookingId,
        startedAt,
        elapsed,
        kilometers,
        fuelPercent,
        isLocked,
        currentPosition,
      ];
}
