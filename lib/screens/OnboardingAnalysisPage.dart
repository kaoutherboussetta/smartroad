import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class OnboardingAnalysisPage extends StatefulWidget {
  @override
  State<OnboardingAnalysisPage> createState() => _OnboardingAnalysisPageState();
}

class _OnboardingAnalysisPageState extends State<OnboardingAnalysisPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  int _currentStep = 0;
  bool _showParticles = false;
  bool _showLocationModal = false;
  bool _hasShownPermissionAlert = false;

  final List<Map<String, dynamic>> _features = [
    {
      'icon': Icons.analytics_outlined,
      'title': 'Analyse IA avancée',
      'description':
          'Notre intelligence artificielle scanne les images satellites en temps réel pour détecter les anomalies routières.',
      'color': Colors.blueAccent,
    },
    {
      'icon': Icons.satellite_alt_outlined,
      'title': 'Données Google Earth',
      'description':
          'Accès aux dernières images satellites haute définition pour une analyse précise du terrain.',
      'color': Colors.greenAccent,
    },
    {
      'icon': Icons.cloud_outlined,
      'title': 'Météo en temps réel',
      'description':
          'Intégration des données météorologiques pour anticiper les conditions routières dangereuses.',
      'color': Colors.cyanAccent,
    },
    {
      'icon': Icons.warning_amber_outlined,
      'title': 'Détection proactive',
      'description':
          'Alertes automatiques sur les risques potentiels avant même votre départ.',
      'color': Colors.orangeAccent,
    },
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();

    // Démarrer l'animation des particules après un délai
    Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showParticles = true;
        });
      }
    });

    // Vérifier et demander la permission de localisation après un délai
    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        _checkAndRequestLocationPermission();
      }
    });
  }

  Future<void> _checkAndRequestLocationPermission() async {
    // Vérifier si l'alerte a déjà été montrée
    if (_hasShownPermissionAlert) {
      return;
    }

    // Vérifier l'état de la permission
    final permissionStatus = await Permission.location.status;

    // Si la permission n'est pas accordée, afficher l'alerte
    if (!permissionStatus.isGranted) {
      _showLocationPermissionModal();
      _hasShownPermissionAlert = true;
    }
  }

  void _showLocationPermissionModal() {
    setState(() {
      _showLocationModal = true;
    });
  }

  void _closeLocationModal() {
    setState(() {
      _showLocationModal = false;
    });
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      print("Permission de localisation accordée");
      _closeLocationModal();
    } else if (status.isDenied) {
      print("Permission de localisation refusée");
      _closeLocationModal();
      // Ne pas réafficher l'alerte
    } else if (status.isPermanentlyDenied) {
      print("Permission de localisation refusée définitivement");
      _closeLocationModal();
      // Optionnel: montrer une dialog pour rediriger vers les paramètres
    }
  }

  void _nextStep() {
    if (_currentStep < _features.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      _goToLoginPage(); // Changé pour aller à la page de connexion
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _goToNextPage() {
    Navigator.pushNamed(context, '/onboarding-alert');
  }

  // Nouvelle méthode pour aller à la page de connexion
  void _goToLoginPage() {
    Navigator.pushNamed(context, '/login'); // Assurez-vous que cette route existe dans votre MaterialApp
  }

  void _selectStep(int index) {
    setState(() {
      _currentStep = index;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Arrière-plan avec effet de particules
          if (_showParticles)
            Positioned.fill(child: CustomPaint(painter: _ParticlesPainter())),

          // Contenu principal
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.08,
              vertical: screenHeight * 0.05,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec logo
                SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SmartRoad',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        '${_currentStep + 1}/${_features.length}',
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Illustration animée
                Center(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Opacity(
                            opacity: _fadeAnimation.value,
                            child: _buildAnimatedIllustration(),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const Spacer(),

                // Titre
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    _features[_currentStep]['title'],
                    key: ValueKey<int>(_currentStep),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.07,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Description
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    _features[_currentStep]['description'],
                    key: ValueKey<int>(_currentStep),
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: screenWidth * 0.04,
                      height: 1.5,
                    ),
                  ),
                ),

                const Spacer(),

                // Boutons de navigation - ICÔNES SUR LES CÔTES
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Bouton précédent (icône ←) à GAUCHE
                      if (_currentStep > 0)
                        IconButton(
                          onPressed: _previousStep,
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white70,
                            size: 32,
                          ),
                          padding: const EdgeInsets.all(16),
                          splashRadius: 24,
                        )
                      else
                        const SizedBox(width: 56), // Espace vide pour l'alignement

                      // Bouton suivant (icône →) ou Connecter (🔐) à DROITE
                      IconButton(
                        onPressed: _nextStep,
                        icon: _currentStep == _features.length - 1
                            ? const Icon(
                                Icons.login,
                                color: Colors.white,
                                size: 32,
                              ) // Icône pour "Connecter"
                            : const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 32,
                              ), // Icône pour "Suivant"
                        padding: const EdgeInsets.all(16),
                        splashRadius: 24,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Modal pour permission de localisation de l'application
          if (_showLocationModal) _buildLocationPermissionModal(),
        ],
      ),
    );
  }

  Widget _buildLocationPermissionModal() {
    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () {},
        child: Container(
          color: Colors.black.withOpacity(0.8),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icône de localisation
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blueAccent.withOpacity(0.2),
                          border: Border.all(
                            color: Colors.blueAccent.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.location_on_outlined,
                          size: 50,
                          color: Colors.blueAccent,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Titre
                      const Text(
                        'Autoriser l\'accès à la localisation',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // Description
                      const Text(
                        'SmartRoad a besoin d\'accéder à votre position pour analyser les routes autour de vous et vous fournir des alertes pertinentes.',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 30),

                      // Bouton unique "Autoriser"
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _requestLocationPermission,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check, color: Colors.white),
                              SizedBox(width: 12),
                              Text(
                                'Autoriser',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Note
                      Text(
                        'Cette alerte ne réapparaîtra plus une fois autorisée',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIllustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Cercle de fond animé
        AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                _features[_currentStep]['color'].withOpacity(0.2),
                Colors.transparent,
              ],
              stops: const [0.1, 0.8],
            ),
          ),
        ),

        // Icône principale avec animation
        RotationTransition(
          turns: Tween(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.5),
              border: Border.all(
                color: _features[_currentStep]['color'].withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              _features[_currentStep]['icon'],
              size: 80,
              color: _features[_currentStep]['color'],
            ),
          ),
        ),
      ],
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 50; i++) {
      final x = (i * 37) % size.width;
      final y = (i * 29) % size.height;
      final radius = 1 + (i % 3).toDouble();

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}