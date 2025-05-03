import 'package:flutter/material.dart';
import 'package:karar_carki/features/wheel/domain/entities/wheel.dart';

class WheelCard extends StatelessWidget {
  final Wheel wheel;
  final VoidCallback onTap;

  const WheelCard({
    super.key,
    required this.wheel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                wheel.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '${wheel.options.length} seçenek',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
              ),
              if (wheel.lastUsedAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Son kullanım: ${_formatDate(wheel.lastUsedAt!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 