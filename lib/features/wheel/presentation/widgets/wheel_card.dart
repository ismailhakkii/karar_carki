import 'dart:math';
import 'package:flutter/material.dart';
import 'package:karar_carki/features/wheel/domain/entities/wheel.dart';

class WheelCard extends StatefulWidget {
  final Wheel wheel;
  final VoidCallback onTap;

  const WheelCard({
    super.key,
    required this.wheel,
    required this.onTap,
  });

  @override
  State<WheelCard> createState() => _WheelCardState();
}

class _WheelCardState extends State<WheelCard> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> gradients = [
      Colors.pinkAccent,
      Colors.blueAccent,
      Colors.orangeAccent,
      Colors.greenAccent,
      Colors.purpleAccent,
      Colors.yellowAccent,
    ];
    final random = Random(widget.wheel.name.hashCode);
    final gradientColors = [
      gradients[random.nextInt(gradients.length)],
      gradients[random.nextInt(gradients.length)],
    ];
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: value,
            child: child,
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(_isPressed ? 0.5 : 0.25),
              blurRadius: _isPressed ? 24 : 12,
              spreadRadius: _isPressed ? 4 : 2,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          onHighlightChanged: (pressed) {
            setState(() {
              _isPressed = pressed;
            });
          },
          child: AnimatedScale(
            scale: _isPressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.casino, color: Colors.white.withOpacity(0.8)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.wheel.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.wheel.options.length} seçenek',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  if (widget.wheel.lastUsedAt != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Son kullanım: ${_formatDate(widget.wheel.lastUsedAt!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white60,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 