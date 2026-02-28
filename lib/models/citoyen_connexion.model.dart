import 'package:mongo_dart/mongo_dart.dart';

class CitoyenConnexion {
  ObjectId? id;
  String email;
  String passwordHash;
  String firstName;
  String lastName;
  DateTime createdAt;
  DateTime? updatedAt;
  bool isActive;
  bool rememberMe;
  bool acceptTerms;
  String? phoneNumber;

  CitoyenConnexion({
    this.id,
    required this.email,
    required this.passwordHash,
    required this.firstName,
    required this.lastName,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.rememberMe = false,
    this.acceptTerms = false,
    this.phoneNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'email': email,
      'passwordHash': passwordHash,
      'firstName': firstName,
      'lastName': lastName,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': (updatedAt ?? createdAt).toUtc().toIso8601String(),
      'isActive': isActive,
      'rememberMe': rememberMe,
      'acceptTerms': acceptTerms,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
    };
  }

  factory CitoyenConnexion.fromMap(Map<String, dynamic> map) {
    return CitoyenConnexion(
      id: map['_id'] is ObjectId ? map['_id'] : null,
      email: map['email'] ?? '',
      passwordHash: map['passwordHash'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      isActive: map['isActive'] ?? true,
      rememberMe: map['rememberMe'] ?? false,
      acceptTerms: map['acceptTerms'] ?? false,
      phoneNumber: map['phoneNumber']?.toString(),
    );
  }
}