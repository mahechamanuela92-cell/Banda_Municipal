import 'package:frontend/config/api.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../widgets/fondos.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  // Controladores para capturar la información
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _numDocumentoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();
  bool _mostrarPassword = false;
  
  // Variable para controlar los términos y condiciones
  bool _aceptaTerminos = false;

  static final RegExp _mayusculaRegex = RegExp(r'[A-ZÁÉÍÓÚÜÑ]');
  static final RegExp _numeroRegex = RegExp(r'[0-9]');
  static final RegExp _simboloRegex =
      RegExp(r'[^A-Za-z0-9ÁÉÍÓÚÜÑáéíóúüñ\s]');

  bool get _cumpleLongitud => _passwordController.text.length >= 8;
  bool get _cumpleMayuscula =>
      _mayusculaRegex.hasMatch(_passwordController.text);
  bool get _cumpleNumero => _numeroRegex.hasMatch(_passwordController.text);
  bool get _cumpleSimbolo => _simboloRegex.hasMatch(_passwordController.text);
  bool get _passwordValida =>
      _cumpleLongitud && _cumpleMayuscula && _cumpleNumero && _cumpleSimbolo;

  // Variable para el tipo de documento seleccionado
  String? _tipoDocumentoElegido;
  final List<String> _tiposDocumento = [
    'Cédula de Ciudadanía',
    'Tarjeta de Identidad',
    'Cédula de Extranjería',
    'Pasaporte'
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _numDocumentoController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    _codigoController.dispose();
    super.dispose();
  }

  // Método para mostrar el modal con las políticas y condiciones
  void _mostrarTerminosYCondiciones(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF3F4647),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE2BC65), width: 1),
          ),
          title: const Text(
            'Términos, Políticas y Condiciones',
            style: TextStyle(color: Color(0xFFE2BC65), fontWeight: FontWeight.bold),
          ),
          content: const SingleChildScrollView(
            child: Text(
              'Bienvenido a la aplicación de la Banda Sinfónica Municipal de Garzón Huila.\n\n'
              '1. Protección de Datos: Al registrarte autorizas el tratamiento de tus datos personales para fines informativos, de gestión de miembros y actividades musicales de la banda.\n\n'
              '2. Uso de la Información: Tus datos de contacto, tipo de documento y número de identificación se mantendrán seguros bajo los protocolos de almacenamiento y no serán compartidos con terceros sin tu consentimiento.\n\n'
              '3. Compromiso del Músico: Te comprometes a hacer un uso adecuado de la plataforma, respetando las normas internas y las convocatorias institucionales.',
              style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cerrar',
                style: TextStyle(color: Color(0xFFE2BC65), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _registrarUsuario() async {
    final nombre = _nombreController.text.trim();
    final tipoDoc = _tipoDocumentoElegido;
    final numDoc = _numDocumentoController.text.trim();
    final telefono = _telefonoController.text.trim();
    final correo = _correoController.text.trim();
    final password = _passwordController.text.trim();
    final codigo = _codigoController.text.trim();

    if (nombre.isEmpty || tipoDoc == null || numDoc.isEmpty || telefono.isEmpty || correo.isEmpty || password.isEmpty || codigo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos y el código')),
      );
      return;
    }

    if (!_passwordValida) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña debe cumplir todos los requisitos'),
        ),
      );
      return;
    }

    // Validación obligatoria de los términos y condiciones
    if (!_aceptaTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los términos, políticas y condiciones'),
        ),
      );
      return;
    }

    try {
      final url = Uri.parse('$apiUrl/api/auth/register');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombre,
          'tipo_documento': tipoDoc,
          'numero_documento': numDoc,
          'telefono': telefono,
          'email': correo,
          'password': password,
          'codigoInvitacion': codigo,
          'acepta_terminos': _aceptaTerminos, // Se envía al backend
        }),
      ).timeout(const Duration(seconds: 5));

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Registro exitoso! Ya puedes iniciar sesión.')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? 'Error al registrarse')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión con el servidor: $e')),
      );
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
                    'REGISTRO DE MÚSICO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE2BC65),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- CAMPO TIPO DE DOCUMENTO ---
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 63, 70, 71).withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(30.0),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.center,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _tipoDocumentoElegido,
                        hint: Row(
                          children: const [
                            Icon(Icons.badge, color: Color(0xFFE2BC65), size: 22),
                            SizedBox(width: 15),
                            Text(
                              'Tipo de Documento',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFE2BC65)),
                        isExpanded: true,
                        dropdownColor: const Color.fromARGB(255, 63, 70, 71).withValues(alpha: 0.75),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        items: _tiposDocumento.map((String tipo) {
                          return DropdownMenuItem<String>(
                            value: tipo,
                            child: Text(tipo, style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (String? nuevoValor) {
                          setState(() {
                            _tipoDocumentoElegido = nuevoValor;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // --- CAMPO NÚMERO DE DOCUMENTO ---
                  _crearCampoTexto(
                    controller: _numDocumentoController,
                    hintText: 'Número de Documento',
                    icon: Icons.confirmation_number,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 14),

                  // --- CAMPO NOMBRE COMPLETO ---
                  _crearCampoTexto(
                    controller: _nombreController,
                    hintText: 'Nombre Completo',
                    icon: Icons.person,
                  ),

                  const SizedBox(height: 14),

                  // --- CAMPO TELÉFONO ---
                  _crearCampoTexto(
                    controller: _telefonoController,
                    hintText: 'Teléfono',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 14),

                  // --- CAMPO CORREO ---
                  _crearCampoTexto(
                    controller: _correoController,
                    hintText: 'Correo electrónico',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 14),

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
                      tooltip: _mostrarPassword ? 'Ocultar contraseña' : 'Mostrar contraseña',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'La contraseña debe incluir:',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        _crearRequisito(_cumpleLongitud, 'Mínimo 8 caracteres'),
                        _crearRequisito(_cumpleMayuscula, 'Una letra mayúscula'),
                        _crearRequisito(_cumpleNumero, 'Un número'),
                        _crearRequisito(_cumpleSimbolo, 'Un símbolo'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // --- CAMPO CÓDIGO DE INVITACIÓN ---
                  _crearCampoTexto(
                    controller: _codigoController,
                    hintText: 'Código de Registro (6 dígitos)',
                    icon: Icons.security,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 18),

                  // --- CHECKBOX DE TÉRMINOS Y POLÍTICAS ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _aceptaTerminos,
                          activeColor: const Color(0xFFE2BC65),
                          checkColor: const Color(0xFF171E20),
                          side: const BorderSide(color: Color(0xFFE2BC65), width: 1.5),
                          onChanged: (bool? value) {
                            setState(() {
                              _aceptaTerminos = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _mostrarTerminosYCondiciones(context),
                            child: const Text(
                              'Acepto los Términos, Políticas y Condiciones de tratamiento de datos.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFFE2BC65),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- BOTÓN REGISTRARSE ---
                  Center(
                    child: SizedBox(
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
                          onPressed: _registrarUsuario,
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
                                    Icons.person_add,
                                    color: Color.fromARGB(255, 23, 30, 32),
                                    size: 22,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'REGISTRARSE',
                                    style: TextStyle(
                                      fontSize: 16,
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

                  const SizedBox(height: 20),

                  // --- VOLVER AL LOGIN ---
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      '¿Ya tienes una cuenta? Inicia Sesión',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- TEXTO INFERIOR ---
                  const Text(
                    'BANDA SINFONICA SAN MIGUEL\nGARZÓN HUILA',
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

  // Método auxiliar reutilizable para los inputs de texto con estilo unificado
  Widget _crearCampoTexto({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
    Widget? suffixIcon,
  }) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 63, 70, 71).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(30.0),
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          icon: Icon(
            icon,
            color: const Color(0xFFE2BC65),
            size: 22,
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
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

  Widget _crearRequisito(bool cumple, String texto) {
    final Color color = cumple ? Colors.greenAccent : Colors.white70;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            cumple ? Icons.check_circle : Icons.circle_outlined,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(texto, style: TextStyle(color: color, fontSize: 13)),
        ],
      ),
    );
  }
}