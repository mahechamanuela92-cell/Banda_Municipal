import 'package:flutter/material.dart';
import '../../themes/colores.dart';
import '../../widgets/fondos.dart';
import 'pantalla_editar.dart';
import '../pantalla_inicio.dart'; // <-- ajusta la ruta a tu pantalla de inicio

class InventarioInstrumentos extends StatefulWidget {
  const InventarioInstrumentos({super.key});

  @override
  State<InventarioInstrumentos> createState() => _InventarioInstrumentosState();
}

class _InventarioInstrumentosState extends State<InventarioInstrumentos> {
  List<String> instrumentos = [
    'Flauta Traversa', 'Flauta Picolo', 'Clarinete', 'Saxófono',
    'Oboe', 'Fagot', 'Trompeta', 'Fliscorno', 'Trombón',
    'Bombardino', 'Tuba', 'Corneta', 'Violín', 'Viola',
    'Violonchelo', 'Contrabajo', 'Bombo', 'Redoblante',
    'Platillos', 'Batería', 'Glockenspiel', 'Timbales Sinfónicos',
    'Congas', 'Timbal',
  ];
  List<String> estados = ['Mantenimiento', 'Buen Estado', 'Mal Estado', 'Préstamo'];
  bool mostrarLista = false;
  String? estadoElegido;
  // Abre la pantalla de editar y guarda la lista actualizada
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

  Widget texto(String t, double size,
          {bool negrita = false, Color color = Colors.white}) =>
      Text(t,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: color,
              fontSize: size,
              fontWeight: negrita ? FontWeight.bold : FontWeight.normal));

  Widget cajaClara(Widget? hijo,
          {double radio = 12, double? alto, EdgeInsets? pad}) =>
      Container(
        width: double.infinity,
        height: alto,
        padding: pad ?? const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
            color: Colores.botonClaro, borderRadius: BorderRadius.circular(radio)),
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colores.bloqueOscuro,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      // Foto atrás (más pequeña), oscurecida con el mismo color del bloque
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
                                        Text(n, style: const TextStyle(fontSize: 14, color: Colors.black)),
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
                          cajaClara(const TextField(
                              decoration: InputDecoration(border: InputBorder.none))),
                          espacio(28),
                          ElevatedButton(
                            onPressed: () {
                              // Mensajito de confirmación (se ve también en la pantalla de inicio)
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Guardado correctamente')));
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => const Inicio()),
                                (route) => false,
                              );
                            },
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
                texto('BANDA SINFONICA SAN MIGUEL DE GARZÓN', 20,
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