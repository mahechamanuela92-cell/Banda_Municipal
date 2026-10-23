import 'package:flutter/material.dart';
import '../../../themes/colores.dart';
import '../../../widgets/fondos.dart';
import 'pantalla_reutilizable.dart';

class PantallaPartitura extends StatelessWidget {
  const PantallaPartitura({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista completa de instrumentos basada en tu imagen
    final List<String> instrumentos = [
      'Flauta Traversa',
      'Flauta Picolo',
      'Clarinete',
      'Saxofón',
      'Oboe',
      'Fagot',
      'Trompeta',
      'Fliscorno',
      'Trombón',
      'Bombardino',
      'Tuba',
      'Corneta',
      'Violín',
      'Viola',
      'Violonchelo',
      'Contrabajo',
      'Bombo',
      'Redoblante',
      'Platillos',
      'Batería',
      'Glockenspiel',
      'Timbales Sinfónicos',
      'Congas',
      'Timbal',
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

              // Título "PARTITURAS"
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'PARTITURAS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              // Caja oscura con la lista de instrumentos
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colores.cajaOscura,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListView.builder(
                    itemCount: instrumentos.length,
                    itemBuilder: (context, index) {
                      final instrumento = instrumentos[index];
                      return ListTile(
                        title: Text(
                          instrumento,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        onTap: () {
                          // Navega a la pantalla reutilizable pasando el instrumento seleccionado
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PantallaDetalleInstrumento(
                                nombreInstrumento: instrumento,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              // Título de abajo
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