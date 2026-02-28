import 'package:flutter/foundation.dart' show kIsWeb;

const int backendPort = 3000;

// Android Emulator
const String backendHostEmulator = '10.0.2.2';

// Téléphone réel (IP de ton PC)
const String backendHostRealDevice = '192.168.100.112';

// Web
const String backendHostWeb = 'localhost';

// ⚠️ false = téléphone réel
// ⚠️ true = émulateur Android
const bool useEmulator = false;

String get backendBaseUrl {
  if (kIsWeb) {
    return 'http://$backendHostWeb:$backendPort';
  }
  return useEmulator
      ? 'http://$backendHostEmulator:$backendPort'
      : 'http://$backendHostRealDevice:$backendPort';
}