import 'package:flutter/material.dart';
import '../../themes/colores.dart';

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onEnviar;
  final bool cargando;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.onEnviar,
    required this.cargando,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 63, 70, 71).withValues(alpha: 0.75), // 🌟 Fondo translúcido unificado
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 93, 95, 95).withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFE2BC65).withValues(alpha: 0.5), // 🌟 Borde sutil dorado unificado
                  width: 1.2,
                ),
              ),
              child: TextField(
                controller: controller,
                enabled: !cargando,
                style: const TextStyle(color: Color.fromARGB(221, 255, 255, 255), fontWeight: FontWeight.w500),
                decoration: const InputDecoration(
                  hintText: 'Escribe tu mensaje...',
                  hintStyle: TextStyle(color: Color.fromARGB(136, 252, 252, 252), fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onSubmitted: (_) => onEnviar(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: cargando ? null : onEnviar,
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFE2BC65),
              foregroundColor: const Color.fromARGB(255, 0, 0, 0),
            ),
            icon: const Icon(Icons.send_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}