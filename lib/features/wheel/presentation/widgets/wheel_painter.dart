import 'dart:math';
import 'package:flutter/material.dart';

class WheelPainter extends CustomPainter {
  final List<String> options;
  final int? selectedIndex;

  WheelPainter({
    required this.options,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final angleStep = 2 * pi / options.length;

    for (var i = 0; i < options.length; i++) {
      final startAngle = i * angleStep;
      final endAngle = (i + 1) * angleStep;

      // Draw segment
      paint.color = i == selectedIndex
          ? Colors.amber
          : Color.lerp(Colors.blue, Colors.purple, i / options.length)!;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        angleStep,
        true,
        paint,
      );

      // Draw text
      final text = options[i];
      textPainter.text = TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();

      final textAngle = startAngle + angleStep / 2;
      final textOffset = Offset(
        center.dx + (radius * 0.6) * cos(textAngle),
        center.dy + (radius * 0.6) * sin(textAngle),
      );

      canvas.save();
      canvas.translate(textOffset.dx, textOffset.dy);
      canvas.rotate(textAngle + pi / 2);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }

    // Draw center circle
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.1, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 