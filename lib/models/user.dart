// lib/models/user.dart
class User {
  int? id;
  String firstName;
  String lastName;
  String email;
  String password; // Stocke le hash du mot de passe
  DateTime createdAt;
  DateTime? updatedAt;
  bool rememberMe;
  bool isActive;
  String? phoneNumber;
  String? profileImage;
  String? address;
  String? city;
  String? country;
  String? postalCode;
  DateTime? dateOfBirth;
  String? drivingLicenseNumber;
  DateTime? drivingLicenseExpiry;
  int totalTrips;
  double totalDistance;
  double averageScore;
  String subscriptionType;
  DateTime? subscriptionExpiry;
  String? emergencyContactName;
  String? emergencyContactPhone;
  List<String> preferences;

  User({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.createdAt,
    this.updatedAt,
    this.rememberMe = false,
    this.isActive = true,
    this.phoneNumber,
    this.profileImage,
    this.address,
    this.city,
    this.country,
    this.postalCode,
    this.dateOfBirth,
    this.drivingLicenseNumber,
    this.drivingLicenseExpiry,
    this.totalTrips = 0,
    this.totalDistance = 0.0,
    this.averageScore = 0.0,
    this.subscriptionType = 'free',
    this.subscriptionExpiry,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.preferences = const [],
  });

  // Getter pour le nom complet
  String get fullName => '$firstName $lastName';

  // Getter pour l'âge (si dateOfBirth est fournie)
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  // Getter pour vérifier si le permis est expiré
  bool get isDrivingLicenseExpired {
    if (drivingLicenseExpiry == null) return false;
    return drivingLicenseExpiry!.isBefore(DateTime.now());
  }

  // Getter pour vérifier si l'abonnement est actif
  bool get isSubscriptionActive {
    if (subscriptionExpiry == null) return false;
    return subscriptionExpiry!.isAfter(DateTime.now());
  }

  // Convertir en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'rememberMe': rememberMe ? 1 : 0,
      'isActive': isActive ? 1 : 0,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'address': address,
      'city': city,
      'country': country,
      'postalCode': postalCode,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'drivingLicenseNumber': drivingLicenseNumber,
      'drivingLicenseExpiry': drivingLicenseExpiry?.toIso8601String(),
      'totalTrips': totalTrips,
      'totalDistance': totalDistance,
      'averageScore': averageScore,
      'subscriptionType': subscriptionType,
      'subscriptionExpiry': subscriptionExpiry?.toIso8601String(),
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'preferences': preferences.join(','), // Convertir liste en string
    };
  }

  // Créer un User à partir d'un Map (depuis SQLite)
  factory User.fromMap(Map<String, dynamic> map) {
    List<String> preferencesList = [];
    if (map['preferences'] != null && map['preferences'].toString().isNotEmpty) {
      preferencesList = map['preferences'].toString().split(',');
    }

    return User(
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
      password: map['password'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      rememberMe: map['rememberMe'] == 1,
      isActive: map['isActive'] == 1,
      phoneNumber: map['phoneNumber'],
      profileImage: map['profileImage'],
      address: map['address'],
      city: map['city'],
      country: map['country'],
      postalCode: map['postalCode'],
      dateOfBirth: map['dateOfBirth'] != null ? DateTime.parse(map['dateOfBirth']) : null,
      drivingLicenseNumber: map['drivingLicenseNumber'],
      drivingLicenseExpiry: map['drivingLicenseExpiry'] != null ? DateTime.parse(map['drivingLicenseExpiry']) : null,
      totalTrips: map['totalTrips'] ?? 0,
      totalDistance: (map['totalDistance'] ?? 0.0).toDouble(),
      averageScore: (map['averageScore'] ?? 0.0).toDouble(),
      subscriptionType: map['subscriptionType'] ?? 'free',
      subscriptionExpiry: map['subscriptionExpiry'] != null ? DateTime.parse(map['subscriptionExpiry']) : null,
      emergencyContactName: map['emergencyContactName'],
      emergencyContactPhone: map['emergencyContactPhone'],
      preferences: preferencesList,
    );
  }

  // Copier avec modifications
  User copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? rememberMe,
    bool? isActive,
    String? phoneNumber,
    String? profileImage,
    String? address,
    String? city,
    String? country,
    String? postalCode,
    DateTime? dateOfBirth,
    String? drivingLicenseNumber,
    DateTime? drivingLicenseExpiry,
    int? totalTrips,
    double? totalDistance,
    double? averageScore,
    String? subscriptionType,
    DateTime? subscriptionExpiry,
    String? emergencyContactName,
    String? emergencyContactPhone,
    List<String>? preferences,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rememberMe: rememberMe ?? this.rememberMe,
      isActive: isActive ?? this.isActive,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      drivingLicenseNumber: drivingLicenseNumber ?? this.drivingLicenseNumber,
      drivingLicenseExpiry: drivingLicenseExpiry ?? this.drivingLicenseExpiry,
      totalTrips: totalTrips ?? this.totalTrips,
      totalDistance: totalDistance ?? this.totalDistance,
      averageScore: averageScore ?? this.averageScore,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      preferences: preferences ?? this.preferences,
    );
  }

  // Convertir en JSON pour API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'address': address,
      'city': city,
      'country': country,
      'postalCode': postalCode,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'drivingLicenseNumber': drivingLicenseNumber,
      'drivingLicenseExpiry': drivingLicenseExpiry?.toIso8601String(),
      'totalTrips': totalTrips,
      'totalDistance': totalDistance,
      'averageScore': averageScore,
      'subscriptionType': subscriptionType,
      'subscriptionExpiry': subscriptionExpiry?.toIso8601String(),
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'preferences': preferences,
    };
  }

  // Créer depuis JSON (API)
  factory User.fromJson(Map<String, dynamic> json) {
    List<String> preferencesList = [];
    if (json['preferences'] != null) {
      if (json['preferences'] is List) {
        preferencesList = List<String>.from(json['preferences']);
      }
    }

    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      password: json['password'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      isActive: json['isActive'] ?? true,
      phoneNumber: json['phoneNumber'],
      profileImage: json['profileImage'],
      address: json['address'],
      city: json['city'],
      country: json['country'],
      postalCode: json['postalCode'],
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : null,
      drivingLicenseNumber: json['drivingLicenseNumber'],
      drivingLicenseExpiry: json['drivingLicenseExpiry'] != null ? DateTime.parse(json['drivingLicenseExpiry']) : null,
      totalTrips: json['totalTrips'] ?? 0,
      totalDistance: (json['totalDistance'] ?? 0.0).toDouble(),
      averageScore: (json['averageScore'] ?? 0.0).toDouble(),
      subscriptionType: json['subscriptionType'] ?? 'free',
      subscriptionExpiry: json['subscriptionExpiry'] != null ? DateTime.parse(json['subscriptionExpiry']) : null,
      emergencyContactName: json['emergencyContactName'],
      emergencyContactPhone: json['emergencyContactPhone'],
      preferences: preferencesList,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, name: $fullName, email: $email, active: $isActive, trips: $totalTrips}';
  }

  // Comparer deux utilisateurs
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}

