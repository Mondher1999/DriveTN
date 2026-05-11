import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'wizard_state.dart';

class WizardCubit extends Cubit<WizardState> {
  WizardCubit() : super(const WizardState());

  void setUseCase(WizardUseCase v) => emit(state.copyWith(useCase: v));
  void setCarType(WizardCarType v) => emit(state.copyWith(carType: v));
  void setStartDate(DateTime d) {
    DateTime end = state.endDate ?? d.add(const Duration(hours: 1));
    if (!end.isAfter(d)) end = d.add(const Duration(hours: 1));
    emit(state.copyWith(startDate: d, endDate: end));
  }
  void setEndDate(DateTime d) {
    if (state.startDate != null && d.isAfter(state.startDate!)) {
      emit(state.copyWith(endDate: d));
    }
  }
  void setBudget(RangeValues v) => emit(state.copyWith(budget: v));
  void setFuel(WizardFuel v) => emit(state.copyWith(fuel: v));
  void setSeats(WizardSeats v) => emit(state.copyWith(seats: v));
  void setTransmission(WizardTransmission v) =>
      emit(state.copyWith(transmission: v));
  void setPickup(WizardPickup v) => emit(state.copyWith(pickup: v));

  void next() {
    if (state.step < WizardState.totalSteps - 1) {
      emit(state.copyWith(step: state.step + 1));
    }
  }

  void prev() {
    if (state.step > 0) emit(state.copyWith(step: state.step - 1));
  }

  void reset() => emit(const WizardState());
}
