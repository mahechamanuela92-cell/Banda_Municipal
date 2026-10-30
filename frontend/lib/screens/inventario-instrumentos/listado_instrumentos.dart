import 'package:flutter/material.dart';
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

  Widget texto(String t, double size, {bool negrita = false, Color color = Colors.white}) => Text(
        t,
        textAlign: TextAlign.center,
        style: TextStyle(color: color, fontSize: size, fontWeight: negrita ? FontWeight.bold : FontWeight.normal),
      );

  Widget espacio(double h) => SizedBox(height: h);

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
              texto('Listado de Instrumentos', 24, negrita: true),
              espacio(16),
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colores.bloqueOscuro,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
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
                                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                  child: ExpansionTile(
                                    title: Text(
                                      nombreInstrumento,
                                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                                    ),
                                    iconColor: Colores.naranja,
                                    collapsedIconColor: Colors.white70,
                                    children: listaDetalles.map((detalle) {
                                      final estado = detalle['instrumento_en'] ?? 'N/A';
                                      final serial = detalle['numero_serial'] ?? 'N/A';
                                      
                                      String fechaFormateada = 'N/A';
                                      if (detalle['fecha_registro'] != null) {
                                        final fecha = DateTime.parse(detalle['fecha_registro']);
                                        fechaFormateada = "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}";
                                      }

                                      return Container(
                                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colores.botonClaro,
                                          borderRadius: BorderRadius.circular(12),
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
              ),
              espacio(20),
              texto('BANDA SINFONICA SAN MIGUEL\nGARZÓN HUILA', 18,
                  negrita: true, color: Colores.colorLetra1),
              espacio(16),
            ],
          ),
        ),
      ),
    );
  }
}