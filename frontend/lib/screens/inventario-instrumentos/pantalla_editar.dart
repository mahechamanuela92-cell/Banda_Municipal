import 'package:flutter/material.dart';
import 'package:frontend/components/chat/boton_chat_flotante.dart';
import 'package:frontend/components/chat/chat_banda_modal.dart';

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

  void _abrirAsistenteIA(BuildContext context) {
    showDialog(context: context, builder: (_) => const ChatBandaModal());
  }

  Future<T?> _dialogo<T>(String t, Widget c, String s, T Function() v) =>
      showDialog<T>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color.fromARGB(255, 63, 70, 71).withValues(alpha: 0.75),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE2BC65), width: 1.2),
          ),
          title: Text(
            t,
            style: const TextStyle(
              color: Color(0xFFE2BC65),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: c,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, v()),
              child: Text(
                s,
                style: const TextStyle(
                  color: Color(0xFFE2BC65),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );

  Future<void> _editar(int i) async {
    final c = TextEditingController(text: _lista[i]);
    final n = await _dialogo<String>(
      'Editar instrumento',
      TextField(
        controller: c,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFE2BC65)),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFE2BC65), width: 2),
          ),
        ),
      ),
      'Aceptar',
      () => c.text.trim(),
    );
    c.dispose();
    if (n != null && n.isNotEmpty) setState(() => _lista[i] = n);
  }

  Future<void> _eliminar(int i) async {
    if (await _dialogo<bool>(
          'Eliminar',
          Text(
            '¿Eliminar "${_lista[i]}" de la lista?',
            style: const TextStyle(color: Colors.white70),
          ),
          'Eliminar',
          () => true,
        ) ==
        true) {
      setState(() => _lista.removeAt(i));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoBase(
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 63, 70, 71).withValues(alpha: 0.75), // 🌟 Fondo translúcido unificado
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(
                      color: const Color(
                        0xFFE2BC65,
                      ).withValues(alpha: 0.5), // 🌟 Borde sutil dorado
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
                    children: [
                      // Botón de regresar unificado
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFFE2BC65),
                            size: 28,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Título principal con degradado dorado unificado
                      Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE2BC65), Color(0xFFC29B45)],
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
                            Icon(
                              Icons.edit_note,
                              color: Color.fromARGB(255, 23, 30, 32),
                              size: 22,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'EDITAR LISTA',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color.fromARGB(255, 23, 30, 32),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Agregar Instrumento a la Lista',
                          style: TextStyle(
                            color: Color(0xFFE2BC65),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // --- CUADRO DE TEXTO CON EL BOTÓN + ADENTRO ---
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 83, 89, 90).withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(
                              0xFFE2BC65,
                            ).withValues(alpha: 0.4),
                            width: 1.0,
                          ),
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
                            hintStyle: const TextStyle(color: Color.fromARGB(137, 255, 254, 254)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.add_circle,
                                color: const Color(0xFFE2BC65),
                                size: 28,
                              ),
                              onPressed: _agregar,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Expanded(
                        child: ListView.builder(
                          itemCount: _lista.length,
                          itemBuilder: (context, i) => Card(
                            color: const Color.fromARGB(255, 90, 91, 92).withValues(alpha: 0.75),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: const Color(
                                  0xFFE2BC65,
                                ).withValues(alpha: 0.3),
                                width: 1.0,
                              ),
                            ),
                            child: ListTile(
                              title: Text(
                                _lista[i],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color.fromARGB(137, 255, 254, 254),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: const Color(0xFFE2BC65),
                                    ),
                                    onPressed: () => _editar(i),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () => _eliminar(i),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Botón Guardar con estilo Píldora
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE2BC65),
                          foregroundColor: const Color.fromARGB(
                            255,
                            23,
                            30,
                            32,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 3,
                        ),
                        onPressed: () => Navigator.pop(context, _lista),
                        child: const Text(
                          'Guardar Cambios',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

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
              BotonChatFlotante(onPressed: () => _abrirAsistenteIA(context)),
            ],
          ),
        ),
      ),
    );
  }
}
