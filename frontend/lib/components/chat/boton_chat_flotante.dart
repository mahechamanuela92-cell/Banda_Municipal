import 'package:flutter/material.dart';
import 'package:frontend/themes/colores.dart';
import 'chat_banda_modal.dart'; // Asegúrate de que la ruta a tu modal sea correcta

class BotonChatFlotante extends StatefulWidget {
  final VoidCallback? onPressed;

  const BotonChatFlotante({super.key, this.onPressed});

  @override
  State<BotonChatFlotante> createState() => _BotonChatFlotanteState();
}

class _BotonChatFlotanteState extends State<BotonChatFlotante> {
  static const double _tamanoBurbuja = 65.0; // Tamaño de tu burbuja flotante
  static const double _margen = 16.0;
  
  // Posiciones iniciales flotantes
  double _posicionX = 20.0;
  double _posicionY = 30.0;

  void _abrirChat() {
    if (widget.onPressed != null) {
      widget.onPressed!();
    } else {
      showDialog(
        context: context,
        builder: (_) => const ChatBandaModal(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final ancho = constraints.maxWidth;
        final alto = constraints.maxHeight;

        // Límites dinámicos exactos basados en la estructura
        final maxX = (ancho - _tamanoBurbuja - _margen).clamp(_margen, ancho).toDouble();
        final maxY = (alto - _tamanoBurbuja - _margen).clamp(_margen, alto).toDouble();
        
        _posicionX = _posicionX.clamp(_margen, maxX).toDouble();
        _posicionY = _posicionY.clamp(_margen, maxY).toDouble();

        return Stack(
          children: [
            Positioned(
              right: _posicionX,
              bottom: _posicionY,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    // Movimiento fluido en cualquier dirección (arriba, abajo, costados)
                    _posicionX = (_posicionX - details.delta.dx).clamp(_margen, maxX).toDouble();
                    _posicionY = (_posicionY - details.delta.dy).clamp(_margen, maxY).toDouble();
                  });
                },
                onTap: _abrirChat,
                child: Container(
                  width: _tamanoBurbuja,
                  height: _tamanoBurbuja,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE2BC65), // 🌟 Borde sutil dorado unificado
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/chatbot.jpg',
                      width: _tamanoBurbuja,
                      height: _tamanoBurbuja,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color.fromARGB(255, 63, 70, 71).withValues(alpha: 0.75),
                        child: const Icon(Icons.chat, color: Color(0xFFE2BC65), size: 30),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}