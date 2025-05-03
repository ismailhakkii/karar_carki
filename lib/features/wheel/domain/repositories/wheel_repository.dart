import 'package:karar_carki/features/wheel/domain/entities/wheel.dart';

abstract class WheelRepository {
  Future<List<Wheel>> getAllWheels();
  Future<Wheel> getWheelById(String id);
  Future<void> saveWheel(Wheel wheel);
  Future<void> deleteWheel(String id);
  Future<void> updateWheel(Wheel wheel);
} 