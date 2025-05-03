import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:karar_carki/features/wheel/domain/entities/wheel.dart';
import 'package:karar_carki/features/wheel/presentation/bloc/wheel_bloc.dart';
import 'package:karar_carki/features/wheel/presentation/widgets/wheel_painter.dart';
import 'package:karar_carki/features/common/widgets/custom_app_bar.dart';
import 'package:confetti/confetti.dart';

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
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));

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
        _confettiController.play();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
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
      appBar: CustomAppBar(
        title: widget.wheel.name,
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {
              // TODO: Implement favorite functionality
            },
          ),
        ],
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    _currentRotation = _rotationAnimation.value;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.rotate(
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
                        ),
                        if (_isSpinning)
                          AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Container(
                                width: 320,
                                height: 320,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.yellow.withOpacity(0.2 + 0.2 * sin(_animationController.value * pi)),
                                      Colors.transparent,
                                    ],
                                    stops: [0.7, 1.0],
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),
                if (_selectedOption != null)
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.7, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _fadeAnimation,
                        curve: Curves.elasticOut,
                      ),
                    ),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.celebration, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Seçilen: $_selectedOption',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
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
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              emissionFrequency: 0.2,
              numberOfParticles: 30,
              maxBlastForce: 30,
              minBlastForce: 10,
              gravity: 0.3,
              colors: [
                Colors.pink,
                Colors.blue,
                Colors.orange,
                Colors.green,
                Colors.purple,
                Colors.yellow,
              ],
            ),
          ],
        ),
      ),
    );
  }
} 