import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/challenge_provider.dart';

class ChallengePage extends ConsumerStatefulWidget {
  const ChallengePage({super.key});

  @override
  ConsumerState<ChallengePage> createState() => _ChallengePageState();
}

class _ChallengePageState extends ConsumerState<ChallengePage> {
  Timer? _timer;
  int _secondsLeft = 145; // 02:25
  int _selectedIndex = -1;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Simulate loading a specific level challenge
    Future.microtask(() {
      ref.read(challengeNotifierProvider.notifier).start(); 
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  String get _formattedTime {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(challengeNotifierProvider);

    ref.listen<ChallengeState>(challengeNotifierProvider, (previous, next) {
      if (previous != null && next.currentIndex > previous.currentIndex) {
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            next.currentIndex,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
          );
        }
      }
      
      if (previous?.finalResult == null && next.finalResult != null) {
        context.go('/dashboard');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: AppSpacing.p16),
            decoration: BoxDecoration(
              color: const Color(0xFFD63000),
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppShadows.md,
            ),
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              onPressed: () => context.go('/dashboard'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: state.isLoading && state.session == null
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : state.error != null && state.session == null
                ? Center(child: Text(state.error!, style: const TextStyle(color: AppColors.error)))
                : state.session == null || state.session!.questions.isEmpty
                    ? const Center(child: Text('No hay preguntas disponibles.'))
                    : _buildChallengeContent(context, state),
      ),
    );
  }

  Widget _buildChallengeContent(BuildContext context, ChallengeState state) {
    if (state.finalResult != null) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p24, vertical: AppSpacing.p16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MISIÓN ACTUAL',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: AppColors.primary,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Fundamentos de Lógica',
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(12),
                              border: const Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 2)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.schedule_rounded, color: AppColors.primaryContainer, size: 20),
                                const SizedBox(width: 4),
                                Text(_formattedTime, style: Theme.of(context).textTheme.labelLarge),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.p24),
                  
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (state.currentIndex + 1) / state.session!.questions.length,
                      minHeight: 16,
                      backgroundColor: AppColors.surfaceContainerHighest,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondaryContainer),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.p8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progreso del desafío', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.gray700)),
                      Text('${state.currentIndex + 1} / ${state.session!.questions.length} preguntas', 
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.gray700)),
                    ],
                  ),
                ],
              ),
            ),
            
            // Carousel of Questions
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Force answering to advance
                itemCount: state.session!.questions.length,
                itemBuilder: (context, index) {
                  final question = state.session!.questions[index];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.p24, 0, AppSpacing.p24, 120),
                    child: _buildQuestionCard(context, question, index),
                  );
                },
              ),
            ),
          ],
        ),
        
        // Floating Action Button
        Positioned(
          bottom: AppSpacing.p24,
          left: AppSpacing.p24,
          right: AppSpacing.p24,
          child: PrimaryButton(
            text: state.isLoading ? 'Verificando...' : 'Confirmar Respuesta',
            icon: Icons.rocket_launch_rounded,
            backgroundColor: const Color(0xFFD63000), // Orange CTA
            shadowColor: const Color(0xFF8A1C00),
            onPressed: state.isLoading ? null : () async {
              if (_selectedIndex == -1) return;
              
              final currentQ = state.session!.questions[state.currentIndex];
              final optionKey = currentQ.options[_selectedIndex].key;
              await ref.read(challengeNotifierProvider.notifier).answer(optionKey);
                  
              if (mounted) {
                final lastResult = ref.read(challengeNotifierProvider).lastResult;
                setState(() => _selectedIndex = -1);
                
                if (lastResult != null) {
                  if (lastResult.isCorrect) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 8),
                            Expanded(child: Text('¡Correcto! +${lastResult.xpAwarded} XP\n${lastResult.feedback}')),
                          ],
                        ),
                        backgroundColor: AppColors.primaryContainer,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.cancel, color: Colors.white),
                            const SizedBox(width: 8),
                            Expanded(child: Text('Incorrecto. -5 XP\n${lastResult.feedback}')),
                          ],
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                  
                  await Future.delayed(const Duration(seconds: 2));
                  if (mounted) {
                    ref.read(challengeNotifierProvider.notifier).nextQuestion();
                  }
                }
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(BuildContext context, dynamic currentQ, int index) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.p24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: AppShadows.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFDEE0FF), // primaryFixed
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'DESAFÍO #${index + 1}',
                style: const TextStyle(
                  color: Color(0xFF000E5E), // onPrimaryFixed
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.p16),
          Text(
            currentQ.stem,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.p24),
          
          // Options Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1, 
              childAspectRatio: 4,
              mainAxisSpacing: AppSpacing.p16,
            ),
            itemCount: currentQ.options.length,
            itemBuilder: (context, i) {
              final isSelected = _selectedIndex == i;
              final option = currentQ.options[i];
              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p16),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFDEE0FF) : AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: AppShadows.sm,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          option.key,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.p16),
                      Expanded(
                        child: Text(
                          option.text,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
