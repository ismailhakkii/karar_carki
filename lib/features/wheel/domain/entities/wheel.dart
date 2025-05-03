import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class Wheel extends Equatable {
  final String id;
  final String name;
  final List<String> options;
  final DateTime createdAt;
  final DateTime? lastUsedAt;

  const Wheel({
    required this.id,
    required this.name,
    required this.options,
    required this.createdAt,
    this.lastUsedAt,
  });

  factory Wheel.create({
    required String name,
    required List<String> options,
  }) {
    return Wheel(
      id: const Uuid().v4(),
      name: name,
      options: options,
      createdAt: DateTime.now(),
    );
  }

  Wheel copyWith({
    String? name,
    List<String>? options,
    DateTime? lastUsedAt,
  }) {
    return Wheel(
      id: id,
      name: name ?? this.name,
      options: options ?? this.options,
      createdAt: createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, options, createdAt, lastUsedAt];
} 