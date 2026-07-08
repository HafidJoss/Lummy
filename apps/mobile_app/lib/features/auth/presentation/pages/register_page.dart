import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:dio/dio.dart';
import '../../data/auth_repository.dart';
import '../../domain/auth_models.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _obscurePass = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty || _nameCtrl.text.isEmpty) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.register(RegisterRequest(email: _emailCtrl.text, password: _passCtrl.text, fullName: _nameCtrl.text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro exitoso. Inicia sesión.')));
        context.go('/login');
      }
    } catch (e) {
      String errMsg = e.toString();
      if (e is DioException && e.response?.data != null) {
        try {
          final data = e.response!.data;
          if (data['error'] != null && data['error']['message'] != null) {
            errMsg = data['error']['message'];
          } else if (data['detail'] != null) {
            errMsg = data['detail'].toString();
          }
        } catch (_) {}
      }
      setState(() { _error = errMsg; });
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  // Title Header
                  Text(
                    '¿Estás listo?',
                    style: Theme.of(context).textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.p8),
                  Text(
                    'Crea tu perfil para empezar tu propia aventura.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.gray700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.p32),

                  // Registration Form Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.p24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24), // HTML has rounded-[2rem]
                      border: Border.all(color: AppColors.outlineVariant),
                      boxShadow: AppShadows.lg, // heroic-shadow
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Name Field
                        Text(
                          'Nombre de Guerrero',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.gray900,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.p8),
                        TextField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Ej. Alex Pendragon',
                            prefixIcon: Icon(Icons.badge_outlined, color: AppColors.outline),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.p16),

                        // Email Field
                        Text(
                          'Correo Galáctico',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.gray900,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.p8),
                        TextField(
                          controller: _emailCtrl,
                          decoration: const InputDecoration(
                            hintText: 'heroe@academia.com',
                            prefixIcon: Icon(Icons.mail_outline, color: AppColors.outline),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: AppSpacing.p16),

                        // Password Field
                        Text(
                          'Código Secreto',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.gray900,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.p8),
                        TextField(
                          controller: _passCtrl,
                          obscureText: _obscurePass,
                          decoration: InputDecoration(
                            hintText: 'Tu contraseña',
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

                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.p16),
                            child: Text(
                              _error!,
                              style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        // CTA Button
                        PrimaryButton(
                          text: 'Crear Cuenta',
                          icon: Icons.rocket_launch_rounded,
                          backgroundColor: const Color(0xFF6DD600),
                          shadowColor: const Color(0xFF4A9100),
                          isLoading: _isLoading,
                          onPressed: _register,
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
                        '¿Ya eres un jugador?',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () => context.go('/login'), // Volver al login
                        child: Text(
                          'Inicia Sesión',
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
