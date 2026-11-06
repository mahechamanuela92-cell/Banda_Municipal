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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color:const Color.fromARGB(255, 45, 51, 53).withValues(alpha: 0.85),  // 🌟 Fondo translúcido unificado
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
                    children: [
                      // Botón de regresar unificado
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFFE2BC65),
                            size: 28,
                          ),
                          tooltip: 'Volver',
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Título principal con degradado dorado unificado
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            '${widget.instrumento.toUpperCase()} - ${widget.voz.toUpperCase()}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color.fromARGB(255, 23, 30, 32),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Contenido de la galería
                      Expanded(
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator(color: Color(0xFFE2BC65)))
                            : partituras.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No hay partituras registradas',
                                      style: TextStyle(color: Colors.white70, fontSize: 15),
                                    ),
                                  )
                                : GridView.builder(
                                    padding: const EdgeInsets.all(4),
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
                                          color: const Color.fromARGB(255, 71, 74, 75).withValues(alpha: 0.85),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: const Color(0xFFE2BC65).withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.insert_drive_file, size: 38, color: Color(0xFFE2BC65)),
                                            const SizedBox(height: 8),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                              child: Text(
                                                nombre,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color.fromARGB(221, 255, 255, 255)),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFFE2BC65),
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                              ),
                                              onPressed: () {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Abriendo/Descargando partitura...')),
                                                );
                                              },
                                              child: const Text('Descargar', style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 11, fontWeight: FontWeight.bold)),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
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

              // Botón flotante del chatbot de la IA
              BotonChatFlotante(onPressed: () => _abrirAsistenteIA(context)),
            ],
          ),
        ),
      ),
    );
  }
}