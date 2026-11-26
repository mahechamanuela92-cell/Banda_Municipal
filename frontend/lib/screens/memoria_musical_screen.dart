import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/api.dart';
import 'package:frontend/config/sesion.dart';
import 'package:frontend/widgets/fondos.dart';
import 'package:http/http.dart' as http;

class _CartaMusical {
  final String claveUnica;
  final String titulo;
  final String subtitulo;
  final IconData icono;
  final Color colorAcento;
  final int estiloMarco;

  const _CartaMusical({
    required this.claveUnica,
    required this.titulo,
    required this.subtitulo,
    required this.icono,
    required this.colorAcento,
    required this.estiloMarco,
  });
}

class _CartaTablero {
  final int uid;
  final _CartaMusical definicion;
  bool volteada = false;
  bool encontrada = false;

  _CartaTablero({
    required this.uid,
    required this.definicion,
  });
}

class MemoriaMusicalScreen extends StatefulWidget {
  const MemoriaMusicalScreen({super.key});

  @override
  State<MemoriaMusicalScreen> createState() => _MemoriaMusicalScreenState();
}

class _MemoriaMusicalScreenState extends State<MemoriaMusicalScreen> {
  static const Color _dorado = Color(0xFFE2BC65);
  static const Color _tarjetaOscura = Color.fromARGB(255, 63, 70, 71);
  static const Color _fondoOscuro = Color.fromARGB(255, 23, 30, 32);

  // Fábrica de 3,600 cartas únicas: 15 motivos x 12 etiquetas x 10 colores x 2 marcos = 3,600
  static final List<_CartaMusical> _catalogoMiles = _generarCatalogoCartas();

  static List<_CartaMusical> _generarCatalogoCartas() {
    final motivos = <(String, IconData)>[
      ('Clave de Sol', Icons.music_note),
      ('Doble Corchea', Icons.queue_music),
      ('Trompeta', Icons.campaign),
      ('Saxofón', Icons.graphic_eq),
      ('Clarinete', Icons.air),
      ('Flauta', Icons.waves),
      ('Percusión', Icons.album),
      ('Armonía', Icons.piano),
      ('Afinación', Icons.tune),
      ('Partitura', Icons.library_music),
      ('Concierto', Icons.festival),
      ('Ensayo', Icons.headphones),
      ('Compás', Icons.speed),
      ('Eco Sinfónico', Icons.surround_sound),
      ('Solista', Icons.star),
    ];

    final etiquetas = <String>[
      'Do',
      'Re',
      'Mi',
      'Fa',
      'Sol',
      'La',
      'Si',
      '4/4',
      '3/4',
      '6/8',
      '♯ Sostenido',
      '♭ Bemol',
    ];

    final colores = <Color>[
      const Color(0xFFE2BC65),
      const Color(0xFF4ADE80),
      const Color(0xFF38BDF8),
      const Color(0xFFF472B6),
      const Color(0xFFFB923C),
      const Color(0xFFA78BFA),
      const Color(0xFF2DD4BF),
      const Color(0xFFFACC15),
      const Color(0xFFF87171),
      const Color(0xFF818CF8),
    ];

    final lista = <_CartaMusical>[];
    for (int m = 0; m < motivos.length; m++) {
      for (int e = 0; e < etiquetas.length; e++) {
        for (int c = 0; c < colores.length; c++) {
          for (int marco = 0; marco < 2; marco++) {
            final (nombreMotivo, icono) = motivos[m];
            final etiqueta = etiquetas[e];
            final color = colores[c];
            final clave = 'm${m}_e${e}_c${c}_f$marco';
            lista.add(
              _CartaMusical(
                claveUnica: clave,
                titulo: nombreMotivo,
                subtitulo: '$etiqueta · #${lista.length + 1}',
                icono: icono,
                colorAcento: color,
                estiloMarco: marco,
              ),
            );
          }
        }
      }
    }
    return lista;
  }

  final AudioPlayer _player = AudioPlayer();
  bool _sonidoActivado = true;

  int _nivel = 1;
  int _puntosTotales = 0;
  int _intentos = 0;
  int _segundosTranscurridos = 0;
  bool _bloqueado = false;
  bool _guardandoResultado = false;
  String _nombreJugador = 'Músico Garzón';

