import 'package:latlong2/latlong.dart';

import 'models/agency.dart';
import 'models/booking.dart';
import 'models/car.dart';
import 'models/user_profile.dart';

class MockData {
  static const tunisCenter = LatLng(36.8065, 10.1815);

  static const List<Agency> agencies = [
    Agency(
      id: 'a1',
      name: 'Tunis Auto Rent',
      address: 'Avenue Habib Bourguiba, Tunis Centre',
      phone: '+216 71 123 456',
      rating: 4.6,
      totalRentals: 1280,
    ),
    Agency(
      id: 'a2',
      name: 'Carthage Cars',
      address: 'Rue de Carthage, Carthage',
      phone: '+216 71 234 567',
      rating: 4.4,
      totalRentals: 890,
    ),
    Agency(
      id: 'a3',
      name: 'Lac Premium',
      address: 'Les Berges du Lac, Tunis',
      phone: '+216 71 345 678',
      rating: 4.8,
      totalRentals: 2105,
    ),
    Agency(
      id: 'a4',
      name: 'Sahel Drive',
      address: 'Route de la Marsa, La Marsa',
      phone: '+216 71 456 789',
      rating: 4.5,
      totalRentals: 1530,
    ),
  ];

  static final List<Car> cars = [
    Car(
      id: 'c1',
      brand: 'Renault',
      model: 'Clio',
      plate: '123 TN 4567',
      year: 2023,
      seats: 5,
      category: CarCategory.city,
      transmission: Transmission.manual,
      fuelType: FuelType.gasoline,
      dailyPrice: 95,
      rating: 4.7,
      reviewsCount: 128,
      location: const LatLng(36.8065, 10.1815),
      photoUrls: const [
        'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=800',
        'https://images.unsplash.com/photo-1502877338535-766e1452684a?w=800',
      ],
      agencyId: 'a1',
      isAvailable: true,
      depositAmount: 600,
    ),
    Car(
      id: 'c2',
      brand: 'Peugeot',
      model: '208',
      plate: '234 TN 5678',
      year: 2024,
      seats: 5,
      category: CarCategory.city,
      transmission: Transmission.automatic,
      fuelType: FuelType.gasoline,
      dailyPrice: 110,
      rating: 4.8,
      reviewsCount: 95,
      location: const LatLng(36.8780, 10.3247),
      photoUrls: const [
        'https://images.unsplash.com/photo-1605559424843-9e4c228bf1c2?w=800',
        'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=800',
      ],
      agencyId: 'a4',
      isAvailable: true,
      depositAmount: 700,
    ),
    Car(
      id: 'c3',
      brand: 'Dacia',
      model: 'Sandero',
      plate: '345 TN 6789',
      year: 2022,
      seats: 5,
      category: CarCategory.city,
      transmission: Transmission.manual,
      fuelType: FuelType.diesel,
      dailyPrice: 80,
      rating: 4.4,
      reviewsCount: 210,
      location: const LatLng(36.8324, 10.2334),
      photoUrls: const [
        'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=800',
      ],
      agencyId: 'a3',
      isAvailable: true,
      depositAmount: 500,
    ),
    Car(
      id: 'c4',
      brand: 'Hyundai',
      model: 'Tucson',
      plate: '456 TN 7890',
      year: 2024,
      seats: 5,
      category: CarCategory.suv,
      transmission: Transmission.automatic,
      fuelType: FuelType.diesel,
      dailyPrice: 220,
      rating: 4.9,
      reviewsCount: 67,
      location: const LatLng(36.8431, 10.2620),
      photoUrls: const [
        'https://images.unsplash.com/photo-1606220838315-056192d5e927?w=800',
        'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800',
      ],
      agencyId: 'a3',
      isAvailable: true,
      depositAmount: 1200,
    ),
    Car(
      id: 'c5',
      brand: 'Volkswagen',
      model: 'Golf',
      plate: '567 TN 8901',
      year: 2023,
      seats: 5,
      category: CarCategory.sedan,
      transmission: Transmission.automatic,
      fuelType: FuelType.gasoline,
      dailyPrice: 160,
      rating: 4.6,
      reviewsCount: 142,
      location: const LatLng(36.8419, 10.1547),
      photoUrls: const [
        'https://images.unsplash.com/photo-1606152421802-db97b9c7a11b?w=800',
      ],
      agencyId: 'a1',
      isAvailable: true,
      depositAmount: 900,
    ),
    Car(
      id: 'c6',
      brand: 'Kia',
      model: 'Picanto',
      plate: '678 TN 9012',
      year: 2023,
      seats: 4,
      category: CarCategory.city,
      transmission: Transmission.manual,
      fuelType: FuelType.gasoline,
      dailyPrice: 85,
      rating: 4.3,
      reviewsCount: 178,
      location: const LatLng(36.8625, 10.1956),
      photoUrls: const [
        'https://images.unsplash.com/photo-1592805144716-feeccccef5ac?w=800',
      ],
      agencyId: 'a4',
      isAvailable: true,
      depositAmount: 500,
    ),
    Car(
      id: 'c7',
      brand: 'Toyota',
      model: 'Yaris',
      plate: '789 TN 0123',
      year: 2024,
      seats: 5,
      category: CarCategory.city,
      transmission: Transmission.automatic,
      fuelType: FuelType.hybrid,
      dailyPrice: 130,
      rating: 4.8,
      reviewsCount: 89,
      location: const LatLng(36.8528, 10.3238),
      photoUrls: const [
        'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800',
      ],
      agencyId: 'a2',
      isAvailable: true,
      depositAmount: 800,
    ),
    Car(
      id: 'c8',
      brand: 'Fiat',
      model: '500',
      plate: '890 TN 1234',
      year: 2022,
      seats: 4,
      category: CarCategory.city,
      transmission: Transmission.manual,
      fuelType: FuelType.gasoline,
      dailyPrice: 90,
      rating: 4.5,
      reviewsCount: 156,
      location: const LatLng(36.8418, 10.1722),
      photoUrls: const [
        'https://images.unsplash.com/photo-1550355291-bbee04a92027?w=800',
      ],
      agencyId: 'a1',
      isAvailable: true,
      depositAmount: 550,
    ),
    Car(
      id: 'c9',
      brand: 'Renault',
      model: 'Symbol',
      plate: '901 TN 2345',
      year: 2023,
      seats: 5,
      category: CarCategory.sedan,
      transmission: Transmission.manual,
      fuelType: FuelType.diesel,
      dailyPrice: 100,
      rating: 4.4,
      reviewsCount: 98,
      location: const LatLng(36.8088, 10.1364),
      photoUrls: const [
        'https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=800',
      ],
      agencyId: 'a2',
      isAvailable: true,
      depositAmount: 600,
    ),
    Car(
      id: 'c10',
      brand: 'Citroën',
      model: 'C3',
      plate: '012 TN 3456',
      year: 2024,
      seats: 5,
      category: CarCategory.city,
      transmission: Transmission.automatic,
      fuelType: FuelType.gasoline,
      dailyPrice: 115,
      rating: 4.6,
      reviewsCount: 112,
      location: const LatLng(36.8769, 10.2253),
      photoUrls: const [
        'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800',
      ],
      agencyId: 'a4',
      isAvailable: true,
      depositAmount: 700,
    ),
    Car(
      id: 'c11',
      brand: 'Skoda',
      model: 'Fabia',
      plate: '111 TN 4567',
      year: 2023,
      seats: 5,
      category: CarCategory.utility,
      transmission: Transmission.manual,
      fuelType: FuelType.diesel,
      dailyPrice: 105,
      rating: 4.2,
      reviewsCount: 76,
      location: const LatLng(36.7654, 10.2310),
      photoUrls: const [
        'https://images.unsplash.com/photo-1604054094723-3a949e4fca0b?w=800',
      ],
      agencyId: 'a3',
      isAvailable: true,
      depositAmount: 650,
    ),
    Car(
      id: 'c12',
      brand: 'Suzuki',
      model: 'Swift',
      plate: '222 TN 5678',
      year: 2024,
      seats: 5,
      category: CarCategory.electric,
      transmission: Transmission.automatic,
      fuelType: FuelType.electric,
      dailyPrice: 250,
      rating: 4.9,
      reviewsCount: 42,
      location: const LatLng(36.7547, 10.2189),
      photoUrls: const [
        'https://images.unsplash.com/photo-1617469767053-d3b523a0b982?w=800',
      ],
      agencyId: 'a3',
      isAvailable: true,
      depositAmount: 1500,
    ),
  ];

