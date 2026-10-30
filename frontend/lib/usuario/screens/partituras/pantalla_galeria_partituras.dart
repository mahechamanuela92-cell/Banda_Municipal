import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../themes/colores.dart';
import '../../../widgets/fondos.dart';
import '../../../config/api.dart'; // Asegúrate de que apunte a tu archivo de configuración de la URL base

class PantallaGaleriaPartituras extends StatefulWidget {
  final String nombreInstrumento;
  final String nombreVoz;

  const PantallaGaleriaPartituras({
    super.key,
    required this.nombreInstrumento,
    required this.nombreVoz,
  });

  @override
  State<PantallaGaleriaPartituras> createState() => _PantallaGaleriaPartiturasState();
}

class _PantallaGaleriaPartiturasState extends State<PantallaGaleriaPartituras> {
  List<dynamic> partiturasFiltradas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarPartiturasGaleria();
  }

  // Petición al backend para filtrar las partituras por instrumento y voz
  Future<void> _cargarPartiturasGaleria() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/partituras'));

      if (!mounted) return;

      print('Código de respuesta galería: ${response.statusCode}');
      print('Cuerpo recibido en galería: ${response.body}'); // <-- MIRA LA CONSOLA DE DEPURACIÓN

      if (response.statusCode == 200) {
        final List<dynamic> todas = jsonDecode(response.body);

        setState(() {
          // Temporalmente mostramos TODO sin filtrar para verificar que se conecte
          partiturasFiltradas = todas;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error en galería: $e');
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
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // Título superior indicando la voz y el instrumento
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${widget.nombreVoz} - ${widget.nombreInstrumento}'.toUpperCase(),
                    style: TextStyle(
                      color: Colores.amarillo,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              // Contenedor principal donde se listan las partituras encontradas
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colores.cajaOscura,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : partiturasFiltradas.isEmpty
                          ? const Center(
                              child: Text(
                                'No hay partituras disponibles para esta voz todavía.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white70, fontSize: 16),
                              ),
                            )
                          : ListView.builder(
                              itemCount: partiturasFiltradas.length,
                              itemBuilder: (context, index) {
                                final item = partiturasFiltradas[index];
                                final categoria = item['categorias_partituras'];
                                final nombreArchivo = categoria['nombre_partitura'] ?? 'Partitura sin nombre';

                                return Card(
                                  color: Colores.botonClaro,
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                                    title: Text(
                                      nombreArchivo,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    trailing: const Icon(Icons.remove_red_eye, color: Colors.black54),
                                    onTap: () {
                                      // Aquí puedes agregar la lógica para abrir el archivo o visualizarlo si lo deseas
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Abriendo: $nombreArchivo')),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                ),
              ),

              // Título inferior de la banda
              const Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  'BANDA SINFONICA SAN MIGUEL\nGARZÓN HUILA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
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