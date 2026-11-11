import 'package:flutter/material.dart';
import 'package:frontend/config/sesion.dart';
import 'package:frontend/services/eventos_api.dart';
import '../../widgets/fondos.dart';
import '../../components/chat/boton_chat_flotante.dart';
import '../../components/chat/chat_banda_modal.dart';

class PantallaEventos extends StatefulWidget {
  const PantallaEventos({super.key});

  @override
  State<PantallaEventos> createState() => _PantallaEventosState();
}

class _PantallaEventosState extends State<PantallaEventos> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController lugarController = TextEditingController(
    text: 'Parque Principal',
  );

  DateTime fechaElegida = DateTime.now();
  TimeOfDay horaElegida = const TimeOfDay(hour: 20, minute: 0);
  List<Map<String, dynamic>> eventos = [];
  String? idEventoEditando;
  bool cargandoEventos = true;
  bool guardando = false;

  @override
  void initState() {
    super.initState();
    cargarEventos();
  }

  String formatearFecha(DateTime fecha) =>
      '${fecha.year.toString().padLeft(4, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';

  String etiquetaFecha(dynamic valor) {
    final fecha = parsearFecha(valor);
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  DateTime parsearFecha(dynamic valor) =>
      DateTime.tryParse(valor?.toString() ?? '') ?? DateTime.now();

  TimeOfDay parsearHora(dynamic valor) {
    final partes = (valor?.toString() ?? '').split(':');
    if (partes.length < 2) return const TimeOfDay(hour: 20, minute: 0);
    return TimeOfDay(
      hour: int.tryParse(partes[0]) ?? 20,
      minute: int.tryParse(partes[1]) ?? 0,
    );
  }

  Future<void> cargarEventos() async {
    setState(() => cargandoEventos = true);
    try {
      final resultado = await EventosApi.listar();
      if (!mounted) return;
      setState(() => eventos = resultado);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudieron cargar los eventos: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => cargandoEventos = false);
    }
  }

  Future<void> elegirHora() async {
    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: horaElegida,
    );
    if (hora != null) {
      setState(() {
        horaElegida = hora;
      });
    }
  }

  Future<void> guardarEvento() async {
    final token = Sesion.token;
    if (token == null || Sesion.rol != 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión como administrador')),
      );
      return;
    }
    if (nombreController.text.trim().isEmpty ||
        lugarController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa el nombre y el lugar del evento'),
        ),
      );
      return;
    }

    setState(() => guardando = true);
    try {
      await EventosApi.guardar(
        token: token,
        id: idEventoEditando,
        evento: {
          'nombre_evento': nombreController.text.trim(),
          'fecha_evento': formatearFecha(fechaElegida),
          'hora_evento':
              '${horaElegida.hour.toString().padLeft(2, '0')}:${horaElegida.minute.toString().padLeft(2, '0')}:00',
          'lugar_evento': lugarController.text.trim(),
        },
      );
      nombreController.clear();
      lugarController.text = 'Parque Principal';
      setState(() {
        fechaElegida = DateTime.now();
        horaElegida = const TimeOfDay(hour: 20, minute: 0);
        idEventoEditando = null;
      });
      await cargarEventos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento guardado correctamente')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo guardar el evento: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => guardando = false);
    }
  }

  void editarEvento(Map<String, dynamic> evento) {
    setState(() {
      idEventoEditando = evento['id_evento'].toString();
      nombreController.text = evento['nombre_evento']?.toString() ?? '';
      lugarController.text =
          evento['lugar_evento']?.toString() ?? 'Parque Principal';
      fechaElegida = parsearFecha(evento['fecha_evento']);
      horaElegida = parsearHora(evento['hora_evento']);
    });
  }

  Future<void> eliminarEvento(Map<String, dynamic> evento) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 63, 70, 71),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE2BC65), width: 1.2),
        ),
        title: const Text(
          'Eliminar evento',
          style: TextStyle(
            color: Color(0xFFE2BC65),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '¿Quieres eliminar "${evento['nombre_evento']}"?',
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
    if (confirmar != true || Sesion.token == null) return;

    try {
      await EventosApi.eliminar(
        id: evento['id_evento'].toString(),
        token: Sesion.token!,
      );
      await cargarEventos();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Evento eliminado')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo eliminar el evento: $error')),
        );
      }
    }
  }

  void cancelarEdicion() {
    setState(() {
      nombreController.clear();
      lugarController.text = 'Parque Principal';
      fechaElegida = DateTime.now();
      horaElegida = const TimeOfDay(hour: 20, minute: 0);
      idEventoEditando = null;
    });
  }

  @override
  void dispose() {
    nombreController.dispose();
    lugarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hoy = DateUtils.dateOnly(DateTime.now());
    final primeraFecha = fechaElegida.isBefore(hoy)
        ? DateUtils.dateOnly(fechaElegida)
        : hoy;
    return Scaffold(
      body: Stack(
        children: [
          FondoBase(
            child: SafeArea(
              child: SingleChildScrollView(
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
                      // Flecha para volver unificada
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
                              'ADMINISTRAR EVENTOS',
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
                          color: const Color.fromARGB(255, 72, 74, 75).withValues(alpha: 0.75),
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
                          style: const TextStyle(
                            color: Color.fromARGB(255, 248, 247, 247),
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Ej. Concierto de Gala',
                            hintStyle: TextStyle(color: Color.fromARGB(137, 255, 255, 255)),
                            border: InputBorder.none,
                            suffixIcon: Icon(
                              Icons.edit,
                              color: Color(0xFFE2BC65),
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Logo opcional
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
                        child: CalendarDatePicker(
                          initialDate: fechaElegida,
                          firstDate: primeraFecha,
                          lastDate: DateTime(2035),
                          onDateChanged: (DateTime fecha) {
                            setState(() => fechaElegida = fecha);
                          },
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
                              side: const BorderSide(color: Color(0xFFE2BC65)),
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
                          color: const Color.fromARGB(255, 76, 78, 78).withValues(alpha: 0.75),
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
                          style: const TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            suffixIcon: Icon(
                              Icons.edit,
                              color: Color(0xFFE2BC65),
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Botones de Guardar / Cancelar Edición
                      Center(
                        child: ElevatedButton(
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
                          onPressed: guardando ? null : guardarEvento,
                          child: guardando
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color.fromARGB(255, 23, 30, 32),
                                  ),
                                )
                              : Text(
                                  idEventoEditando == null
                                      ? 'Guardar evento'
                                      : 'Actualizar evento',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ),
                      if (idEventoEditando != null)
                        Center(
                          child: TextButton(
                            onPressed: guardando ? null : cancelarEdicion,
                            child: const Text(
                              'Cancelar edición',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),

                      const Divider(
                        color: Color(0xFFE2BC65),
                        height: 40,
                        thickness: 0.5,
                      ),

                      // Lista de Eventos Guardados
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Eventos guardados',
                              style: TextStyle(
                                color: Color(0xFFE2BC65),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Actualizar lista',
                            onPressed: cargandoEventos ? null : cargarEventos,
                            icon: const Icon(
                              Icons.refresh,
                              color: Color(0xFFE2BC65),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      if (cargandoEventos)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(
                              color: Color(0xFFE2BC65),
                            ),
                          ),
                        )
                      else if (eventos.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'Todavía no hay eventos registrados.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      else
                        for (final evento in eventos)
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 68, 71, 71).withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(
                                  0xFFE2BC65,
                                ).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        evento['nombre_evento']?.toString() ??
                                            'Evento',
                                        style: const TextStyle(
                                          color: Color.fromARGB(221, 255, 255, 255),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${etiquetaFecha(evento['fecha_evento'])} · ${parsearHora(evento['hora_evento']).format(context)} · ${evento['lugar_evento'] ?? 'Lugar por confirmar'}',
                                        style: const TextStyle(
                                          color: Color.fromARGB(137, 255, 255, 255),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Editar evento',
                                  onPressed: guardando
                                      ? null
                                      : () => editarEvento(evento),
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Color(0xFFE2BC65),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Eliminar evento',
                                  onPressed: guardando
                                      ? null
                                      : () => eliminarEvento(evento),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
            ),
          ),

          // Botón flotante de la IA
          BotonChatFlotante(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const ChatBandaModal(),
              );
            },
          ),
        ],
      ),
    );
  }
}
