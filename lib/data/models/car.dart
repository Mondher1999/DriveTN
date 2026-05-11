import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

enum CarCategory {
  city,
  sedan,
  suv,
  utility,
  electric,
  family,
  minibus,
  fourByFour,
  convertible,
  coupe,
  collection,
  camperVan,
}

enum Transmission { manual, automatic }

enum FuelType { gasoline, diesel, hybrid, electric }

class Car extends Equatable {
  final String id;
  final String brand;
  final String model;
  final String plate;
  final int year;
  final int seats;
  final CarCategory category;
  final Transmission transmission;
  final FuelType fuelType;
  final double dailyPrice;
  final double rating;
  final int reviewsCount;
  final LatLng location;
  final List<String> photoUrls;
  final String agencyId;
  final bool isAvailable;
  final double depositAmount;

  const Car({
    required this.id,
    required this.brand,
    required this.model,
    required this.plate,
    required this.year,
    required this.seats,
    required this.category,
    required this.transmission,
    required this.fuelType,
    required this.dailyPrice,
    required this.rating,
    required this.reviewsCount,
    required this.location,
    required this.photoUrls,
    required this.agencyId,
    required this.isAvailable,
    required this.depositAmount,
  });

  String get displayName => '$brand $model';

  String get categoryLabel {
    switch (category) {
      case CarCategory.city:
        return 'Citadine';
      case CarCategory.sedan:
        return 'Berline';
      case CarCategory.suv:
        return 'SUV';
      case CarCategory.utility:
        return 'Utilitaire';
      case CarCategory.electric:
        return 'Électrique';
      case CarCategory.family:
        return 'Familiale';
      case CarCategory.minibus:
        return 'Minibus';
      case CarCategory.fourByFour:
        return '4x4';
      case CarCategory.convertible:
        return 'Cabriolet';
      case CarCategory.coupe:
        return 'Coupé';
      case CarCategory.collection:
        return 'Collection';
      case CarCategory.camperVan:
        return 'Van aménagé';
    }
  }

  String get transmissionLabel =>
      transmission == Transmission.manual ? 'Manuelle' : 'Automatique';

  String get fuelLabel {
    switch (fuelType) {
      case FuelType.gasoline:
        return 'Essence';
      case FuelType.diesel:
        return 'Diesel';
      case FuelType.hybrid:
        return 'Hybride';
      case FuelType.electric:
        return 'Électrique';
    }
  }

  @override
  List<Object?> get props => [
        id,
        brand,
        model,
        plate,
        year,
        seats,
        category,
        transmission,
        fuelType,
        dailyPrice,
        rating,
        reviewsCount,
        location,
        photoUrls,
        agencyId,
        isAvailable,
        depositAmount,
      ];
}
