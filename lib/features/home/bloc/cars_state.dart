import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../data/models/car.dart';

class CarsState extends Equatable {
  final List<Car> allCars;
  final List<Car> filteredCars;
  final RangeValues priceRange;
  final Set<CarCategory> selectedCategories;
  final Set<Transmission> selectedTransmissions;
  final Set<FuelType> selectedFuels;
  final String? selectedCarId;
  final bool isLoading;

  const CarsState({
    this.allCars = const [],
    this.filteredCars = const [],
    this.priceRange = const RangeValues(0, 300),
    this.selectedCategories = const {},
    this.selectedTransmissions = const {},
    this.selectedFuels = const {},
    this.selectedCarId,
    this.isLoading = false,
  });

  CarsState copyWith({
    List<Car>? allCars,
    List<Car>? filteredCars,
    RangeValues? priceRange,
    Set<CarCategory>? selectedCategories,
    Set<Transmission>? selectedTransmissions,
    Set<FuelType>? selectedFuels,
    String? selectedCarId,
    bool? isLoading,
    bool clearSelectedCarId = false,
  }) {
    return CarsState(
      allCars: allCars ?? this.allCars,
      filteredCars: filteredCars ?? this.filteredCars,
      priceRange: priceRange ?? this.priceRange,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedTransmissions:
          selectedTransmissions ?? this.selectedTransmissions,
      selectedFuels: selectedFuels ?? this.selectedFuels,
      selectedCarId:
          clearSelectedCarId ? null : (selectedCarId ?? this.selectedCarId),
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        allCars,
        filteredCars,
        priceRange,
        selectedCategories,
        selectedTransmissions,
        selectedFuels,
        selectedCarId,
        isLoading,
      ];
}
