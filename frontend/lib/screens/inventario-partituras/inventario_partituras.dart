import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:frontend/components/chat/boton_chat_flotante.dart';
import 'package:frontend/components/chat/chat_banda_modal.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../themes/colores.dart';
import '../../widgets/fondos.dart';
import '../../config/api.dart';

class InventarioPartituras extends StatefulWidget {
  const InventarioPartituras({super.key});

  @override
  State<InventarioPartituras> createState() => _InventarioPartiturasState();
}

class _InventarioPartiturasState extends State<InventarioPartituras> {
  List<String> tipos = ['PDF', 'Imagen', 'Word'];
  
  final List<String> instrumentos = [
    'Flauta Traversa', 'Flauta Picolo', 'Clarinete', 'Saxófono',
    'Oboe', 'Fagot', 'Trompeta', 'Fliscorno', 'Trombón',
    'Bombardino', 'Tuba', 'Corneta', 'Violín', 'Viola',
    'Violonchelo', 'Contrabajo', 'Bombo', 'Redoblante',
    'Platillos', 'Batería', 'Glockenspiel', 'Timbales Sinfónicos',
    'Congas', 'Timbal'
  ];

  final List<String> voces = ['Voz 1', 'Voz 2', 'Voz 3', 'Voz 4', 'Voz 5', 'Voz 6', 'Voz 7'];

  String? tipoElegido;
  String? nombreArchivo;
  String? instrumentoElegido;
  String? vozElegida;

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

  void _abrirAsistenteIA(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const ChatBandaModal(),
    );
  }

  Future<void> guardarEnBackend() async {
    if (nombreArchivo == null || instrumentoElegido == null || vozElegida == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor elige un archivo, un instrumento y una voz')),
      );
      return;
    }

    try {
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
          child: Stack(
            children: [
              Column(
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
                                  'Subir Partitura (Admin)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 40),

                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('Tipo de archivo', style: TextStyle(color: Colors.white, fontSize: 16)),
                                ),
                                const SizedBox(height: 8),
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

                                const SizedBox(height: 20),

                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('Elegir Instrumento', style: TextStyle(color: Colors.white, fontSize: 16)),
                                ),
                                const SizedBox(height: 8),
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

                                const SizedBox(height: 20),

                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('Seleccionar Voz', style: TextStyle(color: Colors.white, fontSize: 16)),
                                ),
                                const SizedBox(height: 8),
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

                                const SizedBox(height: 35),

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
                                  child: const Text('Guardar Partitura', style: TextStyle(fontWeight: FontWeight.bold)),
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