  Timer? _timer;
  List<_CartaTablero> _cartas = [];
  _CartaTablero? _primeraSeleccionada;

  @override
  void initState() {
    super.initState();
    _cargarUsuarioYIniciarPartida();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _reproducirSonido(String nombreArchivo) async {
    if (!_sonidoActivado) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audios/$nombreArchivo'));
    } catch (_) {
      // Si falta un archivo o el audio no está disponible, el juego continúa sin fallar
    }
  }

  void _alternarSonido() {
    setState(() {
      _sonidoActivado = !_sonidoActivado;
    });
    if (!_sonidoActivado) {
      _player.stop();
    } else {
      _reproducirSonido('voltear_carta.mp3');
    }
  }

  Future<void> _cargarUsuarioYIniciarPartida() async {
    await Sesion.cargar();
    final nombreGuardado = Sesion.nombre;
    if (mounted && nombreGuardado != null && nombreGuardado.trim().isNotEmpty) {
      setState(() => _nombreJugador = nombreGuardado.trim());
    }
    _iniciarPartida(reiniciarCronometro: true);
  }

  int _parejasSegunNivel(int nivel) {
    if (nivel <= 1) return 6; // 12 cartas
    if (nivel == 2) return 8; // 16 cartas
    if (nivel == 3) return 10; // 20 cartas
    return 12; // 24 cartas
  }

  String _nombreRangoNivel(int nivel) {
    switch (nivel) {
      case 1:
        return 'Aprendiz';
      case 2:
        return 'Atril';
      case 3:
        return 'Ensamble';
      case 4:
        return 'Solista';
      case 5:
        return 'Concertino';
      default:
        return 'Maestro';
    }
  }

  void _iniciarPartida({bool reiniciarCronometro = true}) {
    _timer?.cancel();

    // Semilla única por partida + jugador para que 30 personas obtengan tableros distintos
    final semilla = DateTime.now().microsecondsSinceEpoch ^
        _nombreJugador.hashCode ^
        (_nivel * 7919);
    final rng = Random(semilla);

    final mazoCopia = List<_CartaMusical>.from(_catalogoMiles)..shuffle(rng);
    final cantidadParejas = _parejasSegunNivel(_nivel);
    final seleccionadas = mazoCopia.take(cantidadParejas).toList();

    final tablero = <_CartaTablero>[];
    int uidCounter = 0;
    for (final def in seleccionadas) {
      tablero.add(_CartaTablero(uid: uidCounter++, definicion: def));
      tablero.add(_CartaTablero(uid: uidCounter++, definicion: def));
    }
    tablero.shuffle(rng);

    setState(() {
      _cartas = tablero;
      _primeraSeleccionada = null;
      _bloqueado = false;
      _intentos = 0;
      if (reiniciarCronometro) {
        _segundosTranscurridos = 0;
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _segundosTranscurridos++);
    });
  }

