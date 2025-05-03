import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:karar_carki/core/providers/theme_provider.dart';
import 'package:karar_carki/features/wheel/domain/entities/wheel.dart';
import 'package:karar_carki/features/wheel/presentation/bloc/wheel_bloc.dart';
import 'package:karar_carki/features/wheel/presentation/pages/wheel_detail_page.dart';
import 'package:karar_carki/features/wheel/presentation/widgets/wheel_card.dart';
import 'package:karar_carki/features/common/widgets/custom_app_bar.dart';
import 'package:simple_animations/simple_animations.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fabController;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fabController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Karar Çarkı',
        actions: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: IconButton(
              icon: Icon(
                Provider.of<ThemeProvider>(context).isDarkMode
                    ? Icons.light_mode
                    : Icons.dark_mode,
                color: Colors.white,
              ),
              onPressed: () {
                final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                themeProvider.setThemeMode(
                  themeProvider.isDarkMode ? ThemeMode.light : ThemeMode.dark,
                );
              },
            ),
          ),
          FadeTransition(
            opacity: _fadeAnimation,
            child: IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white),
              onPressed: () {
                _showInfoDialog(context);
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          AnimatedBackground(),
          BlocBuilder<WheelBloc, WheelState>(
            builder: (context, state) {
              if (state is WheelLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: const Text('Yükleniyor...'),
                      ),
                    ],
                  ),
                );
              } else if (state is WheelError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          state.message,
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<WheelBloc>().add(const LoadWheels());
                        },
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                );
              } else if (state is WheelLoaded) {
                if (state.wheels.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Icon(
                            Icons.add_circle_outline,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            'Henüz çark oluşturulmamış',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            'Yeni bir çark oluşturmak için + butonuna tıklayın',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return AnimatedList(
                  padding: const EdgeInsets.all(16),
                  initialItemCount: state.wheels.length,
                  itemBuilder: (context, index, animation) {
                    final wheel = state.wheels[index];
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOut,
                      )),
                      child: FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(
                            begin: 0.8,
                            end: 1.0,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut,
                          )),
                          child: WheelCard(
                            wheel: wheel,
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) =>
                                      WheelDetailPage(wheel: wheel),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      floatingActionButton: Stack(
        alignment: Alignment.center,
        children: [
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            emissionFrequency: 0.2,
            numberOfParticles: 20,
            maxBlastForce: 20,
            minBlastForce: 8,
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
          AnimatedBuilder(
            animation: _fabController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1 + 0.08 * sin(_fabController.value * 2 * pi),
                child: child,
              );
            },
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    _showCreateWheelDialog(context);
                    _confettiController.play();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Yeni Çark'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Karar Çarkı Hakkında'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Karar vermekte zorlandığınız durumlarda size yardımcı olacak bir uygulama.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Nasıl Kullanılır?',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '1. Yeni bir çark oluşturun\n2. Seçenekleri girin\n3. Çarkı çevirin ve kararınızı alın!',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showCreateWheelDialog(BuildContext context) {
    final nameController = TextEditingController();
    final List<String> options = [];
    final formKey = GlobalKey<FormState>();
    final optionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Yeni Çark Oluştur'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Çark Adı',
                      hintText: 'Örn: Hafta Sonu Planları',
                      prefixIcon: const Icon(Icons.title),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Lütfen bir çark adı girin';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Seçenekler',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (options.isEmpty)
                    const Text(
                      'Henüz seçenek eklenmemiş',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ...options.map((option) => Dismissible(
                    key: Key(option),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      color: Colors.red,
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (direction) {
                      setState(() {
                        options.remove(option);
                      });
                    },
                    child: ListTile(
                      title: Text(option),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            options.remove(option);
                          });
                        },
                      ),
                    ),
                  )),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: optionController,
                          decoration: InputDecoration(
                            labelText: 'Yeni Seçenek',
                            hintText: 'Seçenek ekle',
                            prefixIcon: const Icon(Icons.add),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onFieldSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              setState(() {
                                options.add(value.trim());
                                optionController.clear();
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add_circle),
                        onPressed: () {
                          final option = optionController.text.trim();
                          if (option.isNotEmpty) {
                            setState(() {
                              options.add(option);
                              optionController.clear();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    if (options.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('En az bir seçenek eklemelisiniz'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (options.length < 2) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('En az iki seçenek eklemelisiniz'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final wheel = Wheel.create(
                      name: nameController.text.trim(),
                      options: options,
                    );
                    context.read<WheelBloc>().add(AddWheel(wheel));
                    Navigator.pop(context);
                  }
                },
                child: const Text('Oluştur'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class AnimatedBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MirrorAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 2 * 3.14),
      duration: const Duration(seconds: 10),
      builder: (context, value, child) {
        return CustomPaint(
          painter: ParticlePainter(value),
          child: Container(),
        );
      },
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double value;
  ParticlePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);
    for (int i = 0; i < 30; i++) {
      final radius = 8.0 + random.nextDouble() * 12;
      final dx = (size.width * random.nextDouble()) +
          20 * sin(value + i);
      final dy = (size.height * random.nextDouble()) +
          20 * cos(value + i);
      final paint = Paint()
        ..color = Colors.primaries[i % Colors.primaries.length].withOpacity(0.15);
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
} 