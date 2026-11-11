import 'package:flutter/material.dart';
import 'package:frontend/components/chat/boton_chat_flotante.dart';
import 'package:frontend/components/chat/chat_banda_modal.dart';

import '../../../widgets/fondos.dart';
import 'pantalla_reutilizable.dart';

class PartiturasUsuario extends StatelessWidget {
  const PartiturasUsuario({super.key});

  final List<String> instrumentos = const [
    'Flauta Traversa',
    'Flauta Picolo',
    'Clarinete',
    'Clarinete Bajo',
    'Saxófono',
    'Saxofon Tenor',
    'Saxofon Barítono',
    'Saxofon Soprano',
    'Oboe',
    'Fagot',
    'Trompeta',
    'Fliscorno',
    'Trombón',
    'Bombardino',
    'Tuba',
    'Corno',
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
    'Chucho',
    'Esterilla',
    'Requinto',
    'Marrana',
    'Tambora',
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 45, 51, 53).withValues(alpha: 0.85), // 🌟 Fondo translúcido unificado
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(
                      color: const Color(0xFFE2BC65).withValues(alpha: 0.5), // 🌟 Borde sutil dorado
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Botón de regresar unificado
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFFE2BC65),
                            size: 28,
                          ),
                          tooltip: 'Volver',
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Título principal con degradado dorado unificado
                      Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFE2BC65),
                              Color(0xFFC29B45),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.library_music, color: Color.fromARGB(255, 23, 30, 32), size: 22),
                            SizedBox(width: 10),
                            Text(
                              'PARTITURAS',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Color.fromARGB(255, 23, 30, 32),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Lista de instrumentos
                      Expanded(
                        child: ListView.separated(
                          itemCount: instrumentos.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final instrumento = instrumentos[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 70, 75, 77).withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE2BC65).withValues(alpha: 0.3),
                                  width: 1.0,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                                title: Text(
                                  instrumento,
                                  style: const TextStyle(
                                    color: Color.fromARGB(221, 255, 255, 255),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                leading: Icon(
                                  Icons.music_note,
                                  color: const Color(0xFFE2BC65),
                                  size: 20,
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  color: const Color(0xFFE2BC65),
                                  size: 14,
                                ),
                                onTap: () {
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
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Pie de página institucional unificado
                      const Center(
                        child: Text(
                          "BANDA SINFONICA SAN MIGUEL\nGARZÓN HUILA",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFE2BC65),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Botón flotante del chatbot de la IA
              BotonChatFlotante(onPressed: () => _abrirAsistenteIA(context)),
            ],
          ),
        ),
      ),
    );
  }
}