import 'package:flutter/material.dart';

class BuildCustomPainter extends CustomPainter {
  final Color lineColor;
  const BuildCustomPainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = lineColor
          ..strokeWidth = 0.8;
    for (double y = 0; y < size.height; y += 18) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x < size.width; x += 18) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant BuildCustomPainter old) => old.lineColor != lineColor;
}
