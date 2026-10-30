import 'package:flutter/material.dart';
import 'package:frontend/themes/colores.dart';
import 'package:frontend/widgets/fondos.dart';


// Importación de componentes de los instrumentos
import 'instrumentos-percusion/bombo.dart';
import 'instrumentos-percusion/redoblante.dart';
import 'instrumentos-percusion/platillos.dart';
import 'instrumentos-percusion/bateria.dart';
import 'instrumentos-percusion/congas.dart';
import 'instrumentos-percusion/timbal.dart';
import 'package:frontend/widgets/inicio_pantallas/instrumentos-percusion/glock.dart';
import 'package:frontend/widgets/inicio_pantallas/instrumentos-percusion/timbalesS.dart';

class PercusionPantalla extends StatelessWidget {
  const PercusionPantalla({super.key});

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
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.orange,
                      size: 30,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                        ),
                        child: const ExpansionTile(
                          iconColor: Colors.white,
                          collapsedIconColor: Colors.white,
                          title: Text(
                            "Percusión",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontFamily: 'Serif',
                            ),
                          ),

                          children: [
                            // 1. Bombo
                            BomboItem(),

                            // 2. Redoblante
                            RedoblanteItem(),

                            // 3. Platillos
                            PlatillosItem(),

                            // 4. Batería
                            BateriaItem(),

                            // 5. Glockenspiel
                            GlockenspielItem(),

                            // 6. Timbales Sinfónicos
                            TimbalesSinfonicosItem(),

                            // 7. Congas
                            CongasItem(),

                            // 8. Timbal
                            TimbalItem(),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Center(
                    child: Text(
                      "BANDA SINFONICA SAN MIGUEL\nGARZÓN HUILA",
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