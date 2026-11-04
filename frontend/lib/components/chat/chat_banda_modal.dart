import 'package:flutter/material.dart';
import 'package:frontend/components/chat/chat_burbuja.dart';
import 'package:frontend/components/chat/chat_header.dart';
import 'package:frontend/components/chat/chat_input_field.dart';
import 'package:frontend/services/chat_banda_service.dart';
import '../../themes/colores.dart';

class ChatBandaModal extends StatefulWidget {
  const ChatBandaModal({super.key});

  @override
  State<ChatBandaModal> createState() => _ChatBandaModalState();
}

class _ChatBandaModalState extends State<ChatBandaModal> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  String? sesionId;
  final List<Map<String, String>> _mensajes = [
    {
      'role': 'bot',
      'text': '¡Hola! 🎵 Bienvenida, dime qué necesitas el día de hoy. ¿Has olvidado alguna posición en tu instrumento? 🎺 o ¿Necesitas que te dé alguna recomendación para que tu sonido sea más dulce, agudo, grave o afinado? ✨ Dime lo que necesitas y yo te ayudaré. 🎼',
    }
  ];
  bool _cargando = false;

  void _enviarMensaje() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty || _cargando) return;

    _controller.clear();
    setState(() {
      _mensajes.add({'role': 'user', 'text': texto});
      _cargando = true;
    });

    _scrollHaciaAbajo();

    final resultado = await ChatBandaService.enviarMensaje(texto, sesionId: sesionId);

    if (mounted) {
      setState(() {
        sesionId = resultado['sesionId'] ?? sesionId;
        _mensajes.add({'role': 'bot', 'text': resultado['respuesta'] ?? 'Sin respuesta'});
        _cargando = false;
      });
      _scrollHaciaAbajo();
    }
  }

  void _scrollHaciaAbajo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      child: Container(
        // Ventana más grande: ocupa el 85% de la altura de la pantalla
        height: MediaQuery.of(context).size.height * 0.85,
        margin: EdgeInsets.only(bottom: bottomInset),
        decoration: BoxDecoration(
          color: Colores.bloqueOscuro,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colores.naranja, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colores.naranja.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Column(
          children: [
            const ChatHeader(),
            // Expanded garantiza que la lista ocupe todo el espacio central y baje bien
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _mensajes.length,
                itemBuilder: (context, index) {
                  final item = _mensajes[index];
                  return ChatBurbuja(
                    texto: item['text']!,
                    esUsuario: item['role'] == 'user',
                  );
                },
              ),
            ),
            if (_cargando)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colores.naranja),
                    ),
                    const SizedBox(width: 8),
                    const Text('El asistente está escribiendo...', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
            ChatInputField(
              controller: _controller,
              cargando: _cargando,
              onEnviar: _enviarMensaje,
            ),
          ],
        ),
      ),
    );
  }
}
