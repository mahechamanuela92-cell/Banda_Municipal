import 'package:flutter/material.dart';
import 'eventos/eventos.dart';
import 'multimedia/multimedia.dart';
import 'perfil_usuario.dart';
import 'partituras/partituras_usuario.dart';
import '../../themes/colores.dart';

class MenuUsuario extends StatelessWidget {
  const MenuUsuario({super.key});

  Widget opcionMenu(BuildContext context, String texto, Widget? pantalla) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: const Icon(Icons.music_note, color: Colors.white, size: 28),
      title: Text(
        texto,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
      ),
      onTap: () {
        final navegador = Navigator.of(context);
        navegador.pop(); // cierra el menú
        if (pantalla != null) {
          navegador.push(MaterialPageRoute(builder: (context) => pantalla));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // CAPA 1: al tocar fuera del cuadro se cierra el menú
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.pop(context),
            ),
          ),

          // CAPA 2: cuadro oscuro con las opciones
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colores.bloqueOscuro,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    opcionMenu(context, 'Partituras', const PantallaPartitura()),
                    opcionMenu(context, 'multimedia', const PantallaMultimedia()),
                    opcionMenu(
                      context,
                      'Eventos - presentaciones',
                      PantallaEventos(
                        esAdmin: false,
                        nombreEvento: 'Concierto de Gala',
                        fechaEvento: DateTime(2026, 11, 15),
                        horaEvento: const TimeOfDay(hour: 19, minute: 30),
                        lugarEvento: 'Parque Principal',
                      ),
                    ),
                    opcionMenu(context, 'Perfil', const PantallaPerfil()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}