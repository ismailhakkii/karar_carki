import 'package:flutter/material.dart';

class OnboardingProvider with ChangeNotifier {
  bool _isFirstLaunch = true;

  bool get isFirstLaunch => _isFirstLaunch;

  void completeOnboarding() {
    _isFirstLaunch = false;
    notifyListeners();
  }
} 