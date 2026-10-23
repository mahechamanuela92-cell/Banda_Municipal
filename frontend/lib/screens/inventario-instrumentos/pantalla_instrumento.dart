import 'package:flutter/material.dart';
import '../../themes/colores.dart';
import '../../widgets/fondos.dart';

class PantallaInstrumento extends StatelessWidget {
  const PantallaInstrumento({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoBase(
        child: SafeArea(
          child: Column(
            children: [
              // Flecha para volver
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colores.naranja, size: 30),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),

              // Logo
              Image.asset('assets/images/fondo_login1.png', height: 130),
              SizedBox(height: 20),

              // Caja oscura
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colores.cajaOscura,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: SingleChildScrollView(
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent, // Quita las líneas de separación
                      ),
                      child: Column(
                        children: [
                          // --- CATEGORÍA VIENTO-METAL ---
                          ExpansionTile(
                            title: Text(
                              'Viento-Metal',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            iconColor: Colors.white,
                            collapsedIconColor: Colors.white,
                            children: [
                              ExpansionTile(
                                title: Text('Trompeta', style: TextStyle(color: Colors.white70)),
                                iconColor: Colors.white70,
                                collapsedIconColor: Colors.white70,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Información de Trompeta...', style: TextStyle(color: Colors.white54)),
                                  ),
                                ],
                              ),
                              ExpansionTile(
                                title: Text('Fliscorno', style: TextStyle(color: Colors.white70)),
                                iconColor: Colors.white70,
                                collapsedIconColor: Colors.white70,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Información de Fliscorno...', style: TextStyle(color: Colors.white54)),
                                  ),
                                ],
                              ),
                              ExpansionTile(
                                title: Text('Trombón', style: TextStyle(color: Colors.white70)),
                                iconColor: Colors.white70,
                                collapsedIconColor: Colors.white70,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Información de Trombón...', style: TextStyle(color: Colors.white54)),
                                  ),
                                ],
                              ),
                              ExpansionTile(
                                title: Text('Bombardino', style: TextStyle(color: Colors.white70)),
                                iconColor: Colors.white70,
                                collapsedIconColor: Colors.white70,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Información de Bombardino...', style: TextStyle(color: Colors.white54)),
                                  ),
                                ],
                              ),
                              ExpansionTile(
                                title: Text('Tuba', style: TextStyle(color: Colors.white70)),
                                iconColor: Colors.white70,
                                collapsedIconColor: Colors.white70,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Información de Tuba...', style: TextStyle(color: Colors.white54)),
                                  ),
                                ],
                              ),
                              ExpansionTile(
                                title: Text('Corneta', style: TextStyle(color: Colors.white70)),
                                iconColor: Colors.white70,
                                collapsedIconColor: Colors.white70,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Información de Corneta...', style: TextStyle(color: Colors.white54)),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // --- CATEGORÍA CUERDA ---
                          ExpansionTile(
                            title: Text(
                              'Cuerda',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            iconColor: Colors.white,
                            collapsedIconColor: Colors.white,
                            children: [
                              ExpansionTile(
                                title: Text('Violín', style: TextStyle(color: Colors.white70)),
                                iconColor: Colors.white70,
                                collapsedIconColor: Colors.white70,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Información de Violín...', style: TextStyle(color: Colors.white54)),
                                  ),
                                ],
                              ),
                              ExpansionTile(
                                title: Text('Viola', style: TextStyle(color: Colors.white70)),
                                iconColor: Colors.white70,
                                collapsedIconColor: Colors.white70,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Información de Viola...', style: TextStyle(color: Colors.white54)),
                                  ),
                                ],
                              ),
                              ExpansionTile(
                                title: Text('Violonchelo', style: TextStyle(color: Colors.white70)),
                                iconColor: Colors.white70,
                                collapsedIconColor: Colors.white70,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Información de Violonchelo...', style: TextStyle(color: Colors.white54)),
                                  ),
                                ],
                              ),
                              ExpansionTile(
                                title: Text('Contrabajo', style: TextStyle(color: Colors.white70)),
                                iconColor: Colors.white70,
                                collapsedIconColor: Colors.white70,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Información de Contrabajo...', style: TextStyle(color: Colors.white54)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Título de abajo
              Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  'BANDA SINFONICA SAN MIGUEL DE GARZÓN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colores.amarillo,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}