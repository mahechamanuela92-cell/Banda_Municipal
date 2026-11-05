import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/config/api.dart';
import 'package:frontend/config/sesion.dart';
import 'package:frontend/screens/inicioSesion.dart';
import 'package:frontend/components/chat/boton_chat_flotante.dart';
import 'package:frontend/components/chat/chat_banda_modal.dart';
import '../../themes/colores.dart';
import '../../widgets/fondos.dart';

class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({super.key});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  XFile? _foto;
  Uint8List? _fotoBytes;
  String? _fotoUrl;
  bool _cargandoPerfil = true;
  bool _modoEdicion = false;
  bool _guardando = false;
  final _nombre = TextEditingController(text: Sesion.nombre ?? '');
  final _telefono = TextEditingController();
  final _correo = TextEditingController();
  String _nombreOriginal = '';
  String _telefonoOriginal = '';
  String _correoOriginal = '';

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    _correo.dispose();
    super.dispose();
  }

  void _abrirAsistenteIA(BuildContext context) {
    showDialog(context: context, builder: (_) => const ChatBandaModal());
  }

  String _mensajeError(http.Response response, String alternativa) {
    if (response.statusCode == 404) {
      return 'La ruta del perfil aún no está disponible en el backend.';
    }
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic> && body['error'] is String) {
        return body['error'] as String;
      }
    } on FormatException {
      return alternativa;
    }
    return alternativa;
  }

  Future<void> _cargarPerfil() async {
    final token = Sesion.token;
    if (token == null) {
      setState(() => _cargandoPerfil = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$apiUrl/perfil/me'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception(_mensajeError(response, 'No se pudo cargar el perfil'));
      }

      final perfil = jsonDecode(response.body) as Map<String, dynamic>;
      final usuario = perfil['usuarios'] is Map<String, dynamic>
          ? perfil['usuarios'] as Map<String, dynamic>
          : const <String, dynamic>{};
      _nombre.text = (perfil['nombre'] ?? usuario['nombre'] ?? Sesion.nombre ?? '')
          .toString();
      _telefono.text = (perfil['telefono'] ?? usuario['telefono'] ?? '').toString();
      _correo.text = (perfil['email'] ?? usuario['email'] ?? '').toString();
      _fotoUrl = perfil['foto_perfil']?.toString();
      Sesion.nombre = _nombre.text;
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar perfil: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _cargandoPerfil = false);
    }
  }

  void _iniciarEdicion() {
    setState(() {
      _nombreOriginal = _nombre.text;
      _telefonoOriginal = _telefono.text;
      _correoOriginal = _correo.text;
      _modoEdicion = true;
    });
  }

  void _cancelarEdicion() {
    setState(() {
      _nombre.text = _nombreOriginal;
      _telefono.text = _telefonoOriginal;
      _correo.text = _correoOriginal;
      _foto = null;
      _fotoBytes = null;
      _modoEdicion = false;
    });
  }

  Future<void> _guardarPerfil() async {
    final token = Sesion.token;
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para guardar tu perfil')),
      );
      return;
    }
    if (_nombre.text.trim().isEmpty || _correo.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre y el correo son obligatorios')),
      );
      return;
    }

    setState(() => _guardando = true);
    try {
      final response = await http.put(
        Uri.parse('$urlProduccion/perfil/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'nombre': _nombre.text.trim(),
          'email': _correo.text.trim(),
          'telefono': _telefono.text.trim(),
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception(_mensajeError(response, 'No se pudo guardar el perfil'));
      }

      if (_foto != null) {
        final request = http.MultipartRequest(
          'PUT',
          Uri.parse('$urlProduccion/perfil/foto'),
        )..headers['Authorization'] = 'Bearer $token';
        request.files.add(
          http.MultipartFile.fromBytes(
            'foto',
            _fotoBytes!,
            filename: _foto!.name,
          ),
        );
        final streamedResponse = await request.send().timeout(
          const Duration(seconds: 30),
        );
        final fotoResponse = await http.Response.fromStream(streamedResponse);
        if (fotoResponse.statusCode != 200) {
          throw Exception(_mensajeError(fotoResponse, 'No se pudo guardar la foto'));
        }
        final body = jsonDecode(fotoResponse.body) as Map<String, dynamic>;
        final perfil = body['perfil'] as Map<String, dynamic>?;
        _fotoUrl = perfil?['foto_perfil']?.toString();
        _foto = null;
        _fotoBytes = null;
      }

      _nombre.text = _nombre.text.trim();
      _correo.text = _correo.text.trim();
      Sesion.nombre = _nombre.text;
      _nombreOriginal = _nombre.text;
      _telefonoOriginal = _telefono.text;
      _correoOriginal = _correo.text;
      if (mounted) {
        setState(() => _modoEdicion = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar perfil: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _elegirFoto() async {
    final imagen = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (imagen == null) return;
    final bytes = await imagen.readAsBytes();
    if (!mounted) return;
    setState(() {
      _foto = imagen;
      _fotoBytes = bytes;
    });
  }

  Widget _campo(String titulo, TextEditingController controlador) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (titulo.isNotEmpty)
          Text(titulo, style: const TextStyle(color: Color(0xFFE2BC65), fontSize: 14, fontWeight: FontWeight.bold)),
        TextField(
          controller: controlador,
          readOnly: !_modoEdicion,
          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            suffixIcon: _modoEdicion
                ? const Icon(Icons.edit, color: Color(0xFFE2BC65), size: 18)
                : null,
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE2BC65), width: 0.8),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE2BC65), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _opcionMenu(BuildContext context, String texto, VoidCallback onTap) {
    bool esGuardar = texto == 'Guardar';
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: esGuardar ? const Color(0xFFE2BC65) : const Color(0xFFE2BC65),
          foregroundColor: esGuardar ? const Color.fromARGB(255, 23, 30, 32) : Colors.redAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 3,
        ),
        onPressed: _guardando ? null : onTap,
        child: _guardando && esGuardar
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color.fromARGB(255, 23, 30, 32)),
              )
            : Text(
                texto,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: esGuardar ? const Color.fromARGB(255, 23, 30, 32) : const Color.fromARGB(255, 7, 7, 7),
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoBase(
        child: SafeArea(
          child: Stack(
            children: [
              // Contenido principal dentro de un contenedor unificado
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 63, 70, 71).withValues(alpha: 0.75), // 🌟 Fondo translúcido unificado
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(
                      color: const Color(0xFFE2BC65).withValues(alpha: 0.5), // 🌟 Borde sutil dorado
                      width: 1.2,
                    ),
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
                      // Barra superior (Volver y Botón Editar)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFFE2BC65),
                              size: 28,
                            ),
                            tooltip: _modoEdicion ? 'Volver al perfil' : 'Volver',
                            onPressed: _modoEdicion
                                ? _cancelarEdicion
                                : () => Navigator.pop(context),
                          ),
                          if (!_modoEdicion)
                            OutlinedButton.icon(
                              onPressed: _iniciarEdicion,
                              icon: const Icon(Icons.edit, size: 16, color: Color(0xFFE2BC65)),
                              label: const Text('Editar perfil', style: TextStyle(color: Color(0xFFE2BC65))),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFE2BC65)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),

                      // Título principal unificado con degradado dorado
                      Container(
                        width: double.infinity,
                        height: 55,
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.person, color: Color.fromARGB(255, 23, 30, 32), size: 22),
                            SizedBox(width: 10),
                            Text(
                              'PERFIL DE USUARIO',
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
                      const SizedBox(height: 15),

                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              if (_cargandoPerfil)
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 12),
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE2BC65)),
                                  ),
                                ),

                              // Avatar de Perfil
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: const Color(0xFFE2BC65), width: 2),
                                        ),
                                        child: CircleAvatar(
                                          radius: 56,
                                          backgroundColor: Colors.white,
                                          backgroundImage: _fotoBytes != null
                                              ? MemoryImage(_fotoBytes!)
                                              : _fotoUrl != null && _fotoUrl!.isNotEmpty
                                                  ? NetworkImage(_fotoUrl!)
                                                  : null,
                                          child: _fotoBytes == null &&
                                                  (_fotoUrl == null || _fotoUrl!.isEmpty)
                                              ? const Icon(Icons.person,
                                                  size: 60, color: Colors.grey)
                                              : null,
                                        ),
                                      ),
                                    ),
                                    if (_modoEdicion)
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: CircleAvatar(
                                          backgroundColor: const Color(0xFFE2BC65),
                                          radius: 18,
                                          child: IconButton(
                                            onPressed: _elegirFoto,
                                            icon: const Icon(Icons.camera_alt,
                                                color: Color.fromARGB(255, 23, 30, 32), size: 16),
                                            tooltip: 'Cambiar foto',
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              _campo('Nombre', _nombre),
                              const SizedBox(height: 16),
                              _campo('Teléfono', _telefono),
                              const SizedBox(height: 16),
                              _campo('Correo electrónico', _correo),
                              const SizedBox(height: 25),

                              if (_modoEdicion) ...[
                                _opcionMenu(context, 'Guardar', _guardarPerfil),
                                const SizedBox(height: 12),
                              ],

                              if (!_modoEdicion)
                                _opcionMenu(context, 'Cerrar Sesión', () {
                                  Sesion.token = null;
                                  Sesion.nombre = null;
                                  Sesion.rol = null;
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => const InicioSesion()),
                                    (route) => false,
                                  );
                                }),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Pie de página institucional unificado
                      const Center(
                        child: Text(
                          "BANDA SINFONICA SAN MIGUEL\nGARZÓN HUILA",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFE2BC65),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Botón flotante del chatbot de la IA
              BotonChatFlotante(onPressed: () => _abrirAsistenteIA(context)),
            ],
          ),
        ),
      ),
    );
  }
}