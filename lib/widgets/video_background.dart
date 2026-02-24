import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Widget qui affiche une vidéo en plein écran en arrière-plan (boucle, muet).
/// Utilisé sur les pages login, register, forgot_password.
/// Appeler [VideoBackground.preload] au démarrage pour afficher la vidéo dès l'ouverture (sans fond noir).
class VideoBackground extends StatefulWidget {
  final String videoAsset;
  final Widget child;
  /// Opacité de l'overlay sombre sur la vidéo (0.0 à 1.0). Par défaut 0.35.
  final double opacity;

  const VideoBackground({
    super.key,
    this.videoAsset = 'assets/videos/intro.mp4',
    this.opacity = 0.35,
    required this.child,
  });

  /// Précharge la vidéo pour qu'elle soit prête à l'ouverture de la connexion (plus de fond noir).
  static VideoPlayerController? _cachedController;

  static Future<void> preload() async {
    if (_cachedController != null) return;
    try {
      final c = VideoPlayerController.asset('assets/videos/intro.mp4');
      await c.initialize();
      c.setLooping(true);
      c.setVolume(0);
      c.setPlaybackSpeed(0.5);
      await c.play();
      _cachedController = c;
    } catch (_) {}
  }

  @override
  State<VideoBackground> createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<VideoBackground> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _usingCache = false;

  @override
  void initState() {
    super.initState();
    if (VideoBackground._cachedController != null &&
        VideoBackground._cachedController!.value.isInitialized) {
      _controller = VideoBackground._cachedController;
      _initialized = true;
      _usingCache = true;
      return;
    }
    _initVideo();
  }

  Future<void> _initVideo() async {
    if (VideoBackground._cachedController != null &&
        VideoBackground._cachedController!.value.isInitialized) {
      if (mounted) {
        setState(() {
          _controller = VideoBackground._cachedController;
          _initialized = true;
          _usingCache = true;
        });
      }
      return;
    }
    try {
      final controller = VideoPlayerController.asset(widget.videoAsset);
      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }
      controller.setLooping(true);
      controller.setVolume(0);
      controller.setPlaybackSpeed(0.5);
      await controller.play();
      if (mounted) {
        setState(() {
          _controller = controller;
          _initialized = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _initialized = false);
    }
  }

  @override
  void dispose() {
    if (!_usingCache && _controller != null) {
      _controller!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Pas de fond noir : on affiche uniquement la vidéo une fois prête
        if (_initialized && _controller != null)
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            ),
          ),
        // Overlay léger pour garder le contenu lisible
        if (_initialized)
          Container(color: Colors.black.withOpacity(widget.opacity)),
        widget.child,
      ],
    );
  }
}
