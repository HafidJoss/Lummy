import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../dashboard/presentation/providers/profile_provider.dart';
import '../providers/leaderboard_provider.dart';

class LeaderboardPage extends ConsumerWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(leaderboardProvider);
    final myRankAsync = ref.watch(myRankProvider);
    final profileAsync = ref.watch(profileProvider);

    return SafeArea(
      child: state.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error',
                  style: const TextStyle(color: AppColors.error)),
              const SizedBox(height: 16),
              PrimaryButton(
                text: 'Reintentar',
                onPressed: () => ref.refresh(leaderboardProvider),
              )
            ],
          ),
        ),
        data: (players) {
          final myRank = myRankAsync.valueOrNull ?? 0;
          final profile = profileAsync.valueOrNull;
          return _buildLeaderboardContent(context, players, myRank, profile);
        },
      ),
    );
  }

  Widget _buildLeaderboardContent(BuildContext context, List<dynamic> players,
      int myRank, dynamic profile) {
    if (players.isEmpty) {
      return const Center(
          child: Text('Aún no hay jugadores en la clasificación.'));
    }

    final top3 = players.take(3).toList();
    final rest = players.skip(3).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.p24, vertical: AppSpacing.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Podium Section
          if (top3.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                  top: AppSpacing.p32, bottom: AppSpacing.p32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (top3.length > 1)
                    _buildPodiumItem(
                        context, top3[1], 2, const Color(0xFFC5C5D8)),
                  _buildPodiumItem(
                      context, top3[0], 1, AppColors.secondaryContainer,
                      isWinner: true),
                  if (top3.length > 2)
                    _buildPodiumItem(
                        context, top3[2], 3, const Color(0xFFFFB4A2)),
                ],
              ),
            ),

          // Leaderboard List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('RANKING',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AppColors.gray700, letterSpacing: 1.5)),
              Text('EXPERIENCE',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AppColors.gray700, letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: AppSpacing.p16),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rest.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.p12),
            itemBuilder: (context, index) {
              final player = rest[index];
              return _buildListRow(context, player, index + 4);
            },
          ),

          // Your Position separator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.p24),
            child: Row(
              children: [
                const Expanded(
                    child: Divider(color: AppColors.surfaceContainerHighest)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text('YOUR POSITION',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: AppColors.gray700)),
                ),
                const Expanded(
                    child: Divider(color: AppColors.surfaceContainerHighest)),
              ],
            ),
          ),

          // You Row
          if (profile != null)
            Container(
              padding: const EdgeInsets.all(AppSpacing.p16),
              decoration: BoxDecoration(
                color: const Color(0xFFD63000),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF8A1C00), width: 2),
                boxShadow: AppShadows.md,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text('$myRank',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      image: profile.avatarUrl != null
                          ? DecorationImage(
                              image: NetworkImage(profile.avatarUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: profile.avatarUrl == null
                        ? const Icon(Icons.person,
                            color: AppColors.primary, size: 32)
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.p16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tú (You)',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        Text('Level ${profile.currentLevelId} ${profile.title}',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${profile.xpTotal}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                      Text('XP',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

          const SizedBox(height: AppSpacing.p32),

          PrimaryButton(
            text: '¡Gana más XP!',
            icon: Icons.bolt_rounded,
            backgroundColor: AppColors.secondaryContainer, // Light green
            shadowColor: AppColors.secondary,
            onPressed: () {},
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(
      BuildContext context, dynamic player, int rank, Color color,
      {bool isWinner = false}) {
    final size = isWinner ? 96.0 : 80.0;
    return Padding(
      padding:
          EdgeInsets.only(bottom: isWinner ? 16.0 : 0.0, left: 8.0, right: 8.0),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 4),
                  boxShadow: AppShadows.md,
                  image: player.avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(player.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: player.avatarUrl == null
                    ? Icon(Icons.person,
                        size: size * 0.6, color: AppColors.gray500)
                    : null,
              ),
              Positioned(
                bottom: -12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppShadows.sm,
                  ),
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      color: isWinner
                          ? AppColors.onSecondaryContainer
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.p16),
          Text(
            player.displayName,
            style: TextStyle(
              color: isWinner ? AppColors.primary : AppColors.gray900,
              fontWeight: FontWeight.bold,
              fontSize: isWinner ? 18 : 14,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              const Icon(Icons.star_rounded,
                  color: AppColors.secondary, size: 16),
              const SizedBox(width: 4),
              Text(
                '${player.xpTotal} XP',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: isWinner ? 14 : 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListRow(BuildContext context, dynamic player, int rank) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.p16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceContainer),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text('$rank',
                style: const TextStyle(
                    color: AppColors.gray700,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surfaceContainer),
              image: player.avatarUrl != null
                  ? DecorationImage(
                      image: NetworkImage(player.avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: player.avatarUrl == null
                ? const Icon(Icons.person, color: AppColors.gray500)
                : null,
          ),
          const SizedBox(width: AppSpacing.p16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(player.displayName,
                    style: Theme.of(context).textTheme.labelLarge),
                Text('Level ${player.levelId}',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: AppColors.gray700)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${player.xpTotal}',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const Text('XP',
                  style: TextStyle(color: AppColors.gray700, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
