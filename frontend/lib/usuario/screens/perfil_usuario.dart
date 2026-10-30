import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/config/api.dart';
import 'package:frontend/config/sesion.dart';
import 'package:frontend/screens/inicioSesion.dart';
import '../../themes/colores.dart';
import '../../widgets/fondos.dart';

class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({super.key});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  File? _foto; // foto elegida de la galería
  String? _fotoUrl;
  bool _cargandoPerfil = true;
  bool _guardando = false;
  final _nombre = TextEditingController(text: Sesion.nombre ?? '');
  final _telefono = TextEditingController();
  final _correo = TextEditingController();

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

  String _mensajeError(http.Response response, String alternativa) {
    if (response.statusCode == 404) {
      return 'El backend remoto aún no tiene la ruta para guardar el perfil. Despliega los cambios del backend.';
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
        Uri.parse('$apiUrl/perfil/me'),
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
          Uri.parse('$apiUrl/perfil/foto'),
        )..headers['Authorization'] = 'Bearer $token';
        request.files.add(await http.MultipartFile.fromPath('foto', _foto!.path));
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
      }

      Sesion.nombre = _nombre.text.trim();
      if (mounted) {
        setState(() {});
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

  // Abre la galería y guarda la foto elegida
  Future<void> _elegirFoto() async {
    final imagen = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (imagen != null) {
      setState(() => _foto = File(imagen.path));
    }
  }

  // Campo centrado con lápiz
  Widget _campo(String titulo, TextEditingController controlador) {
    return Column(
      children: [
        if (titulo.isNotEmpty)
          Text(titulo, style: const TextStyle(color: Colors.white, fontSize: 18)),
        TextField(
          controller: controlador,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: const InputDecoration(
            suffixIcon: Icon(Icons.edit, color: Colors.white, size: 16),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // Botón grande
  Widget _boton(String texto, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colores.botonClaro,
          foregroundColor: Colores.bloqueOscuro,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: _guardando ? null : onTap,
        child: _guardando
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(texto, style: const TextStyle(fontSize: 20)),
      ),
    );
  }

  // <--- 2. Método _opcionMenu agregado para que funcione el botón de Cerrar Sesión --->
  Widget _opcionMenu(BuildContext context, String texto, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colores.botonClaro,
          foregroundColor: Colores.bloqueOscuro,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: _guardando ? null : onTap,
        child: Text(texto, style: const TextStyle(fontSize: 20)),
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
              // CAPA 1: el ave, arriba y detrás del bloque oscuro
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Image.asset(
                  'assets/images/fondo_login1.png',
                  height: 260,
                  fit: BoxFit.contain,
                ),
              ),

              // CAPA 2: bloque del perfil + texto de abajo
              Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colores.naranja,
                        size: 30,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
                          decoration: BoxDecoration(
                            color: Colores.bloqueOscuro,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_cargandoPerfil)
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 12),
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              const Text('Perfil',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 20),

                              // Foto con lápiz para editar
                              SizedBox(
                                width: 170,
                                height: 130,
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: CircleAvatar(
                                        radius: 60,
                                        backgroundColor: Colors.white,
                                        backgroundImage: _foto != null
                                          ? FileImage(_foto!)
                                          : _fotoUrl != null
                                            ? NetworkImage(_fotoUrl!)
                                            : null,
                                        child: _foto == null && _fotoUrl == null
                                            ? const Icon(Icons.person,
                                                size: 70, color: Colors.grey)
                                            : null,
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: GestureDetector(
                                        onTap: _elegirFoto,
                                        child: const Icon(Icons.edit, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),
                              _campo('Nombre', _nombre),
                              const SizedBox(height: 28),
                              _campo('Telefono', _telefono),
                              const SizedBox(height: 28),
                              _campo('Correo', _correo),
                              const SizedBox(height: 44),

                              _boton('Guardar', _guardarPerfil),
                              const SizedBox(height: 16),
                              
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
                    ),
                  ),

                  // Texto de abajo
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: Text(
                      'BANDA SINFONICA SAN MIGUEL DE GARZÓN',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colores.colorLetra1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}