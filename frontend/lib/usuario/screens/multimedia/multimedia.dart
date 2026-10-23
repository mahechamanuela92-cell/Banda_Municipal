import 'package:flutter/material.dart';
import '../../../themes/colores.dart';
import '../../../widgets/fondos.dart';
import 'pantalla_galeria_multimedia.dart'; // La pantalla dinámica que crearemos abajo

class PantallaMultimedia extends StatelessWidget {
  const PantallaMultimedia({super.key});

  @override
  Widget build(BuildContext context) {
    // Opciones principales basadas en tu diseño
    final List<Map<String, String>> opciones = [
      {'titulo': 'Fotos', 'tipo': 'foto'},
      {'titulo': 'Videos', 'tipo': 'video'},
    ];

    return Scaffold(
      body: FondoBase(
        child: SafeArea(
          child: Column(
            children: [
              // Flecha para volver
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colores.naranja,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),

              // Título "Multimedia"
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Multimedia',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              // Caja oscura con las opciones de Fotos y Videos
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colores.cajaOscura,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListView.builder(
                    itemCount: opciones.length,
                    itemBuilder: (context, index) {
                      final opcion = opciones[index];
                      return ListTile(
                        title: Text(
                          '${opcion['titulo']}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Icon(
                          Icons.keyboard_arrow_right,
                          color: Colors.white70,
                        ),
                        onTap: () {
                          // Navega a la galería general pasando el tipo ('foto' o 'video')
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PantallaGaleriaMultimedia(
                                tituloSeccion: opcion['titulo']!,
                                tipoMultimedia: opcion['tipo']!,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              // Título inferior institucional
              Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  'BANDA SINFONICA SAN MIGUEL DE GARZÓN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colores.amarillo,
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