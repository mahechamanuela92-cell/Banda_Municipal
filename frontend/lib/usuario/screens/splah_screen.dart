import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/config/sesion.dart';
import 'package:frontend/screens/pantalla_inicio.dart';
import 'package:frontend/usuario/screens/inicial.dart' as musico;
import 'inicio_sesion.dart';
import '../../widgets/fondos.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    _iniciarSiguientePantalla();
  }

  Future<void> _iniciarSiguientePantalla() async {
    await Future.delayed(const Duration(seconds: 3));
    final haySesion = await Sesion.cargar();
    if (!mounted) return;

    Widget destino;
    if (haySesion) {
      if (Sesion.rol == 'admin') {
        destino = const Inicio();
      } else if (Sesion.rol == 'musico') {
        destino = const musico.Inicio();
      } else {
        await Sesion.limpiar();
        if (!mounted) return;
        destino = const InicioSesion();
      }
    } else {
      destino = const InicioSesion();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => destino),
    );
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
                  // Logo
                  Image.asset(
                    "assets/images/fondo_login1.png",
                    height: 230,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 30),

                  // Texto de la Banda
                  const Text(
                    'BANDA SINFONICA SAN MIGUEL\nGARZÓN HUILA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE2BC65), // Dorado/Amarillo
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