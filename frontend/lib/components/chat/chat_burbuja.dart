import 'package:flutter/material.dart';
import 'package:frontend/themes/colores.dart';

class ChatBurbuja extends StatelessWidget {
  final String texto;
  final bool esUsuario;

  const ChatBurbuja({super.key, required this.texto, required this.esUsuario});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: esUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.65,
        ),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: esUsuario ? Colores.naranja : Colors.white12,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(texto, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
