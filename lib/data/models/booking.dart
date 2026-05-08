import 'package:equatable/equatable.dart';

enum BookingStatus { pending, confirmed, inProgress, completed, cancelled }

class Booking extends Equatable {
  final String id;
  final String carId;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final double depositAmount;
  final BookingStatus status;
  final DateTime? pickupVideoAt;
  final DateTime? returnVideoAt;
  final bool isCarUnlocked;
  final bool additionalDriver;
  final bool babySeat;
  final bool unlimitedKm;

  const Booking({
    required this.id,
    required this.carId,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.depositAmount,
    required this.status,
    this.pickupVideoAt,
    this.returnVideoAt,
    this.isCarUnlocked = false,
    this.additionalDriver = false,
    this.babySeat = false,
    this.unlimitedKm = false,
  });

  int get durationDays => endDate.difference(startDate).inDays.clamp(1, 365);

  Booking copyWith({
    String? id,
    String? carId,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    double? totalPrice,
    double? depositAmount,
    BookingStatus? status,
    DateTime? pickupVideoAt,
    DateTime? returnVideoAt,
    bool? isCarUnlocked,
    bool? additionalDriver,
    bool? babySeat,
    bool? unlimitedKm,
  }) {
    return Booking(
      id: id ?? this.id,
      carId: carId ?? this.carId,
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalPrice: totalPrice ?? this.totalPrice,
      depositAmount: depositAmount ?? this.depositAmount,
      status: status ?? this.status,
      pickupVideoAt: pickupVideoAt ?? this.pickupVideoAt,
      returnVideoAt: returnVideoAt ?? this.returnVideoAt,
      isCarUnlocked: isCarUnlocked ?? this.isCarUnlocked,
      additionalDriver: additionalDriver ?? this.additionalDriver,
      babySeat: babySeat ?? this.babySeat,
      unlimitedKm: unlimitedKm ?? this.unlimitedKm,
    );
  }

  @override
  List<Object?> get props => [
        id,
        carId,
        userId,
        startDate,
        endDate,
        totalPrice,
        depositAmount,
        status,
        pickupVideoAt,
        returnVideoAt,
        isCarUnlocked,
        additionalDriver,
        babySeat,
        unlimitedKm,
      ];
}
