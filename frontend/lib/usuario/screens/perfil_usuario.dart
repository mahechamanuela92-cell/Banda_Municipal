import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'inicio_sesion.dart';
import '../../themes/colores.dart';
import '../../widgets/fondos.dart';

class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({super.key});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  File? _foto; // foto elegida de la galería
  final _nombre = TextEditingController(text: 'Danny Camila');
  final _telefono = TextEditingController();
  final _correo = TextEditingController();

  // Abre la galería y guarda la foto elegida
  Future<void> _elegirFoto() async {
    final imagen = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (imagen != null) {
      setState(() => _foto = File(imagen.path));
    }
  }

  // Campo centrado con lápiz
  Widget _campo(String titulo, TextEditingController controlador) {
    return Column(
      children: [
        if (titulo.isNotEmpty)
          Text(titulo, style: const TextStyle(color: Colors.white, fontSize: 18)),
        TextField(
          controller: controlador,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: const InputDecoration(
            suffixIcon: Icon(Icons.edit, color: Colors.white, size: 16),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // Botón grande
  Widget _boton(String texto, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colores.botonClaro,
          foregroundColor: Colores.bloqueOscuro,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: onTap,
        child: Text(texto, style: const TextStyle(fontSize: 20)),
      ),
    );
  }

  // <--- 2. Método _opcionMenu agregado para que funcione el botón de Cerrar Sesión --->
  Widget _opcionMenu(BuildContext context, String texto, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colores.botonClaro,
          foregroundColor: Colores.bloqueOscuro,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: onTap,
        child: Text(texto, style: const TextStyle(fontSize: 20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoBase(
        child: SafeArea(
          child: Stack(
            children: [
              // CAPA 1: el ave, arriba y detrás del bloque oscuro
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Image.asset(
                  'assets/images/fondo_login1.png',
                  height: 260,
                  fit: BoxFit.contain,
                ),
              ),

              // CAPA 2: bloque del perfil + texto de abajo
              Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
                          decoration: BoxDecoration(
                            color: Colores.bloqueOscuro,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Perfil',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 20),

                              // Foto con lápiz para editar
                              SizedBox(
                                width: 170,
                                height: 130,
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: CircleAvatar(
                                        radius: 60,
                                        backgroundColor: Colors.white,
                                        backgroundImage:
                                            _foto != null ? FileImage(_foto!) : null,
                                        child: _foto == null
                                            ? const Icon(Icons.person,
                                                size: 70, color: Colors.grey)
                                            : null,
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: GestureDetector(
                                        onTap: _elegirFoto,
                                        child: const Icon(Icons.edit, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),
                              _campo('', _nombre),
                              const SizedBox(height: 28),
                              _campo('Telefono', _telefono),
                              const SizedBox(height: 28),
                              _campo('Correo', _correo),
                              const SizedBox(height: 44),

                              _boton('Guardar', () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Perfil guardado')),
                                );
                                Navigator.pop(context);
                              }),
                              const SizedBox(height: 16),
                              
                              _opcionMenu(context, 'Cerrar Sesión', () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const InicioSesion()),
                                  (route) => false,
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Texto de abajo
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: Text(
                      'BANDA SINFONICA SAN MIGUEL DE GARZÓN',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colores.colorLetra1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}