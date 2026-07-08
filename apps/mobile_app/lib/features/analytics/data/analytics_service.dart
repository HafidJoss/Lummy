import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(ref.watch(dioProvider));
});

class AnalyticsService {
  final Dio _dio;
  AnalyticsService(this._dio);

  Future<void> submitTestAttempt(String testType, Map<String, dynamic> responses) async {
    await _dio.post('/analytics/test-attempt', data: {
      'test_type': testType, // 'pre_test' o 'post_test'
      'responses': responses,
    });
  }

  // El endpoint de exportación es típicamente para administradores.
  // Aquí se deja la definición base para consumir el contrato.
  Future<void> exportData() async {
    await _dio.get('/analytics/export');
  }
}
