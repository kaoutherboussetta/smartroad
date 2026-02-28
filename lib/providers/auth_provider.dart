// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/connexion_service.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  final ConnexionService _authService = ConnexionService();

  // 🔹 Connexion
  Future<bool> login(String email, String password, bool rememberMe) async {
    try {
      _isLoading = true;
      notifyListeners();

      // ⚡ Maintenant login() retourne directement un User
      final user = await _authService.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      if (user != null) {
        _currentUser = user;
        _isAuthenticated = true;
        return true;
      }

      return false;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔹 Inscription
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required bool acceptTerms,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await _authService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        acceptTerms: acceptTerms,
      );

      return success;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔹 Déconnexion
  Future<void> logout() async {
    _currentUser = null;
    _isAuthenticated = false;
    await _authService.logout();
    notifyListeners();
  }

  // 🔹 Vérifier si l'email existe
  Future<bool> checkEmailExists(String email) async {
    try {
      return await _authService.emailExists(email);
    } catch (e) {
      rethrow;
    }
  }

  // 🔹 Définir manuellement un utilisateur
  void setUser(User user) {
    _currentUser = user;
    _isAuthenticated = true;
    notifyListeners();
  }

  // 🔹 Effacer l'utilisateur
  void clearUser() {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}