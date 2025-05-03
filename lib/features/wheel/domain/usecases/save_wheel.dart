import 'package:karar_carki/features/wheel/domain/entities/wheel.dart';
import 'package:karar_carki/features/wheel/domain/repositories/wheel_repository.dart';

class SaveWheel {
  final WheelRepository repository;

  SaveWheel(this.repository);

  Future<void> call(Wheel wheel) async {
    return await repository.saveWheel(wheel);
  }
} 