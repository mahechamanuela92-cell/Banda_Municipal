import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../themes/colores.dart';
import '../../widgets/fondos.dart';

class InventarioPartituras extends StatefulWidget {
  const InventarioPartituras({super.key});

  @override
  State<InventarioPartituras> createState() => _InventarioPartiturasState();
}

class _InventarioPartiturasState extends State<InventarioPartituras> {
  List<String> partituras = ['Himno de Colombia', 'Himno del Huila', 'Marcha Triunfal'];
  List<String> tipos = ['PDF', 'Imagen', 'Word'];
  
  // Listas para instrumentos y voces
  final List<String> instrumentos = [
    'Flauta Traversa', 'Flauta Picolo', 'Clarinete', 'Saxófono',
    'Oboe', 'Fagot', 'Trompeta', 'Fliscorno', 'Trombón',
    'Bombardino', 'Tuba', 'Corneta', 'Violín', 'Viola',
    'Violonchelo', 'Contrabajo', 'Bombo', 'Redoblante',
    'Platillos', 'Batería', 'Glockenspiel', 'Timbales Sinfónicos',
    'Congas', 'Timbal'
  ];

  final List<String> voces = ['Voz 1', 'Voz 2', 'Voz 3', 'Voz 4', 'Voz 5', 'Voz 6', 'Voz 7'];

  bool mostrarLista = false;
  String? tipoElegido;
  String? nombreArchivo;
  String? instrumentoElegido;
  String? vozElegida;

  // Abre los documentos del celular según el tipo
  void elegirArchivo(String tipo) async {
    List<String> extensiones = ['pdf'];
    if (tipo == 'Imagen') extensiones = ['jpg', 'jpeg', 'png'];
    if (tipo == 'Word') extensiones = ['doc', 'docx'];

    FilePickerResult? resultado = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensiones,
    );
    if (resultado != null) {
      setState(() => nombreArchivo = resultado.files.single.name);
    }
  }

  // Agrega el archivo y vuelve a la pantalla de inicio
  void guardar() {
    if (nombreArchivo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero elige un archivo')),
      );
      return;
    }
    partituras.add(nombreArchivo!);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Partitura guardada')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoBase(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colores.naranja, size: 30),
                  tooltip: 'Volver',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    // Imagen del ave (detrás)
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 80),
                        child: Image.asset('assets/images/fondo_login.png', height: 180),
                      ),
                    ),
                    // Bloque contenedor oscuro semitransparente extendido hacia abajo
                    Container(
                      margin: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colores.bloqueOscuro,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Column(
                          children: [
                            const Text(
                              'Inventario de Partituras',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          
                            // Espacio donde queda el ave expuesta
                            const SizedBox(height: 200),

                            TextButton(
                              onPressed: () => setState(() => mostrarLista = !mostrarLista),
                              child: const Text(
                                'Lista ▾',
                                style: TextStyle(color: Colors.white, fontSize: 22),
                              ),
                            ),

                            // Recuadro claro de la Lista
                            Container(
                              width: double.infinity,
                              height: 180,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colores.botonClaro,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: mostrarLista
                                  ? GridView.count(
                                      crossAxisCount: 2,
                                      childAspectRatio: 5,
                                      children: [
                                        for (String nombre in partituras)
                                          Text(nombre, style: const TextStyle(fontSize: 14, color: Colors.black)),
                                      ],
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 24),
                            
                            // Sección Agregar Documento dentro del mismo fondo oscuro
                            const Text(
                              'Agregar Documento',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colores.botonClaro,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButton<String>(
                                value: tipoElegido,
                                hint: const Text('Subir archivo', style: TextStyle(color: Colors.black54)),
                                isExpanded: true,
                                underline: const SizedBox(),
                                dropdownColor: Colores.botonClaro,
                                items: [
                                  for (String tipo in tipos)
                                    DropdownMenuItem(value: tipo, child: Text(tipo)),
                                ],
                                onChanged: (valor) {
                                  setState(() => tipoElegido = valor);
                                  elegirArchivo(valor!);
                                },
                              ),
                            ),
                            if (nombreArchivo != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Archivo: $nombreArchivo',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),

                            const SizedBox(height: 24),

                            // --- NUEVO: SECCIÓN ELEGIR INSTRUMENTO ---
                            const Text(
                              'Elegir Instrumento',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colores.botonClaro,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButton<String>(
                                value: instrumentoElegido,
                                hint: const Text('Seleccionar instrumento', style: TextStyle(color: Colors.black54)),
                                isExpanded: true,
                                underline: const SizedBox(),
                                dropdownColor: Colores.botonClaro,
                                items: [
                                  for (String instrumento in instrumentos)
                                    DropdownMenuItem(value: instrumento, child: Text(instrumento)),
                                ],
                                onChanged: (valor) {
                                  setState(() => instrumentoElegido = valor);
                                },
                              ),
                            ),

                            const SizedBox(height: 24),

                            // --- NUEVO: SECCIÓN SELECCIONAR VOZ ---
                            const Text(
                              'Seleccionar Voz',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colores.botonClaro,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButton<String>(
                                value: vozElegida,
                                hint: const Text('Seleccionar voz', style: TextStyle(color: Colors.black54)),
                                isExpanded: true,
                                underline: const SizedBox(),
                                dropdownColor: Colores.botonClaro,
                                items: [
                                  for (String voz in voces)
                                    DropdownMenuItem(value: voz, child: Text(voz)),
                                ],
                                onChanged: (valor) {
                                  setState(() => vozElegida = valor);
                                },
                              ),
                            ),

                            const SizedBox(height: 40),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colores.botonClaro,
                                foregroundColor: Colores.bloqueOscuro,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: guardar,
                              child: const Text('Guardar', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Texto inferior fuera del bloque
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Text(
                  'BANDA SINFONICA SAN MIGUEL\nGARZÓN HUILA',
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
        ),
      ),
    );
  }
}