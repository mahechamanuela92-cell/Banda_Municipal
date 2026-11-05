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
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  bool _cargando = false;
  bool _mostrarPassword = false;

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    _nombreController.dispose();
    super.dispose();
  }

  Color _colorRegistrarse = Colors.white;
  Color _colorOlvido = Colors.white;

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
                      color: Color(0xFFE2BC65),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // --- CAMPO NOMBRE ---
                  _crearCampoTexto(
                    controller: _nombreController,
                    hintText: 'Nombre',
                    icon: Icons.person,
                  ),

                  const SizedBox(height: 16),

                  // --- CAMPO CORREO ---
                  _crearCampoTexto(
                    controller: _correoController,
                    hintText: 'Correo electrónico',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 16),

                  // --- CAMPO CONTRASEÑA ---
                  _crearCampoTexto(
                    controller: _passwordController,
                    hintText: 'Contraseña',
                    icon: Icons.vpn_key,
                    obscureText: !_mostrarPassword,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() => _mostrarPassword = !_mostrarPassword);
                      },
                      icon: Icon(
                        _mostrarPassword ? Icons.visibility_off : Icons.visibility,
                        color: const Color(0xFFE2BC65),
                      ),
                      tooltip: _mostrarPassword
                          ? 'Ocultar contraseña'
                          : 'Mostrar contraseña',
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- BOTÓN INICIAR SESIÓN ---
                  Center(
                    child: SizedBox(
                      width: 250, // 👈 Controla qué tan alargado es el botón (puedes subirlo o bajarlo)
                      height: 55,
                      child: Container(
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
                          onPressed: _cargando ? null : _iniciarSesion,
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
                                  Color(0xFFE2BC65),
                                  Color(0xFFC29B45),
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
                                    color: Color.fromARGB(255, 23, 30, 32),
                                    size: 24,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Iniciar Sesion',
                                    style: TextStyle(
                                      fontSize: 16, // Ligeramente ajustado para que luzca proporcionado
                                      fontWeight: FontWeight.w800,
                                      color: Color.fromARGB(255, 23, 30, 32),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // --- OPCIONES INFERIORES ---
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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

                      TextButton(
                        onPressed: () {
                          setState(() {
                            _colorOlvido = Colors.red;
                          });

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

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Método reutilizable para los inputs de texto con estilo elegante y oscuro/translúcido
  Widget _crearCampoTexto({
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    required TextEditingController controller,
    Widget? suffixIcon,
  }) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 63, 70, 71).withValues(alpha: 0.75), // Fondo elegante oscuro que combina con el fondo base
        borderRadius: BorderRadius.circular(30.0),
        border: Border.all(
          color: const Color(0xFFE2BC65).withValues(alpha: 0.5), // Borde sutil dorado elegante
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
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
          color: Colors.white, // Texto que escribe el usuario en blanco para alta visibilidad
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          icon: Icon(
            icon,
            color: const Color(0xFFE2BC65), // 🌟 Icono principal dorado
            size: 22,
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.6), // Hint sutil y elegante
            fontSize: 15,
            fontWeight: FontWeight.normal,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}