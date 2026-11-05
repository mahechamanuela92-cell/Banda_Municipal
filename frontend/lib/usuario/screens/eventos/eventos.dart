import 'package:flutter/material.dart';
import 'package:frontend/services/eventos_api.dart';
import '../../../themes/colores.dart';
import '../../../widgets/fondos.dart';
import 'package:frontend/components/chat/boton_chat_flotante.dart';
import 'package:frontend/components/chat/chat_banda_modal.dart';

class PantallaEventos extends StatefulWidget {
  final bool esAdmin; // true = puede editar, false = solo ver
  final String nombreEvento;
  final DateTime fechaEvento;
  final TimeOfDay horaEvento;
  final String lugarEvento;

  const PantallaEventos({
    super.key,
    this.esAdmin = false,
    this.nombreEvento = '',
    required this.fechaEvento,
    this.horaEvento = const TimeOfDay(hour: 20, minute: 0),
    this.lugarEvento = 'Parque Principal',
  });

  @override
  State<PantallaEventos> createState() => _PantallaEventosState();
}

class _PantallaEventosState extends State<PantallaEventos> {
  late final TextEditingController nombreController;
  late final TextEditingController lugarController;
  late DateTime fechaElegida;
  late TimeOfDay horaElegida;

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.nombreEvento);
    lugarController = TextEditingController(text: widget.lugarEvento);
    fechaElegida = widget.fechaEvento;
    horaElegida = widget.horaEvento;
  }

  void _abrirAsistenteIA(BuildContext context) {
    showDialog(context: context, builder: (_) => const ChatBandaModal());
  }

  Future<void> elegirHora() async {
    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: horaElegida,
    );
    if (hora != null) setState(() => horaElegida = hora);
  }

  void guardarEvento() {
    final String mensaje =
        '${nombreController.text} ${fechaElegida.day}/${fechaElegida.month}/${fechaElegida.year} '
        'a las ${horaElegida.format(context)} en ${lugarController.text}';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    nombreController.dispose();
    lugarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool admin = widget.esAdmin;

    return Scaffold(
      body: FondoBase(
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 63, 70, 71).withValues(alpha: 0.75), // 🌟 Fondo translúcido unificado
                    borderRadius: BorderRadius.circular(24.0),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Botón de regresar unificado
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFFE2BC65),
                          size: 28,
                        ),
                        tooltip: 'Volver',
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(height: 10),

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
                          children: const [
                            Icon(
                              Icons.event,
                              color: Color.fromARGB(255, 23, 30, 32),
                              size: 22,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'DETALLE DE EVENTO',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Color.fromARGB(255, 23, 30, 32),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Nombre del evento
                      const Text(
                        'Nombre del evento',
                        style: TextStyle(
                          color: Color(0xFFE2BC65),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 79, 83, 83).withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(
                              0xFFE2BC65,
                            ).withValues(alpha: 0.4),
                            width: 1.0,
                          ),
                        ),
                        child: TextField(
                          controller: nombreController,
                          readOnly: !admin,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Nombre del evento',
                            hintStyle: const TextStyle(color: Colors.black54),
                            border: InputBorder.none,
                            suffixIcon: admin
                                ? const Icon(
                                    Icons.edit,
                                    color: Color(0xFF0F4C5C),
                                    size: 18,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      Center(
                        child: Image.asset(
                          'assets/images/fondo_login.png',
                          height: 120,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Calendario estilizado
                      const Text(
                        'Fecha del evento',
                        style: TextStyle(
                          color: Color(0xFFE2BC65),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(
                              0xFFE2BC65,
                            ).withValues(alpha: 0.4),
                            width: 1.0,
                          ),
                        ),
                        child: IgnorePointer(
                          ignoring: !admin,
                          child: CalendarDatePicker(
                            initialDate: fechaElegida,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                            onDateChanged: (DateTime fecha) {
                              setState(() => fechaElegida = fecha);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Hora
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Hora: ${horaElegida.format(context)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (admin)
                            OutlinedButton.icon(
                              onPressed: elegirHora,
                              icon: const Icon(
                                Icons.access_time,
                                color: Color(0xFFE2BC65),
                                size: 18,
                              ),
                              label: const Text(
                                'Cambiar Hora',
                                style: TextStyle(color: Color(0xFFE2BC65)),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFE2BC65),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Lugar
                      const Text(
                        'Lugar del evento',
                        style: TextStyle(
                          color: Color(0xFFE2BC65),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 73, 76, 77).withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(
                              0xFFE2BC65,
                            ).withValues(alpha: 0.4),
                            width: 1.0,
                          ),
                        ),
                        child: TextField(
                          controller: lugarController,
                          readOnly: !admin,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            suffixIcon: admin
                                ? const Icon(
                                    Icons.edit,
                                    color: Color(0xFF0F4C5C),
                                    size: 18,
                                  )
                                : null,
                          ),
                        ),
                      ),

                      if (admin) ...[
                        const SizedBox(height: 25),
                        Center(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE2BC65),
                              foregroundColor: const Color.fromARGB(
                                255,
                                23,
                                30,
                                32,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 3,
                            ),
                            onPressed: guardarEvento,
                            icon: const Icon(Icons.save),
                            label: const Text(
                              'Guardar',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 25),

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
              BotonChatFlotante(onPressed: () => _abrirAsistenteIA(context)),
            ],
          ),
        ),
      ),
    );
  }
}

class ListaEventosUsuario extends StatefulWidget {
  const ListaEventosUsuario({super.key});

  @override
  State<ListaEventosUsuario> createState() => _ListaEventosUsuarioState();
}

class _ListaEventosUsuarioState extends State<ListaEventosUsuario> {
  late Future<List<Map<String, dynamic>>> _eventos;

  @override
  void initState() {
    super.initState();
    _eventos = EventosApi.listar();
  }

  void _abrirAsistenteIA(BuildContext context) {
    showDialog(context: context, builder: (_) => const ChatBandaModal());
  }

  Future<void> _recargar() async {
    setState(() => _eventos = EventosApi.listar());
    await _eventos;
  }

  DateTime _fecha(Map<String, dynamic> evento) =>
      DateTime.tryParse(evento['fecha_evento']?.toString() ?? '') ??
      DateTime.now();

  TimeOfDay _hora(Map<String, dynamic> evento) {
    final partes = (evento['hora_evento']?.toString() ?? '').split(':');
    if (partes.length < 2) return const TimeOfDay(hour: 20, minute: 0);
    return TimeOfDay(
      hour: int.tryParse(partes[0]) ?? 20,
      minute: int.tryParse(partes[1]) ?? 0,
    );
  }

  String _fechaLegible(DateTime fecha) =>
      '${fecha.day}/${fecha.month}/${fecha.year}';

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
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 63, 70, 71).withValues(alpha: 0.75), // 🌟 Fondo translúcido unificado
                    borderRadius: BorderRadius.circular(24.0),
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
                            tooltip: 'Actualizar eventos',
                            onPressed: _recargar,
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
                          children: const [
                            Icon(
                              Icons.event_note,
                              color: Color.fromARGB(255, 23, 30, 32),
                              size: 22,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'EVENTOS Y PRESENTACIONES',
                              style: TextStyle(
                                fontSize: 15,
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
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          future: _eventos,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFE2BC65),
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'No se pudieron cargar los eventos.',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    TextButton.icon(
                                      onPressed: _recargar,
                                      icon: const Icon(
                                        Icons.refresh,
                                        color: Color(0xFFE2BC65),
                                      ),
                                      label: const Text(
                                        'Reintentar',
                                        style: TextStyle(
                                          color: Color(0xFFE2BC65),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            final eventos = snapshot.data ?? [];
                            if (eventos.isEmpty) {
                              return const Center(
                                child: Text(
                                  'Aún no hay eventos publicados.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white70),
                                ),
                              );
                            }

                            return ListView.separated(
                              itemCount: eventos.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final evento = eventos[index];
                                final fecha = _fecha(evento);
                                final hora = _hora(evento);
                                final lugar =
                                    evento['lugar_evento']?.toString() ??
                                    'Lugar por confirmar';

                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 129, 133, 133).withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(
                                        0xFFE2BC65,
                                      ).withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        evento['nombre_evento']?.toString() ??
                                            'Evento',
                                        style: const TextStyle(
                                          color: Color.fromARGB(221, 253, 250, 250),
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '📅 ${_fechaLegible(fecha)} · ⏰ ${hora.format(context)}',
                                        style: const TextStyle(
                                          color: Color.fromARGB(137, 241, 240, 240),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '📍 $lugar',
                                        style: const TextStyle(
                                          color: Color.fromARGB(137, 250, 247, 247),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
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
              BotonChatFlotante(onPressed: () => _abrirAsistenteIA(context)),
            ],
          ),
        ),
      ),
    );
  }
}
