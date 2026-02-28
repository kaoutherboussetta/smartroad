import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/backend_config.dart';
import '../models/user.dart';

/// Client pour le backend Node.js (server.js) — authentification.
/// Utilise toujours [backendBaseUrl] (pas d'URL en dur) : emulator 10.0.2.2, téléphone = IP du PC, web = localhost.
class ConnexionBackendClient {
  static final ConnexionBackendClient instance = ConnexionBackendClient._();

  /// Lu à chaque requête pour éviter tout cache localhost.
  String get _base => backendBaseUrl;

  ConnexionBackendClient._();

  dynamic _parseJson(String body, String context) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      throw Exception('Réponse vide. Vérifiez que le backend (server.js) tourne sur $backendBaseUrl');
    }
    if (trimmed.startsWith('<')) {
      throw Exception(
        'Le serveur a renvoyé du HTML au lieu de JSON. '
        'Démarrez le backend : dans le dossier backend lancez "npm start", '
        'puis assurez-vous que le backend est bien à l\'adresse $backendBaseUrl',
      );
    }
    try {
      return jsonDecode(body);
    } catch (e) {
      throw Exception('$context — réponse invalide: ${body.length > 80 ? "${body.substring(0, 80)}..." : body}');
    }
  }

  Future<User?> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
        'rememberMe': rememberMe,
      }),
    );
    final body = _parseJson(res.body, 'Login');
    if (res.statusCode != 200) {
      throw Exception((body is Map ? body['error'] : null) ?? 'Connexion impossible');
    }
    final map = body as Map<String, dynamic>;
    return User(
      id: null,
      firstName: map['firstName']?.toString() ?? '',
      lastName: map['lastName']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      password: map['passwordHash']?.toString() ?? '',
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
      rememberMe: map['rememberMe'] == true,
      isActive: map['isActive'] ?? true,
      phoneNumber: map['phoneNumber']?.toString(),
    );
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    bool acceptTerms = false,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/api/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': email.trim(),
        'password': password,
        'acceptTerms': acceptTerms,
      }),
    );
    if (res.statusCode == 201 || res.statusCode == 200) return true;
    final body = _parseJson(res.body, 'Inscription');
    throw Exception((body is Map ? body['error'] : null) ?? 'Erreur inscription');
  }

  Future<bool> emailExists(String email) async {
    final encoded = Uri.encodeComponent(email.trim().toLowerCase());
    final res = await http.get(Uri.parse('$_base/api/email-exists/$encoded'));
    if (res.statusCode != 200) return false;
    final body = _parseJson(res.body, 'email-exists');
    return body is Map && body['exists'] == true;
  }

  Future<bool> updatePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    final res = await http.put(
      Uri.parse('$_base/api/update-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.trim(),
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );
    if (res.statusCode == 200) return true;
    final body = _parseJson(res.body, 'update-password');
    throw Exception((body is Map ? body['error'] : null) ?? 'Erreur mise à jour mot de passe');
  }

  DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    return DateTime.now();
  }
}
