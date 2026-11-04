import 'package:flutter/material.dart';
import 'package:frontend/screens/inventario-partituras/detalle_instrumentos_voces.dart';
import '../../themes/colores.dart';
import '../../widgets/fondos.dart';// Importamos la segunda pantalla

class InventarioPartituras extends StatelessWidget {
  const InventarioPartituras({super.key});

  final List<String> instrumentos = const [
    'Flauta Traversa', 'Flauta Picolo', 'Clarinete', 'Saxófono',
    'Oboe', 'Fagot', 'Trompeta', 'Fliscorno', 'Trombón',
    'Bombardino', 'Tuba', 'Corneta', 'Violín', 'Viola',
    'Violonchelo', 'Contrabajo', 'Bombo', 'Redoblante',
    'Platillos', 'Batería', 'Glockenspiel', 'Timbales Sinfónicos',
    'Congas', 'Timbal'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoBase(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colores.naranja, size: 30),
                  tooltip: 'Volver',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Image.asset('assets/images/fondo_login.png', height: 120),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colores.bloqueOscuro,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'PARTITURAS',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: instrumentos.length,
                              itemBuilder: (context, index) {
                                final instrumento = instrumentos[index];
                                return TextButton(
                                  onPressed: () {
                                    // Navegamos a la Pantalla 2 enviando el instrumento seleccionado
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetalleInstrumentoVoices(instrumento: instrumento),
                                      ),
                                    );
                                  },
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      instrumento,
                                      style: const TextStyle(color: Colors.white70, fontSize: 18),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Text(
                  'BANDA SINFONICA SAN MIGUEL DE\nGARZÓN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colores.colorLetra1,
                    fontWeight: FontWeight.bold,
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