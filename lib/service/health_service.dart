// Singleton Health Service
import 'package:health/health.dart';

class HealthService {
  static final _startTime = DateTime(2024);
  static final _endTime = DateTime(2025);
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  final Health _health = Health();

  Future<void> init() async {
    await configure();
    await requestAuthorization(HealthDataType.values);
    await getHealthDataFromTypes(HealthDataType.values);
  }

  Future<void> configure() async {
    await _health.configure();
  }

  Future<void> requestAuthorization(List<HealthDataType> types) async {
    await _health.requestAuthorization(types);
  }

  Future<List<HealthDataPoint>> getHealthDataFromTypes(
      List<HealthDataType> types) async {
    return await _health.getHealthDataFromTypes(
        types: types, startTime: _startTime, endTime: _endTime);
  }

  Future<int> getSteps() async {
    final now = DateTime.now();
    var midnight = DateTime(now.year, now.month, now.day);
    int? steps = await _health.getTotalStepsInInterval(midnight, now);
    return steps ?? -1;
  }
}
