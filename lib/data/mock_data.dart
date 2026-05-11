import 'package:latlong2/latlong.dart';

import 'models/agency.dart';
import 'models/booking.dart';
import 'models/car.dart';
import 'models/conversation.dart';
import 'models/message.dart';
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
        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c6/Renault_Clio_V_(2023)_1X7A1577.jpg/500px-Renault_Clio_V_(2023)_1X7A1577.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4b/Renault_Clio_V_(2023)_1X7A1579.jpg/500px-Renault_Clio_V_(2023)_1X7A1579.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/Renault_Clio_V_Genf_2019_1Y7A5590.jpg/500px-Renault_Clio_V_Genf_2019_1Y7A5590.jpg',
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
        'https://upload.wikimedia.org/wikipedia/commons/thumb/7/78/Peugeot_208_GT_P21_Vertigo_Blue_%281%29.jpg/500px-Peugeot_208_GT_P21_Vertigo_Blue_%281%29.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b4/Peugeot_208_GT_P21_Vertigo_Blue_%286%29.jpg/500px-Peugeot_208_GT_P21_Vertigo_Blue_%286%29.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/7/74/Peugeot_208_GT_P21_Vertigo_Blue_%2812%29.jpg/500px-Peugeot_208_GT_P21_Vertigo_Blue_%2812%29.jpg',
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
        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/ce/Dacia_Sandero_(2020-present)-Front.jpg/500px-Dacia_Sandero_(2020-present)-Front.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/51/Dacia_Sandero_(2020-present)-Rear.jpg/500px-Dacia_Sandero_(2020-present)-Rear.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/6/69/Dacia_Sandero_2023_Front_1.jpg/500px-Dacia_Sandero_2023_Front_1.jpg',
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
        'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/2021_Hyundai_Tucson_Elite_N-Line_front.jpg/500px-2021_Hyundai_Tucson_Elite_N-Line_front.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/2021_Hyundai_Tucson_Elite_N-Line_rear.jpg/500px-2021_Hyundai_Tucson_Elite_N-Line_rear.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7b/2021_Hyundai_Tucson_Elite_N-Line_front_(1).jpg/500px-2021_Hyundai_Tucson_Elite_N-Line_front_(1).jpg',
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
        'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8a/2020_Volkswagen_Golf_Style_1.5_Front.jpg/500px-2020_Volkswagen_Golf_Style_1.5_Front.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/4/49/2020_Volkswagen_Golf_Style_1.5_Rear.jpg/500px-2020_Volkswagen_Golf_Style_1.5_Rear.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/Volkswagen_Golf_VIII_1X7A0353.jpg/500px-Volkswagen_Golf_VIII_1X7A0353.jpg',
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
        'https://upload.wikimedia.org/wikipedia/commons/thumb/b/be/2017_Kia_Picanto_GT-Line_S_1.2_Front.jpg/500px-2017_Kia_Picanto_GT-Line_S_1.2_Front.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/3/39/2017_Kia_Picanto_GT-Line_S_1.2_Rear.jpg/500px-2017_Kia_Picanto_GT-Line_S_1.2_Rear.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/2017_Kia_Picanto_1_1.0_Front.jpg/500px-2017_Kia_Picanto_1_1.0_Front.jpg',
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
        'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/2020-2024_Toyota_Yaris_Hybrid.jpg/500px-2020-2024_Toyota_Yaris_Hybrid.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/2020-2024_Toyota_Yaris_Z_rear.jpg/500px-2020-2024_Toyota_Yaris_Z_rear.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3e/2020_Toyota_Yaris_Design_HEV_CVT_1.5_Front.jpg/500px-2020_Toyota_Yaris_Design_HEV_CVT_1.5_Front.jpg',
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
        'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/2008_Fiat_500_(1).jpg/500px-2008_Fiat_500_(1).jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/2008_Fiat_500_(2).jpg/500px-2008_Fiat_500_(2).jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/8/82/2008_Fiat_500_01.JPG/500px-2008_Fiat_500_01.JPG',
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
        'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Renault_Symbol_(3914609043).jpg/500px-Renault_Symbol_(3914609043).jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/9/93/Renault_Symbol_(3399981339).jpg/500px-Renault_Symbol_(3399981339).jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/Renault_Symbol_(2993567559).jpg/500px-Renault_Symbol_(2993567559).jpg',
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
        'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7d/2017_Citroen_C3_Feel_Puretech_1.2.jpg/500px-2017_Citroen_C3_Feel_Puretech_1.2.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e3/Citroen_C3_PureTech_82_Feel_2017_(33137298670).jpg/500px-Citroen_C3_PureTech_82_Feel_2017_(33137298670).jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/2017_Citroen_C3_1.2_Feel.jpg/500px-2017_Citroen_C3_1.2_Feel.jpg',
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
        'https://upload.wikimedia.org/wikipedia/commons/thumb/3/35/Skoda_Fabia_IV_-_front.jpg/500px-Skoda_Fabia_IV_-_front.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7f/Skoda_Fabia_IV_-_rear.jpg/500px-Skoda_Fabia_IV_-_rear.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7d/Skoda_Fabia_IV_IMG_5307.jpg/500px-Skoda_Fabia_IV_IMG_5307.jpg',
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
        'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/2018_Suzuki_Swift_SZ5_Boosterjet_SHVS_1.0_Front.jpg/500px-2018_Suzuki_Swift_SZ5_Boosterjet_SHVS_1.0_Front.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/2018_Suzuki_Swift_SZ5_Boosterjet_SHVS_1.0_Rear.jpg/500px-2018_Suzuki_Swift_SZ5_Boosterjet_SHVS_1.0_Rear.jpg',
        'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/2017_Suzuki_Swift_SZ-L_1.2_Front.jpg/500px-2017_Suzuki_Swift_SZ-L_1.2_Front.jpg',
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

  static final List<Conversation> conversations = [
    // 1. Tunis Auto Rent — discussion avant réservation
    Conversation(
      id: 'conv-a1',
      agencyId: 'a1',
      agencyName: 'Tunis Auto Rent',
      agencyAvatarUrl:
          'https://images.unsplash.com/photo-1560179707-f14e90ef3623?w=400',
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      messages: [
        Message(
          id: 'm1-1',
          conversationId: 'conv-a1',
          sender: MessageSender.user,
          text: 'Bonjour, la Renault Clio est-elle disponible ce week-end ?',
          createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
          isRead: true,
        ),
        Message(
          id: 'm1-2',
          conversationId: 'conv-a1',
          sender: MessageSender.agency,
          text: 'Bonjour ! Oui, elle est libre samedi et dimanche. Souhaitez-vous la réserver ?',
          createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 4, minutes: 30)),
          isRead: true,
        ),
        Message(
          id: 'm1-3',
          conversationId: 'conv-a1',
          sender: MessageSender.user,
          text: 'Parfait, je prends pour 2 jours. Le prix est bien 95 DT/jour ?',
          createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
          isRead: true,
        ),
        Message(
          id: 'm1-4',
          conversationId: 'conv-a1',
          sender: MessageSender.agency,
          text: 'Exact. Avec l\'option sans clé incluse. On vous attend à notre agence sur l\'avenue Habib Bourguiba.',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: false,
        ),
      ],
    ),

    // 2. Carthage Cars — discussion post-réservation
    Conversation(
      id: 'conv-a2',
      agencyId: 'a2',
      agencyName: 'Carthage Cars',
      agencyAvatarUrl:
          'https://images.unsplash.com/photo-1497366216548-37526070297c?w=400',
      updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
      messages: [
        Message(
          id: 'm2-1',
          conversationId: 'conv-a2',
          sender: MessageSender.user,
          text: 'Bonjour, je viens de réserver la Toyota Yaris pour demain. Quelles sont les modalités de retrait ?',
          createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 10)),
          isRead: true,
        ),
        Message(
          id: 'm2-2',
          conversationId: 'conv-a2',
          sender: MessageSender.agency,
          text: 'Merci pour votre réservation ! Présentez votre pièce d\'identité et permis à l\'agence. Caution : 800 DT.',
          createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 9)),
          isRead: true,
        ),
        Message(
          id: 'm2-3',
          conversationId: 'conv-a2',
          sender: MessageSender.user,
          text: 'D\'accord, je serai là à 10h. Merci !',
          createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
          isRead: true,
        ),
        Message(
          id: 'm2-4',
          conversationId: 'conv-a2',
          sender: MessageSender.agency,
          text: 'À demain 10h ! N\'oubliez pas d\'activer le Bluetooth pour le déverrouillage sans clé.',
          createdAt: DateTime.now().subtract(const Duration(hours: 8)),
          isRead: false,
        ),
      ],
    ),

    // 3. Lac Premium — location en cours (problème technique)
    Conversation(
      id: 'conv-a3',
      agencyId: 'a3',
      agencyName: 'Lac Premium',
      agencyAvatarUrl:
          'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=400',
      updatedAt: DateTime.now().subtract(const Duration(minutes: 45)),
      messages: [
        Message(
          id: 'm3-1',
          conversationId: 'conv-a3',
          sender: MessageSender.user,
          text: 'Bonjour, j\'ai un problème avec la climatisation de la Tucson. Elle ne semble pas fonctionner.',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          isRead: true,
        ),
        Message(
          id: 'm3-2',
          conversationId: 'conv-a3',
          sender: MessageSender.agency,
          text: 'Bonjour, désolé pour ce désagrément. Pouvez-vous vérifier le bouton AC sur le tableau de bord ?',
          createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 50)),
          isRead: true,
        ),
        Message(
          id: 'm3-3',
          conversationId: 'conv-a3',
          sender: MessageSender.user,
          text: 'C\'est bon, j\'ai trouvé ! Le bouton était sur "éco". Merci pour votre réactivité.',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: true,
        ),
        Message(
          id: 'm3-4',
          conversationId: 'conv-a3',
          sender: MessageSender.agency,
          text: 'Super ! N\'hésitez pas si vous avez besoin d\'autre chose. Bonne route !',
          createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
          isRead: true,
        ),
      ],
    ),

    // 4. Sahel Drive — location terminée (avis & remerciement)
    Conversation(
      id: 'conv-a4',
      agencyId: 'a4',
      agencyName: 'Sahel Drive',
      agencyAvatarUrl:
          'https://images.unsplash.com/photo-1557804506-669a67965ba0?w=400',
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      messages: [
        Message(
          id: 'm4-1',
          conversationId: 'conv-a4',
          sender: MessageSender.agency,
          text: 'Merci d\'avoir loué chez Sahel Drive ! Comment s\'est passée votre expérience avec la Peugeot 208 ?',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          isRead: true,
        ),
        Message(
          id: 'm4-2',
          conversationId: 'conv-a4',
          sender: MessageSender.user,
          text: 'Excellente expérience ! Voiture propre, sans clé pratique, et excellent rapport qualité-prix.',
          createdAt: DateTime.now().subtract(const Duration(days: 5, hours: 2)),
          isRead: true,
        ),
        Message(
          id: 'm4-3',
          conversationId: 'conv-a4',
          sender: MessageSender.agency,
          text: 'Ravi de lire ça ! Votre avis nous aide beaucoup. À bientôt pour une prochaine location.',
          createdAt: DateTime.now().subtract(const Duration(days: 4)),
          isRead: true,
        ),
        Message(
          id: 'm4-4',
          conversationId: 'conv-a4',
          sender: MessageSender.user,
          text: 'Merci à vous ! Je recommanderai votre agence.',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          isRead: true,
        ),
      ],
    ),
  ];
}
