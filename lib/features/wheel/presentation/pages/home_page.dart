import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:karar_carki/features/wheel/domain/entities/wheel.dart';
import 'package:karar_carki/features/wheel/presentation/bloc/wheel_bloc.dart';
import 'package:karar_carki/features/wheel/presentation/pages/wheel_detail_page.dart';
import 'package:karar_carki/features/wheel/presentation/widgets/wheel_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Karar Çarkı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showInfoDialog(context);
            },
          ),
        ],
      ),
      body: BlocBuilder<WheelBloc, WheelState>(
        builder: (context, state) {
          if (state is WheelLoading) {
            return const Center(
              child: CircularProgressIndicator(),
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
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
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
                    Icon(
                      Icons.add_circle_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz çark oluşturulmamış',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Yeni bir çark oluşturmak için + butonuna tıklayın',
                      style: Theme.of(context).textTheme.bodyMedium,
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
                    child: WheelCard(
                      wheel: wheel,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WheelDetailPage(wheel: wheel),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCreateWheelDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Yeni Çark'),
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
                  ...options.map((option) => ListTile(
                    title: Text(option),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          options.remove(option);
                        });
                      },
                    ),
                  )),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
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
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add_circle),
                        onPressed: () {
                          final option = nameController.text.trim();
                          if (option.isNotEmpty) {
                            setState(() {
                              options.add(option);
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