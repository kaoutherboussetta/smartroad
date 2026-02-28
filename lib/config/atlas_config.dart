/// Configuration MongoDB Atlas (utilisée par le backend Node.js server.js).
const String atlasMongoUri =
    'mongodb+srv://oumaymabenna2_db_user:Test123456@trigessalama.sw3x05v.mongodb.net/trig_essalama?retryWrites=true&w=majority';

/// Base de données et collections
const String atlasDatabase = 'trig_essalama';
const String atlasCollectionUsers = 'users';
const String atlasCollectionCitizens = 'citizens';
const String atlasCollectionConnexions = 'connexions';
/// Table des comptes citoyens (inscription) — enregistrement automatique à l'inscription
const String atlasCollectionCompteCitoyens = 'compte_citoyens';
const String atlasCollectionUserCitoyens = 'user_citoyens';
const String atlasCollectionContacts = 'contacts';
