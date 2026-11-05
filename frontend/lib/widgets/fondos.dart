import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../themes/colores.dart';

class FondoBase extends StatefulWidget {
  final Widget child;

  const FondoBase({
    super.key,
    required this.child,
  });

  @override
  State<FondoBase> createState() => _FondoBaseState();
}

class _FondoBaseState extends State<FondoBase>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Un poco más lento = más elegante
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colores.fondoColor,          // #0F172A
            Colores.fondoBolitasOscuro,  // #020617
          ],
        ),
      ),
      child: Stack(
        children: [
          // Animación del fondo
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: FondoMusicalPainter(progress: _controller.value),
                );
              },
            ),
          ),
          // Contenido de la pantalla
          widget.child,
        ],
      ),
    );
  }
}

class FondoMusicalPainter extends CustomPainter {
  final double progress;

  FondoMusicalPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // --- Nubes / bolitas sutiles ---
    final Paint paintNubesClaras = Paint()
      ..color = Colores.fondoBolitasClaro.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    final Paint paintNubesOscuras = Paint()
      ..color = Colores.fondoBolitasClaro.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    // Líneas de los pentagramas (oro muy suave)
    final Paint paintLineas = Paint()
      ..color = Colores.oro.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    // Notas musicales (oro)
    final Paint paintNotas = Paint()
      ..color = const Color.fromARGB(255, 235, 216, 50).withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    // --- 1. Formas circulares de fondo (más sutiles) ---
    canvas.drawCircle(Offset(width * 0.1, height * 0.05), width * 0.35, paintNubesClaras);
    canvas.drawCircle(Offset(width * 0.85, height * 0.1), width * 0.45, paintNubesClaras);
    canvas.drawCircle(Offset(width * 0.1, height * 0.35), width * 0.4, paintNubesClaras);
    canvas.drawCircle(Offset(width * 0.9, height * 0.65), width * 0.35, paintNubesClaras);
    canvas.drawCircle(Offset(width * 0.2, height * 0.9), width * 0.5, paintNubesClaras);

    canvas.drawCircle(Offset(width * 0.5, height * 0.18), width * 0.22, paintNubesOscuras);
    canvas.drawCircle(Offset(width * 0.2, height * 0.52), width * 0.28, paintNubesOscuras);
    canvas.drawCircle(Offset(width * 0.78, height * 0.45), width * 0.2, paintNubesOscuras);
    canvas.drawCircle(Offset(width * 0.55, height * 0.82), width * 0.32, paintNubesOscuras);

    // --- Oscilación suave ---
    final double oscilacionLeve = math.sin(progress * 2 * math.pi) * 6.0;

    // --- 2. Pentagrama Superior + Notas ---
    final Offset p1Top = Offset(-20, height * 0.52 + oscilacionLeve);
    final Offset p2Top = Offset(width * 0.3, height * 0.44 + oscilacionLeve);
    final Offset p3Top = Offset(width * 0.7, height * 0.38 + oscilacionLeve);
    final Offset p4Top = Offset(width + 20, height * 0.15 + oscilacionLeve);

    _dibujarPentagrama(canvas, paintLineas, p1: p1Top, p2: p2Top, p3: p3Top, p4: p4Top);

    _dibujarNotaSimple(canvas, _calcularBezier((0.18 + progress) % 1.0, p1Top, p2Top, p3Top, p4Top), paintNotas, paintLineas);
    _dibujarNotaDoble(canvas, _calcularBezier((0.40 + progress) % 1.0, p1Top, p2Top, p3Top, p4Top), paintNotas, paintLineas);
    _dibujarNotaSimple(canvas, _calcularBezier((0.65 + progress) % 1.0, p1Top, p2Top, p3Top, p4Top), paintNotas, paintLineas);
    _dibujarNotaDoble(canvas, _calcularBezier((0.85 + progress) % 1.0, p1Top, p2Top, p3Top, p4Top), paintNotas, paintLineas);

    // --- 3. Pentagrama Inferior + Notas ---
    final Offset p1Bot = Offset(-20, height * 0.82 + oscilacionLeve);
    final Offset p2Bot = Offset(width * 0.4, height * 0.9 + oscilacionLeve);
    final Offset p3Bot = Offset(width * 0.6, height * 0.65 + oscilacionLeve);
    final Offset p4Bot = Offset(width + 20, height * 0.63 + oscilacionLeve);

    _dibujarPentagrama(canvas, paintLineas, p1: p1Bot, p2: p2Bot, p3: p3Bot, p4: p4Bot);

