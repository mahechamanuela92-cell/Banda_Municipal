import 'package:shared_preferences/shared_preferences.dart';

class Sesion {
  static const String _keyToken = 'sesion_token';
  static const String _keyNombre = 'sesion_nombre';
  static const String _keyRol = 'sesion_rol';

  static String? token;
  static String? nombre;
  static String? rol;

  /// Guarda los datos de sesión en memoria y en el dispositivo.
  static Future<void> guardar({
    required String nuevoToken,
    String? nuevoNombre,
    String? nuevoRol,
  }) async {
    token = nuevoToken;
    nombre = nuevoNombre;
    rol = nuevoRol;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, nuevoToken);
    if (nuevoNombre != null) {
      await prefs.setString(_keyNombre, nuevoNombre);
    } else {
      await prefs.remove(_keyNombre);
    }
    if (nuevoRol != null) {
      await prefs.setString(_keyRol, nuevoRol);
    } else {
      await prefs.remove(_keyRol);
    }
  }

  /// Carga la sesión guardada al abrir la app.
  static Future<bool> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString(_keyToken);
    nombre = prefs.getString(_keyNombre);
    rol = prefs.getString(_keyRol);
    return token != null && token!.isNotEmpty;
  }

  /// Limpia la sesión al cerrar sesión.
  static Future<void> limpiar() async {
    token = null;
    nombre = null;
    rol = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyNombre);
    await prefs.remove(_keyRol);
  }
}