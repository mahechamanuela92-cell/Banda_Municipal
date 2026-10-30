// Dirección del backend.
// - Emulador Android: http://10.0.2.2:3000
// - Celular real: http://<IP de tu computador>:3000
// - Chrome / simulador iPhone: http://localhost:3000
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // Cambia a false cuando quieras volver a probar con tu servidor Node.js local
  static const bool useRemote = false;

  // URL de tu backend desplegado en Render (sin /api al final,
  // porque las pantallas ya agregan /api/auth/... en cada ruta)
  static const String _remoteUrl = 'https://banda-municipal-garzon.onrender.com';

  // Puerto de tu servidor local
  static const int _port = 3000;

  // Si pruebas en un celular real, pon aquí la IP de tu computador
  // (ej: '192.168.1.10'). Déjalo en null si no lo usas.
  static const String? _lanIp = null;

  static String get baseUrl {
    // Servidor desplegado
    if (useRemote) {
      return _remoteUrl;
    }

    // Configuración para desarrollo local
    if (kIsWeb) {
      return 'http://localhost:$_port'; // Chrome
    }
    if (_lanIp != null) {
      return 'http://$_lanIp:$_port'; // Celular real
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:$_port'; // Emulador Android
    }
    return 'http://localhost:$_port'; // Simulador iPhone / escritorio
  }
}

// Compatibilidad: las pantallas existentes usan $apiUrl
String get apiUrl => ApiConfig.baseUrl;