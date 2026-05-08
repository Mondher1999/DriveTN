import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/mock_data.dart';
import '../../../data/models/booking.dart';
import 'inspection_state.dart';

class InspectionCubit extends Cubit<InspectionState> {
  InspectionCubit() : super(const InspectionState());

  Timer? _stepTimer;

  void start(InspectionMode mode) {
    emit(InspectionState(mode: mode));
  }

  void setCameraReady(bool v) => emit(state.copyWith(cameraReady: v));

  void startRecordingStep() {
    emit(state.copyWith(isRecording: true));
    _stepTimer?.cancel();
  }

  void nextStep() {
    _stepTimer?.cancel();
    if (state.currentStep + 1 >= state.totalSteps) {
      emit(state.copyWith(
        isRecording: false,
        isCompleted: true,
        currentStep: state.totalSteps,
      ));
    } else {
      emit(state.copyWith(
        currentStep: state.currentStep + 1,
        isRecording: false,
      ));
    }
  }

  Future<void> simulateAll() async {
    if (state.isCompleted || state.isRecording) return;
    emit(state.copyWith(isRecording: true));
    for (int i = 0; i < state.totalSteps; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (isClosed) return;
      if (i < state.totalSteps - 1) {
        emit(state.copyWith(currentStep: i + 1));
      }
    }
    if (isClosed) return;
    emit(state.copyWith(
      isCompleted: true,
      isRecording: false,
      currentStep: state.totalSteps,
    ));
  }

  void completePickup(String bookingId) {
    final b = MockData.bookingById(bookingId);
    if (b != null) {
      final updated = b.copyWith(
        pickupVideoAt: DateTime.now(),
        status: BookingStatus.inProgress,
      );
      final i = MockData.bookings.indexWhere((x) => x.id == bookingId);
      if (i == -1) return;
      MockData.bookings[i] = updated;
    }
  }

  void completeReturn(String bookingId) {
    final b = MockData.bookingById(bookingId);
    if (b != null) {
      final updated = b.copyWith(
        returnVideoAt: DateTime.now(),
        status: BookingStatus.completed,
      );
      final i = MockData.bookings.indexWhere((x) => x.id == bookingId);
      if (i == -1) return;
      MockData.bookings[i] = updated;
    }
  }

  @override
  Future<void> close() {
    _stepTimer?.cancel();
    return super.close();
  }
}
