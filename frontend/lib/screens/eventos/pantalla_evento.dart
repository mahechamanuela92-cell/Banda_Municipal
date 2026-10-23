import 'package:flutter/material.dart';
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
  final TextEditingController lugarController =
      TextEditingController(text: 'Parque Principal');

  DateTime fechaElegida = DateTime.now();
  TimeOfDay horaElegida = const TimeOfDay(hour: 20, minute: 0);

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

  // Muestra un mensaje con los datos del evento y vuelve a la página principal
  void guardarEvento() {
    final String mensaje =
        '${nombreController.text} ${fechaElegida.day}/${fechaElegida.month}/${fechaElegida.year} '
        'a las ${horaElegida.format(context)} en ${lugarController.text}';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );

    // Vuelve a la página principal
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
    return Scaffold(
      body: FondoBase(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 1. Recuadro oscuro con el formulario
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
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Nombre del evento',
                          hintStyle: TextStyle(color: Colors.white),
                          suffixIcon: Icon(Icons.edit,
                              color: Colors.white, size: 18),
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
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                          onDateChanged: (DateTime fecha) {
                            fechaElegida = fecha;
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
                                color: Colors.white, fontSize: 16),
                          ),
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
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                suffixIcon: Icon(Icons.edit,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Botón guardar
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colores.botonClaro,
                          ),
                          onPressed: guardarEvento,
                          child: const Text('Guardar'),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Texto ubicado POR FUERA del bloque oscuro
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