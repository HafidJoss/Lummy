import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/leaderboard/data/leaderboard_repository.dart';
import 'package:mobile_app/features/leaderboard/domain/leaderboard_models.dart';
import 'package:mobile_app/features/leaderboard/presentation/providers/leaderboard_provider.dart';

class MockLeaderboardRepository extends Mock implements LeaderboardRepository {}

void main() {
  late MockLeaderboardRepository mockRepository;

  setUp(() {
    mockRepository = MockLeaderboardRepository();
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        leaderboardRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('Leaderboard Providers', () {
    test('leaderboardProvider fetches leaderboard from repository', () async {
      final mockData = [
        LeaderboardEntry(
          rankPosition: 1,
          userId: 'user1',
          displayName: 'Player 1',
          title: 'Master',
          xpTotal: 1000,
          levelId: 10,
          accuracyGlobal: 95.0,
        ),
        LeaderboardEntry(
          rankPosition: 2,
          userId: 'user2',
          displayName: 'Player 2',
          title: 'Novice',
          xpTotal: 500,
          levelId: 5,
          accuracyGlobal: 80.0,
        ),
      ];

      when(() => mockRepository.getGlobalLeaderboard()).thenAnswer((_) async => mockData);

      final container = createContainer();
      
      // read the future
      final result = await container.read(leaderboardProvider.future);

      expect(result.length, 2);
      expect(result[0].displayName, 'Player 1');
      expect(result[1].displayName, 'Player 2');
      verify(() => mockRepository.getGlobalLeaderboard()).called(1);
    });

    test('myRankProvider fetches my rank from repository', () async {
      when(() => mockRepository.getMyRank()).thenAnswer((_) async => 42);

      final container = createContainer();
      
      final result = await container.read(myRankProvider.future);

      expect(result, 42);
      verify(() => mockRepository.getMyRank()).called(1);
    });
  });
}
