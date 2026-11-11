import 'package:flutter/material.dart';
import 'package:frontend/config/sesion.dart';
import 'package:frontend/screens/eventos/pantalla_evento.dart';
import 'package:frontend/screens/multimedia/multimedia.dart';
import 'package:frontend/screens/pantalla_generar_codigo.dart';

import 'inventario-partituras/inventario_partituras.dart';
import 'inventario-instrumentos/inventario_instrumentos.dart';
import 'pantalla_perfil.dart';

class MenuUsuario extends StatelessWidget {
  const MenuUsuario({super.key});

  Widget opcionMenu(BuildContext context, String texto, Widget? pantalla, IconData icono) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(
        icono, 
        color: const Color(0xFFE2BC65), // Iconos en tono dorado elegante
        size: 26,
      ),
      title: Text(
        texto,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      onTap: () {
        final navegador = Navigator.of(context);
        navegador.pop();
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
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 63, 70, 71).withValues(alpha: 0.75), // Fondo oscuro translúcido unificado
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFE2BC65).withValues(alpha: 0.5), // Borde dorado sutil
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    opcionMenu(
                      context,
                      'Inventario - Instrumentos',
                      const InventarioInstrumentos(),
                      Icons.piano, // Icono representativo de instrumentos
                    ),
                    opcionMenu(
                      context,
                      'Inventario - Partituras',
                      const InventarioPartituras(),
                      Icons.library_music, // Icono representativo de partituras/música
                    ),
                    opcionMenu(
                      context,
                      'Multimedia',
                      const MultimediaPantalla(),
                      Icons.perm_media, // Icono multimedia / videos / fotos
                    ),
                    opcionMenu(
                      context,
                      'Eventos',
                      const PantallaEventos(),
                      Icons.event, // Icono de calendario / eventos
                    ),
                    if (Sesion.rol == 'admin')
                      opcionMenu(
                        context,
                        'Generar Código de Registro',
                        const PantallaGenerarCodigo(),
                        Icons.qr_code_rounded, // Icono de códigos QR / registro
                      ),
                    opcionMenu(
                      context,
                      'Perfil',
                      const PantallaPerfil(),
                      Icons.person_outline, // Icono de perfil de usuario
                    ),
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
