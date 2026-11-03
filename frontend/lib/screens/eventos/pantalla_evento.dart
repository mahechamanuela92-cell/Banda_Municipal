import 'package:flutter/material.dart';
import 'package:frontend/config/sesion.dart';
import 'package:frontend/services/eventos_api.dart';
import '../../themes/colores.dart';
import '../../widgets/fondos.dart';

class PantallaEventos extends StatefulWidget {
  const PantallaEventos({super.key});

  @override
  State<PantallaEventos> createState() => _PantallaEventosState();
}

class _PantallaEventosState extends State<PantallaEventos> {
  // Aquí guardamos lo que el usuario escribe o elige
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

  // Abre el reloj para escoger la hora
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
        title: const Text('Eliminar evento'),
        content: Text('¿Quieres eliminar "${evento['nombre_evento']}"?'),
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
                    tooltip: 'Volver',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                // Formulario para crear o editar eventos
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
                        'Administrar eventos',
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
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Nombre del evento',
                          hintStyle: TextStyle(color: Colors.white),
                          suffixIcon: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),

                      // Logo
                      Center(
                        child: Image.asset(
                          'assets/images/fondo_login.png',
                          height: 150,
                        ),
                      ),

                      // Calendario
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
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
                          Text(
                            'Hora: ${horaElegida.format(context)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
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
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                suffixIcon: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Guardar o cancelar
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colores.botonClaro,
                          ),
                          onPressed: guardando ? null : guardarEvento,
                          child: guardando
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  idEventoEditando == null
                                      ? 'Guardar evento'
                                      : 'Actualizar evento',
                                ),
                        ),
                      ),
                      if (idEventoEditando != null)
                        Center(
                          child: TextButton(
                            onPressed: guardando ? null : cancelarEdicion,
                            child: const Text('Cancelar edición'),
                          ),
                        ),
                      const Divider(color: Colors.white30, height: 36),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Eventos guardados',
                              style: TextStyle(
                                color: Colors.white,
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
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      if (cargandoEventos)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
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
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
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
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${etiquetaFecha(evento['fecha_evento'])} · ${parsearHora(evento['hora_evento']).format(context)} · ${evento['lugar_evento'] ?? 'Lugar por confirmar'}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
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
                                    color: Colors.white70,
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
                    ],
                  ),
                ),

                // 2. Texto ubicado POR FUERA del bloque oscuro
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
