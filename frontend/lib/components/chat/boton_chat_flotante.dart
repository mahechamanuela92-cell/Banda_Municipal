import 'package:flutter/material.dart';
import 'package:frontend/themes/colores.dart';


class BotonChatFlotante extends StatefulWidget {
  final VoidCallback onPressed;

  const BotonChatFlotante({super.key, required this.onPressed});

  @override
  State<BotonChatFlotante> createState() => _BotonChatFlotanteState();
}

class _BotonChatFlotanteState extends State<BotonChatFlotante> {
  // Posición inicial del botón en la esquina inferior derecha
  double _bottom = 30.0;
  double _right = 30.0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: _bottom,
      right: _right,
      child: GestureDetector(
        // Permite arrastrar el botón por toda la pantalla
        onPanUpdate: (details) {
          setState(() {
            // Restamos el delta para moverlo fluidamente con el dedo
            _bottom -= details.delta.dy;
            _right -= details.delta.dx;

            // Opcional: Limitar para que no se salga completamente de la pantalla
            if (_bottom < 0) _bottom = 0;
            if (_right < 0) _right = 0;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colores.naranja.withOpacity(0.6),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: SizedBox(
            width: 80, // Cambiado de 65 a 80
            height: 80, // Cambiado de 65 a 80
            child: FloatingActionButton(
              onPressed: widget.onPressed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: ClipOval(
                child: Image.asset(
                  'assets/images/chatbot.jpg',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}