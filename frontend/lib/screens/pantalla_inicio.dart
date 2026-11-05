import 'package:flutter/material.dart';
import 'package:frontend/components/chat/chat_banda_modal.dart';
import 'package:frontend/components/chat/boton_chat_flotante.dart';
import 'package:frontend/screens/pantalla_menuusuario.dart';
import 'package:frontend/widgets/inicio_pantallas/instrumentos_pantallas.dart';
import 'package:frontend/widgets/inicio_pantallas/nuestra_historia_pantalla.dart';
import 'package:frontend/widgets/inicio_pantallas/contactenos_pantalla.dart';
import '../../themes/colores.dart';
import '../../widgets/fondos.dart';

class Inicio extends StatelessWidget {
  const Inicio({super.key});

  get tarjetas => null;

  void _abrirAsistenteIA(BuildContext context) {
    showDialog(context: context, builder: (_) => const ChatBandaModal());
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> tarjetas = [
      {
        'titulo': 'NUESTRA HISTORIA',
        'img': 'assets/images/libro.png',
        'der': false,
        'destino': const NuestraHistoriaPantalla(),
      },
      {
        'titulo': 'INSTRUMENTOS CON LOS QUE CONTAMOS',
        'img': 'assets/images/instrumentos.png',
        'der': false,
        'destino': const InstrumentosPantalla(),
      },
      {
        'titulo': 'CONTÁCTENOS',
        'img': 'assets/images/contacto.png',
        'der': false,
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
                  vertical: 10.0,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.asset(
                          "assets/images/fondo_login1.png",
                          fit: BoxFit.contain,
                          height: 230,
                        ),
                      ),
                    ),
                    Text(
                      "BANDA SINFONICA SAN MIGUEL\nGARZÓN HUILA",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colores.colorLetra1,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Tarjetas con navegación
                    ...tarjetas.map(
                      (t) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _crearTarjeta(
                          titulo: t['titulo'] as String,
                          rutaImagen: t['img'] as String,
                          imagenALaDerecha: t['der'] as bool,
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

                    const SizedBox(height: 4),
                  ],
                ),
              ),

              // 2. Botón superior del menú
              Positioned(
                top: 10,
                left: 12,
                child: _buildBotonMenuIcono(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        opaque: false,
                        barrierColor: Colors.transparent,
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const MenuUsuario(),
                      ),
                    );
                  },
                ),
              ),

              // 3. Botón flotante de la IA directo al final del Stack (sin Positioned externo)
              BotonChatFlotante(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const ChatBandaModal(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Método para el botón del menú superior con diseño de estilo degradado turquesa
Widget _buildBotonMenuIcono({required VoidCallback onTap}) {
  return Container(
    height: 48,
    width: 48,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFB3F0EC), Color(0xFF8AE1DC)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      borderRadius: BorderRadius.circular(24.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24.0),
        child: const Icon(Icons.menu, color: Color(0xFF0F4C5C), size: 26),
      ),
    ),
  );
}

// Método auxiliar para crear las tarjetas principales
Widget _crearTarjeta({
  required String titulo,
  required String rutaImagen,
  required bool imagenALaDerecha,
  required VoidCallback onTap,
}) {
  final imgWidget = Image.asset(
    rutaImagen,
    height: 48,
    width: 48,
    fit: BoxFit.contain,
  );

  return Container(
    width: double.infinity,
    height: 90,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(30.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30.0),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFB3F0EC), Color(0xFF8AE1DC)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                if (!imagenALaDerecha) ...[
                  imgWidget,
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Text(
                    titulo,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F4C5C),
                    ),
                  ),
                ),
                if (imagenALaDerecha) ...[const SizedBox(width: 12), imgWidget],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}