import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:karar_carki/features/wheel/domain/entities/wheel.dart';
import 'package:karar_carki/features/wheel/presentation/bloc/wheel_bloc.dart';
import 'package:karar_carki/features/wheel/presentation/widgets/wheel_painter.dart';

class WheelDetailPage extends StatefulWidget {
  final Wheel wheel;

  const WheelDetailPage({
    super.key,
    required this.wheel,
  });

  @override
  State<WheelDetailPage> createState() => _WheelDetailPageState();
}

class _WheelDetailPageState extends State<WheelDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String? _selectedOption;
  bool _isSpinning = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spinWheel() {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _selectedOption = null;
    });

    final random = Random();
    final rotations = 5 + random.nextInt(5);
    final angle = random.nextDouble() * 2 * pi;

    _controller.reset();
    _controller.forward().then((_) {
      setState(() {
        _isSpinning = false;
        final index = (angle / (2 * pi / widget.wheel.options.length)).floor();
        _selectedOption = widget.wheel.options[index];
        
        // Update last used time
        final updatedWheel = widget.wheel.copyWith(
          lastUsedAt: DateTime.now(),
        );
        context.read<WheelBloc>().add(UpdateWheel(updatedWheel));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wheel.name),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              height: 300,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _animation.value * 2 * pi * 5,
                    child: CustomPaint(
                      painter: WheelPainter(
                        options: widget.wheel.options,
                        selectedIndex: _selectedOption != null
                            ? widget.wheel.options.indexOf(_selectedOption!)
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            if (_selectedOption != null) ...[
              Text(
                'Seçilen: $_selectedOption',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton(
              onPressed: _isSpinning ? null : _spinWheel,
              child: Text(_isSpinning ? 'Dönüyor...' : 'Çevir'),
            ),
          ],
        ),
      ),
    );
  }
} 