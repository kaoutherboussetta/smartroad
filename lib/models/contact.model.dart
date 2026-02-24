import 'package:mongo_dart/mongo_dart.dart';

/// Modèle Contact pour MongoDB (collection contacts).
class Contact {
  ObjectId? id;
  String nom;
  String prenom;
  String telephone;
  String email;
  String? imagePath;

  Contact({
    this.id,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.email,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'email': email,
    };
    if (imagePath != null) map['imagePath'] = imagePath!;
    if (id != null) map['_id'] = id;
    return map;
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    ObjectId? docId;
    if (map['_id'] != null) {
      docId = map['_id'] is ObjectId ? map['_id'] as ObjectId : ObjectId.fromHexString(map['_id'].toString());
    }
    return Contact(
      id: docId,
      nom: map['nom']?.toString() ?? '',
      prenom: map['prenom']?.toString() ?? '',
      telephone: map['telephone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      imagePath: map['imagePath']?.toString(),
    );
  }
}
