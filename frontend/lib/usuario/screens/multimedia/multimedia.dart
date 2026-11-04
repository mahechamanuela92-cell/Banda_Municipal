import 'package:flutter/material.dart';
import 'package:frontend/components/chat/boton_chat_flotante.dart';
import 'package:frontend/components/chat/chat_banda_modal.dart';
import '../../../themes/colores.dart';
import '../../../widgets/fondos.dart';
import 'pantalla_galeria_multimedia.dart';

class PantallaMultimedia extends StatelessWidget {
  const PantallaMultimedia({super.key});

  void _abrirAsistenteIA(BuildContext context) {
    showDialog(context: context, builder: (_) => const ChatBandaModal());
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> opciones = [
      {'titulo': 'Fotos', 'tipo': 'foto'},
      {'titulo': 'Videos', 'tipo': 'video'},
    ];

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
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Multimedia',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colores.cajaOscura,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListView.builder(
                        itemCount: opciones.length,
                        itemBuilder: (context, index) {
                          final opcion = opciones[index];
                          return ListTile(
                            title: Text(
                              '${opcion['titulo']}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Icon(
                              Icons.keyboard_arrow_right,
                              color: Colors.white70,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PantallaGaleriaMultimedia(
                                        tituloSeccion: opcion['titulo']!,
                                        tipoMultimedia: opcion['tipo']!,
                                      ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Text(
                      'BANDA SINFONICA SAN MIGUEL\nGARZÓN HUILA',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colores.amarillo,
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
