import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Données utilisateur fictives
  final Map<String, dynamic> _userData = {
    'name': 'Jean Dupont',
    'email': 'jean.dupont@example.com',
    'avatar': 'JD',
  };

  final List<Map<String, dynamic>> _routes = [
    {
      'title': 'Accueil',
      'icon': Icons.home_outlined,
      'selectedIcon': Icons.home,
    },
    {
      'title': 'Carte',
      'icon': Icons.map_outlined,
      'selectedIcon': Icons.map,
    },
    {
      'title': 'Alertes',
      'icon': Icons.notifications_outlined,
      'selectedIcon': Icons.notifications,
    },
    {
      'title': 'Profil',
      'icon': Icons.person_outlined,
      'selectedIcon': Icons.person,
    },
  ];

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Déconnexion',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir vous déconnecter ?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: _logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    // Fermer le dialog
    Navigator.pop(context);
    
    // Simulation de déconnexion
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Déconnexion réussie'),
        backgroundColor: Colors.green,
      ),
    );

    // Retour à la page de connexion
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _routes[_selectedIndex]['title'],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Avatar utilisateur
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = 3;
                });
              },
              child: CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Text(
                  _userData['avatar'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.grey[900],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // En-tête du drawer
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      _userData['avatar'],
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _userData['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userData['email'],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Options du menu
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: Colors.white70),
              title: const Text(
                'Paramètres',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.help_outline, color: Colors.white70),
              title: const Text(
                'Aide & Support',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.shield_outlined, color: Colors.white70),
              title: const Text(
                'Confidentialité',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.white70),
              title: const Text(
                'À propos',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {},
            ),

            const Divider(color: Colors.white24),

            // Déconnexion
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Déconnexion',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: _showLogoutDialog,
            ),
          ],
        ),
      ),
      body: _buildPageContent(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: _routes.map((route) {
          return BottomNavigationBarItem(
            icon: Icon(route['icon']),
            activeIcon: Icon(route['selectedIcon']),
            label: route['title'],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPageContent() {
    switch (_selectedIndex) {
      case 0: // Accueil
        return _buildHomePage();
      case 1: // Carte
        return _buildMapPage();
      case 2: // Alertes
        return _buildAlertsPage();
      case 3: // Profil
        return _buildProfilePage();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bonjour message
          Text(
            'Bonjour, ${_userData['name']} 👋',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Votre sécurité routière en temps réel',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 30),

          // Statistiques
          Row(
            children: [
              _buildStatCard(
                'Routes analysées',
                '247',
                Icons.analytics_outlined,
                Colors.blueAccent,
              ),
              const SizedBox(width: 16),
              _buildStatCard(
                'Alertes actives',
                '12',
                Icons.warning_outlined,
                Colors.orangeAccent,
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Dernières alertes
          const Text(
            'Dernières alertes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildAlertCard(
            'Accident sur A6',
            'Route bloquée - Déviations en place',
            Colors.redAccent,
            'Il y a 15 min',
          ),
          const SizedBox(height: 12),
          _buildAlertCard(
            'Travaux sur N7',
            'Ralentissements jusqu\'à 19h',
            Colors.orangeAccent,
            'Il y a 2h',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(String title, String description, Color color, String time) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_outlined, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.map_outlined,
            size: 100,
            color: Colors.white24,
          ),
          const SizedBox(height: 20),
          Text(
            'Carte en cours de développement',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildAlertCard(
            'Accident grave sur A6',
            'Route complètement bloquée - Déviation par la sortie 21',
            Colors.redAccent,
            'Maintenant',
          ),
          const SizedBox(height: 12),
          _buildAlertCard(
            'Brouillard dense sur RN7',
            'Visibilité réduite à 50m - Réduisez votre vitesse',
            Colors.orangeAccent,
            'Il y a 30 min',
          ),
          const SizedBox(height: 12),
          _buildAlertCard(
            'Chaussée glissante',
            'Rue de la Paix - Attention aux freinages',
            Colors.yellowAccent,
            'Il y a 1h',
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.blueAccent,
            child: Text(
              _userData['avatar'],
              style: const TextStyle(
                fontSize: 36,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _userData['name'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userData['email'],
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 30),

          // Informations
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildProfileItem('Membre depuis', 'Mars 2024', Icons.calendar_today),
                const Divider(color: Colors.white24),
                _buildProfileItem('Type de compte', 'Premium', Icons.star_outline),
                const Divider(color: Colors.white24),
                _buildProfileItem('Dernière connexion', 'Aujourd\'hui, 14:30', Icons.access_time),
                const Divider(color: Colors.white24),
                _buildProfileItem('Localisation', 'Paris, France', Icons.location_on_outlined),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Bouton déconnexion
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showLogoutDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 12),
                  Text(
                    'Déconnexion',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}