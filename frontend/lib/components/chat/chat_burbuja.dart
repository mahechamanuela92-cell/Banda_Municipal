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
          maxWidth: MediaQuery.sizeOf(context).width * 0.70,
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          // 🌟 Estilo unificado: acento dorado para el usuario, fondo claro/translúcido sutil para el bot
          color: esUsuario ? const Color(0xFFE2BC65) : const Color.fromARGB(255, 93, 95, 95).withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 255, 255, 255).withValues(alpha: 0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          texto,
          style: TextStyle(
            // 🌟 Texto oscuro legible sobre fondos claros/dorados, o blanco si fuera necesario
            color: esUsuario ? const Color.fromARGB(255, 0, 0, 0) : const Color.fromARGB(221, 255, 254, 254),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}