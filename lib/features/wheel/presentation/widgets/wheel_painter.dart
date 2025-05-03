import 'dart:math';
import 'package:flutter/material.dart';

class WheelPainter extends CustomPainter {
  final List<String> options;
  final String? selectedOption;

  WheelPainter({
    required this.options,
    this.selectedOption,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final anglePerOption = 2 * pi / options.length;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    for (int i = 0; i < options.length; i++) {
      final startAngle = i * anglePerOption;
      final endAngle = (i + 1) * anglePerOption;

      // Seçili seçenek için farklı renk
      if (selectedOption == options[i]) {
        paint.color = Colors.green.withOpacity(0.3);
      } else {
        paint.color = Colors.primaries[i % Colors.primaries.length].withOpacity(0.3);
      }

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        anglePerOption,
        true,
        paint,
      );

      // Seçenek metni
      final textPainter = TextPainter(
        text: TextSpan(
          text: options[i],
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final textAngle = startAngle + anglePerOption / 2;
      final textOffset = Offset(
        center.dx + (radius * 0.7) * cos(textAngle),
        center.dy + (radius * 0.7) * sin(textAngle),
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

    // Merkez nokta
    canvas.drawCircle(
      center,
      10,
      Paint()..color = Colors.black,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 