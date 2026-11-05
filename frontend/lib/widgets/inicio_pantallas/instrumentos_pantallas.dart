import 'package:flutter/material.dart';
import 'package:frontend/widgets/inicio_pantallas/cuerdas_pantallas.dart';
import 'package:frontend/widgets/inicio_pantallas/percusion_pantallas.dart';
import 'package:frontend/widgets/inicio_pantallas/viento_maderda_pantalla.dart';
import 'package:frontend/widgets/inicio_pantallas/viento_metal.dart';
import '../fondos.dart';

class InstrumentosPantalla extends StatelessWidget {
  const InstrumentosPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, Object>> categorias = [
      {
        'titulo': 'Viento - Madera',
        'icono': Icons.air,
        'destino': const VientoMaderaPantalla(),
      },
      {
        'titulo': 'Viento - Metal',
        'icono': Icons.graphic_eq,
        'destino': const VientoMetalPantalla(),
      },
      {
        'titulo': 'Cuerdas',
        'icono': Icons.music_note,
        'destino': const CuerdasPantalla(),
      },
      {
        'titulo': 'Percusión',
        'icono': Icons.album,
        'destino': const PercusionPantalla(),
      },
    ];

    return Scaffold(
      body: FondoBase(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(
                  255,
                  63,
                  70,
                  71,
                ).withValues(alpha: 0.75), // Estilo translúcido unificado
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(
                  color: const Color(
                    0xFFE2BC65,
                  ).withValues(alpha: 0.5), // Borde dorado sutil
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
                  // Botón de regresar unificado
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFFE2BC65),
                      size: 28,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 10),

                  // Título principal con degradado unificado
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE2BC65), Color(0xFFC29B45)],
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
                        Icon(
                          Icons.piano,
                          color: Color.fromARGB(255, 23, 30, 32),
                          size: 22,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'NUESTROS INSTRUMENTOS',
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
                  const SizedBox(height: 20),

                  // Lista de categorías con diseño de tarjetas unificado
                  Expanded(
                    child: ListView.builder(
                      itemCount: categorias.length,
                      itemBuilder: (context, index) {
                        final cat = categorias[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14.0),
                          child: _buildOpcionCategoria(
                            context: context,
                            titulo: cat['titulo'] as String,
                            icono: cat['icono'] as IconData,
                            pantallaDestino: cat['destino'] as Widget,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Pie de página institucional
                  const Center(
                    child: Text(
                      "BANDA SINFONICA SAN MIGUEL\nGARZÓN HUILA",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFE2BC65),
                        fontSize: 16,
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

  // Método auxiliar para crear cada tarjeta de categoría con estilo unificado
  Widget _buildOpcionCategoria({
    required BuildContext context,
    required String titulo,
    required IconData icono,
    required Widget pantallaDestino,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 74, 82, 83).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: const Color(0xFFE2BC65).withValues(alpha: 0.4),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => pantallaDestino),
            );
          },
          borderRadius: BorderRadius.circular(20.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18.0,
              vertical: 16.0,
            ),
            child: Row(
              children: [
                Icon(icono, color: const Color(0xFFE2BC65), size: 26),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFFE2BC65),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
