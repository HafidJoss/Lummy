import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/profile_provider.dart';

class MissionSelectionPage extends ConsumerWidget {
  const MissionSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return SafeArea(
      child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (profile) {
            int missingXp = profile.nextLevelXpMin - profile.xpTotal;
            if (missingXp < 0) missingXp = 0;

            double progress = 1.0;
            if (profile.nextLevelXpMin > profile.currentLevelXpMin) {
              progress = (profile.xpTotal - profile.currentLevelXpMin) /
                  (profile.nextLevelXpMin - profile.currentLevelXpMin);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.p24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero Progress Section
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.p24),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.p24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.surfaceVariant),
                        boxShadow: AppShadows.sm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tu Progreso',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    profile.nextLevelXpMin >
                                            profile.currentLevelXpMin
                                        ? 'Faltan $missingXp XP para Nivel ${profile.currentLevelId + 1}'
                                        : '¡Nivel Máximo Alcanzado!',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: AppColors.gray700,
                                        ),
                                  ),
                                ],
                              ),
                              const Icon(Icons.insights_rounded,
                                  size: 48,
                                  color: AppColors
                                      .surfaceContainer), // Placeholder icon decoration
                            ],
                          ),
                          const SizedBox(height: AppSpacing.p16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress.clamp(0.0, 1.0),
                              minHeight: 16,
                              backgroundColor: AppColors.surfaceContainerHigh,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFD63000)), // orange
                            ),
                          ),
                          const SizedBox(height: AppSpacing.p8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Nivel ${profile.currentLevelId}',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.outline)),
                              Text('Nivel ${profile.currentLevelId + 1}',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.outline)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.p48),

                  // Graphic and CTA
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.p24),
                    child: Column(
                      children: [
                        Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(Icons.inventory_2_rounded,
                                size: 120, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.p32),
                        SizedBox(
                          width: double.infinity,
                          child: PrimaryButton(
                            text: 'INICIAR RETO',
                            backgroundColor: const Color(0xFF6DD600),
                            shadowColor: const Color(0xFF346B00),
                            onPressed: () => context.push('/challenge'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
