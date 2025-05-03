import 'dart:convert';
import 'package:karar_carki/features/wheel/domain/entities/wheel.dart';
import 'package:karar_carki/features/wheel/domain/repositories/wheel_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WheelRepositoryImpl implements WheelRepository {
  static const String _wheelsKey = 'wheels';

  @override
  Future<List<Wheel>> getAllWheels() async {
    final prefs = await SharedPreferences.getInstance();
    final wheelsJson = prefs.getStringList(_wheelsKey) ?? [];
    
    return wheelsJson.map((json) {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return Wheel(
        id: map['id'] as String,
        name: map['name'] as String,
        options: List<String>.from(map['options'] as List),
        createdAt: DateTime.parse(map['createdAt'] as String),
        lastUsedAt: map['lastUsedAt'] != null 
            ? DateTime.parse(map['lastUsedAt'] as String)
            : null,
      );
    }).toList();
  }

  @override
  Future<Wheel> getWheelById(String id) async {
    final wheels = await getAllWheels();
    return wheels.firstWhere((wheel) => wheel.id == id);
  }

  @override
  Future<void> saveWheel(Wheel wheel) async {
    final prefs = await SharedPreferences.getInstance();
    final wheels = await getAllWheels();
    
    final existingIndex = wheels.indexWhere((w) => w.id == wheel.id);
    if (existingIndex != -1) {
      wheels[existingIndex] = wheel;
    } else {
      wheels.add(wheel);
    }
    
    final wheelsJson = wheels.map((wheel) {
      return jsonEncode({
        'id': wheel.id,
        'name': wheel.name,
        'options': wheel.options,
        'createdAt': wheel.createdAt.toIso8601String(),
        'lastUsedAt': wheel.lastUsedAt?.toIso8601String(),
      });
    }).toList();
    
    await prefs.setStringList(_wheelsKey, wheelsJson);
  }

  @override
  Future<void> deleteWheel(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final wheels = await getAllWheels();
    
    wheels.removeWhere((wheel) => wheel.id == id);
    
    final wheelsJson = wheels.map((wheel) {
      return jsonEncode({
        'id': wheel.id,
        'name': wheel.name,
        'options': wheel.options,
        'createdAt': wheel.createdAt.toIso8601String(),
        'lastUsedAt': wheel.lastUsedAt?.toIso8601String(),
      });
    }).toList();
    
    await prefs.setStringList(_wheelsKey, wheelsJson);
  }

  @override
  Future<void> updateWheel(Wheel wheel) async {
    await saveWheel(wheel);
  }
} 