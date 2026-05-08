import 'package:equatable/equatable.dart';

class Agency extends Equatable {
  final String id;
  final String name;
  final String address;
  final String phone;
  final double rating;
  final int totalRentals;

  const Agency({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.rating,
    required this.totalRentals,
  });

  @override
  List<Object?> get props => [id, name, address, phone, rating, totalRentals];
}
