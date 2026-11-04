import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart'; // Útil para abrir/descargar archivos externos si usas URLs
import '../../themes/colores.dart';
import '../../widgets/fondos.dart';
import '../../config/api.dart';

class ListaPartiturasScreen extends StatefulWidget {
  final String instrumento;
  final String voz;

  const ListaPartiturasScreen({super.key, required this.instrumento, required this.voz});

  @override
  State<ListaPartiturasScreen> createState() => _ListaPartiturasScreenState();
}

class _ListaPartiturasScreenState extends State<ListaPartiturasScreen> {
  List<dynamic> partituras = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarPartiturasFiltradas();
  }

  Future<void> _cargarPartiturasFiltradas() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/partituras'));
      if (response.statusCode == 200) {
        List<dynamic> todas = jsonDecode(response.body);
        
        // Filtramos asegurando coincidencia de voz y que el nombre incluya el instrumento
        setState(() {
          partituras = todas.where((item) {
            final cat = item['categorias_partituras'];
            if (cat == null) return false;
            
            final String nombrePartitura = (cat['nombre_partitura'] ?? '').toString().toLowerCase();
            final String vozPartitura = (cat['voz_partitura'] ?? '').toString().trim();
            
            final String instrumentoBuscado = widget.instrumento.toLowerCase();
            final String vozBuscada = widget.voz.trim();

            // Valida que la voz sea idéntica y el nombre contenga el instrumento
            bool coincideVoz = vozPartitura.toLowerCase() == vozBuscada.toLowerCase();
            bool coincideInstrumento = nombrePartitura.contains(instrumentoBuscado);

            return coincideVoz && coincideInstrumento;
          }).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

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
                          widget.voz.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator(color: Colors.white))
                            : partituras.isEmpty
                                ? const Center(
                                    child: Text('No hay partituras para esta voz',
                                        style: TextStyle(color: Colors.white70)),
                                  )
                                : GridView.builder(
                                    padding: const EdgeInsets.all(12),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 0.8,
                                    ),
                                    itemCount: partituras.length,
                                    itemBuilder: (context, index) {
                                      final partitura = partituras[index];
                                      final cat = partitura['categorias_partituras'];
                                      final nombre = cat != null ? cat['nombre_partitura'] : 'Partitura';
                                      
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colores.botonClaro,
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.insert_drive_file, size: 50, color: Colors.black87),
                                            const SizedBox(height: 8),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                              child: Text(
                                                nombre,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colores.bloqueOscuro,
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                              ),
                                              onPressed: () {
                                                // Aquí puedes manejar la lógica para ver en pantalla completa o descargar
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Abriendo partitura...')),
                                                );
                                              },
                                              child: const Text('Descargar', style: TextStyle(color: Colors.white, fontSize: 10)),
                                            ),
                                          ],
                                        ),
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