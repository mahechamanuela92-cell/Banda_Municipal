import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../themes/colores.dart';
import '../../widgets/fondos.dart';
import '../../config/api.dart'; // Asegúrate de tener tu URL base configurada aquí

class InventarioPartituras extends StatefulWidget {
  const InventarioPartituras({super.key});

  @override
  State<InventarioPartituras> createState() => _InventarioPartiturasState();
}

class _InventarioPartiturasState extends State<InventarioPartituras> {
  List<dynamic> partiturasRegistradas = [];
  List<String> tipos = ['PDF', 'Imagen', 'Word'];
  
  // Listas para instrumentos y voces
  final List<String> instrumentos = [
    'Flauta Traversa', 'Flauta Picolo', 'Clarinete', 'Saxófono',
    'Oboe', 'Fagot', 'Trompeta', 'Fliscorno', 'Trombón',
    'Bombardino', 'Tuba', 'Corneta', 'Violín', 'Viola',
    'Violonchelo', 'Contrabajo', 'Bombo', 'Redoblante',
    'Platillos', 'Batería', 'Glockenspiel', 'Timbales Sinfónicos',
    'Congas', 'Timbal'
  ];

  final List<String> voces = ['Voz 1', 'Voz 2', 'Voz 3', 'Voz 4', 'Voz 5', 'Voz 6', 'Voz 7'];

  bool mostrarLista = false;
  String? tipoElegido;
  String? nombreArchivo;
  String? instrumentoElegido;
  String? vozElegida;

  @override
  void initState() {
    super.initState();
    _obtenerPartiturasDesdeBackend();
  }

  // Función para obtener las partituras del backend
  Future<void> _obtenerPartiturasDesdeBackend() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/partituras'));
      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          partiturasRegistradas = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print('Error al conectar con el servidor: $e');
    }
  }

  // Abre los documentos del celular según el tipo
  void elegirArchivo(String tipo) async {
    List<String> extensiones = ['pdf'];
    if (tipo == 'Imagen') extensiones = ['jpg', 'jpeg', 'png'];
    if (tipo == 'Word') extensiones = ['doc', 'docx'];

    FilePickerResult? resultado = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensiones,
    );
    if (resultado != null) {
      setState(() => nombreArchivo = resultado.files.single.name);
    }
  }

  // Enviar partitura y categoría al backend
  Future<void> guardarEnBackend() async {
    if (nombreArchivo == null || instrumentoElegido == null || vozElegida == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor elige un archivo, un instrumento y una voz')),
      );
      return;
    }

    try {
      // 1. Guardamos la categoría de la partitura en el backend
      final responseCategoria = await http.post(
        Uri.parse('$apiUrl/partituras/categorias'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre_partitura': '$nombreArchivo ($instrumentoElegido)',
          'voz_partitura': vozElegida,
        }),
      );

      if (!mounted) return;

      if (responseCategoria.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Partitura guardada correctamente en la BD')),
        );
        Navigator.pop(context);
      } else {
        final errorData = jsonDecode(responseCategoria.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${errorData['error'] ?? 'No se pudo guardar'}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
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
                        padding: const EdgeInsets.only(top: 80),
                        child: Image.asset('assets/images/fondo_login.png', height: 180),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colores.bloqueOscuro,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Column(
                          children: [
                            const Text(
                              'Inventario de Partituras',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 200),

                            TextButton(
                              onPressed: () => setState(() => mostrarLista = !mostrarLista),
                              child: const Text(
                                'Lista ▾',
                                style: TextStyle(color: Colors.white, fontSize: 22),
                              ),
                            ),

                            Container(
                              width: double.infinity,
                              height: 180,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colores.botonClaro,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: mostrarLista
                                  ? ListView.builder(
                                      itemCount: partiturasRegistradas.length,
                                      itemBuilder: (context, index) {
                                        final partitura = partiturasRegistradas[index];
                                        final categoria = partitura['categorias_partituras'];
                                        final nombre = categoria != null ? categoria['nombre_partitura'] : 'Sin nombre';
                                        final voz = categoria != null ? categoria['voz_partitura'] : '';

                                        return ListTile(
                                          title: Text(nombre, style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold)),
                                          subtitle: Text('Voz: $voz', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                        );
                                      },
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 24),
                            
                            const Text('Agregar Documento', style: TextStyle(color: Colors.white, fontSize: 18)),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colores.botonClaro,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButton<String>(
                                value: tipoElegido,
                                hint: const Text('Subir archivo', style: TextStyle(color: Colors.black54)),
                                isExpanded: true,
                                underline: const SizedBox(),
                                dropdownColor: Colores.botonClaro,
                                items: [
                                  for (String tipo in tipos)
                                    DropdownMenuItem(value: tipo, child: Text(tipo)),
                                ],
                                onChanged: (valor) {
                                  setState(() => tipoElegido = valor);
                                  elegirArchivo(valor!);
                                },
                              ),
                            ),
                            if (nombreArchivo != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Archivo: $nombreArchivo',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),

                            const SizedBox(height: 24),

                            const Text('Elegir Instrumento', style: TextStyle(color: Colors.white, fontSize: 18)),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colores.botonClaro,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButton<String>(
                                value: instrumentoElegido,
                                hint: const Text('Seleccionar instrumento', style: TextStyle(color: Colors.black54)),
                                isExpanded: true,
                                underline: const SizedBox(),
                                dropdownColor: Colores.botonClaro,
                                items: [
                                  for (String instrumento in instrumentos)
                                    DropdownMenuItem(value: instrumento, child: Text(instrumento)),
                                ],
                                onChanged: (valor) {
                                  setState(() => instrumentoElegido = valor);
                                },
                              ),
                            ),

                            const SizedBox(height: 24),

                            const Text('Seleccionar Voz', style: TextStyle(color: Colors.white, fontSize: 18)),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colores.botonClaro,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButton<String>(
                                value: vozElegida,
                                hint: const Text('Seleccionar voz', style: TextStyle(color: Colors.black54)),
                                isExpanded: true,
                                underline: const SizedBox(),
                                dropdownColor: Colores.botonClaro,
                                items: [
                                  for (String voz in voces)
                                    DropdownMenuItem(value: voz, child: Text(voz)),
                                ],
                                onChanged: (valor) {
                                  setState(() => vozElegida = valor);
                                },
                              ),
                            ),

                            const SizedBox(height: 40),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colores.botonClaro,
                                foregroundColor: Colores.bloqueOscuro,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: guardarEnBackend,
                              child: const Text('Guardar', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Text(
                  'BANDA SINFONICA SAN MIGUEL\nGARZÓN HUILA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
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