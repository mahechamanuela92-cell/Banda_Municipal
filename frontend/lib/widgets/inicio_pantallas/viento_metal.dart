import 'package:flutter/material.dart';
import 'package:frontend/themes/colores.dart';
import 'package:frontend/widgets/fondos.dart';
import 'package:frontend/widgets/inicio_pantallas/intrumentos-metal/bombardino.dart';
import 'package:frontend/widgets/inicio_pantallas/intrumentos-metal/corneta.dart';
import 'package:frontend/widgets/inicio_pantallas/intrumentos-metal/fliscorno.dart';
import 'package:frontend/widgets/inicio_pantallas/intrumentos-metal/trombon.dart';
import 'package:frontend/widgets/inicio_pantallas/intrumentos-metal/tuba.dart';
import 'intrumentos-metal/trompeta.dart';

// Importación de componentes de los instrumentos de viento metal


class VientoMetalPantalla extends StatelessWidget {
  const VientoMetalPantalla({super.key});

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
                            "Viento- Metal",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontFamily: 'Serif',
                            ),
                          ),
                          children: [
                            // 1. Trompeta
                            TrompetaItem(),
                            //2. Fliscorno
                            FliscornoItem(),
                            //3. tuba
                            TubaItem(),
                            //4. Trombon
                            TrombonItem(),
                            //5. Corneta
                            CornetaItem(),
                            //6. bombardino
                            BombardinoItem(),
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