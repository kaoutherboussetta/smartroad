import 'package:mongo_dart/mongo_dart.dart';

/// Modèle des données de connexion d'un citoyen (collection MongoDB "connexions").
/// Utilisé pour stocker email, mot de passe hashé, nom, prénom, etc.
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
    final map = <String, dynamic>{
      'email': email,
      'passwordHash': passwordHash,
      'firstName': firstName,
      'lastName': lastName,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'isActive': isActive,
      'rememberMe': rememberMe,
      'acceptTerms': acceptTerms,
    };
    if (id != null) map['_id'] = id;
    if (updatedAt != null) map['updatedAt'] = updatedAt!.toUtc().toIso8601String();
    if (phoneNumber != null) map['phoneNumber'] = phoneNumber;
    return map;
  }

  factory CitoyenConnexion.fromMap(Map<String, dynamic> map) {
    ObjectId? docId;
    if (map['_id'] != null) {
      docId = map['_id'] is ObjectId
          ? map['_id'] as ObjectId
          : ObjectId.fromHexString(map['_id'].toString());
    }
    return CitoyenConnexion(
      id: docId,
      email: map['email']?.toString() ?? '',
      passwordHash: map['passwordHash']?.toString() ?? '',
      firstName: map['firstName']?.toString() ?? '',
      lastName: map['lastName']?.toString() ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'].toString()).toLocal()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'].toString()).toLocal()
          : null,
      isActive: map['isActive'] == true,
      rememberMe: map['rememberMe'] == true,
      acceptTerms: map['acceptTerms'] == true,
      phoneNumber: map['phoneNumber']?.toString(),
    );
  }
}
