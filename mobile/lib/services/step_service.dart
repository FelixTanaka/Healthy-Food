import 'package:pedometer/pedometer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/services/api_service.dart';

class StepService {
  static final StepService _instance = StepService._internal();
  factory StepService() => _instance;
  StepService._internal();

  int _baseline = 0;
  bool _isFirst = true;

  double _weight = 0.0;

  int _steps = 0;
  double _calories = 0;

  bool _isWeightLoaded = false;

  double get weight => _weight;


  Future<void> initUserWeight() async {
    if (_isWeightLoaded) return; 

    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(
       Uri.parse("${ApiService.baseUrl}/api/berat-user"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _weight = double.parse(data['berat'].toString());
      _isWeightLoaded = true;
    }
  }

  Stream<StepData> get stepStream async* {
    await for (final event in Pedometer.stepCountStream) {
      int rawSteps = event.steps;

      if (_isFirst) {
        _baseline = rawSteps;
        _isFirst = false;
      }

      int currentSteps = rawSteps - _baseline;
      if (currentSteps < 0) currentSteps = 0;

      _steps = currentSteps;
      _calories = _calculateCalories(currentSteps);

      yield StepData(
        steps: _steps,
        calories: _calories,
      );
    }
  }

  double _calculateCalories(int steps) {
    return steps * 0.04 * (_weight / 70);
  }
}

class StepData {
  final int steps;
  final double calories;

  StepData({
    required this.steps,
    required this.calories,
  });
}