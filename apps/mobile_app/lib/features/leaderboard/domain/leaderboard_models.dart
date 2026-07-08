class LeaderboardEntry {
  final int rankPosition;
  final String userId;
  final String displayName;
  final String title;
  final String? avatarUrl;
  final int xpTotal;
  final int levelId;
  final double accuracyGlobal;

  LeaderboardEntry({
    required this.rankPosition,
    required this.userId,
    required this.displayName,
    required this.title,
    this.avatarUrl,
    required this.xpTotal,
    required this.levelId,
    required this.accuracyGlobal,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rankPosition: json['rank_position'] ?? 0,
      userId: json['user_id'] ?? '',
      displayName: json['display_name'] ?? 'Usuario',
      title: json['title'] ?? 'Explorador Novato',
      avatarUrl: json['avatar_url'],
      xpTotal: json['xp_total'] ?? 0,
      levelId: json['level_id'] ?? 1,
      accuracyGlobal: (json['accuracy_global'] ?? 0.0).toDouble(),
    );
  }
}
