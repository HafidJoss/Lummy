class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String displayName;
  final String title;
  final String? avatarUrl;
  final int xpTotal;
  final int currentLevelId;
  final double accuracyGlobal;
  final int currentLevelXpMin;
  final int nextLevelXpMin;
  final int totalAnswered;
  final int rankPosition;
  final int currentStreak;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.displayName,
    required this.title,
    this.avatarUrl,
    required this.xpTotal,
    required this.currentLevelId,
    required this.accuracyGlobal,
    required this.currentLevelXpMin,
    required this.nextLevelXpMin,
    required this.totalAnswered,
    required this.rankPosition,
    required this.currentStreak,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      displayName: json['display_name'] ?? '',
      title: json['title'] ?? 'Explorador Novato',
      avatarUrl: json['avatar_url'],
      xpTotal: json['xp_total'] ?? 0,
      currentLevelId: json['current_level_id'] ?? 1,
      accuracyGlobal: (json['accuracy_global'] ?? 0.0).toDouble(),
      currentLevelXpMin: json['current_level_xp_min'] ?? 0,
      nextLevelXpMin: json['next_level_xp_min'] ?? 0,
      totalAnswered: json['total_answered'] ?? 0,
      rankPosition: json['rank_position'] ?? 0,
      currentStreak: json['current_streak'] ?? 0,
    );
  }
}
