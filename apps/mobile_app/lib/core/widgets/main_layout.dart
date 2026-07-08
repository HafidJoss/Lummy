import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/providers/profile_provider.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/challenge_session/presentation/providers/challenge_provider.dart';
import '../theme/app_theme.dart';
import 'primary_button.dart';
import 'bottom_nav_bar.dart';

class MainLayout extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final challengeState = ref.watch(challengeNotifierProvider);

    if (challengeState.finalResult != null) {
      final result = challengeState.finalResult!;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Limpiamos el resultado inmediatamente para que no se vuelva a mostrar si hay un rebuild
        ref.read(challengeNotifierProvider.notifier).resetFinalResult();

        showGeneralDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(0.4),
          barrierDismissible: true,
          barrierLabel: 'Resultados',
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) {
            return Stack(
              children: [
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(color: Colors.transparent),
                ),
                Center(
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.5), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6DD600).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.stars_rounded,
                                color: Color(0xFF6DD600), size: 48),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            '¡Misión Completada!',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'XP Ganada: +${result.xpGained}',
                            style: const TextStyle(
                                fontSize: 18,
                                color: Color(0xFF346B00),
                                fontWeight: FontWeight.bold),
                          ),
                          if (result.xpLost > 0)
                            Text(
                              'XP Perdida: -${result.xpLost}',
                              style: const TextStyle(
                                  fontSize: 16, color: AppColors.error),
                            ),
                          const SizedBox(height: 32),
                          PrimaryButton(
                            text: '¡Genial!',
                            backgroundColor: const Color(0xFFD63000),
                            shadowColor: const Color(0xFF8A1C00),
                            onPressed: () {
                              Navigator.of(context).pop();
                              ref.refresh(profileProvider);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      });
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.primaryContainer.withOpacity(0.08),
        title: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withOpacity(0.1),
                    shape: BoxShape.circle,
                    image: profileAsync.valueOrNull?.avatarUrl != null
                        ? DecorationImage(
                            image: NetworkImage(
                                profileAsync.valueOrNull!.avatarUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: profileAsync.valueOrNull?.avatarUrl == null
                      ? const Icon(Icons.person_rounded,
                          color: AppColors.primaryContainer)
                      : null,
                ),
                Positioned(
                  bottom: -4,
                  right: -8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6DD600),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.surface, width: 1),
                    ),
                    child: Text(
                      'LVL ${profileAsync.valueOrNull?.currentLevelId ?? 1}',
                      style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.p12),
            const Text(
              'Lummy',
              style: TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: AppSpacing.p16),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.p12, vertical: AppSpacing.p4),
            decoration: BoxDecoration(
              color: AppColors.tertiaryContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.tertiaryContainer.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department_rounded,
                    color: AppColors.tertiary, size: 20),
                const SizedBox(width: AppSpacing.p4),
                Text(
                  '${profileAsync.valueOrNull?.currentStreak ?? 0}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.tertiary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: navigationShell,
      ),
    );
  }
}
