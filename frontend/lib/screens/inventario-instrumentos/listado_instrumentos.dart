import 'package:flutter/material.dart';
import 'package:frontend/components/chat/boton_chat_flotante.dart';
import 'package:frontend/components/chat/chat_banda_modal.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../themes/colores.dart';
import '../../widgets/fondos.dart';
import '../../config/api.dart';

class ListadoInstrumentosScreen extends StatefulWidget {
  const ListadoInstrumentosScreen({super.key});

  @override
  State<ListadoInstrumentosScreen> createState() => _ListadoInstrumentosScreenState();
}

class _ListadoInstrumentosScreenState extends State<ListadoInstrumentosScreen> {
  List<dynamic> instrumentosRegistrados = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _obtenerInstrumentosDesdeBackend();
  }

  Future<void> _obtenerInstrumentosDesdeBackend() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/instrumentos'));

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          instrumentosRegistrados = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar los instrumentos del servidor')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    }
  }

  void _abrirAsistenteIA(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const ChatBandaModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Aplanamos la estructura que viene del INNER JOIN del backend
    final Map<String, List<dynamic>> instrumentosAgrupados = {};
    
    for (var instrumento in instrumentosRegistrados) {
      final serial = instrumento['numero_serial'] ?? 'N/A';
      final detalles = instrumento['listado_instrumentos'];

      if (detalles != null) {
        List<dynamic> listaDetalle = detalles is List ? detalles : [detalles];

        for (var detalle in listaDetalle) {
          final nombre = detalle['nombre_de_instrumento'] ?? 'Desconocido';
          
          final itemConSerial = {
            ...detalle,
            'numero_serial': serial,
          };

          if (!instrumentosAgrupados.containsKey(nombre)) {
            instrumentosAgrupados[nombre] = [];
          }
          instrumentosAgrupados[nombre]!.add(itemConSerial);
        }
      }
    }

    return Scaffold(
      body: FondoBase(
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
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
                        icon: const Icon(Icons.arrow_back, color: Color(0xFFE2BC65), size: 28),
                        tooltip: 'Volver',
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(height: 10),

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
                              color: const Color.fromARGB(255, 99, 96, 96).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.list_alt, color: Color.fromARGB(255, 23, 30, 32), size: 22),
                            SizedBox(width: 10),
                            Text(
                              'LISTADO DE INSTRUMENTOS',
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

                      // Contenedor interno para la lista
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.55,
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator(color: Color(0xFFE2BC65)))
                            : instrumentosAgrupados.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No hay instrumentos registrados aún.',
                                      style: TextStyle(color: Colors.white70, fontSize: 16),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : ListView(
                                    children: instrumentosAgrupados.entries.map((entry) {
                                      final nombreInstrumento = entry.key;
                                      final listaDetalles = entry.value;

                                      return Theme(
                                        data: Theme.of(context).copyWith(dividerColor: const Color.fromARGB(0, 148, 144, 144)),
                                        child: ExpansionTile(
                                          title: Text(
                                            nombreInstrumento,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                          iconColor: const Color(0xFFE2BC65),
                                          collapsedIconColor: const Color(0xFFE2BC65),
                                          children: listaDetalles.map((detalle) {
                                            final estado = detalle['instrumento_en'] ?? 'N/A';
                                            final serial = detalle['numero_serial'] ?? 'N/A';
                                            
                                            String fechaFormateada = 'N/A';
                                            if (detalle['fecha_registro'] != null) {
                                              final fecha = DateTime.parse(detalle['fecha_registro']);
                                              fechaFormateada = "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}";
                                            }

                                            return Container(
                                              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: const Color.fromARGB(255, 63, 70, 71).withValues(alpha: 0.75),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: const Color(0xFFE2BC65).withValues(alpha: 0.3),
                                                  width: 1.0,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      estado,
                                                      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      serial,
                                                      style: const TextStyle(color: Colors.black54),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      fechaFormateada,
                                                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                                                      textAlign: TextAlign.end,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                      ),
                      const SizedBox(height: 20),

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

              // Chatbot flotante arrastrable
              BotonChatFlotante(
                onPressed: () => _abrirAsistenteIA(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}