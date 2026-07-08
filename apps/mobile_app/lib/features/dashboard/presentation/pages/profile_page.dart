import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../domain/profile_model.dart';
import '../providers/profile_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return SafeArea(
      child: profileAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (profile) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.p24, vertical: AppSpacing.p32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Section
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topRight,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        width: 128,
                        height: 128,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: AppShadows.md,
                          image: profile.avatarUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(profile.avatarUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: profile.avatarUrl == null
                            ? const Icon(Icons.person,
                                size: 64, color: AppColors.primary)
                            : null,
                      ),
                      Positioned(
                        bottom: -12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6DD600), // secondary green
                            borderRadius: BorderRadius.circular(16),
                            border: const Border(
                                bottom: BorderSide(
                                    color: Color(0xFF346B00), width: 4)),
                            boxShadow: AppShadows.sm,
                          ),
                          child: Text(
                            'Lvl ${profile.currentLevelId}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 0,
                    right: -16,
                    child: InkWell(
                      onTap: () =>
                          _showEditProfileDialog(context, ref, profile),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD63000), // orange
                          shape: BoxShape.circle,
                          boxShadow: AppShadows.sm,
                        ),
                        child: const Icon(Icons.edit,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.p32),

              Text(
                profile.displayName.isNotEmpty
                    ? profile.displayName
                    : 'Sin Nombre',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 4),
              Text(
                profile.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.gray700,
                    ),
              ),
              const SizedBox(height: AppSpacing.p32),

              // Progress Section
              Container(
                padding: const EdgeInsets.all(AppSpacing.p24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceVariant),
                  boxShadow: AppShadows.sm,
                ),
                child: Builder(builder: (context) {
                  final levelSize =
                      profile.nextLevelXpMin - profile.currentLevelXpMin;
                  final currentProgress =
                      profile.xpTotal - profile.currentLevelXpMin;

                  // if max level, levelSize is 0
                  final isMaxLevel = levelSize <= 0;
                  final double progressPct = isMaxLevel
                      ? 1.0
                      : (currentProgress / levelSize).clamp(0.0, 1.0);

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Level ${profile.currentLevelId} Progress',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(color: AppColors.gray700)),
                          Text(
                              isMaxLevel
                                  ? '${profile.xpTotal} XP'
                                  : '${profile.xpTotal} / ${profile.nextLevelXpMin} XP',
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.p12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progressPct,
                          minHeight: 16,
                          backgroundColor: AppColors.surfaceContainerHigh,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.secondaryContainer),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.p12),
                      Text(
                        isMaxLevel
                            ? '¡Nivel Máximo Alcanzado!'
                            : 'Faltan ${profile.nextLevelXpMin - profile.xpTotal} XP para el nivel ${profile.currentLevelId + 1}',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: AppColors.gray700),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.p24),

              // Stats Grid (Bento Style)
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.local_fire_department_rounded,
                      iconColor: AppColors.tertiary,
                      iconBgColor: AppColors.tertiaryContainer.withOpacity(0.1),
                      label: 'Racha',
                      value: '${profile.currentStreak} días',
                      valueColor: AppColors.tertiaryContainer,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.p16),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.star_rounded,
                      iconColor: AppColors.primary,
                      iconBgColor: AppColors.primaryContainer.withOpacity(0.1),
                      label: 'Total XP',
                      value: '${profile.xpTotal}',
                      valueColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.p16),

              // Misiones Completadas Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.p16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceVariant),
                  boxShadow: AppShadows.sm,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.military_tech_rounded,
                          size: 32, color: AppColors.secondary),
                    ),
                    const SizedBox(width: AppSpacing.p16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Misiones Completadas',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: AppColors.gray700)),
                          Text('${profile.totalAnswered}',
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.outlineVariant),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p24),

              // Dark Mode Switch Placeholder
              Container(
                padding: const EdgeInsets.all(AppSpacing.p16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceVariant),
                  boxShadow: AppShadows.sm,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.dark_mode_rounded,
                          color: AppColors.primary),
                    ),
                    const SizedBox(width: AppSpacing.p16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Modo Oscuro',
                              style: Theme.of(context).textTheme.labelLarge),
                          Text('Cambiar apariencia',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: AppColors.gray700)),
                        ],
                      ),
                    ),
                    Switch(value: false, onChanged: (v) {}),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.p24),

              // Logout Button
              InkWell(
                onTap: () async {
                  await ref.read(authNotifierProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                },
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.p16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF41572B), // from HTML
                    borderRadius: BorderRadius.circular(16),
                    border: const Border(
                        bottom: BorderSide(color: Color(0xFF253316), width: 4)),
                    boxShadow: AppShadows.sm,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Cerrar Sesión',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.p16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(height: AppSpacing.p12),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: AppColors.gray700)),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: valueColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showEditProfileDialog(
      BuildContext context, WidgetRef ref, UserProfile profile) {
    final nameController = TextEditingController(text: profile.displayName);
    final titleController = TextEditingController(text: profile.title);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: AppSpacing.p24,
            right: AppSpacing.p24,
            top: AppSpacing.p24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Editar Perfil',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.p24),
              GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final XFile? image =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    await ref
                        .read(profileProvider.notifier)
                        .uploadAvatar(image);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    shape: BoxShape.circle,
                    image: profile.avatarUrl != null
                        ? DecorationImage(
                            image: NetworkImage(profile.avatarUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: profile.avatarUrl == null
                      ? const Icon(Icons.camera_alt,
                          size: 40, color: AppColors.primary)
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              Text('Toca para cambiar foto',
                  style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: AppSpacing.p24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre de Usuario',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: AppSpacing.p16),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: AppSpacing.p32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () async {
                    await ref.read(profileProvider.notifier).updateProfile(
                          nameController.text,
                          titleController.text,
                        );
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Guardar Cambios',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: AppSpacing.p32),
            ],
          ),
        );
      },
    );
  }
}
