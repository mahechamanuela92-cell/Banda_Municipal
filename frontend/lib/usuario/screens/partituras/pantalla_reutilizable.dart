import 'package:flutter/material.dart';
import '../../../themes/colores.dart';
import '../../../widgets/fondos.dart';
import '../pantalla_galeria_partituras.dart'; // Asegúrate de importar la pantalla de galería que creamos antes

class PantallaDetalleInstrumento extends StatelessWidget {
  final String nombreInstrumento;

  const PantallaDetalleInstrumento({
    super.key,
    required this.nombreInstrumento,
  });

  @override
  Widget build(BuildContext context) {
    // Lista fija con las 6 voces requeridas
    final List<String> voces = [
      'Voz 1',
      'Voz 2',
      'Voz 3',
      'Voz 4',
      'Voz 5',
      'Voz 6',
    ];

    return Scaffold(
      body: FondoBase(
        child: SafeArea(
          child: Column(
            children: [
              // Botón para volver atrás
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

              // Título del instrumento seleccionado
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    nombreInstrumento.toUpperCase(),
                    style: TextStyle(
                      color: Colores.amarillo,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              // Caja oscura con las 6 voces
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
                    itemCount: voces.length,
                    itemBuilder: (context, index) {
                      final voz = voces[index];
                      return ListTile(
                        title: Text(
                          voz,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Icon(
                          Icons.keyboard_arrow_right,
                          color: Colors.white70,
                        ),
                        onTap: () {
                          // Al hacer clic en la voz, navega a la galería pasando
                          // tanto el instrumento (ej. "Clarinete") como la voz (ej. "Voz 1")
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PantallaGaleriaPartituras(
                                nombreInstrumento: nombreInstrumento,
                                nombreVoz: voz,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              // Título inferior de la banda
              Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  'BANDA SINFONICA SAN MIGUEL\nGARZÓN HUILA',
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