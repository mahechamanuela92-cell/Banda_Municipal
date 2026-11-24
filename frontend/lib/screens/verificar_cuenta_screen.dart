import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/config/api.dart';
import 'package:frontend/screens/inicioSesion.dart';
import 'package:frontend/widgets/fondos.dart';
import 'package:http/http.dart' as http;

class VerificarCuentaScreen extends StatefulWidget {
  final String correoRegistrado;

  const VerificarCuentaScreen({super.key, required this.correoRegistrado});

  @override
  State<VerificarCuentaScreen> createState() => _VerificarCuentaScreenState();
}

class _VerificarCuentaScreenState extends State<VerificarCuentaScreen> {
  final TextEditingController _codigoController = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  Future<void> _verificarCodigo() async {
    final codigo = _codigoController.text.trim();

    if (codigo.isEmpty || codigo.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa el código de 6 dígitos'),
        ),
      );
      return;
    }

    setState(() => _cargando = true);

    try {
      final url = Uri.parse('$apiUrl/api/auth/verify-account');

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': widget.correoRegistrado.trim(),
              'codigo': codigo,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        _mostrarExitoYRedirigir(
          data['message']?.toString() ?? '¡Cuenta verificada exitosamente!',
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['error']?.toString() ??
                  data['message']?.toString() ??
                  'Código incorrecto',
            ),
          ),
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

  void _mostrarExitoYRedirigir(String mensaje) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 63, 70, 71),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE2BC65), width: 1.5),
          ),
          title: const Text(
            '¡CUENTA VERIFICADA!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFE2BC65),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              const CircularProgressIndicator(
                color: Color(0xFFE2BC65),
              ),
              const SizedBox(height: 18),
              Text(
                mensaje,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Redirigiendo al inicio de sesión...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const InicioSesion()),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoBase(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFFE2BC65),
                        size: 28,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.asset(
                        'assets/images/fondo_login1.png',
                        fit: BoxFit.contain,
                        height: 150,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'VERIFICAR CUENTA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE2BC65),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Te enviamos un código de 6 dígitos al correo:\n${widget.correoRegistrado}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 63, 70, 71)
                          .withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE2BC65).withValues(alpha: 0.5),
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
                    child: TextField(
                      controller: _codigoController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 4,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        icon: const Icon(
                          Icons.pin_outlined,
                          color: Color(0xFFE2BC65),
                          size: 22,
                        ),
                        hintText: 'Código de 6 cifras',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 15,
                          letterSpacing: 0,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: 250,
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
                        onPressed: _cargando ? null : _verificarCodigo,
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
                            child: _cargando
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Color.fromARGB(255, 23, 30, 32),
                                    ),
                                  )
                                : const Text(
                                    'Verificar Código',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Color.fromARGB(255, 23, 30, 32),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
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