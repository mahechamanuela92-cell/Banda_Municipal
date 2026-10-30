import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../themes/colores.dart';
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
    'Flauta Traversa', 'Flauta Picolo', 'Clarinete', 'Saxófono',
    'Oboe', 'Fagot', 'Trompeta', 'Fliscorno', 'Trombón',
    'Bombardino', 'Tuba', 'Corneta', 'Violín', 'Viola',
    'Violonchelo', 'Contrabajo', 'Bombo', 'Redoblante',
    'Platillos', 'Batería', 'Glockenspiel', 'Timbales Sinfónicos',
    'Congas', 'Timbal',
  ];
  
  // Nota: Asegúrate de que estos textos coincidan con lo que acepta tu base de datos (o minúsculas si el CHECK lo exige)
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

  Future<void> _guardarInstrumentoEnBackend() async {
    final serial = _serialController.text.trim();

    if (serial.isEmpty || estadoElegido == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor llena el serial y selecciona el estado')),
      );
      return;
    }

    try {
      print('Enviando a: $apiUrl/instrumentos');

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

      print('Código de respuesta: ${response.statusCode}');
      print('Respuesta del servidor: ${response.body}');

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
        decoration: BoxDecoration(color: Colores.botonClaro, borderRadius: BorderRadius.circular(radio)),
        child: hijo,
      );

  Widget espacio(double h) => SizedBox(height: h);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoBase(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colores.bloqueOscuro,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 38, left: 20, right: 20,
                        child: Image.asset('assets/images/fondo_login.png', height: 180,
                            color: Colores.bloqueOscuro, colorBlendMode: BlendMode.srcATop),
                      ),
                      Column(
                        children: [
                          texto('Inventario de Instrumentos', 24, negrita: true),
                          espacio(200),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () => setState(() => mostrarLista = !mostrarLista),
                                child: texto('Lista ▾', 22),
                              ),
                              OutlinedButton(
                                onPressed: irAEditar,
                                style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.white)),
                                child: const Text('Editar Lista'),
                              ),
                            ],
                          ),
                          espacio(8),
                          cajaClara(
                            mostrarLista
                                ? GridView.count(
                                    crossAxisCount: 2,
                                    childAspectRatio: 5,
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
                                          child: Text(
                                            n,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: instrumentoSeleccionado == n ? Colores.naranja : Colors.black,
                                              fontWeight: instrumentoSeleccionado == n ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                    ],
                                  )
                                : null,
                            radio: 20,
                            alto: 250,
                            pad: const EdgeInsets.all(12),
                          ),
                          espacio(24),
                          texto('Instrumento en', 18),
                          espacio(8),
                          cajaClara(
                            DropdownButton<String>(
                              value: estadoElegido,
                              hint: const Text('Seleccionar estado'),
                              isExpanded: true,
                              underline: const SizedBox(),
                              dropdownColor: Colores.botonClaro,
                              style: const TextStyle(color: Colors.black),
                              items: [for (String e in estados) DropdownMenuItem(value: e, child: Text(e))],
                              onChanged: (v) => setState(() => estadoElegido = v),
                            ),
                          ),
                          espacio(20),
                          texto('Serial', 18),
                          espacio(8),
                          cajaClara(TextField(
                            controller: _serialController,
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(border: InputBorder.none),
                          )),
                          espacio(28),
                          ElevatedButton(
                            onPressed: _guardarInstrumentoEnBackend,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colores.botonClaro,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Text('Guardar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                espacio(40),
                texto('BANDA SINFONICA SAN MIGUEL\nGARZÓN HUILA', 20,
                    negrita: true, color: Colores.colorLetra1),
                espacio(16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}