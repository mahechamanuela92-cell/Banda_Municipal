import 'package:flutter/material.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
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
        content: Text(ok
            ? 'Listo, te recordaremos un día antes 🔔'
            : 'El evento es en menos de un día, ya no se puede programar el recordatorio'),
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
                              ? const Icon(Icons.edit,
                                  color: Colors.white, size: 18)
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
                                color: Colors.white, fontSize: 16),
                          ),
                          if (admin)
                            IconButton(
                              onPressed: elegirHora,
                              icon: const Icon(Icons.edit,
                                  color: Colors.white, size: 18),
                            ),
                        ],
                      ),

                      // Lugar
                      Row(
                        children: [
                          const Text(
                            'Lugar: ',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          Expanded(
                            child: TextField(
                              controller: lugarController,
                              readOnly: !admin,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                suffixIcon: admin
                                    ? const Icon(Icons.edit,
                                        color: Colors.white, size: 18)
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
                          icon: Icon(admin
                              ? Icons.save
                              : Icons.notifications_active),
                          label: Text(
                              admin ? 'Guardar' : 'Recuérdame un día antes'),
                        ),
                      ),
                    ],
                  ),
                ),

                // Texto por fuera del bloque oscuro
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
          ),
        ),
      ),
    );
  }
}