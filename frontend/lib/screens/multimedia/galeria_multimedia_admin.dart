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
        title: const Text('Eliminar archivo'),
        content: Text(
          '¿Quieres eliminar "${archivo['titulo'] ?? 'este archivo'}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
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
      borderRadius: BorderRadius.circular(10),
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
                        color: Colors.white,
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
                icon: const Icon(Icons.delete_outline, color: Colors.white),
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
                style: const TextStyle(color: Colors.white),
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colores.bloqueOscuro,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Volver',
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colores.naranja,
                          size: 30,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          widget.titulo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Actualizar',
                        onPressed: _cargando || _subiendo ? null : _cargarDatos,
                        icon: const Icon(Icons.refresh, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _idEvento,
                    dropdownColor: Colores.bloqueOscuro,
                    decoration: const InputDecoration(
                      labelText: 'Evento (opcional)',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
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
                  const SizedBox(height: 12),
                  Expanded(
                    child: _cargando
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Colores.amarillo,
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
                  const SizedBox(height: 12),
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
                              child: CircularProgressIndicator(strokeWidth: 2),
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
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA1E3D8),
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
