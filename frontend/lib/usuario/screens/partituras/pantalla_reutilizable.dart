import 'package:flutter/material.dart';
import '../../../themes/colores.dart';
import '../../../widgets/fondos.dart';
import 'pantalla_galeria_partituras.dart';

class PantallaReutilizable extends StatelessWidget {
  final String instrumento;
  const PantallaReutilizable({super.key, required this.instrumento});

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
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(12),
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
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: voces.length,
                          itemBuilder: (context, index) {
                            final voz = voces[index];
                            return ListTile(
                              title: Text(voz, style: const TextStyle(color: Colors.white, fontSize: 18)),
                              trailing: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PantallaGaleriaPartituras(
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
            ],
          ),
        ),
      ),
    );
  }
}