    _dibujarNotaDoble(canvas, _calcularBezier((0.15 + progress) % 1.0, p1Bot, p2Bot, p3Bot, p4Bot), paintNotas, paintLineas);
    _dibujarNotaSimple(canvas, _calcularBezier((0.38 + progress) % 1.0, p1Bot, p2Bot, p3Bot, p4Bot), paintNotas, paintLineas);
    _dibujarNotaSimple(canvas, _calcularBezier((0.62 + progress) % 1.0, p1Bot, p2Bot, p3Bot, p4Bot), paintNotas, paintLineas);
    _dibujarNotaDoble(canvas, _calcularBezier((0.85 + progress) % 1.0, p1Bot, p2Bot, p3Bot, p4Bot), paintNotas, paintLineas);

    // --- 4. Líneas decorativas en oro/ámbar ---
    _dibujarLineasDecorativasGradient(canvas, size);
  }

  void _dibujarLineasDecorativasGradient(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // Gradiente elegante oro → ámbar
    final Gradient gradient = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: const [
        Color.fromARGB(255, 238, 234, 9), // Amarillo
        Color.fromARGB(255, 235, 156, 10), // Naranja
        Color.fromARGB(255, 245, 11, 214), // Rosa
        Color.fromARGB(255, 78, 21, 236), // Morado
      ],
      transform: GradientRotation(progress * 2 * math.pi),
    );

    final Paint paintGradient = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, width, height));

    final double offsetY = math.sin(progress * 2 * math.pi) * 10.0;

    // Línea superior derecha
    final pathTopRight = Path();
    pathTopRight.moveTo(width * 0.72, offsetY);
    pathTopRight.cubicTo(
      width * 0.82, height * 0.05 + offsetY,
      width * 0.88, offsetY,
      width + 10, height * 0.065 + offsetY,
    );
    canvas.drawPath(pathTopRight, paintGradient);

    // Línea lateral izquierda
    final pathLeft = Path();
    pathLeft.moveTo(-10, height * 0.31 + offsetY);
    pathLeft.cubicTo(
      width * 0.2, height * 0.37 + offsetY,
      width * 0.12, height * 0.44 + offsetY,
      -10, height * 0.46 + offsetY,
    );
    canvas.drawPath(pathLeft, paintGradient);

    // Línea inferior derecha
    final pathBottomRight = Path();
    pathBottomRight.moveTo(width + 5, height * 0.78 + offsetY);
    pathBottomRight.cubicTo(
      width * 0.85, height * 0.88 + offsetY,
      width * 0.55, height * 0.94 + offsetY,
      width * 0.62, height + 10 + offsetY,
    );
    canvas.drawPath(pathBottomRight, paintGradient);
  }

  Offset _calcularBezier(double t, Offset p0, Offset p1, Offset p2, Offset p3) {
    final double u = 1 - t;
    final double tt = t * t;
    final double uu = u * u;
    final double uuu = uu * u;
    final double ttt = tt * t;

    double x = uuu * p0.dx + 3 * uu * t * p1.dx + 3 * u * tt * p2.dx + ttt * p3.dx;
    double y = uuu * p0.dy + 3 * uu * t * p1.dy + 3 * u * tt * p2.dy + ttt * p3.dy;

    return Offset(x, y);
  }

  void _dibujarPentagrama(
    Canvas canvas,
    Paint paint, {
    required Offset p1,
    required Offset p2,
    required Offset p3,
    required Offset p4,
  }) {
    const double espaciado = 8.5;
    for (int i = 0; i < 5; i++) {
      final double offset = (i - 2) * espaciado;
      final path = Path();
      path.moveTo(p1.dx, p1.dy + offset);
      path.cubicTo(
        p2.dx, p2.dy + offset,
        p3.dx, p3.dy + offset,
        p4.dx, p4.dy + offset,
      );
      canvas.drawPath(path, paint);
    }
  }

  void _dibujarNotaSimple(Canvas canvas, Offset pos, Paint paintFill, Paint paintStroke) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(-15 * math.pi / 180);

    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 14, height: 10),
      paintFill,
    );
    canvas.drawLine(const Offset(5.5, 0), const Offset(5.5, -23), paintStroke);

    canvas.restore();
  }

  void _dibujarNotaDoble(Canvas canvas, Offset pos, Paint paintFill, Paint paintStroke) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);

    canvas.save();
    canvas.rotate(-15 * math.pi / 180);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 14, height: 10),
      paintFill,
    );
    canvas.restore();
    canvas.drawLine(const Offset(5, 0), const Offset(5, -25), paintStroke);

    canvas.save();
    canvas.translate(20, -3);
    canvas.rotate(-15 * math.pi / 180);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 14, height: 10),
      paintFill,
    );
    canvas.restore();
    canvas.drawLine(const Offset(25, -3), const Offset(25, -28), paintStroke);

    final paintBarra = Paint()
      ..color = paintFill.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2;

    canvas.drawLine(const Offset(5, -25), const Offset(25, -28), paintBarra);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant FondoMusicalPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
