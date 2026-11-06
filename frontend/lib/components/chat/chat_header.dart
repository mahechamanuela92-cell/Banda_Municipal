import 'package:flutter/material.dart';
import '../../themes/colores.dart';

class ChatHeader extends StatelessWidget {
  const ChatHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 63, 70, 71).withValues(alpha: 0.75), // 🌟 Fondo translúcido unificado
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE2BC65).withValues(alpha: 0.5), // 🌟 Borde sutil dorado unificado
            width: 1.2,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color.fromARGB(255, 63, 70, 71).withValues(alpha: 0.75),
                backgroundImage: const AssetImage('assets/images/chatbot.jpg'),
              ),
              const SizedBox(width: 10),
              const Text(
                'ASISTENTE IA',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFFE2BC65)),
            tooltip: 'Cerrar',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}