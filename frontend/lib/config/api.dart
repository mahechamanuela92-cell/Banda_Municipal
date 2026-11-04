import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

// Cambia esto a 'true' si estás corriendo tu backend localmente en tu PC, 
// o a 'false' si quieres que siempre use la nube de Render.
const bool usarLocal = false; 

const String urlProduccion = 'https://banda-municipal-garzon.onrender.com';

String get apiUrl {
  if (!usarLocal) return urlProduccion; // ¡Aquí siempre usará Render si está en false!
  
  if (kIsWeb) return 'http://localhost:3000';
  if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:3000';
  return 'http://localhost:3000';
}