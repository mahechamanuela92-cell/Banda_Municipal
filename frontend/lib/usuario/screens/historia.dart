import 'package:flutter/material.dart';
import '../../themes/colores.dart';
import '../../widgets/fondos.dart';
class PantallaHistoria extends StatelessWidget {
  const PantallaHistoria({super.key});

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

              // Caja oscura con la historia
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colores.bloqueOscuro,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NUESTRA HISTORIA',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          'La Banda Sinfónica Municipal de Garzón es el pilar cultural de la "Capital Diocesana" del Huila. Con una trayectoria que nace de la tradición de las retretas del siglo XX, se ha consolidado como una institución esencial para la formación artística de la juventud garzonena, fusionando la disciplina técnica con el sentimiento regional.\n\n'
                          'Es reconocida por su maestría en ritmos tradicionales como el bambuco y el pasillo, además de un amplio repertorio internacional y clásico. Funciona como una escuela de vida, permitiendo que niños y jóvenes se profesionalicen en música de viento y percusión.\n\n'
                          'Participaciones constantes en el Concurso Nacional de Bandas de Paipa. Fue galardonada como una de las 10 mejores bandas del Huila, reafirmando su excelencia musical en el departamento. Bajo la dirección de maestros locales, continúa siendo el alma de las festividades en la Catedral de San Miguel y el parque principal, manteniendo vigente el patrimonio musical del municipio.\n\n',
                          textAlign: TextAlign.justify,
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ],
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