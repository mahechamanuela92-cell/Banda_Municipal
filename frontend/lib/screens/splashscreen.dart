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
  await Future.delayed(const Duration(seconds: 3));
  if (!mounted) return;

  final haySesion = await Sesion.cargar();
  if (!mounted) return;

  Widget pantallaDestino;
  if (haySesion && Sesion.rol == 'admin') {
    pantallaDestino = const Inicio();
  } else if (haySesion && Sesion.rol == 'musico') {
    pantallaDestino = const musico.Inicio();
  } else {
    await Sesion.limpiar();
    if (!mounted) return;
    pantallaDestino = const InicioSesion();
  }

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => pantallaDestino),
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