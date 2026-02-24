/// Configuration pour l'API Data MongoDB Atlas.
///
/// Pour obtenir APP_ID et API_KEY :
/// 1. Atlas → votre projet → App Services (ou "Realm" / "Data API")
/// 2. Créez une application et liez-la à votre cluster
/// 3. Activez la "Data API" dans les paramètres
/// 4. Créez une API Key dans "Authentication" → "API Keys"
/// 5. Le "App ID" est dans l’URL de l’app ou dans "Client App ID"
///
/// dataSource : nom de la source de données dans App Services (souvent "mongodb-atlas" ou le nom de votre cluster)
// App ID = ID de l'app App Services (pas le Project ID). Menu Atlas → App Services → votre app → URL ou "Client App ID"
const String atlasDataApiAppId = ''; // ex: trigessalama-abcde ou valeur depuis l'URL de l'app
const String atlasDataApiKey = 'rbhhhiic';  // Collez votre clé API
const String atlasDataSource = 'mongodb-atlas';
const String atlasDatabase = 'trig_essalama';
const String atlasCollectionUsers = 'users';
const String atlasCollectionCitizens = 'citizens';
// Les collections sont créées automatiquement au 1er enregistrement dans Atlas.

bool get isAtlasDataApiConfigured =>
    atlasDataApiAppId.isNotEmpty && atlasDataApiKey.isNotEmpty;
