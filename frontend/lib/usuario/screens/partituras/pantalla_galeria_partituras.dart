import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/components/chat/boton_chat_flotante.dart';
import 'package:frontend/components/chat/chat_banda_modal.dart';
import '../../../themes/colores.dart';
import '../../../widgets/fondos.dart';
import '../../../config/api.dart';

class PantallaGaleriaPartituras extends StatefulWidget {
  final String instrumento;
  final String voz;

  const PantallaGaleriaPartituras({super.key, required this.instrumento, required this.voz});

  @override
  State<PantallaGaleriaPartituras> createState() => _PantallaGaleriaPartiturasState();
}

class _PantallaGaleriaPartiturasState extends State<PantallaGaleriaPartituras> {
  List<dynamic> partituras = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarPartituras();
  }

  void _abrirAsistenteIA(BuildContext context) {
    showDialog(context: context, builder: (_) => const ChatBandaModal());
  }

  Future<void> _cargarPartituras() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/partituras'));
      if (response.statusCode == 200) {
        List<dynamic> todas = jsonDecode(response.body);
        setState(() {
          partituras = todas.where((item) {
            final cat = item['categorias_partituras'];
            if (cat == null) return false;
            final String nombre = (cat['nombre_partitura'] ?? '').toString().toLowerCase();
            final String vozPart = (cat['voz_partitura'] ?? '').toString().trim();
            return vozPart.toLowerCase() == widget.voz.toLowerCase() && nombre.contains(widget.instrumento.toLowerCase());
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
          child: Stack(
            children: [
              Column(
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
                              '${widget.instrumento}\n${widget.voz}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: isLoading
                                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                                : partituras.isEmpty
                                    ? const Center(child: Text('No hay partituras registradas', style: TextStyle(color: Colors.white70)))
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
                                                const Icon(Icons.insert_drive_file, size: 40, color: Colors.black87),
                                                const SizedBox(height: 8),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                  child: Text(
                                                    nombre,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colores.bloqueOscuro,
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                                  ),
                                                  onPressed: () {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Abriendo/Descargando partitura...')),
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
                ],
              ),
              BotonChatFlotante(onPressed: () => _abrirAsistenteIA(context)),
            ],
          ),
        ),
      ),
    );
  }
}