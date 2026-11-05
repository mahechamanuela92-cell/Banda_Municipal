import 'package:flutter/material.dart';
import 'package:frontend/components/chat/boton_chat_flotante.dart';
import 'package:frontend/components/chat/chat_banda_modal.dart';
import '../../../themes/colores.dart';
import '../../../widgets/fondos.dart';
import 'pantalla_reutilizable.dart';

class PartiturasUsuario extends StatelessWidget {
  const PartiturasUsuario({super.key});

  final List<String> instrumentos = const [
    'Flauta Traversa',
    'Flauta Picolo',
    'Clarinete',
    'Saxófono',
    'Oboe',
    'Fagot',
    'Trompeta',
    'Fliscorno',
    'Trombón',
    'Bombardino',
    'Tuba',
    'Corneta',
    'Violín',
    'Viola',
    'Violonchelo',
    'Contrabajo',
    'Bombo',
    'Redoblante',
    'Platillos',
    'Batería',
    'Glockenspiel',
    'Timbales Sinfónicos',
    'Congas',
    'Timbal',
  ];

  void _abrirAsistenteIA(BuildContext context) {
    showDialog(context: context, builder: (_) => const ChatBandaModal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoBase(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colores.naranja,
                        size: 30,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colores.bloqueOscuro,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'PARTITURAS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              itemCount: instrumentos.length,
                              itemBuilder: (context, index) {
                                final instrumento = instrumentos[index];
                                return TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PantallaReutilizable(
                                              instrumento: instrumento,
                                            ),
                                      ),
                                    );
                                  },
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      instrumento,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              BotonChatFlotante(onPressed: () => _abrirAsistenteIA(context)),
            ],
          ),
        ),
      ),
    );
  }
}
