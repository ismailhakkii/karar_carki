import 'package:karar_carki/features/wheel/domain/entities/wheel.dart';
import 'package:karar_carki/features/wheel/domain/repositories/wheel_repository.dart';

class GetAllWheels {
  final WheelRepository repository;

  GetAllWheels(this.repository);

  Future<List<Wheel>> call() async {
    return await repository.getAllWheels();
  }
} 