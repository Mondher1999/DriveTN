import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../../../data/mock_data.dart';
import 'rental_state.dart';

class RentalCubit extends Cubit<RentalState> {
  RentalCubit() : super(const RentalState());

  Timer? _ticker;
  final _rng = Random();

  void start(String bookingId) {
    final booking = MockData.bookingById(bookingId);
    final car = booking != null ? MockData.carById(booking.carId) : null;
    emit(RentalState(
      bookingId: bookingId,
      startedAt: DateTime.now(),
      currentPosition: car?.location ?? const LatLng(36.8065, 10.1815),
    ));
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (state.startedAt == null) return;
    final elapsed = DateTime.now().difference(state.startedAt!);
    int km = state.kilometers;
    int fuel = state.fuelPercent;
    LatLng pos = state.currentPosition;

    if (elapsed.inSeconds % 5 == 0) km += 1;
    if (elapsed.inSeconds % 10 == 0 && fuel > 0) fuel -= 1;
    if (elapsed.inSeconds % 10 == 0) {
      pos = LatLng(
        pos.latitude + (_rng.nextDouble() - 0.5) * 0.002,
        pos.longitude + (_rng.nextDouble() - 0.5) * 0.002,
      );
    }
    emit(state.copyWith(
      elapsed: elapsed,
      kilometers: km,
      fuelPercent: fuel,
      currentPosition: pos,
    ));
  }

  void toggleLock() => emit(state.copyWith(isLocked: !state.isLocked));

  void stop() {
    _ticker?.cancel();
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
