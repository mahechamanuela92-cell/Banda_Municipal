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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF0F4C5C,
                    ).withValues(alpha: 0.8), // 🌟 Fondo translúcido unificado
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(
                      color: const Color(
                        0xFFE2BC65,
                      ).withValues(alpha: 0.5), // 🌟 Borde sutil dorado
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
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Título principal con degradado dorado unificado
                      Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE2BC65), Color(0xFFC29B45)],
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
                            Icon(
                              Icons.perm_media,
                              color: Color.fromARGB(255, 23, 30, 32),
                              size: 22,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'MULTIMEDIA',
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
                      const SizedBox(height: 20),

                      // Lista de opciones multimedia
                      Expanded(
                        child: ListView.separated(
                          itemCount: opciones.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final opcion = opciones[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: Colores.botonClaro,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(
                                    0xFFE2BC65,
                                  ).withValues(alpha: 0.4),
                                  width: 1.0,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                title: Text(
                                  '${opcion['titulo']}',
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                leading: Icon(
                                  opcion['tipo'] == 'foto'
                                      ? Icons.photo_library
                                      : Icons.video_library,
                                  color: const Color(0xFF0F4C5C),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Color(0xFF0F4C5C),
                                  size: 16,
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
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

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