// Enum pour les types d'abonnement
enum SubscriptionType {
  free('Gratuit', 'free'),
  basic('Basique', 'basic'),
  premium('Premium', 'premium'),
  pro('Professionnel', 'pro');

  final String displayName;
  final String value;

  const SubscriptionType(this.displayName, this.value);
}

// Extension pour convertir String en SubscriptionType
extension SubscriptionTypeExtension on String {
  SubscriptionType toSubscriptionType() {
    switch (this) {
      case 'basic':
        return SubscriptionType.basic;
      case 'premium':
        return SubscriptionType.premium;
      case 'pro':
        return SubscriptionType.pro;
      default:
        return SubscriptionType.free;
    }
  }
}

// Extension pour SubscriptionType
extension SubscriptionTypeMethods on SubscriptionType {
  double get monthlyPrice {
    switch (this) {
      case SubscriptionType.free:
        return 0.0;
      case SubscriptionType.basic:
        return 4.99;
      case SubscriptionType.premium:
        return 9.99;
      case SubscriptionType.pro:
        return 19.99;
    }
  }

  List<String> get features {
    switch (this) {
      case SubscriptionType.free:
        return [
          'Trajets illimités',
          'Statistiques basiques',
          'Carte standard',
        ];
      case SubscriptionType.basic:
        return [
          'Toutes les fonctionnalités gratuites',
          'Statistiques avancées',
          'Notifications personnalisées',
          'Support email',
        ];
      case SubscriptionType.premium:
        return [
          'Toutes les fonctionnalités basiques',
          'Analyses détaillées',
          'Carte offline',
          'Export des données',
          'Support prioritaire',
        ];
      case SubscriptionType.pro:
        return [
          'Toutes les fonctionnalités premium',
          'API personnalisée',
          'Tableau de bord avancé',
          'Support 24/7',
          'Formation personnalisée',
        ];
    }
  }

  int get maxVehicles {
    switch (this) {
      case SubscriptionType.free:
        return 1;
      case SubscriptionType.basic:
        return 3;
      case SubscriptionType.premium:
        return 10;
      case SubscriptionType.pro:
        return 999; // Illimité
    }
  }

  int get maxTripHistory {
    switch (this) {
      case SubscriptionType.free:
        return 30; // 30 jours
      case SubscriptionType.basic:
        return 90; // 3 mois
      case SubscriptionType.premium:
        return 365; // 1 an
      case SubscriptionType.pro:
        return 365 * 5; // 5 ans
    }
  }
}