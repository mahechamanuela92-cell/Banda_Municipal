import 'package:flutter/material.dart';
import '../../themes/colores.dart';
import '../../widgets/fondos.dart';

class PantallaEditar extends StatefulWidget {
  final List<String> instrumentos;
  const PantallaEditar({super.key, required this.instrumentos});

  @override
  State<PantallaEditar> createState() => _PantallaEditarState();
}

class _PantallaEditarState extends State<PantallaEditar> {
  final _nombre = TextEditingController();
  late final List<String> _lista = List<String>.from(widget.instrumentos);

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  void _agregar() {
    final texto = _nombre.text.trim();
    if (texto.isEmpty) return;
    setState(() => _lista.add(texto));
    _nombre.clear();
  }

  Future<T?> _dialogo<T>(String t, Widget c, String s, T Function() v) => showDialog<T>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(t),
          content: c,
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            TextButton(onPressed: () => Navigator.pop(ctx, v()), child: Text(s)),
          ],
        ),
      );

  Future<void> _editar(int i) async {
    final c = TextEditingController(text: _lista[i]);
    final n = await _dialogo<String>(
      'Editar instrumento',
      TextField(controller: c, autofocus: true),
      'Aceptar',
      () => c.text.trim(),
    );
    c.dispose();
    if (n != null && n.isNotEmpty) setState(() => _lista[i] = n);
  }

  Future<void> _eliminar(int i) async {
    if (await _dialogo<bool>(
          'Eliminar',
          Text('¿Eliminar "${_lista[i]}" de la lista?'),
          'Eliminar',
          () => true,
        ) ==
        true) {
      setState(() => _lista.removeAt(i));
    }
  }

  Widget _texto(String t, double sz, {bool b = false, Color col = Colors.white}) => Text(
        t,
        textAlign: TextAlign.center,
        style: TextStyle(color: col, fontSize: sz, fontWeight: b ? FontWeight.bold : FontWeight.normal),
      );

  Widget _esp(double h) => SizedBox(height: h);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoBase(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colores.bloqueOscuro,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 38,
                          left: 20,
                          right: 20,
                          child: Image.asset(
                            'assets/images/fondo_login1.png',
                            height: 150,
                            color: Colores.bloqueOscuro,
                            colorBlendMode: BlendMode.srcATop,
                            errorBuilder: (context, error, stackTrace) => const SizedBox(),
                          ),
                        ),
                        Positioned.fill(
                          child: Column(
                            children: [
                              _texto('Editar Lista', 24, b: true),
                              _esp(170),
                              _texto('Agregar Instrumento a la Lista', 18),
                              _esp(10),

                              // --- CUADRO DE TEXTO CON EL BOTÓN + ADENTRO ---
                              Container(
                                decoration: BoxDecoration(
                                  color: Colores.botonClaro,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: TextField(
                                  controller: _nombre,
                                  onSubmitted: (_) => _agregar(),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Nombre del instrumento...',
                                    hintStyle: const TextStyle(color: Colors.black54),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                    suffixIcon: IconButton(
                                      icon: const Icon(
                                        Icons.add_circle,
                                        color: Color(0xFF0F4C5C), // Color oscuro para hacer bonito contraste
                                        size: 28,
                                      ),
                                      onPressed: _agregar,
                                    ),
                                  ),
                                ),
                              ),

                              _esp(16),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: _lista.length,
                                  itemBuilder: (context, i) => Card(
                                    color: Colores.botonClaro,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        _lista[i],
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Color(0xFF0F4C5C)),
                                            onPressed: () => _editar(i),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _eliminar(i),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              _esp(12),

                              // Botón Guardar con estilo Píldora
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colores.botonClaro,
                                  foregroundColor: const Color(0xFF0F4C5C),
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 3,
                                ),
                                onPressed: () => Navigator.pop(context, _lista),
                                child: const Text(
                                  'Guardar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _esp(24),
                _texto(
                  'BANDA SINFONICA SAN MIGUEL DE GARZÓN',
                  20,
                  b: true,
                  col: Colores.colorLetra1,
                ),
                _esp(16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}