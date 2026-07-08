import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../domain/leaderboard_models.dart';

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  return LeaderboardRepository(ref.watch(dioProvider));
});

class LeaderboardRepository {
  final Dio _dio;
  LeaderboardRepository(this._dio);

  Future<List<LeaderboardEntry>> getGlobalLeaderboard({int page = 1, int limit = 20}) async {
    final response = await _dio.get('/leaderboard', queryParameters: {'page': page, 'limit': limit});
    final List items = response.data['items'] ?? [];
    return items.map((item) => LeaderboardEntry.fromJson(item)).toList();
  }

  Future<int> getMyRank() async {
    final response = await _dio.get('/leaderboard/me');
    return response.data['rank_position'] ?? 0;
  }
}
