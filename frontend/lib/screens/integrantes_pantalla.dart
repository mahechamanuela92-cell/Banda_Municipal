import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/config/api.dart';
import 'package:frontend/config/sesion.dart';
import 'package:frontend/components/chat/boton_chat_flotante.dart';
import 'package:frontend/components/chat/chat_banda_modal.dart';
import '../widgets/fondos.dart';

class IntegranteItem {
  final String? id;
  final String nombre;
  final String rol;
  final String? fotoPerfil;
  final bool esMaestroDestacado;

  const IntegranteItem({
    this.id,
    required this.nombre,
    required this.rol,
    this.fotoPerfil,
    this.esMaestroDestacado = false,
  });

  factory IntegranteItem.fromJson(Map<String, dynamic> json) {
    final nombreStr = (json['nombre'] ?? 'Integrante').toString().trim();
    final rolStr = (json['rol'] ?? 'musico').toString().trim().toLowerCase();
    final rawId = json['user_id'] ?? json['id'];
    final rawFoto = json['foto_perfil']?.toString().trim();

    return IntegranteItem(
      id: rawId?.toString(),
      nombre: nombreStr.isEmpty ? 'Integrante' : nombreStr,
      rol: rolStr,
      fotoPerfil: (rawFoto != null && rawFoto.isNotEmpty) ? rawFoto : null,
      esMaestroDestacado: nombreStr.toLowerCase().contains('sergio') ||
          rolStr == 'maestro',
    );
  }
}

class PantallaIntegrantes extends StatefulWidget {
  const PantallaIntegrantes({super.key});

  @override
  State<PantallaIntegrantes> createState() => _PantallaIntegrantesState();
}

class _PantallaIntegrantesState extends State<PantallaIntegrantes> {
  bool _cargando = true;
  String? _error;
  IntegranteItem? _maestro;
  List<IntegranteItem> _integrantes = [];

  bool get _esAdmin => Sesion.rol?.toLowerCase() == 'admin';

  @override
  void initState() {
    super.initState();
    _cargarIntegrantes();
  }

  void _abrirAsistenteIA(BuildContext context) {
    showDialog(context: context, builder: (_) => const ChatBandaModal());
  }

  Future<void> _cargarIntegrantes() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (Sesion.token != null && Sesion.token!.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${Sesion.token}';
      }

      final response = await http
          .get(Uri.parse('$apiUrl/api/users'), headers: headers)
          .timeout(const Duration(seconds: 12));

      final body = jsonDecode(response.body);
      if (response.statusCode != 200) {
        final msg = (body is Map && body['error'] != null)
            ? body['error'].toString()
            : 'No se pudieron cargar los integrantes';
        throw Exception(msg);
      }

      final listaRaw = body is Map && body['usuarios'] is List
          ? body['usuarios'] as List
          : (body is List ? body : const []);

      final todos = listaRaw
    .whereType<Map<String, dynamic>>()
    .map(IntegranteItem.fromJson)
    .toList();

      IntegranteItem? maestroEncontrado;
      final resto = <IntegranteItem>[];

      for (final item in todos) {
        if (maestroEncontrado == null && item.esMaestroDestacado) {
          maestroEncontrado = IntegranteItem(
            id: item.id,
            nombre: item.nombre.toLowerCase().contains('sergio') &&
                    !item.nombre.toLowerCase().startsWith('maestro')
                ? 'Maestro ${item.nombre}'
                : item.nombre,
            rol: item.rol,
            fotoPerfil: item.fotoPerfil,
            esMaestroDestacado: true,
          );
        } else {
          resto.add(item);
        }
      }

      maestroEncontrado ??= const IntegranteItem(
        nombre: 'Maestro Sergio',
        rol: 'admin',
        esMaestroDestacado: true,
      );

      resto.sort(
        (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()),
      );

      if (!mounted) return;
      setState(() {
        _maestro = maestroEncontrado;
        _integrantes = resto;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _confirmarYEliminar(IntegranteItem integrante) async {
    if (!_esAdmin || integrante.rol == 'admin' || integrante.id == null) {
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 63, 70, 71),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE2BC65), width: 1.2),
        ),
        title: const Text(
          'Eliminar integrante',
          style: TextStyle(
            color: Color(0xFFE2BC65),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(
          '¿Deseas eliminar a ${integrante.nombre} de la Banda Sinfónica San Miguel?',
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'No',
              style: TextStyle(
                color: Color(0xFFE2BC65),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Sí, eliminar',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    try {
      final response = await http
          .delete(
            Uri.parse('$apiUrl/api/users/${integrante.id}'),
            headers: {
              'Content-Type': 'application/json',
              if (Sesion.token != null) 'Authorization': 'Bearer ${Sesion.token}',
            },
          )
          .timeout(const Duration(seconds: 12));

      final body = jsonDecode(response.body);
      if (response.statusCode != 200) {
        final msg = (body is Map && body['error'] != null)
            ? body['error'].toString()
            : 'No se pudo eliminar el integrante';
        throw Exception(msg);
      }

      if (!mounted) return;
      setState(() {
        _integrantes.removeWhere((u) => u.id == integrante.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${integrante.nombre} fue eliminado')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  void _abrirVistaSimpleUsuario(IntegranteItem integrante) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _VistaPerfilSimpleUsuario(integrante: integrante),
      ),
    );
  }

  Widget _avatar(IntegranteItem item, {double radius = 26}) {
    final tieneFoto = item.fotoPerfil != null && item.fotoPerfil!.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE2BC65), width: 1.5),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: const Color.fromARGB(255, 45, 51, 53),
        backgroundImage: tieneFoto ? NetworkImage(item.fotoPerfil!) : null,
        child: !tieneFoto
            ? Icon(
                Icons.person,
                size: radius * 1.1,
                color: const Color(0xFFE2BC65),
              )
            : null,
      ),
    );
  }

