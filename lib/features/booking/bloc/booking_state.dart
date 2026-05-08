import 'package:equatable/equatable.dart';
import '../../../data/models/booking.dart';
import '../../../data/models/car.dart';

class BookingState extends Equatable {
  final Car? car;
  final DateTime startDate;
  final DateTime endDate;
  final bool additionalDriver;
  final bool babySeat;
  final bool unlimitedKm;
  final bool isProcessing;
  final Booking? confirmedBooking;

  BookingState({
    this.car,
    DateTime? startDate,
    DateTime? endDate,
    this.additionalDriver = false,
    this.babySeat = false,
    this.unlimitedKm = false,
    this.isProcessing = false,
    this.confirmedBooking,
  })  : startDate = startDate ?? DateTime.now(),
        endDate = endDate ?? DateTime.now().add(const Duration(days: 1));

  int get durationDays {
    final d = endDate.difference(startDate).inDays;
    return d < 1 ? 1 : d;
  }

  double get extrasPerDay {
    double e = 0;
    if (additionalDriver) e += 20;
    if (babySeat) e += 10;
    if (unlimitedKm) e += 30;
    return e;
  }

  double get total {
    if (car == null) return 0;
    return (car!.dailyPrice + extrasPerDay) * durationDays;
  }

  BookingState copyWith({
    Car? car,
    DateTime? startDate,
    DateTime? endDate,
    bool? additionalDriver,
    bool? babySeat,
    bool? unlimitedKm,
    bool? isProcessing,
    Booking? confirmedBooking,
  }) {
    return BookingState(
      car: car ?? this.car,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      additionalDriver: additionalDriver ?? this.additionalDriver,
      babySeat: babySeat ?? this.babySeat,
      unlimitedKm: unlimitedKm ?? this.unlimitedKm,
      isProcessing: isProcessing ?? this.isProcessing,
      confirmedBooking: confirmedBooking ?? this.confirmedBooking,
    );
  }

  @override
  List<Object?> get props => [
        car,
        startDate,
        endDate,
        additionalDriver,
        babySeat,
        unlimitedKm,
        isProcessing,
        confirmedBooking,
      ];
}
