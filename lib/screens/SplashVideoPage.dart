import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';

class SplashVideoPage extends StatefulWidget {
  @override
  State<SplashVideoPage> createState() => _SplashVideoPageState();
}

class _SplashVideoPageState extends State<SplashVideoPage> with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _isVideoInitialized = false;
  bool _showSkipButton = true;
  bool _hasUserInteracted = false;
  Timer? _skipButtonTimer;
  double _playbackSpeed = 1.0;
  
  @override
  void initState() {
    super.initState();
    
    // Initialisation des animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
    
    _animationController.forward();
    
    // Initialisation de la vidéo
    _initializeVideo();
    
    // Timer pour cacher le bouton skip après 5 secondes
    _startSkipButtonTimer();
  }
  
  void _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset('assets/videos/intro.mp4')
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isVideoInitialized = true;
            });
            
            // Lecture de la vidéo
            _controller.play();
            
            // Mise en boucle
            _controller.setLooping(true);
            
            // Écoute des erreurs de lecture
            _controller.addListener(_videoListener);
          }
        }).catchError((error) {
          print("Erreur d'initialisation vidéo: $error");
          _handleVideoError();
        });
    } catch (e) {
      print("Erreur de chargement vidéo: $e");
      _handleVideoError();
    }
  }
  
  void _videoListener() {
    if (_controller.value.hasError) {
      print("Erreur de lecture vidéo: ${_controller.value.errorDescription}");
      _handleVideoError();
    }
  }
  
  void _handleVideoError() {
    // Si la vidéo échoue, on navigue après un court délai
    Future.delayed(const Duration(seconds: 2), _goToOnboarding);
  }
  
  void _startSkipButtonTimer() {
    _skipButtonTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && !_hasUserInteracted) {
        setState(() {
          _showSkipButton = false;
        });
      }
    });
  }
  
  void _goToOnboarding() async {
    // Animation de sortie
    await _animationController.reverse();
    
    // Arrêt de la vidéo
    if (_controller.value.isPlaying) {
      await _controller.pause();
    }
    
    // Navigation
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/onboarding-analysis');
    }
  }
  
  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
    
    setState(() {
      _hasUserInteracted = true;
      _showSkipButton = true;
    });
  }
  
  void _togglePlaybackSpeed() {
    setState(() {
      _playbackSpeed = _playbackSpeed == 1.0 ? 1.5 : 1.0;
      _controller.setPlaybackSpeed(_playbackSpeed);
      _hasUserInteracted = true;
      _showSkipButton = true;
    });
  }
  
  void _restartVideo() {
    _controller.seekTo(Duration.zero);
    _controller.play();
    
    setState(() {
      _hasUserInteracted = true;
      _showSkipButton = true;
    });
  }
  
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
  
  @override
  void dispose() {
    _skipButtonTimer?.cancel();
    _animationController.dispose();
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Stack(
                children: [
                  // Vidéo en arrière-plan
                  if (_isVideoInitialized)
                    SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controller.value.size.width,
                          height: _controller.value.size.height,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                    )
                  else
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Chargement...',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Overlay avec gradient pour améliorer la lisibilité
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.6),
                          ],
                          stops: [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  
                  // Contenu principal
                  Positioned.fill(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Logo/Header (optionnel)
                        Padding(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top + 20,
                          ),
                          child: AnimatedOpacity(
                            opacity: _showSkipButton ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              'SMARTROAD',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                        
                        // Slogan
                        Padding(
                          padding: EdgeInsets.only(bottom: screenHeight * 0.15),
                          child: Column(
                            children: [
                              Text(
                                'SmartRoad',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 8.0,
                                      color: Colors.black.withOpacity(0.5),
                                      offset: const Offset(2.0, 2.0),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Prévenir les risques avant d\'arriver',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Contrôles en bas
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            children: [
                              // Contrôles vidéo (visible sur interaction)
                              if (_showSkipButton && _isVideoInitialized)
                                AnimatedOpacity(
                                  opacity: _showSkipButton ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 300),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildControlButton(
                                        icon: _controller.value.isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        onTap: _togglePlayPause,
                                        tooltip: _controller.value.isPlaying
                                            ? 'Pause'
                                            : 'Lecture',
                                      ),
                                      const SizedBox(width: 16),
                                      _buildControlButton(
                                        icon: Icons.speed,
                                        onTap: _togglePlaybackSpeed,
                                        tooltip: 'Vitesse ${_playbackSpeed}x',
                                        text: '${_playbackSpeed}x',
                                      ),
                                      const SizedBox(width: 16),
                                      _buildControlButton(
                                        icon: Icons.replay,
                                        onTap: _restartVideo,
                                        tooltip: 'Redémarrer',
                                      ),
                                    ],
                                  ),
                                ),
                              
                              const SizedBox(height: 20),
                              
                              // Bouton de navigation principal
                              MouseRegion(
                                onEnter: (_) {
                                  setState(() {
                                    _hasUserInteracted = true;
                                    _showSkipButton = true;
                                  });
                                },
                                child: GestureDetector(
                                  onTap: _goToOnboarding,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.black,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Indicateur de temps (optionnel)
                              if (_isVideoInitialized && _showSkipButton)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    '${_formatDuration(_controller.value.position)} / ${_formatDuration(_controller.value.duration)}',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Barre de progression (en bas)
                  if (_isVideoInitialized)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(
                        value: _controller.value.duration.inMilliseconds > 0
                            ? _controller.value.position.inMilliseconds /
                                _controller.value.duration.inMilliseconds
                            : 0,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.5),
                        ),
                        minHeight: 2,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
    String? text,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
              if (text != null)
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}