  static UserProfile profile = UserProfile(
    name: 'Mohamed Ben Salah',
    email: 'mohamed.bensalah@example.tn',
    phone: '+216 22 345 678',
    avatarUrl:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
  );

  static List<Booking> bookings = [
    Booking(
      id: 'b-up-1',
      carId: 'c5',
      userId: 'user1',
      startDate: DateTime.now().add(const Duration(days: 5)),
      endDate: DateTime.now().add(const Duration(days: 8)),
      totalPrice: 480,
      depositAmount: 900,
      status: BookingStatus.confirmed,
    ),
    Booking(
      id: 'b-now-1',
      carId: 'c1',
      userId: 'user1',
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 2)),
      totalPrice: 285,
      depositAmount: 600,
      status: BookingStatus.inProgress,
      isCarUnlocked: true,
    ),
    Booking(
      id: 'b-past-1',
      carId: 'c8',
      userId: 'user1',
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now().subtract(const Duration(days: 26)),
      totalPrice: 360,
      depositAmount: 550,
      status: BookingStatus.completed,
    ),
    Booking(
      id: 'b-past-2',
      carId: 'c2',
      userId: 'user1',
      startDate: DateTime.now().subtract(const Duration(days: 60)),
      endDate: DateTime.now().subtract(const Duration(days: 58)),
      totalPrice: 220,
      depositAmount: 700,
      status: BookingStatus.completed,
    ),
  ];

  static Car? carById(String id) {
    for (final c in cars) {
      if (c.id == id) return c;
    }
    return null;
  }

  static Agency? agencyById(String id) {
    for (final a in agencies) {
      if (a.id == id) return a;
    }
    return null;
  }

  static Booking? bookingById(String id) {
    for (final b in bookings) {
      if (b.id == id) return b;
    }
    return null;
  }
}
