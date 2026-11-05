import 'package:flutter/material.dart';
import 'package:frontend/config/sesion.dart';
import 'package:frontend/services/multimedia_api.dart';
import 'package:frontend/themes/colores.dart';
import 'package:frontend/widgets/fondos.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class GaleriaMultimediaAdmin extends StatefulWidget {
  final String tipoMultimedia;
  final String titulo;

  const GaleriaMultimediaAdmin({
    super.key,
    required this.tipoMultimedia,
    required this.titulo,
  });

  @override
  State<GaleriaMultimediaAdmin> createState() => _GaleriaMultimediaAdminState();
}

class _GaleriaMultimediaAdminState extends State<GaleriaMultimediaAdmin> {
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _archivos = [];
  List<Map<String, dynamic>> _eventos = [];
  String? _idEvento;
  String? _error;
  bool _cargando = true;
  bool _subiendo = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final archivos = await MultimediaApi.listar(tipo: widget.tipoMultimedia);
      List<Map<String, dynamic>> eventos = [];
      try {
        eventos = await MultimediaApi.listarEventos();
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _archivos = archivos;
        _eventos = eventos;
        if (_idEvento != null &&
            !eventos.any(
              (evento) => evento['id_evento'].toString() == _idEvento,
            )) {
          _idEvento = null;
        }
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  bool _validarCarga() {
    if (Sesion.token == null || Sesion.rol != 'admin') {
      _mostrarMensaje('Inicia sesión como administrador para subir archivos');
      return false;
    }
    return true;
  }

  Future<void> _seleccionarFotos() async {
    if (!_validarCarga()) return;
    final archivos = await _picker.pickMultiImage();
    if (archivos.isNotEmpty) await _subirArchivos(archivos);
  }

  Future<void> _seleccionarVideo() async {
    if (!_validarCarga()) return;
    final archivo = await _picker.pickVideo(source: ImageSource.gallery);
    if (archivo != null) await _subirArchivos([archivo]);
  }

  Future<void> _subirArchivos(List<XFile> archivos) async {
    setState(() => _subiendo = true);
    try {
      for (final archivo in archivos) {
        if (await archivo.length() > 50 * 1024 * 1024) {
          throw Exception('${archivo.name} supera el límite de 50 MB');
        }
        final titulo = archivo.name.replaceFirst(RegExp(r'\.[^.]+$'), '');
        await MultimediaApi.subir(
          archivo: archivo,
          token: Sesion.token!,
          tipo: widget.tipoMultimedia,
          idEvento: _idEvento,
          titulo: titulo,
        );
      }
      await _cargarDatos();
      _mostrarMensaje('Archivo(s) subido(s) correctamente');
    } catch (error) {
      _mostrarMensaje('No se pudo subir el archivo: $error');
    } finally {
      if (mounted) setState(() => _subiendo = false);
    }
  }

  Future<void> _eliminarArchivo(Map<String, dynamic> archivo) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 63, 70, 71).withValues(alpha: 0.75),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE2BC65), width: 1.2),
        ),
        title: const Text(
          'Eliminar archivo',
          style: TextStyle(
            color: Color(0xFFE2BC65),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '¿Quieres eliminar "${archivo['titulo'] ?? 'este archivo'}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    try {
      await MultimediaApi.borrar(
        id: archivo['id_multimedia'].toString(),
        token: Sesion.token!,
      );
      await _cargarDatos();
      _mostrarMensaje('Archivo eliminado');
    } catch (error) {
      _mostrarMensaje('No se pudo eliminar el archivo: $error');
    }
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _abrirArchivo(Map<String, dynamic> archivo) async {
    final url = Uri.tryParse(archivo['url_archivo']?.toString() ?? '');
    if (url == null ||
        !await launchUrl(url, mode: LaunchMode.externalApplication)) {
      _mostrarMensaje('No se pudo abrir el archivo');
    }
  }

  Widget _tarjetaArchivo(Map<String, dynamic> archivo) {
    final url = archivo['url_archivo']?.toString() ?? '';
    final esFoto = widget.tipoMultimedia == 'foto';
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Material(
            color: Colors.black26,
            child: InkWell(
              onTap: () => _abrirArchivo(archivo),
              child: esFoto
                  ? Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Center(
                        child: Icon(Icons.broken_image, color: Colors.white70),
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        color: Color(0xFFE2BC65),
                        size: 56,
                      ),
                    ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: IconButton(
                tooltip: 'Eliminar',
                onPressed: _subiendo ? null : () => _eliminarArchivo(archivo),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black54,
              child: Text(
                archivo['titulo']?.toString() ?? widget.titulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoBase(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 63, 70, 71).withValues(alpha: 0.75), // 🌟 Fondo translúcido unificado
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(
                    0xFFE2BC65,
                  ).withValues(alpha: 0.5), // 🌟 Borde sutil dorado
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
                  // Cabecera con botón de regresar y botón de actualizar
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Volver',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFFE2BC65),
                          size: 28,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Actualizar',
                        onPressed: _cargando || _subiendo ? null : _cargarDatos,
                        icon: const Icon(
                          Icons.refresh,
                          color: Color(0xFFE2BC65),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // Título principal con degradado dorado unificado
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE2BC65), Color(0xFFC29B45)],
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
                      children: [
                        Icon(
                          widget.tipoMultimedia == 'foto'
                              ? Icons.photo_library
                              : Icons.video_library,
                          color: const Color.fromARGB(255, 23, 30, 32),
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.titulo.toUpperCase(),
                          style: const TextStyle(
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

                  // Selector de Evento (opcional)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 76, 79, 80).withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE2BC65).withValues(alpha: 0.4),
                        width: 1.0,
                      ),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _idEvento,
                      dropdownColor: const Color.fromARGB(255, 76, 79, 80).withValues(alpha: 0.75),
                      decoration: const InputDecoration(
                        labelText: 'Evento (opcional)',
                        labelStyle: TextStyle(color: Color.fromARGB(137, 247, 245, 245)),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: '',
                          child: Text('Sin asociar a evento'),
                        ),
                        for (final evento in _eventos)
                          DropdownMenuItem(
                            value: evento['id_evento'].toString(),
                            child: Text(
                              evento['nombre_evento']?.toString() ?? 'Evento',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: _subiendo
                          ? null
                          : (value) => setState(
                              () => _idEvento = value?.isEmpty == true
                                  ? null
                                  : value,
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Grid de archivos
                  Expanded(
                    child: _cargando
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFE2BC65),
                            ),
                          )
                        : _error != null
                        ? Center(
                            child: Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          )
                        : _archivos.isEmpty
                        ? Center(
                            child: Text(
                              'Todavía no hay ${widget.titulo.toLowerCase()}.',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          )
                        : GridView.builder(
                            itemCount: _archivos.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                            itemBuilder: (context, index) =>
                                _tarjetaArchivo(_archivos[index]),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Botón de selección / subida con estilo píldora
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _subiendo
                          ? null
                          : widget.tipoMultimedia == 'foto'
                          ? _seleccionarFotos
                          : _seleccionarVideo,
                      icon: _subiendo
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color.fromARGB(255, 23, 30, 32),
                              ),
                            )
                          : Icon(
                              widget.tipoMultimedia == 'foto'
                                  ? Icons.add_photo_alternate_outlined
                                  : Icons.video_call_outlined,
                            ),
                      label: Text(
                        _subiendo
                            ? 'Subiendo...'
                            : 'Seleccionar ${widget.tipoMultimedia == 'foto' ? 'fotos' : 'video'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE2BC65),
                        foregroundColor: const Color.fromARGB(255, 23, 30, 32),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

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
        ),
      ),
    );
  }
}
