import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/video_background.dart';

const String _kLocationPermissionAskedKey = 'location_permission_asked_once';

class CompleteOnboardingPage extends StatefulWidget {
  @override
  State<CompleteOnboardingPage> createState() => _CompleteOnboardingPageState();
}

class _CompleteOnboardingPageState extends State<CompleteOnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 4;

  // Couleurs
  static const Color _primaryColor = Color(0xFF0088CC);
  static const Color _secondaryColor = Color(0xFF25D366);
  static const Color _accentColor = Color(0xFFFF9500);
  static const Color _textSecondary = Color(0xFFAEAEB2);
  static const Color _bgColor = Color(0xFF000000);

  @override
  void initState() {
    super.initState();
    VideoBackground.preload();
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_currentPage == _totalPages - 1) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _previousPage() {
    HapticFeedback.lightImpact();
    _pageController.previousPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  /// Demande l'autorisation de localisation une seule fois (au premier lancement après installation).
  Future<void> _showLocationPermissionDialogIfFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_kLocationPermissionAskedKey) == true) return;
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: _primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Accès à la localisation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: const Text(
            'Treg-Eslama a besoin de votre position pour vous alerter en temps réel sur les dangers (accidents, inondations, travaux) et vous proposer des itinéraires plus sûrs.\n\nVos données restent anonymisées et ne sont utilisées que pour votre sécurité.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final p = await SharedPreferences.getInstance();
                await p.setBool(_kLocationPermissionAskedKey, true);
              },
              child: Text(
                'Plus tard',
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Permission.locationWhenInUse.request();
                final p = await SharedPreferences.getInstance();
                await p.setBool(_kLocationPermissionAskedKey, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: _primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Autoriser',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: SafeArea(
          child: Stack(
        children: [
              // Fond avec léger dégradé
          Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topCenter,
                      radius: 1.5,
                      colors: [_bgColor.withOpacity(0.9), _bgColor],
                      stops: const [0.0, 0.8],
                    ),
                  ),
                ),
              ),

              // Pages
              PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                  setState(() => _currentPage = index);
                  if (index > 0) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _showLocationPermissionDialogIfFirstTime();
                    });
                  }
                    },
                    itemCount: _totalPages,
                itemBuilder: (context, index) => _buildPage(index),
              ),

              // Header : indicateurs + bouton retour/skip
          Positioned(
                top: 20,
                left: 24,
                right: 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0)
                      GestureDetector(
                        onTap: _previousPage,
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 20),
                      )
                    else
                      const SizedBox(width: 20),
                    Row(
                      children: List.generate(_totalPages, (i) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _currentPage ? 22 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: i == _currentPage
                                ? _getPageColor(i)
                                : _textSecondary.withOpacity(0.3),
                          ),
                        );
                      }),
                    ),
                    if (_currentPage < _totalPages - 1)
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: const Text(
                          "Passer",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 20),
                  ],
                ),
              ),

              // Bouton principal
              Positioned(
                bottom: 100,
                left: 40,
                right: 40,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    elevation: 2,
                  ),
                  child: Text(
                    _currentPage == _totalPages - 1
                        ? "Commencer"
                        : "Continuer",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ),

              // Choix langue
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Choisir la langue",
                      style: TextStyle(
                        color: _primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Construction d'une page : logo, titre, phrase (même style qu'avant)
  Widget _buildPage(int index) {
    final page = _getPageData(index);
    const double logoSize = 150;
    const double iconSize = 100;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (index == 0)
              Image.asset(
                "assets/images/logo_treg_eslama.png",
                height: logoSize,
                width: logoSize,
                fit: BoxFit.contain,
              )
            else
              Icon(
                page.icon,
                size: iconSize,
                color: _getPageColor(index),
              ),
            const SizedBox(width: 20),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    page.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                      fontFamily: 'Roboto',
                    ),
                  ),
                        const SizedBox(height: 10),
                        Text(
                    page.subtitle,
                    style: const TextStyle(
                            fontSize: 16,
                      color: Colors.white70,
                      height: 1.4,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Couleur des pages
  Color _getPageColor(int index) {
    switch (index) {
      case 0:
        return _primaryColor;
      case 1:
        return _accentColor;
      case 2:
        return _primaryColor;
      case 3:
        return _secondaryColor;
      default:
        return _primaryColor;
    }
  }

  // Données des pages
  _PageData _getPageData(int index) {
    switch (index) {
      case 0:
        return _PageData(
          title: 'Treg-Eslama',
          subtitle:
              'Votre sécurité sur la route, en temps réel.\nUne application conçue pour protéger vos trajets.',
        );
      case 1:
        return _PageData(
          title: 'Routes dangereuses',
          subtitle:
              'Accidents, routes coupées, inondations.\nSoyez informé avant qu’il ne soit trop tard.',
          icon: Icons.warning_amber_rounded,
        );
      case 2:
        return _PageData(
          title: 'Carte intelligente',
          subtitle:
              'Alertes en temps réel, trafic & météo.\nItinéraires plus sûrs grâce à l’IA.',
          icon: Icons.map_outlined,
        );
      case 3:
        return _PageData(
          title: 'Vie privée protégée',
          subtitle:
              'Données anonymisées.\nLocalisation uniquement avec votre accord.',
          icon: Icons.lock_outline,
        );
      default:
        return _PageData(title: '', subtitle: '');
    }
  }
}

class _PageData {
  final String title;
  final String subtitle;
  final IconData icon;

  _PageData({
    required this.title,
    required this.subtitle,
    this.icon = Icons.safety_check,
  });
}
