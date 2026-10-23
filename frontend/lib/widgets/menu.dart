import 'package:flutter/material.dart';
import 'package:frontend/screens/eventos/pantalla_evento.dart';
import 'package:frontend/screens/inventario-instrumentos/inventario_instrumentos.dart';
import 'package:frontend/screens/inventario-partituras/inventario_partituras.dart';
import 'package:frontend/screens/multimedia/multimedia.dart';
import 'package:frontend/screens/pantalla_perfil.dart';
import 'package:frontend/themes/colores.dart';
// TODO: Importa aquí tu pantalla de generar código cuando la crees

class MenuUsuario extends StatelessWidget {
  const MenuUsuario({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colores.bloqueOscuro,
      elevation: 0,
      width: 300,
      child: SafeArea(
        child: Align(
          alignment: Alignment.topLeft,
          child: Container(
            margin: const EdgeInsets.only(top: 8, left: 8),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colores.bloqueOscuro,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              children: [
                _item(context, 'Inventario- Instrumentos',
                    const InventarioInstrumentos()),
                _item(context, 'Inventario- Partituras',
                    const InventarioPartituras()),
                _item(context, 'Multimedia', 
                    const MultimediaPantalla()),
                _item(context, 'Eventos',
                    const PantallaEventos()),
                // --- NUEVA OPCIÓN PARA EL ADMIN ---
                _item(context, 'Generar Código de Registro', null), // Cambia 'null' por la pantalla destino cuando la tengas
                _item(context, 'Perfil', const PantallaPerfil()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, String texto, Widget? destino) {
    return ListTile(
      leading: const Icon(Icons.music_note, color: Colors.white),
      title: Text(
        texto,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      trailing: const SizedBox(width: 24),
      onTap: () {
        Navigator.pop(context); // Cierra el Drawer

        if (destino != null) {
          Future.microtask(() {
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => destino),
              );
            }
          });
        }
      },
    );
  }
}