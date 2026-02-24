import 'package:dio/dio.dart';
import '../config/atlas_config.dart';
import '../models/citoyen_connexion.model.dart';

/// Client API Data MongoDB Atlas.
/// - **users** : authentification (email, password bcrypt, first_name, last_name, name, created_at, updated_at)
/// - **citizens** : fiche citoyen liée à l'utilisateur (user_id, email, first_name, last_name, created_at)
class MongoDBAtlasDataApi {
  MongoDBAtlasDataApi._();
  static final MongoDBAtlasDataApi instance = MongoDBAtlasDataApi._();

  Dio? _dio;

  Dio get _client {
    if (_dio != null) return _dio!;
    if (!isAtlasDataApiConfigured) {
      throw Exception(
        'Atlas Data API non configurée. Renseignez atlasDataApiAppId et atlasDataApiKey dans lib/config/atlas_config.dart.',
      );
    }
    _dio = Dio(BaseOptions(
      baseUrl:
          'https://data.mongodb-api.com/app/$atlasDataApiAppId/endpoint/data/v1/action',
      headers: {
        'apiKey': atlasDataApiKey,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));
    return _dio!;
  }

  Map<String, dynamic> _body({
    required String collection,
    Map<String, dynamic>? filter,
    Map<String, dynamic>? document,
    Map<String, dynamic>? update,
  }) {
    final body = <String, dynamic>{
      'dataSource': atlasDataSource,
      'database': atlasDatabase,
      'collection': collection,
    };
    if (filter != null) body['filter'] = filter;
    if (document != null) body['document'] = document;
    if (update != null) body['update'] = update;
    return body;
  }

  /// Document users pour l'API (schéma Atlas : name, first_name, last_name, email, password, created_at, updated_at)
  static Map<String, dynamic> _userDocToApi({
    required String email,
    required String passwordBcrypt,
    required String firstName,
    required String lastName,
    required String name,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) {
    final map = <String, dynamic>{
      'email': email.trim().toLowerCase(),
      'password': passwordBcrypt,
      'first_name': firstName,
      'last_name': lastName,
      'name': name,
      'created_at': {'\$date': createdAt.toUtc().toIso8601String()},
      'updated_at': {'\$date': (updatedAt ?? createdAt).toUtc().toIso8601String()},
    };
    return map;
  }

  /// Document citizens pour l'API (user_id, email, first_name, last_name, created_at)
  static Map<String, dynamic> _citizenDocToApi({
    required String userIdOid,
    required String email,
    required String firstName,
    required String lastName,
    required DateTime createdAt,
  }) {
    return {
      'user_id': {r'$oid': userIdOid},
      'email': email.trim().toLowerCase(),
      'first_name': firstName,
      'last_name': lastName,
      'created_at': {'\$date': createdAt.toUtc().toIso8601String()},
    };
  }

  /// Normalise un document users de l'API vers le format CitoyenConnexion
  static Map<String, dynamic> _normalizeUserDoc(Map<String, dynamic>? doc) {
    if (doc == null) return {};
    final m = Map<String, dynamic>.from(doc);
    if (m['_id'] is Map && (m['_id'] as Map).containsKey(r'$oid')) {
      m['_id'] = (m['_id'] as Map)[r'$oid'].toString();
    }
    m['passwordHash'] = m['password']?.toString() ?? '';
    m['firstName'] = m['first_name']?.toString() ?? '';
    m['lastName'] = m['last_name']?.toString() ?? '';
    for (final k in ['created_at', 'updated_at']) {
      if (m[k] is Map && (m[k] as Map).containsKey(r'$date')) {
        final d = (m[k] as Map)[r'$date'];
        final keyOut = k == 'created_at' ? 'createdAt' : 'updatedAt';
        m[keyOut] = d is String ? d : d.toString();
      }
    }
    m['isActive'] = true;
    m['rememberMe'] = m['remember_me'] == true;
    m['acceptTerms'] = m['accept_terms'] == true;
    return m;
  }

  /// Récupère un utilisateur par email (collection users)
  Future<CitoyenConnexion?> getCitoyenByEmail(String email) async {
    try {
      final res = await _client.post(
        '/findOne',
        data: _body(
          collection: atlasCollectionUsers,
          filter: {'email': email.trim().toLowerCase()},
        ),
      );
      final doc = res.data['document'] as Map<String, dynamic>?;
      if (doc == null) return null;
      return CitoyenConnexion.fromMap(_normalizeUserDoc(doc));
    } on DioException catch (e) {
      if (e.response?.statusCode != null) {
        throw Exception(
          'API Atlas: ${e.response?.statusCode} ${e.response?.data ?? e.message}',
        );
      }
      rethrow;
    }
  }

  /// Inscription : insert dans users puis dans citizens (citoyen lié à l'utilisateur)
  Future<void> insertCitoyenConnexion(CitoyenConnexion citoyen) async {
    try {
      final name = '${citoyen.firstName} ${citoyen.lastName}'.trim();
      final userDoc = _userDocToApi(
        email: citoyen.email,
        passwordBcrypt: citoyen.passwordHash,
        firstName: citoyen.firstName,
        lastName: citoyen.lastName,
        name: name,
        createdAt: citoyen.createdAt,
        updatedAt: citoyen.updatedAt,
      );

      final res = await _client.post(
        '/insertOne',
        data: _body(collection: atlasCollectionUsers, document: userDoc),
      );

      final insertedId = res.data['insertedId'];
      String? oid;
      if (insertedId is Map && insertedId.containsKey(r'$oid')) {
        oid = insertedId[r'$oid'].toString();
      } else if (insertedId != null) {
        oid = insertedId.toString();
      }

      if (oid != null && oid.isNotEmpty) {
        final citizenDoc = _citizenDocToApi(
          userIdOid: oid,
          email: citoyen.email,
          firstName: citoyen.firstName,
          lastName: citoyen.lastName,
          createdAt: citoyen.createdAt,
        );
        await _client.post(
          '/insertOne',
          data: _body(collection: atlasCollectionCitizens, document: citizenDoc),
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 11000 ||
          e.response?.data?.toString().contains('duplicate') == true) {
        throw Exception('Un compte avec cet email existe déjà');
      }
      if (e.response?.statusCode != null) {
        throw Exception(
          'API Atlas: ${e.response?.statusCode} ${e.response?.data ?? e.message}',
        );
      }
      rethrow;
    }
  }

  Future<bool> updateRememberMe(String email, bool rememberMe) async {
    try {
      final res = await _client.post(
        '/updateOne',
        data: _body(
          collection: atlasCollectionUsers,
          filter: {'email': email.trim().toLowerCase()},
          update: {
            r'$set': {
              'updated_at': {
                r'$date': DateTime.now().toUtc().toIso8601String(),
              },
            },
          },
        ),
      );
      return (res.data['modifiedCount'] as num?)?.toInt() == 1;
    } on DioException catch (e) {
      if (e.response?.statusCode != null) {
        throw Exception(
          'API Atlas: ${e.response?.statusCode} ${e.response?.data ?? e.message}',
        );
      }
      rethrow;
    }
  }

  Future<bool> updateCitoyenPasswordByEmail(String email, String newPasswordBcrypt) async {
    try {
      final res = await _client.post(
        '/updateOne',
        data: _body(
          collection: atlasCollectionUsers,
          filter: {'email': email.trim().toLowerCase()},
          update: {
            r'$set': {
              'password': newPasswordBcrypt,
              'updated_at': {
                r'$date': DateTime.now().toUtc().toIso8601String(),
              },
            },
          },
        ),
      );
      return (res.data['modifiedCount'] as num?)?.toInt() == 1;
    } on DioException catch (e) {
      if (e.response?.statusCode != null) {
        throw Exception(
          'API Atlas: ${e.response?.statusCode} ${e.response?.data ?? e.message}',
        );
      }
      rethrow;
    }
  }

  Future<bool> citoyenEmailExists(String email) async {
    final c = await getCitoyenByEmail(email);
    return c != null;
  }
}
