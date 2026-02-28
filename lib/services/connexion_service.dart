// lib/services/connexion_service.dart
import '../models/user.dart';
import 'connexion_backend_client.dart';

/// Service de connexion : utilise le backend Node.js (server.js) pour l'authentification.
/// La base MongoDB Atlas est liée via server.js, pas directement depuis l'app.
class ConnexionService {
  final ConnexionBackendClient _backend = ConnexionBackendClient.instance;

  Future<User?> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    return _backend.login(email: email, password: password, rememberMe: rememberMe);
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    bool acceptTerms = false,
  }) async {
    if (!acceptTerms) {
      throw Exception('Vous devez accepter les conditions d\'utilisation');
    }
    return _backend.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      acceptTerms: acceptTerms,
    );
  }

  Future<bool> emailExists(String email) async {
    return _backend.emailExists(email);
  }

  Future<bool> updatePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    return _backend.updatePassword(
      email: email,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<void> logout() async {}
}
