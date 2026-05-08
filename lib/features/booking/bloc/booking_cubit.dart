import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/mock_data.dart';
import '../../../data/models/booking.dart';
import '../../../data/models/car.dart';
import 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  BookingCubit() : super(BookingState());

  void initForCar(Car car) {
    emit(BookingState(
      car: car,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 1)),
    ));
  }

  void setStartDate(DateTime d) {
    DateTime end = state.endDate;
    if (!end.isAfter(d)) end = d.add(const Duration(days: 1));
    emit(state.copyWith(startDate: d, endDate: end));
  }

  void setEndDate(DateTime d) {
    if (d.isAfter(state.startDate)) {
      emit(state.copyWith(endDate: d));
    }
  }

  void toggleAdditionalDriver(bool v) =>
      emit(state.copyWith(additionalDriver: v));
  void toggleBabySeat(bool v) => emit(state.copyWith(babySeat: v));
  void toggleUnlimitedKm(bool v) => emit(state.copyWith(unlimitedKm: v));

  Future<Booking> confirmBooking() async {
    if (state.car == null) {
      return Future.error(StateError('No car selected'));
    }
    emit(state.copyWith(isProcessing: true));
    await Future.delayed(const Duration(seconds: 2));
    final booking = Booking(
      id: 'b${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      carId: state.car!.id,
      userId: 'user1',
      startDate: state.startDate,
      endDate: state.endDate,
      totalPrice: state.total,
      depositAmount: state.car!.depositAmount,
      status: BookingStatus.confirmed,
      additionalDriver: state.additionalDriver,
      babySeat: state.babySeat,
      unlimitedKm: state.unlimitedKm,
    );
    MockData.bookings.add(booking);
    emit(state.copyWith(isProcessing: false, confirmedBooking: booking));
    return booking;
  }
}
