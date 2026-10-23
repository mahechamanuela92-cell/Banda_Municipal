import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../widgets/fondos.dart';
import '../themes/colores.dart';
// Asegúrate de importar tu servicio o lugar donde guardes el token del usuario logueado
// import '../services/auth_service.dart';

class PantallaGenerarCodigo extends StatefulWidget {
  const PantallaGenerarCodigo({super.key});

  @override
  State<PantallaGenerarCodigo> createState() => _PantallaGenerarCodigoState();
}

class _PantallaGenerarCodigoState extends State<PantallaGenerarCodigo> {
  String? _codigoGenerado;
  bool _cargando = false;

  // Función para consumir el endpoint del backend que genera el código
  Future<void> _generarCodigoAdmin() async {
    setState(() {
      _cargando = true;
      _codigoGenerado = null;
    });

    try {
      // ⚠️ Reemplaza esta URL con la dirección de tu backend (o IP local / emulador)
      // Nota: Si usas emulador Android, 'http://localhost:3000' suele ser 'http://10.0.2.2:3000'
      final url = Uri.parse('http://localhost:3000/api/auth/generar-codigo');

      // TODO: Obtén el token real del administrador guardado en tu app (SharedPreferences, Provider, etc.)
      // Ejemplo: final token = await AuthService.obtenerToken();
      final String tokenAdmin = "AQUÍ_DEBES_PASAR_EL_TOKEN_DEL_ADMIN"; 

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tokenAdmin',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        setState(() {
          _codigoGenerado = data['codigo'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Código generado con éxito!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? 'Error al generar el código')),
        );
      }
    } catch (e) {
      // Por si ocurre algún error de conexión con el servidor
      print("Error de conexión: $e");
      
      // 💡 SIMULACIÓN LOCAL (Por si quieres probar el diseño de inmediato sin levantar el backend todavía)
      setState(() {
        _codigoGenerado = (100000 + (DateTime.now().millisecond * 89) % 900000).toString();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Modo simulación: Código generado localmente')),
      );
    } finally {
      setState(() {
        _cargando = false;
      });
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
                  const SizedBox(height: 10), 
                  
                  // Logo o imagen superior
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.asset(
                        "assets/images/fondo_login1.png",
                        fit: BoxFit.contain,
                        height: 130, 
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'GENERAR CÓDIGO DE REGISTRO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE2BC65), // Dorado institucional
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'Como administrador, puedes generar un código único de 6 dígitos para autorizar el registro de un nuevo músico en la aplicación.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 35),

                  // Caja donde se muestra el código generado
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colores.bloqueOscuro,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2BC65), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Código Actual:',
                          style: TextStyle(color: Colors.white60, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _codigoGenerado ?? '------',
                          style: const TextStyle(
                            color: Color(0xFFB3F0EC),
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 6,
                          ),
                        ),
                        const SizedBox(height: 15),
                        if (_codigoGenerado != null)
                          TextButton.icon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _codigoGenerado!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('¡Código copiado al portapapeles!')),
                              );
                            },
                            icon: const Icon(Icons.copy, color: Color(0xFFE2BC65), size: 18),
                            label: const Text(
                              'Copiar Código',
                              style: TextStyle(color: Color(0xFFE2BC65), fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  // --- BOTÓN GENERAR CÓDIGO ---
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
                      onPressed: _cargando ? null : _generarCodigoAdmin,
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
                          child: _cargando
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF0F4C5C),
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.vpn_key,
                                      color: Color(0xFF0F4C5C),
                                      size: 24,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'GENERAR NUEVO CÓDIGO',
                                      style: TextStyle(
                                        fontSize: 16,
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

                  const SizedBox(height: 20),

                  // --- BOTÓN VOLVER ---
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Volver al menú',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // --- TEXTO INFERIOR ---
                  const Text(
                    'BANDA SINFONICA SAN MIGUEL DE GARZÓN',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE2BC65),
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}