import 'package:frontend/screens/inicioSesion.dart';
import 'package:frontend/themes/colores.dart';
import 'package:flutter/material.dart';
import '../widgets/fondos.dart';

class Inicio1 extends StatelessWidget {
  const Inicio1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoBase(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Imagen/Logo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.asset(
                      "assets/images/fondo_login1.png",
                      fit: BoxFit.contain,
                      height: 230,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Título
                  Text(
                    "BANDA SINFONICA MUNICIPAL DE GARZÓN",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colores.colorLetra1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  // Espacio debajo del texto
                  const SizedBox(height: 45),

                  // Botón Estilizado Igual a la Imagen
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const InicioSesion()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          // Degradado similar al de la imagen (de un tono aqua claro a un cian suave)
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFB3F0EC),
                              Color(0xFF8AE1DC),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          constraints: const BoxConstraints(minHeight: 55),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.music_note,
                                color: Color(0xFF0F4C5C), // Color oscuro para que contraste
                                size: 24,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Ingresa a tu plataforma musical",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF0F4C5C), // Texto oscuro acorde al diseño
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}