  Widget _tarjetaIntegrante(
    IntegranteItem item, {
    bool esEncabezadoMaestro = false,
  }) {
    final puedeEliminar = _esAdmin && !esEncabezadoMaestro && item.rol != 'admin';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: esEncabezadoMaestro
            ? const Color.fromARGB(255, 45, 51, 53).withValues(alpha: 0.9)
            : const Color.fromARGB(255, 63, 70, 71).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2BC65)
              .withValues(alpha: esEncabezadoMaestro ? 0.95 : 0.5),
          width: esEncabezadoMaestro ? 1.8 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: !_esAdmin ? () => _abrirVistaSimpleUsuario(item) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                _avatar(item, radius: esEncabezadoMaestro ? 28 : 24),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (esEncabezadoMaestro)
                        const Text(
                          'Dirección Musical',
                          style: TextStyle(
                            color: Color(0xFFE2BC65),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
                if (puedeEliminar)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    tooltip: 'Eliminar integrante',
                    onPressed: () => _confirmarYEliminar(item),
                  )
                else if (!_esAdmin)
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 15,
                    color: Color(0xFFE2BC65),
                  ),
              ],
            ),
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(18.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 63, 70, 71)
                        .withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(
                      color: const Color(0xFFE2BC65).withValues(alpha: 0.5),
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
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFFE2BC65),
                              size: 28,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        height: 52,
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
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.groups,
                              color: Color.fromARGB(255, 23, 30, 32),
                              size: 22,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'INTEGRANTES',
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
                      const SizedBox(height: 16),
                      Expanded(
                        child: _cargando
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFE2BC65),
                                ),
                              )
                            : _error != null
                                ? Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _error!,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFFE2BC65),
                                            foregroundColor: const Color.fromARGB(
                                                255, 23, 30, 32),
                                          ),
                                          onPressed: _cargarIntegrantes,
                                          child: const Text('Reintentar'),
                                        ),
                                      ],
                                    ),
                                  )
                                : RefreshIndicator(
                                    color: const Color(0xFFE2BC65),
                                    onRefresh: _cargarIntegrantes,
                                    child: ListView(
                                      children: [
                                        if (_maestro != null)
                                          _tarjetaIntegrante(
                                            _maestro!,
                                            esEncabezadoMaestro: true,
                                          ),
                                        if (_integrantes.isEmpty)
                                          const Padding(
                                            padding: EdgeInsets.all(24),
                                            child: Text(
                                              'Aún no hay integrantes registrados.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                              ),
                                            ),
                                          )
                                        else
                                          ..._integrantes.map(
                                            (item) => _tarjetaIntegrante(item),
                                          ),
                                      ],
                                    ),
                                  ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'BANDA SINFONICA SAN MIGUEL\nGARZÓN HUILA',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFE2BC65),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              BotonChatFlotante(onPressed: () => _abrirAsistenteIA(context)),
            ],
          ),
        ),
      ),
    );
  }
}

class _VistaPerfilSimpleUsuario extends StatelessWidget {
  final IntegranteItem integrante;

  const _VistaPerfilSimpleUsuario({required this.integrante});

  @override
  Widget build(BuildContext context) {
    final tieneFoto =
        integrante.fotoPerfil != null && integrante.fotoPerfil!.isNotEmpty;

    return Scaffold(
      body: FondoBase(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 63, 70, 71)
                    .withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(
                  color: const Color(0xFFE2BC65).withValues(alpha: 0.5),
                  width: 1.2,
                ),
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFFE2BC65),
                        size: 28,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE2BC65),
                        width: 2.5,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 82,
                      backgroundColor: const Color.fromARGB(255, 45, 51, 53),
                      backgroundImage:
                          tieneFoto ? NetworkImage(integrante.fotoPerfil!) : null,
                      child: !tieneFoto
                          ? const Icon(
                              Icons.person,
                              size: 86,
                              color: Color(0xFFE2BC65),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    integrante.nombre,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'BANDA SINFONICA SAN MIGUEL\nGARZÓN HUILA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFE2BC65),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
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