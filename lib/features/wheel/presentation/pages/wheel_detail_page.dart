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
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  String? _selectedOption;
  bool _isSpinning = false;
  double _currentRotation = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi * 5, // 5 tam tur
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
          _calculateSelectedOption();
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _calculateSelectedOption() {
    final anglePerOption = 2 * pi / widget.wheel.options.length;
    final normalizedRotation = _currentRotation % (2 * pi);
    final selectedIndex = (normalizedRotation / anglePerOption).floor();
    setState(() {
      _selectedOption = widget.wheel.options[selectedIndex];
    });
  }

  void _spinWheel() {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _selectedOption = null;
    });

    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wheel.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // TODO: Implement favorite functionality
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                _currentRotation = _rotationAnimation.value;
                return Transform.rotate(
                  angle: _currentRotation,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: CustomPaint(
                      size: const Size(300, 300),
                      painter: WheelPainter(
                        options: widget.wheel.options,
                        selectedOption: _selectedOption,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            if (_selectedOption != null)
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Seçilen: $_selectedOption',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSpinning ? null : _spinWheel,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _isSpinning ? 'Çark Dönüyor...' : 'Çarkı Çevir',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 