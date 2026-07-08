import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/challenge_repository.dart';
import '../../domain/challenge_models.dart';

class ChallengeState {
  final bool isLoading;
  final String? error;
  final ChallengeSession? session;
  final int currentIndex;
  final AnswerResult? lastResult;
  final SessionResult? finalResult;
  final DateTime? questionStartTime; // Para calcular response_time_ms
  final int lives;

  ChallengeState({
    this.isLoading = false,
    this.error,
    this.session,
    this.currentIndex = 0,
    this.lastResult,
    this.finalResult,
    this.questionStartTime,
    this.lives = 3,
  });

  ChallengeState copyWith({
    bool? isLoading,
    String? error,
    ChallengeSession? session,
    int? currentIndex,
    AnswerResult? lastResult,
    SessionResult? finalResult,
    DateTime? questionStartTime,
    int? lives,
  }) {
    return ChallengeState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      session: session ?? this.session,
      currentIndex: currentIndex ?? this.currentIndex,
      lastResult: lastResult,
      finalResult: finalResult ?? this.finalResult,
      questionStartTime: questionStartTime ?? this.questionStartTime,
      lives: lives ?? this.lives,
    );
  }
}

class ChallengeNotifier extends StateNotifier<ChallengeState> {
  final ChallengeRepository _repository;

  ChallengeNotifier(this._repository) : super(ChallengeState());

  Future<void> start() async {
    state = ChallengeState(isLoading: true, lives: 3);
    try {
      final session = await _repository.startSession();
      state = state.copyWith(
        isLoading: false, 
        session: session, 
        questionStartTime: DateTime.now(),
        lives: 3,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> answer(String optionKey) async {
    if (state.session == null || state.isLoading || state.lastResult != null) return;
    
    // Calcular response_time_ms
    final responseTimeMs = state.questionStartTime != null
        ? DateTime.now().difference(state.questionStartTime!).inMilliseconds
        : 0;
    
    state = state.copyWith(isLoading: true, error: null);
    try {
      final question = state.session!.questions[state.currentIndex];
      final result = await _repository.answerQuestion(
        state.session!.sessionId, 
        question.sessionQuestionId, 
        optionKey,
        responseTimeMs,
      );
      state = state.copyWith(
        isLoading: false, 
        lastResult: result,
        lives: result.livesRemaining,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> nextQuestion() async {
    if (state.session == null || state.isLoading) return;

    if (state.currentIndex + 1 < state.session!.questions.length) {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1, 
        lastResult: null,
        questionStartTime: DateTime.now(),
      );
    } else {
      state = state.copyWith(isLoading: true);
      try {
        final result = await _repository.finishSession(state.session!.sessionId);
        state = state.copyWith(isLoading: false, finalResult: result);
      } catch (e) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  void resetFinalResult() {
    state = ChallengeState(
      isLoading: state.isLoading,
      error: state.error,
      session: state.session,
      currentIndex: state.currentIndex,
      lastResult: state.lastResult,
      questionStartTime: state.questionStartTime,
      lives: state.lives,
      finalResult: null, // intentionally null
    );
  }
}

final challengeNotifierProvider = StateNotifierProvider<ChallengeNotifier, ChallengeState>((ref) {
  return ChallengeNotifier(ref.watch(challengeRepositoryProvider));
});
