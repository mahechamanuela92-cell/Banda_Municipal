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
    'Flauta Traversa', 'Flauta Picolo', 'Clarinete','Clarinete Bajo', 'Saxófono', 'Saxofon Tenor', 'Saxofon Barítono', 'Saxofon Soprano',
    'Oboe', 'Fagot', 'Trompeta', 'Fliscorno', 'Trombón',
    'Bombardino', 'Tuba', 'Corno',
    'Violonchelo', 'Contrabajo', 'Bombo', 'Redoblante',
    'Platillos', 'Batería', 'Glockenspiel', 'Timbales Sinfónicos',
    'Congas', 'Timbal', 'Chucho', 'Esterilla', 'Requinto', 'Marrana', 'Tambora',
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
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.library_music, color: Color.fromARGB(255, 23, 30, 32), size: 22),
                            SizedBox(width: 10),
                            Text(
                              'SUBIR PARTITURA (ADMIN)',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Color.fromARGB(255, 23, 30, 32),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Tipo de archivo
                      const Text('Tipo de archivo', style: TextStyle(color: Color(0xFFE2BC65), fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 67, 71, 71).withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE2BC65).withValues(alpha: 0.4),
                            width: 1.0,
                          ),
                        ),
                        child: DropdownButton<String>(
                          value: tipoElegido,
                          hint: const Text('Subir archivo', style: TextStyle(color: Color.fromARGB(137, 247, 246, 246))),
                          isExpanded: true,
                          underline: const SizedBox(),
                          dropdownColor: const Color.fromARGB(255, 67, 71, 71).withValues(alpha: 0.75),
                          style: const TextStyle(color: Color.fromARGB(255, 250, 250, 250), fontSize: 15),
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
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Elegir Instrumento
                      const Text('Elegir Instrumento', style: TextStyle(color: Color(0xFFE2BC65), fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 67, 71, 71).withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE2BC65).withValues(alpha: 0.4),
                            width: 1.0,
                          ),
                        ),
                        child: DropdownButton<String>(
                          value: instrumentoElegido,
                          hint: const Text('Seleccionar instrumento', style: TextStyle(color: Color.fromARGB(137, 250, 250, 250))),
                          isExpanded: true,
                          underline: const SizedBox(),
                          dropdownColor: const Color.fromARGB(255, 63, 70, 71).withValues(alpha: 0.75),
                          style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 15),
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

                      // Seleccionar Voz
                      const Text('Seleccionar Voz', style: TextStyle(color: Color(0xFFE2BC65), fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 67, 71, 71).withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE2BC65).withValues(alpha: 0.4),
                            width: 1.0,
                          ),
                        ),
                        child: DropdownButton<String>(
                          value: vozElegida,
                          hint: const Text('Seleccionar voz', style: TextStyle(color: Color.fromARGB(137, 250, 250, 250))),
                          isExpanded: true,
                          underline: const SizedBox(),
                          dropdownColor: const Color.fromARGB(255, 67, 71, 71).withValues(alpha: 0.75),
                          style: const TextStyle(color: Color.fromARGB(255, 253, 253, 253), fontSize: 15),
                          items: [
                            for (String voz in voces)
                              DropdownMenuItem(value: voz, child: Text(voz)),
                          ],
                          onChanged: (valor) {
                            setState(() => vozElegida = valor);
                          },
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Botón Guardar con estilo píldora
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE2BC65),
                            foregroundColor: const Color.fromARGB(255, 23, 30, 32),
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 3,
                          ),
                          onPressed: guardarEnBackend,
                          child: const Text(
                            'Guardar Partitura',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

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