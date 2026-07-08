import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/leaderboard_repository.dart';
import '../../domain/leaderboard_models.dart';

final leaderboardProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  return ref.watch(leaderboardRepositoryProvider).getGlobalLeaderboard();
});

final myRankProvider = FutureProvider<int>((ref) async {
  return ref.watch(leaderboardRepositoryProvider).getMyRank();
});
