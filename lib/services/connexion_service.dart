// lib/services/connexion_service.dart
import 'package:bcrypt/bcrypt.dart';
import 'mongodb_atlas_data_api.dart';
import '../models/user.dart';
import '../models/citoyen_connexion.model.dart';

/// Service de connexion : collection **users** (auth) + **citizens** (fiche citoyen) dans MongoDB Atlas.
class ConnexionService {
  final MongoDBAtlasDataApi _api = MongoDBAtlasDataApi.instance;

  String _hashPassword(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }

  bool _verifyPassword(String inputPassword, String storedHash) {
    try {
      return BCrypt.checkpw(inputPassword, storedHash);
    } catch (_) {
      return false;
    }
  }

  User _userFromCitoyen(CitoyenConnexion c) {
    return User(
      id: null,
      firstName: c.firstName,
      lastName: c.lastName,
      email: c.email,
      password: c.passwordHash,
      createdAt: c.createdAt,
      updatedAt: c.updatedAt,
      rememberMe: c.rememberMe,
      isActive: c.isActive,
      phoneNumber: c.phoneNumber,
    );
  }

  Future<User?> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final citoyen = await _api.getCitoyenByEmail(email);
      if (citoyen == null || !citoyen.isActive) return null;
      if (!_verifyPassword(password, citoyen.passwordHash)) return null;

      await _api.updateRememberMe(email, rememberMe);
      return _userFromCitoyen(citoyen);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    bool acceptTerms = false,
  }) async {
    try {
      if (!acceptTerms) {
        throw Exception('Vous devez accepter les conditions d\'utilisation');
      }

      final exists = await _api.citoyenEmailExists(email);
      if (exists) {
        throw Exception('Un compte avec cet email existe déjà');
      }

      final citoyen = CitoyenConnexion(
        email: email,
        passwordHash: _hashPassword(password),
        firstName: firstName,
        lastName: lastName,
        createdAt: DateTime.now(),
        isActive: true,
        acceptTerms: acceptTerms,
      );

      await _api.insertCitoyenConnexion(citoyen);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> emailExists(String email) async {
    try {
      return await _api.citoyenEmailExists(email);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updatePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final citoyen = await _api.getCitoyenByEmail(email);
      if (citoyen == null) {
        throw Exception('Utilisateur non trouvé');
      }
      if (!_verifyPassword(currentPassword, citoyen.passwordHash)) {
        throw Exception('Mot de passe actuel incorrect');
      }
      return await _api.updateCitoyenPasswordByEmail(email, _hashPassword(newPassword));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {}
}
