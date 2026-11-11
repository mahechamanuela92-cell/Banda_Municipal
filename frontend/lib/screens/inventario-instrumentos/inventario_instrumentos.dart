import 'package:flutter/material.dart';
import 'package:frontend/components/chat/boton_chat_flotante.dart';
import 'package:frontend/components/chat/chat_banda_modal.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../widgets/fondos.dart';
import '../../config/api.dart';
import 'pantalla_editar.dart';
import 'listado_instrumentos.dart';

class InventarioInstrumentos extends StatefulWidget {
  const InventarioInstrumentos({super.key});

  @override
  State<InventarioInstrumentos> createState() => _InventarioInstrumentosState();
}

class _InventarioInstrumentosState extends State<InventarioInstrumentos> {
  final TextEditingController _serialController = TextEditingController();
  
  List<String> instrumentos = [
    'Flauta Traversa', 'Flauta Picolo', 'Clarinete', 'Clarinete Bajo','Saxófono', 'Saxofon Tenor', 'Saxofon Barítono', 'Saxofon Soprano',
    'Oboe', 'Fagot', 'Trompeta', 'Fliscorno', 'Trombón',
    'Bombardino', 'Tuba', 'Corno',
    'Violonchelo', 'Contrabajo', 'Bombo', 'Redoblante',
    'Platillos', 'Batería', 'Glockenspiel', 'Timbales Sinfónicos',
    'Congas', 'Timbal', 'Chucho', 'Esterilla', 'Requinto', 'Marrana', 'Tambora',
  ];
  
  List<String> estados = ['Mantenimiento', 'Buen estado', 'Mal estado', 'Préstamo'];
  bool mostrarLista = false;
  String? estadoElegido;
  String? instrumentoSeleccionado;

  @override
  void dispose() {
    _serialController.dispose();
    super.dispose();
  }

  void irAEditar() async {
    final nuevaLista = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(builder: (_) => PantallaEditar(instrumentos: instrumentos)),
    );
    if (nuevaLista == null) return;
    setState(() {
      instrumentos = nuevaLista;
      mostrarLista = true;
    });
  }

  void _abrirAsistenteIA(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const ChatBandaModal(),
    );
  }

  Future<void> _guardarInstrumentoEnBackend() async {
    final serial = _serialController.text.trim();

    if (serial.isEmpty || estadoElegido == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor llena el serial y selecciona el estado')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/instrumentos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'numero_serial': serial,
          'nombre_de_instrumento': instrumentoSeleccionado ?? instrumentos.first,
          'instrumento_en': estadoElegido,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Guardado correctamente en la BD')),
        );
        
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ListadoInstrumentosScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error del servidor: ${response.body}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo conectar con el servidor: $e')),
      );
    }
  }

  Widget texto(String t, double size, {bool negrita = false, Color color = Colors.white}) => Text(
      t,
      textAlign: TextAlign.center,
      style: TextStyle(color: color, fontSize: size, fontWeight: negrita ? FontWeight.bold : FontWeight.normal),
    );

  Widget cajaClara(Widget? hijo, {double radio = 12, double? alto, EdgeInsets? pad}) => Container(
        width: double.infinity,
        height: alto,
        padding: pad ?? const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color:Color.fromARGB(255, 82, 88, 88).withValues(alpha: 0.75), borderRadius: BorderRadius.circular(radio)),
        child: hijo,
      );

  Widget espacio(double h) => SizedBox(height: h);

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
                            Icon(Icons.inventory_2, color: Color.fromARGB(255, 23, 30, 32), size: 22),
                            SizedBox(width: 10),
                            Text(
                              'INVENTARIO DE INSTRUMENTOS',
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
                      const SizedBox(height: 20),

// Reemplaza esta sección en tu código (alrededor de los botones de lista) por esto:

                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => setState(() => mostrarLista = !mostrarLista),
                              style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
                              child: Text(
                                mostrarLista ? 'Ocultar Lista ▴' : 'Ver Lista ▾',
                                style: const TextStyle(color: Color(0xFFE2BC65), fontSize: 15, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: irAEditar,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFE2BC65),
                              side: const BorderSide(color: Color(0xFFE2BC65)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Editar Lista', style: TextStyle(fontSize: 13)),
                          ),
                        ],
                      ),
                      espacio(8),

                      cajaClara(
                        mostrarLista
                            ? GridView.count(
                                crossAxisCount: 2,
                                childAspectRatio: 4.5,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  for (String n in instrumentos)
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          instrumentoSeleccionado = n;
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Seleccionado: $n')),
                                        );
                                      },
                                      child: Center(
                                        child: Text(
                                          n,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: instrumentoSeleccionado == n ? const Color(0xFFC29B45) : const Color.fromARGB(255, 161, 159, 159),
                                            fontWeight: instrumentoSeleccionado == n ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              )
                            : null,
                        radio: 20,
                        alto: mostrarLista ? 250 : 0,
                        pad: const EdgeInsets.all(12),
                      ),
                      
                      espacio(24),
                      texto('Instrumento en:', 16, color: const Color(0xFFE2BC65), negrita: true),
                      espacio(8),
                      cajaClara(
                        DropdownButton<String>(
                          value: estadoElegido,
                          hint: const Text('Seleccionar estado', style: TextStyle(color: Color.fromARGB(115, 255, 255, 255))),
                          isExpanded: true,
                          underline: const SizedBox(),
                          dropdownColor: const Color.fromARGB(255, 63, 70, 71).withValues(alpha: 0.75),
                          style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 15),
                          items: [for (String e in estados) DropdownMenuItem(value: e, child: Text(e))],
                          onChanged: (v) => setState(() => estadoElegido = v),
                        ),
                      ),
                      
                      espacio(20),
                      texto('Serial del Instrumento:', 16, color: const Color(0xFFE2BC65), negrita: true),
                      espacio(8),
                      cajaClara(TextField(
                        controller: _serialController,
                        style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 15),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Ej. SN-12345',
                          hintStyle: TextStyle(color: Color.fromARGB(115, 255, 255, 255)),
                        ),
                      )),
                      
                      espacio(28),
                      Center(
                        child: ElevatedButton(
                          onPressed: _guardarInstrumentoEnBackend,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE2BC65),
                            foregroundColor: const Color.fromARGB(255, 23, 30, 32),
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 4,
                          ),
                          child: const Text('Guardar', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      
                      espacio(30),
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