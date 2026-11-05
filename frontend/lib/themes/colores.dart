import 'package:flutter/material.dart';

class Colores {
  // ===== NUEVA PALETA ELEGANTE (Azul noche + Oro) =====
  static const Color fondoColor = Color.fromARGB(255, 0, 0, 0);           // Azul slate oscuro (arriba)
  static const Color fondoBolitasOscuro = Color.fromARGB(255, 0, 0, 0);   // Azul casi negro (abajo)
  static const Color fondoBolitasClaro = Color(0xFF334155);    // Gris azulado para las "nubes"

  // Acentos
  static const Color oro = Color(0xFFD4AF37);                  // Oro clásico principal
  static const Color oroSuave = Color(0xFFE2BC65);             // Oro más claro
  static const Color naranja = Color(0xFFF59E0B);              // Ámbar (reemplazo suave del naranja fuerte)

  // Colores de apoyo (se mantienen para que no se rompa el resto de la app)
  static const Color verdeAcento = Color(0xFF0D8C35);
  static const Color botonClaro = Color(0xFFA5E0DC);
  static const Color cajaOscura = Color(0xFF0B3B3F);
  static const Color amarillo = Color(0xFFF2B84B);
  static const Color menuOscuro = Color(0xE60B3B3F);
  static const Color bloqueOscuro = Color.fromARGB(215, 14, 61, 61);

  // Transparentes para el fondo
  static const Color bolitaClara = Color(0x33334155);
  static const Color bolitaOscura = Color(0x40D4AF37);         // Oro transparente
  static const Color notaMusical = Color(0x55D4AF37);
  static const Color colorLetra1 = Color(0xFFE2BC65);
}