  String _formatearTiempo(int segundos) {
    final mins = (segundos ~/ 60).toString().padLeft(2, '0');
    final secs = (segundos % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void _alTocarCarta(_CartaTablero carta) {
    if (_bloqueado || carta.volteada || carta.encontrada) return;

    setState(() {
      carta.volteada = true;
    });

    if (_primeraSeleccionada == null) {
      _reproducirSonido('voltear_carta.mp3');
      _primeraSeleccionada = carta;
      return;
    }

    final anterior = _primeraSeleccionada!;
    _primeraSeleccionada = null;
    setState(() => _intentos++);

    if (anterior.definicion.claveUnica == carta.definicion.claveUnica) {
      _reproducirSonido('correcto.mp3');
      setState(() {
        anterior.encontrada = true;
        carta.encontrada = true;
        _puntosTotales += 50 * _nivel;
      });
      _verificarVictoria();
    } else {
      _reproducirSonido('incorrecto.mp3');
      setState(() => _bloqueado = true);
      Future.delayed(const Duration(milliseconds: 650), () {
        if (!mounted) return;
        setState(() {
          anterior.volteada = false;
          carta.volteada = false;
          _bloqueado = false;
        });
      });
    }
  }

  Future<void> _verificarVictoria() async {
    final todasEncontradas = _cartas.every((c) => c.encontrada);
    if (!todasEncontradas) return;

    _timer?.cancel();
    _reproducirSonido('victoria.mp3');

    // Bono por rapidez (hasta 300 pts si resuelve rápido)
    final bonoTiempo = max(0, 300 - (_segundosTranscurridos * 2));
    final puntosGanadosPartida = (_parejasSegunNivel(_nivel) * 60) + bonoTiempo;

    setState(() {
      _puntosTotales += bonoTiempo;
      _guardandoResultado = true;
    });

    await _enviarResultadoAlRanking(
      puntosAEnviar: _puntosTotales,
      tiempoSegundos: max(1, _segundosTranscurridos),
      intentos: _intentos,
    );

    if (!mounted) return;
    setState(() => _guardandoResultado = false);

    _mostrarModalFinalPartida(puntosGanadosPartida);
  }

  Future<void> _enviarResultadoAlRanking({
    required int puntosAEnviar,
    required int tiempoSegundos,
    required int intentos,
  }) async {
    try {
      final url = Uri.parse('$apiUrl/api/ranking-memoria');
      await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'nombre': _nombreJugador,
              'nivel': _nivel,
              'puntos': puntosAEnviar,
              'tiempoSegundos': tiempoSegundos,
              'intentos': intentos,
            }),
          )
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      // Si no hay conexión en el momento, el jugador igual puede ver su partida y reintentar el ranking
    }
  }

  Future<List<Map<String, dynamic>>> _consultarRanking() async {
    final url = Uri.parse('$apiUrl/api/ranking-memoria');
    final resp = await http.get(url).timeout(const Duration(seconds: 8));
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
    }
    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    final lista = (decoded['ranking'] as List<dynamic>? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    return lista;
  }

  void _mostrarModalRanking({bool cerrarPrevio = false}) {
    if (cerrarPrevio && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _fondoOscuro,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: _dorado, width: 1.2),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events, color: _dorado, size: 26),
                      SizedBox(width: 8),
                      Text(
                        'RANKING DE LA BANDA',
                        style: TextStyle(
                          color: _dorado,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ordenado del 1° al último puesto por puntos y tiempo récord',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _consultarRanking(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(color: _dorado),
                          );
                        }
                        if (snapshot.hasError || !snapshot.hasData) {
                          return Center(
                            child: Text(
                              'No fue posible cargar el ranking.\n${snapshot.error ?? 'Verifica la conexión con el servidor.'}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }

                        final filas = snapshot.data!;
                        if (filas.isEmpty) {
                          return const Center(
                            child: Text(
                              'Aún no hay puntajes registrados.\n¡Sé el primero en completar una partida!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white70),
                            ),
                          );
                        }

                        return ListView.separated(
                          controller: scrollController,
                          itemCount: filas.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, index) {
                            final item = filas[index];
                            final puesto = item['puesto'] ?? (index + 1);
                            final nombre = (item['nombre'] ?? '').toString();
                            final nivel = item['nivel'] ?? 1;
                            final puntos = item['puntos'] ?? 0;
                            final tiempoStr = (item['tiempo_formateado'] ??
                                    _formatearTiempo(
                                        (item['mejor_tiempo_segundos'] ?? 0)
                                            as int))
                                .toString();

                            final esMiUsuario = nombre.toLowerCase() ==
                                _nombreJugador.toLowerCase();

                            String medalla = '#$puesto';
                            if (puesto == 1) medalla = '🥇 1°';
                            if (puesto == 2) medalla = '🥈 2°';
                            if (puesto == 3) medalla = '🥉 3°';

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: esMiUsuario
                                    ? _dorado.withValues(alpha: 0.2)
                                    : _tarjetaOscura.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: esMiUsuario
                                      ? _dorado
                                      : Colors.white.withValues(alpha: 0.12),
                                  width: esMiUsuario ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 54,
                                    child: Text(
                                      medalla,
                                      style: const TextStyle(
                                        color: _dorado,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          nombre,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          'Nivel $nivel (${_nombreRangoNivel(nivel is int ? nivel : int.tryParse('$nivel') ?? 1)})',
                                          style: const TextStyle(
                                            color: Colors.white60,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '$puntos pts',
                                        style: const TextStyle(
                                          color: _dorado,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '⏱ $tiempoStr',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _mostrarModalFinalPartida(int puntosGanadosPartida) {
    final tiempoFinal = _formatearTiempo(_segundosTranscurridos);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: _tarjetaOscura,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: _dorado, width: 1.5),
          ),
          title: const Text(
            '¡TABLERO COMPLETADO!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _dorado,
              fontWeight: FontWeight.bold,
              fontSize: 19,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¡Excelente trabajo, $_nombreJugador!',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 14),
              _filaResumen('Tiempo de partida', tiempoFinal),
              _filaResumen('Intentos', '$_intentos'),
              _filaResumen('Ganado en ronda', '+$puntosGanadosPartida pts'),
              _filaResumen('Puntos acumulados', '$_puntosTotales pts'),
              _filaResumen(
                  'Nivel actual', 'Nivel $_nivel · ${_nombreRangoNivel(_nivel)}'),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton.icon(
              onPressed: () => _mostrarModalRanking(cerrarPrevio: true),
              icon: const Icon(Icons.leaderboard, color: _dorado),
              label: const Text(
                'Ver Ranking',
                style: TextStyle(
                  color: _dorado,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _dorado,
                foregroundColor: _fondoOscuro,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() => _nivel++);
                _iniciarPartida(reiniciarCronometro: true);
              },
              child: const Text(
                'Subir de Nivel',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _filaResumen(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(
            valor,
            style: const TextStyle(
              color: _dorado,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartaWidget(_CartaTablero carta) {
    final descubierta = carta.volteada || carta.encontrada;
    final def = carta.definicion;

    return GestureDetector(
      onTap: () => _alTocarCarta(carta),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: descubierta
              ? _fondoOscuro.withValues(alpha: 0.95)
              : _tarjetaOscura.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: carta.encontrada
                ? Colors.greenAccent
                : descubierta
                    ? def.colorAcento
                    : _dorado.withValues(alpha: 0.45),
            width: descubierta ? 2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: descubierta
            ? Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(def.icono, color: def.colorAcento, size: 26),
                    const SizedBox(height: 4),
                    Text(
                      def.titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      def.subtitulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: def.colorAcento,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            : Center(
                child: Icon(
                  def.estiloMarco == 0 ? Icons.music_note : Icons.queue_music,
                  color: _dorado.withValues(alpha: 0.75),
                  size: 28,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final columnas = _cartas.length <= 12 ? 3 : 4;

    return Scaffold(
      body: FondoBase(
        child: SafeArea(
          child: Column(
            children: [
              // Barra superior
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: _dorado),
                    ),
                    const Expanded(
                      child: Text(
                        'MEMORIA MUSICAL',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _dorado,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: _sonidoActivado ? 'Silenciar' : 'Activar sonido',
                      onPressed: _alternarSonido,
                      icon: Icon(
                        _sonidoActivado ? Icons.volume_up : Icons.volume_off,
                        color: _dorado,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Ver Ranking',
                      onPressed: () => _mostrarModalRanking(),
                      icon: const Icon(Icons.leaderboard, color: _dorado),
                    ),
                  ],
                ),
              ),

              // Panel de estadísticas (Nivel, Tiempo, Puntos, Intentos)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _tarjetaOscura.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _dorado.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem('Nivel $_nivel', _nombreRangoNivel(_nivel)),
                    _statItem(
                        'Tiempo', _formatearTiempo(_segundosTranscurridos)),
                    _statItem('Puntos', '$_puntosTotales'),
                    _statItem('Intentos', '$_intentos'),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Cuadrícula de cartas
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    itemCount: _cartas.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columnas,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.9,
                    ),
                    itemBuilder: (_, index) => _buildCartaWidget(_cartas[index]),
                  ),
                ),
              ),

              // Botones inferiores
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _dorado,
                          side: const BorderSide(color: _dorado),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () =>
                            _iniciarPartida(reiniciarCronometro: true),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text(
                          'Nuevo Tablero',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _dorado,
                          foregroundColor: _fondoOscuro,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: _guardandoResultado
                            ? null
                            : () => _mostrarModalRanking(),
                        icon: const Icon(Icons.emoji_events, size: 18),
                        label: Text(
                          _guardandoResultado ? 'Guardando...' : 'Ranking',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(String titulo, String valor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          valor,
          style: const TextStyle(
            color: _dorado,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          titulo,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}