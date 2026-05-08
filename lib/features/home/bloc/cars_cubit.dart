import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/mock_data.dart';
import '../../../data/models/car.dart';
import 'cars_state.dart';

class CarsCubit extends Cubit<CarsState> {
  CarsCubit() : super(const CarsState(isLoading: true)) {
    loadCars();
  }

  Future<void> loadCars() async {
    emit(state.copyWith(isLoading: true));
    await Future.delayed(const Duration(milliseconds: 400));
    emit(state.copyWith(
      allCars: MockData.cars,
      filteredCars: MockData.cars,
      isLoading: false,
    ));
  }

  void applyFilters({
    RangeValues? priceRange,
    Set<CarCategory>? categories,
    Set<Transmission>? transmissions,
    Set<FuelType>? fuels,
    int? minSeats,
    int? maxSeats,
  }) {
    final pr = priceRange ?? state.priceRange;
    final cats = categories ?? state.selectedCategories;
    final trans = transmissions ?? state.selectedTransmissions;
    final fuelsSet = fuels ?? state.selectedFuels;

    final filtered = state.allCars.where((c) {
      if (c.dailyPrice < pr.start || c.dailyPrice > pr.end) return false;
      if (cats.isNotEmpty && !cats.contains(c.category)) return false;
      if (trans.isNotEmpty && !trans.contains(c.transmission)) return false;
      if (fuelsSet.isNotEmpty && !fuelsSet.contains(c.fuelType)) return false;
      if (minSeats != null && c.seats < minSeats) return false;
      if (maxSeats != null && c.seats > maxSeats) return false;
      return true;
    }).toList();

    emit(state.copyWith(
      filteredCars: filtered,
      priceRange: pr,
      selectedCategories: cats,
      selectedTransmissions: trans,
      selectedFuels: fuelsSet,
    ));
  }

  void selectCar(String? id) {
    if (id == null) {
      emit(state.copyWith(clearSelectedCarId: true));
    } else {
      emit(state.copyWith(selectedCarId: id));
    }
  }

  void resetFilters() {
    emit(state.copyWith(
      priceRange: const RangeValues(0, 300),
      selectedCategories: const {},
      selectedTransmissions: const {},
      selectedFuels: const {},
      filteredCars: state.allCars,
    ));
  }
}
