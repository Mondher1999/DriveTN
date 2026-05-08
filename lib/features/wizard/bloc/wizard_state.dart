import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../data/models/car.dart';

enum WizardUseCase { city, business, weekend, family, electric }
enum WizardCarType { city, sedan, suv, utility, electric, any }
enum WizardFuel { gasoline, diesel, hybrid, any }
enum WizardSeats { small, medium, large }
enum WizardTransmission { automatic, manual, any }
enum WizardPickup { tunisCentre, laMarsa, lac1, lac2, ariana, soukra, carthage, any }

class WizardState extends Equatable {
  final int step;
  final WizardUseCase? useCase;
  final WizardCarType? carType;
  final DateTime? startDate;
  final DateTime? endDate;
  final RangeValues budget;
  final WizardFuel? fuel;
  final WizardSeats? seats;
  final WizardTransmission? transmission;
  final WizardPickup? pickup;

  const WizardState({
    this.step = 0,
    this.useCase,
    this.carType,
    this.startDate,
    this.endDate,
    this.budget = const RangeValues(80, 500),
    this.fuel,
    this.seats,
    this.transmission,
    this.pickup,
  });

  static const totalSteps = 8;

  bool get canAdvance {
    switch (step) {
      case 0: return useCase != null;
      case 1: return carType != null;
      case 2: return startDate != null && endDate != null && endDate!.isAfter(startDate!);
      case 3: return true;
      case 4: return fuel != null;
      case 5: return seats != null;
      case 6: return transmission != null;
      case 7: return pickup != null;
      default: return true;
    }
  }

  int get durationDays {
    if (startDate == null || endDate == null) return 1;
    return endDate!.difference(startDate!).inDays.clamp(1, 365);
  }

  WizardState copyWith({
    int? step,
    WizardUseCase? useCase,
    WizardCarType? carType,
    DateTime? startDate,
    DateTime? endDate,
    RangeValues? budget,
    WizardFuel? fuel,
    WizardSeats? seats,
    WizardTransmission? transmission,
    WizardPickup? pickup,
  }) {
    return WizardState(
      step: step ?? this.step,
      useCase: useCase ?? this.useCase,
      carType: carType ?? this.carType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      budget: budget ?? this.budget,
      fuel: fuel ?? this.fuel,
      seats: seats ?? this.seats,
      transmission: transmission ?? this.transmission,
      pickup: pickup ?? this.pickup,
    );
  }

  Set<CarCategory> get matchedCategories {
    if (carType != null && carType != WizardCarType.any) {
      switch (carType!) {
        case WizardCarType.city: return {CarCategory.city};
        case WizardCarType.sedan: return {CarCategory.sedan};
        case WizardCarType.suv: return {CarCategory.suv};
        case WizardCarType.utility: return {CarCategory.utility};
        case WizardCarType.electric: return {CarCategory.electric};
        case WizardCarType.any: return const {};
      }
    }
    if (useCase == null) return const {};
    switch (useCase!) {
      case WizardUseCase.city: return {CarCategory.city};
      case WizardUseCase.business: return {CarCategory.sedan};
      case WizardUseCase.weekend: return {CarCategory.suv, CarCategory.sedan};
      case WizardUseCase.family: return {CarCategory.suv, CarCategory.utility};
      case WizardUseCase.electric: return {CarCategory.electric};
    }
  }

  Set<FuelType> get matchedFuels {
    if (fuel == null || fuel == WizardFuel.any) return const {};
    switch (fuel!) {
      case WizardFuel.gasoline: return {FuelType.gasoline};
      case WizardFuel.diesel: return {FuelType.diesel};
      case WizardFuel.hybrid: return {FuelType.hybrid};
      case WizardFuel.any: return const {};
    }
  }

  Set<Transmission> get matchedTransmissions {
    if (transmission == null || transmission == WizardTransmission.any) {
      return const {};
    }
    return transmission == WizardTransmission.automatic
        ? {Transmission.automatic}
        : {Transmission.manual};
  }

  int get minSeats {
    switch (seats) {
      case WizardSeats.small: return 2;
      case WizardSeats.medium: return 5;
      case WizardSeats.large: return 7;
      case null: return 2;
    }
  }

  int get maxSeats {
    switch (seats) {
      case WizardSeats.small: return 4;
      case WizardSeats.medium: return 6;
      case WizardSeats.large: return 99;
      case null: return 99;
    }
  }

  @override
  List<Object?> get props => [step, useCase, carType, startDate, endDate, budget, fuel, seats, transmission, pickup];
}
