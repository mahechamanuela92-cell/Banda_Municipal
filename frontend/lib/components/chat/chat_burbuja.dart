import 'package:flutter/material.dart';

class ChatBurbuja extends StatelessWidget {
  final String texto;
  final bool esUsuario;

  const ChatBurbuja({super.key, required this.texto, required this.esUsuario});

  bool _esFilaTabla(String linea) {
    final l = linea.trim();
    return l.startsWith('|') && l.endsWith('|') && l.split('|').length > 2;
  }

  bool _esSeparadorTabla(String linea) {
    final l = linea.trim();
    if (!_esFilaTabla(l)) return false;
    final celdas = l.substring(1, l.length - 1).split('|');
    return celdas.every((c) => RegExp(r'^[\s\-:]+$').hasMatch(c));
  }

  List<String> _parsearCeldas(String linea) {
    final l = linea.trim();
    final sinBordes = l.substring(1, l.length - 1);
    return sinBordes.split('|').map((c) => c.trim()).toList();
  }

  List<Widget> _construirContenido(BuildContext context, Color colorTexto) {
    if (esUsuario) {
      return [
        Text(
          texto,
          style: TextStyle(
            color: colorTexto,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ];
    }

    final lineas = texto.split('\n');
    final List<Widget> widgets = [];
    final StringBuffer bufferTexto = StringBuffer();
    final List<List<String>> filasTabla = [];

    void vaciarTexto() {
      final contenido = bufferTexto.toString().trim();
      if (contenido.isNotEmpty) {
        widgets.add(
          Text(
            contenido,
            style: TextStyle(
              color: colorTexto,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        );
      }
      bufferTexto.clear();
    }

    void vaciarTabla() {
      if (filasTabla.isEmpty) return;
      final headers = filasTabla.first;
      final dataRows = filasTabla.length > 1 ? filasTabla.sublist(1) : <List<String>>[];

      widgets.add(
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 42, 47, 48).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE2BC65).withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                const Color(0xFFE2BC65).withValues(alpha: 0.25),
              ),
              dataRowColor: WidgetStateProperty.all(Colors.transparent),
              columnSpacing: 16,
              horizontalMargin: 12,
              headingTextStyle: const TextStyle(
                color: Color(0xFFE2BC65),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              dataTextStyle: TextStyle(
                color: colorTexto,
                fontSize: 13,
              ),
              columns: headers
                  .map((h) => DataColumn(label: Text(h.replaceAll('**', ''))))
                  .toList(),
              rows: dataRows.map((fila) {
                final celdasAjustadas = List<String>.generate(
                  headers.length,
                  (i) => i < fila.length ? fila[i].replaceAll('**', '') : '',
                );
                return DataRow(
                  cells: celdasAjustadas.map((c) => DataCell(Text(c))).toList(),
                );
              }).toList(),
            ),
          ),
        ),
      );
      filasTabla.clear();
    }

    for (final linea in lineas) {
      if (_esSeparadorTabla(linea)) {
        continue;
      }
      if (_esFilaTabla(linea)) {
        vaciarTexto();
        filasTabla.add(_parsearCeldas(linea));
      } else {
        vaciarTabla();
        bufferTexto.writeln(linea);
      }
    }

    vaciarTabla();
    vaciarTexto();

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final colorTexto = esUsuario
        ? const Color.fromARGB(255, 0, 0, 0)
        : const Color.fromARGB(221, 255, 254, 254);

    return Align(
      alignment: esUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: esUsuario
              ? const Color(0xFFE2BC65)
              : const Color.fromARGB(255, 93, 95, 95).withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 255, 255, 255).withValues(alpha: 0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: _construirContenido(context, colorTexto),
        ),
      ),
    );
  }
}