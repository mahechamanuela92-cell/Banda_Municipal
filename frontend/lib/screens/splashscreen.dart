import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/screens/inicioSesion.dart';
import 'package:frontend/screens/pantalla_inicio.dart';
import 'package:frontend/usuario/screens/inicial.dart' as musico;
import 'package:frontend/config/sesion.dart';
import 'package:frontend/widgets/fondos.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    _verificarSesionGuardada();
  }

  Future<void> _verificarSesionGuardada() async {
    // Esperamos 3 segundos para mostrar el splash institucional
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Consultamos la memoria interna del teléfono
    final prefs = await SharedPreferences.getInstance();
    final tokenGuardado = prefs.getString('token');
    final rolGuardado = prefs.getString('rol');
    final nombreGuardado = prefs.getString('nombre');

    if (tokenGuardado != null && tokenGuardado.isNotEmpty) {
      // Restauramos los datos en tu clase estática Sesion
      Sesion.token = tokenGuardado;
      Sesion.rol = rolGuardado;
      Sesion.nombre = nombreGuardado;

      // Redirigimos según el rol guardado sin pasar por el login
      Widget pantallaDestino;
      if (rolGuardado == 'admin') {
        pantallaDestino = const Inicio();
      } else if (rolGuardado == 'musico') {
        pantallaDestino = const musico.Inicio();
      } else {
        pantallaDestino = const InicioSesion();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => pantallaDestino),
      );
    } else {
      // Si no hay sesión, mandamos al login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const InicioSesion()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoBase(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/fondo_login1.png",
                    height: 230,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'BANDA SINFONICA SAN MIGUEL\nGARZÓN HUILA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE2BC65),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}