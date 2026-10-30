import 'package:flutter/material.dart';
import 'package:frontend/themes/colores.dart';
import 'package:frontend/widgets/inicio_pantallas/cuerdas_pantallas.dart';
import 'package:frontend/widgets/inicio_pantallas/percusion_pantallas.dart';
import 'package:frontend/widgets/inicio_pantallas/viento_maderda_pantalla.dart';
import 'package:frontend/widgets/inicio_pantallas/viento_metal.dart';
import '../fondos.dart';

class InstrumentosPantalla extends StatelessWidget {
  const InstrumentosPantalla({super.key});

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
                color: Colores.bloqueOscuro,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.orange, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 10),

                Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFB3F0EC),
                        Color(0xFF8AE1DC),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(30.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(width: 10),
                      Text(
                        'NUESTRO INSTRUMENTOS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F4C5C),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: ListView(
                      children: [
                        _buildOpcionCategoria(
                          context: context,
                          titulo: 'Viento- Madera',
                          pantallaDestino: const VientoMaderaPantalla(),
                        ),
                        _buildOpcionCategoria(
                          context: context,
                          titulo: 'Viento- Metal',
                          pantallaDestino: const VientoMetalPantalla(),
                        ),
                        _buildOpcionCategoria(
                          context: context,
                          titulo: 'Cuerdas',
                          pantallaDestino: const CuerdasPantalla(),
                        ),
                        _buildOpcionCategoria(
                          context: context,
                          titulo: 'Percusión',
                          pantallaDestino: const PercusionPantalla(),
                        ),
                      ],
                    ),
                  ),

                  const Center(
                    child: Text(
                      "BANDA SINFONICA SAN MIGUEL\nGARZÓN HUILA",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFD3A456),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Nombre corregido sin tilde: _buildOpcionCategoria
  Widget _buildOpcionCategoria({
    required BuildContext context,
    required String titulo,
    required Widget pantallaDestino,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        titulo,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontFamily: 'Serif',
        ),
      ),
      trailing: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => pantallaDestino),
        );
      },
    );
  }
}