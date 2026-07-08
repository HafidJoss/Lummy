import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Lummy',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p24, vertical: AppSpacing.p32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero Header
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.p16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDEE0FF), // primary-fixed
                          shape: BoxShape.circle,
                          boxShadow: AppShadows.sm,
                        ),
                        child: const Icon(
                          Icons.shield_rounded, // fallback for shield_person
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.p16),
                      Text(
                        '¡Bienvenido!',
                        style: Theme.of(context).textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.p8),
                      Text(
                        '¡Aprendamos de programación juntos!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.gray700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.p32),

                  // Login Form Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.p24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.outlineVariant),
                      boxShadow: AppShadows.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Email Field
                        Text(
                          'Correo Electrónico',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.gray700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.p8),
                        TextField(
                          controller: _emailCtrl,
                          decoration: const InputDecoration(
                            hintText: 'tu@academia.com',
                            prefixIcon: Icon(Icons.mail_outline, color: AppColors.outline),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: AppSpacing.p16),

                        // Password Field
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Contraseña',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: AppColors.gray700,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                '¿Olvidaste tu contraseña?',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.tertiary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.p8),
                        TextField(
                          controller: _passCtrl,
                          obscureText: _obscurePass,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePass ? Icons.visibility_off : Icons.visibility,
                                color: AppColors.outline,
                              ),
                              onPressed: () => setState(() => _obscurePass = !_obscurePass),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.p32),

                        if (authState.error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.p16),
                            child: Text(
                              authState.error!,
                              style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        // CTA Button
                        PrimaryButton(
                          text: 'Iniciar Misión',
                          icon: Icons.send_rounded,
                          backgroundColor: const Color(0xFF6DD600), // Match HTML green
                          shadowColor: const Color(0xFF346B00),     // Match HTML shadow green
                          isLoading: authState.isLoading,
                          onPressed: () async {
                            if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) return;
                            
                            final success = await ref.read(authNotifierProvider.notifier).login(
                              _emailCtrl.text,
                              _passCtrl.text,
                            );
                            if (success && context.mounted) {
                              context.go('/dashboard');
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.p32),
                  
                  // Footer Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿Eres nuevo?',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () => context.push('/register'),
                        child: Text(
                          'Únete a la Academia',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
