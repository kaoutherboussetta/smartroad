import 'package:mongo_dart/mongo_dart.dart';
import '../models/contact.model.dart';
import '../models/citoyen_connexion.model.dart';

/// Helper pour la liaison entre l'application et MongoDB Atlas.
/// Base de données : trig_essalama
/// Collections : contacts, connexions (données de connexion des citoyens)
class MongoDBHelper {
  static final MongoDBHelper instance = MongoDBHelper._init();
  static Db? _db;
  static DbCollection? _contactsCollection;
  static DbCollection? _connexionsCollection;

  /// Chaîne de connexion MongoDB Atlas (trig_essalama).
  /// mongo_dart ne supporte pas "mongodb+srv://", on utilise "mongodb://" avec host, port 27017 et tls=true.
  static const String MONGO_URL =
      'mongodb://oumaymabenna2_db_user:Test123456@trigessalama.sw3x05v.mongodb.net:27017/trig_essalama?retryWrites=true&w=majority&tls=true';

  static const String COLLECTION_NAME = 'contacts';
  /// Collection pour stocker les données de connexion des citoyens (email, mot de passe hashé, nom, etc.)
  static const String COLLECTION_CONNEXIONS = 'connexions';

  MongoDBHelper._init();

  Future<Db> get database async {
    if (_db != null && _db!.isConnected) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<DbCollection> get contactsCollection async {
    final db = await database;
    if (_contactsCollection == null) {
      _contactsCollection = db.collection(COLLECTION_NAME);
    }
    return _contactsCollection!;
  }

  /// Collection des données de connexion des citoyens
  Future<DbCollection> get connexionsCollection async {
    final db = await database;
    if (_connexionsCollection == null) {
      _connexionsCollection = db.collection(COLLECTION_CONNEXIONS);
      await _ensureConnexionsIndex();
    }
    return _connexionsCollection!;
  }

  /// Crée un index unique sur email pour la collection connexions
  Future<void> _ensureConnexionsIndex() async {
    if (_connexionsCollection == null) return;
    try {
      await _connexionsCollection!.createIndex(key: 'email', unique: true);
    } catch (e) {
      // ignore: avoid_print
      print('Index connexions (email): $e');
    }
  }

  Future<Db> _initDB() async {
    try {
      final uri = MONGO_URL.trim();
      if (uri.isEmpty || !uri.startsWith('mongodb')) {
        throw Exception('URI MongoDB invalide');
      }
      final db = Db(uri);
      await db.open();
      // ignore: avoid_print
      print('Connexion à MongoDB Atlas (trig_essalama) réussie');
      return db;
    } catch (e) {
      // ignore: avoid_print
      print('Erreur de connexion à MongoDB: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    if (_db != null && _db!.isConnected) {
      await _db!.close();
      _db = null;
      _contactsCollection = null;
      _connexionsCollection = null;
      // ignore: avoid_print
      print('Connexion MongoDB fermée');
    }
  }

  // ─────────────── Connexions (citoyens) ───────────────

  Future<ObjectId> insertCitoyenConnexion(CitoyenConnexion citoyen) async {
    try {
      final collection = await connexionsCollection;
      final map = citoyen.toMap();
      map.remove('_id');
      map['email'] = (map['email'] as String).trim().toLowerCase();
      final result = await collection.insertOne(map);
      return result.id as ObjectId;
    } catch (e) {
      // ignore: avoid_print
      print('Erreur insertion connexion citoyen: $e');
      rethrow;
    }
  }

  Future<CitoyenConnexion?> getCitoyenByEmail(String email) async {
    try {
      final collection = await connexionsCollection;
      final result = await collection.findOne(where.eq('email', email.trim().toLowerCase()));
      if (result != null) return CitoyenConnexion.fromMap(result);
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Erreur getCitoyenByEmail: $e');
      return null;
    }
  }

  Future<bool> updateCitoyenConnexion(CitoyenConnexion citoyen) async {
    if (citoyen.id == null) return false;
    try {
      final collection = await connexionsCollection;
      citoyen.updatedAt = DateTime.now();
      final result = await collection.updateOne(
        where.eq('_id', citoyen.id),
        modify
            .set('email', citoyen.email)
            .set('passwordHash', citoyen.passwordHash)
            .set('firstName', citoyen.firstName)
            .set('lastName', citoyen.lastName)
            .set('updatedAt', citoyen.updatedAt!.toUtc().toIso8601String())
            .set('isActive', citoyen.isActive)
            .set('rememberMe', citoyen.rememberMe)
            .set('acceptTerms', citoyen.acceptTerms)
            .set('phoneNumber', citoyen.phoneNumber ?? ''),
      );
      return result.isSuccess;
    } catch (e) {
      // ignore: avoid_print
      print('Erreur updateCitoyenConnexion: $e');
      return false;
    }
  }

  Future<bool> updateRememberMe(String email, bool rememberMe) async {
    try {
      final c = await getCitoyenByEmail(email);
      if (c == null) return false;
      c.rememberMe = rememberMe;
      return updateCitoyenConnexion(c);
    } catch (e) {
      // ignore: avoid_print
      print('Erreur updateRememberMe: $e');
      return false;
    }
  }

  Future<bool> citoyenEmailExists(String email) async {
    final c = await getCitoyenByEmail(email.trim());
    return c != null;
  }

  Future<bool> updateCitoyenPasswordByEmail(String email, String newPasswordHash) async {
    try {
      final c = await getCitoyenByEmail(email);
      if (c == null) return false;
      c.passwordHash = newPasswordHash;
      c.updatedAt = DateTime.now();
      return updateCitoyenConnexion(c);
    } catch (e) {
      // ignore: avoid_print
      print('Erreur updateCitoyenPasswordByEmail: $e');
      return false;
    }
  }

  Future<List<CitoyenConnexion>> getAllCitoyensConnexions() async {
    try {
      final collection = await connexionsCollection;
      final result = await collection.find().toList();
      return result.map((map) => CitoyenConnexion.fromMap(map)).toList();
    } catch (e) {
      // ignore: avoid_print
      print('Erreur getAllCitoyensConnexions: $e');
      return [];
    }
  }

  Future<ObjectId> insertContact(Contact contact) async {
    try {
      final collection = await contactsCollection;
      final result = await collection.insertOne(contact.toMap());
      return result.id as ObjectId;
    } catch (e) {
      // ignore: avoid_print
      print('Erreur lors de l\'insertion: $e');
      rethrow;
    }
  }

  Future<List<Contact>> getAllContacts() async {
    try {
      final collection = await contactsCollection;
      final result = await collection.find().toList();
      return result.map((map) => Contact.fromMap(map)).toList();
    } catch (e) {
      // ignore: avoid_print
      print('Erreur lors de la récupération des contacts: $e');
      return [];
    }
  }

  Future<Contact?> getContactById(ObjectId id) async {
    try {
      final collection = await contactsCollection;
      final result = await collection.findOne(where.eq('_id', id));
      if (result != null) {
        return Contact.fromMap(result);
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Erreur lors de la récupération du contact: $e');
      return null;
    }
  }

  Future<bool> updateContact(Contact contact) async {
    if (contact.id == null) return false;
    try {
      final collection = await contactsCollection;
      final result = await collection.updateOne(
        where.eq('_id', contact.id),
        modify
            .set('nom', contact.nom)
            .set('prenom', contact.prenom)
            .set('telephone', contact.telephone)
            .set('email', contact.email)
            .set('imagePath', contact.imagePath ?? ''),
      );
      return result.isSuccess;
    } catch (e) {
      // ignore: avoid_print
      print('Erreur lors de la mise à jour: $e');
      return false;
    }
  }

  Future<bool> deleteContact(ObjectId id) async {
    try {
      final collection = await contactsCollection;
      final result = await collection.deleteOne(where.eq('_id', id));
      return result.isSuccess;
    } catch (e) {
      // ignore: avoid_print
      print('Erreur lors de la suppression: $e');
      return false;
    }
  }

  Future<List<Contact>> searchContacts(String query) async {
    try {
      if (query.isEmpty) return getAllContacts();
      final collection = await contactsCollection;
      final regex = RegExp.escape(query);
      final selector = {
        r'$or': [
          {'nom': {r'$regex': regex, r'$options': 'i'}},
          {'prenom': {r'$regex': regex, r'$options': 'i'}},
          {'telephone': {r'$regex': regex, r'$options': 'i'}},
          {'email': {r'$regex': regex, r'$options': 'i'}},
        ],
      };
      final result = await collection.find(selector).toList();
      return result.map((map) => Contact.fromMap(map)).toList();
    } catch (e) {
      // ignore: avoid_print
      print('Erreur lors de la recherche: $e');
      return [];
    }
  }
}
