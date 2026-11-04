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
        color: Colores.bloqueOscuro,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colores.naranja.withOpacity(0.4)),
              ),
              child: TextField(
                controller: controller,
                enabled: !cargando,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Escribe tu mensaje...',
                  hintStyle: TextStyle(color: Colors.white54, fontSize: 13),
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
              backgroundColor: Colors.transparent,
              foregroundColor: Colores.naranja,
            ),
            icon: const Icon(Icons.send_rounded, size: 24),
          ),
        ],
      ),
    );
  }
}