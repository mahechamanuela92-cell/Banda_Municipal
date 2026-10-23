import 'package:flutter/material.dart';
import 'package:frontend/themes/colores.dart';
import 'package:frontend/widgets/fondos.dart';

// Importacion de componentes de los instrumentos
import 'instrumentos-madera/flautaTraversa.dart';
import 'instrumentos-madera/clarinete.dart';
import 'instrumentos-madera/fagot.dart';
import 'instrumentos-madera/flautaPicolo.dart';
import 'instrumentos-madera/oboe.dart';
import 'instrumentos-madera/saxofon.dart';

class VientoMaderaPantalla extends StatelessWidget {
  const VientoMaderaPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoBase(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colores.bloqueOscuro,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.orange, size: 30),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 10),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: const ExpansionTile(
                          iconColor: Colors.white,
                          collapsedIconColor: Colors.white,
                          title: Text(
                            "Viento- Madera",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontFamily: 'Serif',
                            ),
                          ),
                          children: [
                            // 1. Flauta Traversa
                            FlautaTraversaItem(),
                            // 2. Flauta Píccolo
                            FlautaPiccoloItem(),
                            //3. Clarinete
                            ClarineteItem(),
                            //4. Oboe
                            OboeItem(),
                            //5. Saxofon
                            SaxofonItem(),
                            //6. Fagot
                            FagotItem(),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Center(
                    child: Text(
                      "BANDA SINFÓNICA SAN MIGUEL DE GARZÓN",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFD3A456),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}