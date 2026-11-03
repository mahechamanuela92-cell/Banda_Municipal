import 'package:flutter/material.dart';
import 'package:frontend/services/eventos_api.dart';
import '../../servicios/servicios_noti.dart';
import '../../../themes/colores.dart';
import '../../../widgets/fondos.dart';

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

  // Abre el reloj para escoger la hora (solo admin)
  Future<void> elegirHora() async {
    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: horaElegida,
    );
    if (hora != null) setState(() => horaElegida = hora);
  }

  // SOLO ADMIN: guarda el evento
  void guardarEvento() {
    final String mensaje =
        '${nombreController.text} ${fechaElegida.day}/${fechaElegida.month}/${fechaElegida.year} '
        'a las ${horaElegida.format(context)} en ${lugarController.text}';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
    Navigator.pop(context);
  }

  // SOLO USUARIO: programa la notificación un día antes
  Future<void> recordarme() async {
    final DateTime fechaHora = DateTime(
      fechaElegida.year,
      fechaElegida.month,
      fechaElegida.day,
      horaElegida.hour,
      horaElegida.minute,
    );

    final bool ok = await ServicioNotificaciones.programarRecordatorio(
      id: fechaHora.millisecondsSinceEpoch.hashCode & 0x7FFFFFFF,
      titulo: 'Mañana: ${nombreController.text}',
      cuerpo:
          '${horaElegida.format(context)} en ${lugarController.text}. ¡No te lo pierdas!',
      fechaEvento: fechaHora,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Listo, te recordaremos un día antes 🔔'
              : 'El evento es en menos de un día, ya no se puede programar el recordatorio',
        ),
      ),
    );
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
          child: SingleChildScrollView(
            child: Column(
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

                // Recuadro oscuro con la información
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colores.bloqueOscuro,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Eventos',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Nombre del evento
                      TextField(
                        controller: nombreController,
                        readOnly: !admin,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Nombre del evento',
                          hintStyle: const TextStyle(color: Colors.white),
                          suffixIcon: admin
                              ? const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 18,
                                )
                              : null,
                        ),
                      ),

                      // Logo
                      Center(
                        child: Image.asset(
                          'assets/images/fondo_login.png',
                          height: 150,
                        ),
                      ),

                      // Calendario (el usuario solo lo ve)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
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
                          Text(
                            'Hora: ${horaElegida.format(context)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          if (admin)
                            IconButton(
                              onPressed: elegirHora,
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                        ],
                      ),

                      // Lugar
                      Row(
                        children: [
                          const Text(
                            'Lugar: ',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          Expanded(
                            child: TextField(
                              controller: lugarController,
                              readOnly: !admin,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                suffixIcon: admin
                                    ? const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 18,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Botón: Guardar (admin) / Recuérdame (usuario)
                      Center(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colores.botonClaro,
                          ),
                          onPressed: admin ? guardarEvento : recordarme,
                          icon: Icon(
                            admin ? Icons.save : Icons.notifications_active,
                          ),
                          label: Text(
                            admin ? 'Guardar' : 'Recuérdame un día antes',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Texto por fuera del bloque oscuro
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Text(
                    'BANDA SINFONICA SAN MIGUEL\nGARZÓN HUILA',
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

  Future<void> _recordarme(Map<String, dynamic> evento) async {
    final fecha = _fecha(evento);
    final hora = _hora(evento);
    final fechaHora = DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      hora.hour,
      hora.minute,
    );
    final nombre = evento['nombre_evento']?.toString() ?? 'Evento';
    final lugar = evento['lugar_evento']?.toString() ?? 'Lugar por confirmar';

    final programado = await ServicioNotificaciones.programarRecordatorio(
      id: fechaHora.millisecondsSinceEpoch.hashCode & 0x7FFFFFFF,
      titulo: 'Mañana: $nombre',
      cuerpo: '${hora.format(context)} en $lugar. ¡No te lo pierdas!',
      fechaEvento: fechaHora,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          programado
              ? 'Listo, te recordaremos un día antes'
              : 'No se pudo programar el recordatorio para este evento',
        ),
      ),
    );
  }

  String _fechaLegible(DateTime fecha) =>
      '${fecha.day}/${fecha.month}/${fecha.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoBase(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                child: Row(
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
                    const Expanded(
                      child: Text(
                        'Eventos y presentaciones',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Actualizar eventos',
                      onPressed: _recargar,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colores.bloqueOscuro,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _eventos,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Colores.amarillo,
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
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reintentar'),
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
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final evento = eventos[index];
                          final fecha = _fecha(evento);
                          final hora = _hora(evento);
                          final lugar =
                              evento['lugar_evento']?.toString() ??
                              'Lugar por confirmar';
                          final fechaHora = DateTime(
                            fecha.year,
                            fecha.month,
                            fecha.day,
                            hora.hour,
                            hora.minute,
                          );
                          final puedeRecordar = fechaHora.isAfter(
                            DateTime.now(),
                          );

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  evento['nombre_evento']?.toString() ??
                                      'Evento',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${_fechaLegible(fecha)} · ${hora.format(context)}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  lugar,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton.icon(
                                    onPressed: puedeRecordar
                                        ? () => _recordarme(evento)
                                        : null,
                                    icon: const Icon(
                                      Icons.notifications_active_outlined,
                                    ),
                                    label: Text(
                                      puedeRecordar
                                          ? 'Recuérdame'
                                          : 'Evento finalizado',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colores.botonClaro,
                                      foregroundColor: Colores.bloqueOscuro,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
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
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Text(
                  'BANDA SINFONICA SAN MIGUEL\nGARZÓN HUILA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colores.colorLetra1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
