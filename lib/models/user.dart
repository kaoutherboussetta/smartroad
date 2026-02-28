// lib/models/user.dart
class User {
  int? id;
  String firstName;
  String lastName;
  String email;
  String password;
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

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    List<String> preferencesList = [];
    if (json['preferences'] != null) {
      if (json['preferences'] is List) {
        preferencesList = List<String>.from(json['preferences']);
      }
    }

    return User(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString() ?? json['passwordHash']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is String
              ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
              : DateTime.now())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null && json['updatedAt'] is String
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      rememberMe: json['rememberMe'] == true,
      isActive: json['isActive'] ?? true,
      phoneNumber: json['phoneNumber']?.toString(),
      profileImage: json['profileImage']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      country: json['country']?.toString(),
      postalCode: json['postalCode']?.toString(),
      dateOfBirth: json['dateOfBirth'] != null && json['dateOfBirth'] is String
          ? DateTime.tryParse(json['dateOfBirth'])
          : null,
      drivingLicenseNumber: json['drivingLicenseNumber']?.toString(),
      drivingLicenseExpiry: json['drivingLicenseExpiry'] != null && json['drivingLicenseExpiry'] is String
          ? DateTime.tryParse(json['drivingLicenseExpiry'])
          : null,
      totalTrips: json['totalTrips'] is int ? json['totalTrips'] as int : int.tryParse(json['totalTrips']?.toString() ?? '0') ?? 0,
      totalDistance: (json['totalDistance'] ?? 0.0).toDouble(),
      averageScore: (json['averageScore'] ?? 0.0).toDouble(),
      subscriptionType: json['subscriptionType']?.toString() ?? 'free',
      subscriptionExpiry: json['subscriptionExpiry'] != null && json['subscriptionExpiry'] is String
          ? DateTime.tryParse(json['subscriptionExpiry'])
          : null,
      emergencyContactName: json['emergencyContactName']?.toString(),
      emergencyContactPhone: json['emergencyContactPhone']?.toString(),
      preferences: preferencesList,
    );
  }

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
      'totalTrips': totalTrips,
    };
  }

  @override
  String toString() => 'User($fullName, $email)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id && email == other.email;

  @override
  int get hashCode => Object.hash(id, email);
}
