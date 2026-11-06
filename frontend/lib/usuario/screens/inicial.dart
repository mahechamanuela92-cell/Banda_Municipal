import 'package:flutter/material.dart';
import 'package:frontend/components/chat/chat_banda_modal.dart';
import 'package:frontend/components/chat/boton_chat_flotante.dart';
import 'package:frontend/usuario/screens/menu_usuario.dart';
import 'package:frontend/widgets/inicio_pantallas/instrumentos_pantallas.dart';
import 'package:frontend/widgets/inicio_pantallas/nuestra_historia_pantalla.dart';
import 'package:frontend/widgets/inicio_pantallas/contactenos_pantalla.dart';
import '../../themes/colores.dart';
import '../../widgets/fondos.dart';

class Inicio extends StatelessWidget {
  const Inicio({super.key});

  void _abrirAsistenteIA(BuildContext context) {
    showDialog(context: context, builder: (_) => const ChatBandaModal());
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, Object>> tarjetas = [
      {
        'titulo': 'NUESTRA HISTORIA',
        'icono': Icons.menu_book,
        'destino': const NuestraHistoriaPantalla(),
      },
      {
        'titulo': 'INSTRUMENTOS CON LOS QUE CONTAMOS',
        'icono': Icons.music_note,
        'destino': const InstrumentosPantalla(),
      },
      {
        'titulo': 'CONTÁCTENOS',
        'icono': Icons.contact_support,
        'destino': const PantallaContacto(),
      },
    ];

    return Scaffold(
      body: FondoBase(
        child: SafeArea(
          child: Stack(
            children: [
              // 1. Contenido principal desplazable
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.asset(
                          "assets/images/fondo_login1.png",
                          fit: BoxFit.contain,
                          height: 180,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "BANDA SINFONICA SAN MIGUEL\nGARZÓN HUILA",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colores.colorLetra1,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 25),

                    // Tarjetas una debajo de otra (Verticales)
                    ...tarjetas.map(
                      (t) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _crearTarjetaVertical(
                          titulo: t['titulo'] as String,
                          icono: t['icono'] as IconData,
                          onTap: () {
                            final destino = t['destino'] as Widget?;
                            if (destino != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => destino,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${t['titulo']}: pantalla no disponible',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),

              // 2. Botón superior del menú con estilo unificado
              Positioned(
                top: 15,
                left: 20,
                child: _buildBotonMenuIcono(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        opaque: false,
                        barrierColor: const Color.fromARGB(0, 46, 42, 42),
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const MenuUsuarios(),
                      ),
                    );
                  },
                ),
              ),

              // 3. Botón flotante de la IA
              BotonChatFlotante(onPressed: () => _abrirAsistenteIA(context)),
            ],
          ),
        ),
      ),
    );
  }
}

// Método para el botón del menú superior con diseño estilizado y elegante
Widget _buildBotonMenuIcono({required VoidCallback onTap}) {
  return Container(
    height: 45,
    width: 45,
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 45, 51, 53).withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(15.0),
      border: Border.all(
        color: const Color(0xFFE2BC65).withValues(alpha: 0.6),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15.0),
        child: const Icon(Icons.menu, color: Color(0xFFE2BC65), size: 24),
      ),
    ),
  );
}

// Método auxiliar para crear las tarjetas verticales (una debajo de otra)
Widget _crearTarjetaVertical({
  required String titulo,
  required IconData icono,
  required VoidCallback onTap,
}) {
  return Container(
    width: 270,
    height: 120,
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 63, 70, 71).withValues(alpha: 0.75), // Fondo translúcido elegante
      borderRadius: BorderRadius.circular(24.0),
      border: Border.all(
        color: const Color(
          0xFFE2BC65,
        ).withValues(alpha: 0.5), // Borde sutil dorado
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              // Icono dorado a la izquierda
              Icon(icono, size: 32, color: const Color(0xFFE2BC65)),
              const SizedBox(width: 18),
              // Título de la tarjeta expandido
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFFE2BC65),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
