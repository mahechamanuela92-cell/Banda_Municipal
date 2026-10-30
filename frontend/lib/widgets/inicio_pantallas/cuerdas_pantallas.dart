import 'package:flutter/material.dart';
import 'package:frontend/themes/colores.dart';
import 'package:frontend/widgets/fondos.dart';
import 'package:frontend/widgets/inicio_pantallas/instrumentos-cuerda/contrabajo.dart';
import 'package:frontend/widgets/inicio_pantallas/instrumentos-cuerda/viola.dart';
import 'package:frontend/widgets/inicio_pantallas/instrumentos-cuerda/violonchelo.dart';

// Importación de componentes de instrumentos de cuerda
import 'instrumentos-cuerda/violin.dart';
class CuerdasPantalla extends StatelessWidget {
  const CuerdasPantalla({super.key});

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
                            "Cuerdas",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontFamily: 'Serif',
                            ),
                          ),
                          children: [
                            // 1. Violín
                            ViolinItem(),
                            // 2. Viola
                            ViolaItem(),
                            //3. violonvhelo
                            VioloncheloItem(),
                            //4. Contrabajo
                            ContrabajoItem(),
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