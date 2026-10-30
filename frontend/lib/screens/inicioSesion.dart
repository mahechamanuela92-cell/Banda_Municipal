import 'package:frontend/config/api.dart';
import 'package:frontend/config/sesion.dart';
import 'package:frontend/screens/recuperar_password.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/screens/pantalla_inicio.dart';
import 'package:frontend/usuario/screens/inicial.dart' as musico;
import 'package:flutter/material.dart';
import '../widgets/fondos.dart';
import 'pantalla_registro.dart';

class InicioSesion extends StatefulWidget {
  const InicioSesion({super.key});

  @override
  State<InicioSesion> createState() => _InicioSesionState();
}

class _InicioSesionState extends State<InicioSesion> {
  // 👈 AGREGA ESTOS CONTROLADORES AQUÍ ARRIBA
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  bool _cargando = false;
  @override
void dispose() {
  _correoController.dispose();
  _passwordController.dispose();
  _nombreController.dispose();
  super.dispose();
}
  // Variables para controlar el cambio de color al hacer clic
  Color _colorRegistrarse = Colors.white;
  Color _colorOlvido = Colors.white;

  // Pantalla a la que se envía al usuario según su rol
  Widget? _pantallaSegunRol(String? rol) {
    switch (rol) {
      case 'admin':
        return const Inicio();
      case 'musico':
        return const musico.Inicio();
      default:
        return null;
    }
  }

  Future<void> _iniciarSesion() async {
    final correo = _correoController.text.trim();
    final password = _passwordController.text.trim();

    if (correo.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa tu correo y contraseña')),
      );
      return;
    }

    setState(() => _cargando = true);

    try {
      final url = Uri.parse('$apiUrl/api/auth/login');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': correo,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 5));

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final pantalla = _pantallaSegunRol(data['rol']);
        if (pantalla == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tu usuario no tiene un rol válido')),
          );
          return;
        }

        Sesion.token = data['token'];
        Sesion.nombre = data['nombre'];
        Sesion.rol = data['rol'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('¡Bienvenido, ${data['nombre']}!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => pantalla),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? 'Error al iniciar sesión')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo conectar con el servidor')),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoBase(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20), 
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.asset(
                        "assets/images/fondo_login1.png",
                        fit: BoxFit.contain,
                        height: 160, 
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'INICIAR SESIÓN',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 226, 188, 101),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // --- CAMPO NOMBRE ---
                _crearCampoTexto(
                  controller: _nombreController, // 👈 Agrégale esta línea aquí también
                  hintText: 'Nombre',
                  icon: Icons.people,
                ),

                  const SizedBox(height: 16),

                  // --- CAMPO CORREO ---
                _crearCampoTexto(
                  controller: _correoController, // 👈 Agrégale esta línea
                  hintText: 'Correo',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),

                  const SizedBox(height: 16),

                  // --- CAMPO CONTRASEÑA ---
                  _crearCampoTexto(
                  controller: _passwordController, // 👈 Agrégale esta línea
                  hintText: 'Contraseña',
                  icon: Icons.vpn_key,
                  obscureText: true,
                ),
                  const SizedBox(height: 30),

                  // --- BOTÓN INICIAR SESIÓN ---
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _cargando ? null : _iniciarSesion, // 👈 Un solo onPressed limpio
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFB3F0EC),
                              Color(0xFF8AE1DC),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          constraints: const BoxConstraints(minHeight: 55),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.music_note,
                                color: Color(0xFF0F4C5C),
                                size: 24,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'INICIAR SESION',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F4C5C),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // --- OPCIONES INFERIORES: REGISTRO Y RECUPERAR CONTRASEÑA (CORREGIDO EN COLUMN) ---
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ¿No tienes cuenta? Regístrate (Cambia a verde)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _colorRegistrarse = Colors.green;
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PantallaRegistro()),
                          );
                        },
                        child: Text(
                          '¿No tienes cuenta? Regístrate',
                          style: TextStyle(
                            color: _colorRegistrarse,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),

                      // ¿Olvidaste tu contraseña?
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _colorOlvido = Colors.red; // Mantiene tu efecto visual si lo deseas
                          });

                          // Navegar a la pantalla de recuperación de contraseña
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PantallaRecuperarPassword(),
                            ),
                          );
                        },
                        child: Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(
                            color: _colorOlvido,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // --- TEXTO INFERIOR ---
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

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Método reutilizable para los inputs de texto
  Widget _crearCampoTexto({
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text, required TextEditingController controller,
  }) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFB3F0EC),
            Color(0xFF8AE1DC),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Color(0xFF0F4C5C),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          icon: Icon(
            icon,
            color: const Color(0xFF0F4C5C),
            size: 22,
          ),
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF0F4C5C),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}