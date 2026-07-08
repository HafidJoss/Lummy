import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/profile_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return SafeArea(
      child: profileAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (error, _) => Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('Error: $error', style: const TextStyle(color: AppColors.error)),
          const SizedBox(height: AppSpacing.p16),
          PrimaryButton(
            text: 'Reintentar',
            onPressed: () => ref.refresh(profileProvider),
          )
        ])),
        data: (profile) {
          double progress = 1.0;
          if (profile.nextLevelXpMin > profile.currentLevelXpMin) {
            progress = (profile.xpTotal - profile.currentLevelXpMin) /
                (profile.nextLevelXpMin - profile.currentLevelXpMin);
          }
          final int progressPercentage =
              (progress.clamp(0.0, 1.0) * 100).toInt();

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.p24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome Section
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.p24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Hola, ${profile.displayName}!',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: AppSpacing.p8),
                      Text(
                        '¡Tu próxima gran aventura de conocimiento comienza ahora!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.gray700,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.p32),

                // Daily Quest Card
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.p24),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.p24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: AppColors.surfaceContainer),
                      boxShadow: AppShadows.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.p16,
                                vertical: AppSpacing.p8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFDAD2),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Text(
                              'Misión Actual',
                              style: TextStyle(
                                color: Color(0xFF3D0700),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.p24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progreso',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            Text(
                              '$progressPercentage%',
                              style: const TextStyle(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.p8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            minHeight: 16,
                            backgroundColor: AppColors.surfaceContainer,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.secondary),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.p24),
                        PrimaryButton(
                          text: 'Continuar Aventura',
                          icon: Icons.play_arrow_rounded,
                          backgroundColor: const Color(0xFF6DD600),
                          shadowColor: const Color(0xFF346B00),
                          onPressed: () => context.push('/challenge'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.p32),

                // Quick Dashboard Grid
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.p24),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: AppSpacing.p16,
                    mainAxisSpacing: AppSpacing.p16,
                    childAspectRatio: 1.5,
                    children: [
                      _buildStatCard(
                          context,
                          Icons.local_fire_department_rounded,
                          'Racha',
                          '${profile.currentStreak} Días',
                          AppColors.tertiary),
                      _buildStatCard(context, Icons.bolt_rounded, 'Total XP',
                          '${profile.xpTotal}', AppColors.primary),
                      _buildStatCard(context, Icons.task_alt_rounded, 'Quests',
                          '${profile.totalAnswered}', AppColors.secondary),
                      _buildStatCard(
                          context,
                          Icons.leaderboard_rounded,
                          'Global',
                          '#${profile.rankPosition}',
                          AppColors.primaryContainer),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.p32),

                // Tip del Dia
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.p24),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.p24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD63000), // Orange tip card
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Tip del Día 💡',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.p16),
                        Text(
                          '¿Sabías que repasar un tema 10 minutos después de aprenderlo ayuda a retener el 80% de la información? ¡Inténtalo con tu lección de hoy!',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.p48), // Bottom padding
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, IconData icon, String label,
      String value, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.p16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceContainer),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: AppSpacing.p8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.gray700,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.p8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
