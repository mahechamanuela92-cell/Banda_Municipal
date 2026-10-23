import 'package:flutter/material.dart';
import 'package:frontend/screens/eventos/pantalla_evento.dart';
import 'package:frontend/screens/multimedia/multimedia.dart';
import 'package:frontend/screens/pantalla_generar_codigo.dart';
import 'package:frontend/themes/colores.dart';
// Importaciones de tus pantallas
import 'inventario-partituras/inventario_partituras.dart';
import 'inventario-instrumentos/inventario_instrumentos.dart';
import 'pantalla_perfil.dart';
// TODO: Importa aquí tu pantalla de generar código cuando la crees, por ejemplo:
// import 'generar_codigo_pantalla.dart';

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
          navegador.push(
            MaterialPageRoute(builder: (context) => pantalla),
          );
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
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.pop(context),
            ),
          ),
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
                    opcionMenu(context, 'Inventario- Instrumentos', const InventarioInstrumentos()),
                    opcionMenu(context, 'Inventario- Partituras', const InventarioPartituras()),
                    opcionMenu(context, 'Multimedia', const MultimediaPantalla()),
                    opcionMenu(context, 'Eventos', const PantallaEventos()),
                    // --- NUEVA OPCIÓN PARA EL ADMIN ---
                    opcionMenu(context, 'Generar Código de Registro', const PantallaGenerarCodigo()),
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