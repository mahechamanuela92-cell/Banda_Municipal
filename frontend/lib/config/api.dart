import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'dart:io' show Platform;

const bool usarLocal = !kReleaseMode;

const String urlProduccion = 'https://banda-municipal-garzon.onrender.com';

String get apiUrl {
  if (!usarLocal) return urlProduccion;
  if (kIsWeb) return 'http://localhost:3000';
  if (Platform.isAndroid) return 'http://10.0.2.2:3000'; // emulador Android
  return 'http://localhost:3000'; // Windows, iOS simulador
}