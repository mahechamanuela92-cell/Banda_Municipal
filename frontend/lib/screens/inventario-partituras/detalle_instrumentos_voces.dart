import 'package:flutter/material.dart';
import '../../themes/colores.dart';
import '../../widgets/fondos.dart';
import 'lista_partituras_screen.dart'; // Importamos la tercera pantalla

class DetalleInstrumentoVoices extends StatelessWidget {
  final String instrumento;

  const DetalleInstrumentoVoices({super.key, required this.instrumento});

  final List<String> voces = const ['Voz 1', 'Voz 2', 'Voz 3', 'Voz 4', 'Voz 5', 'Voz 6', 'Voz 7'];

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
                child: Container(
                  margin: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colores.bloqueOscuro,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          instrumento.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: voces.length,
                          itemBuilder: (context, index) {
                            final voz = voces[index];
                            return ListTile(
                              title: Text(voz, style: const TextStyle(color: Colors.white, fontSize: 18)),
                              trailing: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                              onTap: () {
                                // Navegamos a la Pantalla 3 pasando el instrumento y la voz seleccionada
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ListaPartiturasScreen(
                                      instrumento: instrumento,
                                      voz: voz,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
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