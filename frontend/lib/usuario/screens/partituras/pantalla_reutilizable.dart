import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../themes/colores.dart';
import '../../../widgets/fondos.dart';
import '../../../config/api.dart'; // Asegúrate de que apunte a tu archivo api.dart
import '../pantalla_galeria_partituras.dart';

class PantallaDetalleInstrumento extends StatefulWidget {
  final String nombreInstrumento;

  const PantallaDetalleInstrumento({
    super.key,
    required this.nombreInstrumento,
  });

  @override
  State<PantallaDetalleInstrumento> createState() => _PantallaDetalleInstrumentoState();
}

class _PantallaDetalleInstrumentoState extends State<PantallaDetalleInstrumento> {
  List<dynamic> partiturasDelInstrumento = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarPartiturasDelServidor();
  }

  // Petición al backend para traer las partituras registradas
  Future<void> _cargarPartiturasDelServidor() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/partituras'));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> todasLasPartituras = jsonDecode(response.body);

        setState(() {
          partiturasDelInstrumento = todasLasPartituras.where((p) {
            final categoria = p['categorias_partituras'];
            if (categoria == null) return false;
            
            final nombrePartitura = (categoria['nombre_partitura'] ?? '').toString().toLowerCase();
            final instrumentoBuscado = widget.nombreInstrumento.toLowerCase();

            // Verificamos si incluye el nombre del instrumento (eliminando posibles tildes básicas si es necesario)
            return nombrePartitura.contains(instrumentoBuscado) || 
                   nombrePartitura.contains(instrumentoBuscado.replaceAll('ó', 'o').replaceAll('á', 'a'));
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
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
              // Botón para volver atrás
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colores.naranja,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),

              // Título del instrumento seleccionado
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.nombreInstrumento.toUpperCase(),
                    style: TextStyle(
                      color: Colores.amarillo,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              // Caja oscura con las partituras encontradas en la BD
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colores.cajaOscura,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : partiturasDelInstrumento.isEmpty
                          ? const Center(
                              child: Text(
                                'No hay partituras registradas para este instrumento.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white70, fontSize: 16),
                              ),
                            )
                          : ListView.builder(
                              itemCount: partiturasDelInstrumento.length,
                              itemBuilder: (context, index) {
                                final partitura = partiturasDelInstrumento[index];
                                final categoria = partitura['categorias_partituras'];
                                final nombreArchivo = categoria != 'Sin nombre' ? categoria['nombre_partitura'] : 'Partitura';
                                final voz = categoria['voz_partitura'] ?? 'Voz';

                                return ListTile(
                                  title: Text(
                                    '$nombreArchivo - $voz',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.keyboard_arrow_right,
                                    color: Colors.white70,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PantallaGaleriaPartituras(
                                          nombreInstrumento: widget.nombreInstrumento,
                                          nombreVoz: voz,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                ),
              ),

              // Título inferior de la banda
              Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  'BANDA SINFONICA SAN MIGUEL\nGARZÓN HUILA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colores.amarillo,
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