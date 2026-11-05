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
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 63, 70, 71).withValues(alpha: 0.75), // 🌟 Fondo translúcido unificado
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(
                  color: const Color(0xFFE2BC65).withValues(alpha: 0.5), // 🌟 Borde sutil dorado
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Botón de regresar unificado en dorado
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFFE2BC65),
                      size: 28,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),

                  const SizedBox(height: 10),

                  // Título superior con degradado unificado
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFE2BC65),
                          Color(0xFFC29B45),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(30.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.album, color: Color.fromARGB(255, 23, 30, 32), size: 22),
                        SizedBox(width: 10),
                        Text(
                          'PERCUSIÓN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color.fromARGB(255, 23, 30, 32),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Contenido con ExpansionTile estilizado
                  Expanded(
                    child: SingleChildScrollView(
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          iconColor: const Color(0xFFE2BC65),
                          collapsedIconColor: const Color(0xFFE2BC65),
                          title: const Text(
                            "Ver Instrumentos",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          children: const [
                            SizedBox(height: 10),
                            // 1. Bombo
                            BomboItem(),
                            SizedBox(height: 8),
                            // 2. Redoblante
                            RedoblanteItem(),
                            SizedBox(height: 8),
                            // 3. Platillos
                            PlatillosItem(),
                            SizedBox(height: 8),
                            // 4. Batería
                            BateriaItem(),
                            SizedBox(height: 8),
                            // 5. Glockenspiel
                            GlockenspielItem(),
                            SizedBox(height: 8),
                            // 6. Timbales Sinfónicos
                            TimbalesSinfonicosItem(),
                            SizedBox(height: 8),
                            // 7. Congas
                            CongasItem(),
                            SizedBox(height: 8),
                            // 8. Timbal
                            TimbalItem(),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Pie de página institucional unificado
                  const Center(
                    child: Text(
                      "BANDA SINFONICA SAN MIGUEL\nGARZÓN HUILA",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFE2BC65),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
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