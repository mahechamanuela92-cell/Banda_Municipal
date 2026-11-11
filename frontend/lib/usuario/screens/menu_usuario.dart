import 'package:flutter/material.dart';
import 'eventos/eventos.dart';
import 'multimedia/multimedia.dart';
import 'perfil_usuario.dart';
import 'partituras/partituras_usuario.dart';


class MenuUsuarios extends StatelessWidget {
  const MenuUsuarios({super.key});

  Widget opcionMenu(BuildContext context, String texto, Widget? pantalla, IconData icono) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Icon(icono, color: const Color(0xFFE2BC65), size: 24), // 🌟 Icono en tono dorado sutil
      title: Text(
        texto,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white70,
        size: 14,
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

          // CAPA 2: cuadro translúcido principal con bordes dorados
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  width: 280, // Ajusta el ancho si prefieres que sea más compacto o déjalo adaptado
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 45, 51, 53).withValues(alpha: 0.85), // 🌟 Fondo translúcido oscuro unificado
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE2BC65).withValues(alpha: 0.6), // 🌟 Borde sutil dorado
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      opcionMenu(
                        context,
                        'Partituras',
                        const PartiturasUsuario(),
                        Icons.library_music,
                      ),
                      opcionMenu(
                        context,
                        'Multimedia',
                        const PantallaMultimedia(),
                        Icons.perm_media,
                      ),
                      opcionMenu(
                        context,
                        'Eventos - presentaciones',
                        const ListaEventosUsuario(),
                        Icons.event_note,
                      ),
                      opcionMenu(
                        context,
                        'Perfil',
                        const PantallaPerfil(),
                        Icons.person_pin,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}