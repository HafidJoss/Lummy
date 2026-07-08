import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../domain/challenge_models.dart';

final challengeRepositoryProvider = Provider<ChallengeRepository>((ref) {
  return ChallengeRepository(ref.watch(dioProvider));
});

class ChallengeRepository {
  final Dio _dio;
  ChallengeRepository(this._dio);

  Future<ChallengeSession> startSession() async {
    final response = await _dio.post('/challenge/start');
    return ChallengeSession.fromJson(response.data);
  }

  Future<AnswerResult> answerQuestion(String sessionId, String sessionQuestionId, String selectedOptionKey, int responseTimeMs) async {
    final response = await _dio.post('/challenge/$sessionId/answer', data: {
      'session_question_id': sessionQuestionId,
      'selected_option_key': selectedOptionKey,
      'response_time_ms': responseTimeMs,
    });
    return AnswerResult.fromJson(response.data);
  }

  Future<SessionResult> finishSession(String sessionId) async {
    final response = await _dio.post('/challenge/$sessionId/finish');
    return SessionResult.fromJson(response.data);
  }
}
