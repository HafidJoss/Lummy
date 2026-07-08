import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/profile_repository.dart';
import '../../domain/profile_model.dart';

class ProfileNotifier extends AsyncNotifier<UserProfile> {
  @override
  FutureOr<UserProfile> build() async {
    final repo = ref.watch(profileRepositoryProvider);
    return repo.getProfile();
  }

  Future<void> updateProfile(String? displayName, String? title) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(profileRepositoryProvider);
      return repo.updateProfile(displayName, title);
    });
  }

  Future<void> uploadAvatar(XFile file) async {
    final repo = ref.read(profileRepositoryProvider);
    final newUrl = await repo.uploadAvatar(file);
    if (state.hasValue) {
      final current = state.value!;
      state = AsyncValue.data(UserProfile(
        id: current.id,
        email: current.email,
        fullName: current.fullName,
        displayName: current.displayName,
        title: current.title,
        avatarUrl: newUrl,
        xpTotal: current.xpTotal,
        currentLevelId: current.currentLevelId,
        accuracyGlobal: current.accuracyGlobal,
        currentLevelXpMin: current.currentLevelXpMin,
        nextLevelXpMin: current.nextLevelXpMin,
        totalAnswered: current.totalAnswered,
        rankPosition: current.rankPosition,
        currentStreak: current.currentStreak,
      ));
    }
  }
}

final profileProvider = AsyncNotifierProvider<ProfileNotifier, UserProfile>(() {
  return ProfileNotifier();
});
