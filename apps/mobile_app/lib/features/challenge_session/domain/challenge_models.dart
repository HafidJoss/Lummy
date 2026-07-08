class ChallengeSession {
  final String sessionId;
  final int totalQuestions;
  final List<ChallengeQuestion> questions;
  
  ChallengeSession({required this.sessionId, required this.totalQuestions, required this.questions});
  
  factory ChallengeSession.fromJson(Map<String, dynamic> json) {
    return ChallengeSession(
      sessionId: json['session_id'],
      totalQuestions: json['total_questions'] ?? 5,
      questions: (json['questions'] as List).map((q) => ChallengeQuestion.fromJson(q)).toList(),
    );
  }
}

class ChallengeQuestion {
  final String sessionQuestionId;
  final int order;
  final int difficulty;
  final String stem;
  final List<QuestionOption> options;
  
  ChallengeQuestion({
    required this.sessionQuestionId, 
    required this.order, 
    required this.difficulty, 
    required this.stem, 
    required this.options,
  });
  
  factory ChallengeQuestion.fromJson(Map<String, dynamic> json) {
    return ChallengeQuestion(
      sessionQuestionId: json['session_question_id'],
      order: json['order'] ?? 1,
      difficulty: json['difficulty'] ?? 2,
      stem: json['stem'],
      options: (json['options'] as List).map((o) => QuestionOption.fromJson(o)).toList(),
    );
  }
}

class QuestionOption {
  final String key;  // "A", "B", "C", "D"
  final String text;
  
  QuestionOption({required this.key, required this.text});
  
  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(key: json['key'], text: json['text']);
  }
}

class AnswerResult {
  final bool isCorrect;
  final String correctOptionKey;
  final int xpAwarded;
  final String feedback;
  final int livesRemaining;
  
  AnswerResult({
    required this.isCorrect, 
    required this.correctOptionKey, 
    required this.xpAwarded, 
    required this.feedback,
    required this.livesRemaining,
  });
  
  factory AnswerResult.fromJson(Map<String, dynamic> json) {
    return AnswerResult(
      isCorrect: json['is_correct'],
      correctOptionKey: json['correct_option_key'] ?? '',
      xpAwarded: json['xp_awarded'] ?? 0,
      feedback: json['feedback'] ?? '',
      livesRemaining: json['lives_remaining'] ?? 3,
    );
  }
}

class SessionResult {
  final String sessionId;
  final int correctAnswers;
  final int wrongAnswers;
  final int xpGained;
  final int xpLost;
  final int xpDelta;
  final bool levelUp;
  final bool floorApplied;
  final int newXpTotal;
  final int newLevelId;
  
  SessionResult({
    required this.sessionId,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.xpGained,
    required this.xpLost,
    required this.xpDelta,
    required this.levelUp,
    required this.floorApplied,
    required this.newXpTotal,
    required this.newLevelId,
  });
  
  factory SessionResult.fromJson(Map<String, dynamic> json) {
    return SessionResult(
      sessionId: json['session_id'] ?? '',
      correctAnswers: json['correct_answers'] ?? 0,
      wrongAnswers: json['wrong_answers'] ?? 0,
      xpGained: json['xp_gained'] ?? 0,
      xpLost: json['xp_lost'] ?? 0,
      xpDelta: json['xp_delta'] ?? 0,
      levelUp: json['level_up'] ?? false,
      floorApplied: json['floor_applied'] ?? false,
      newXpTotal: json['new_xp_total'] ?? 0,
      newLevelId: json['new_level_id'] ?? 1,
    );
  }
}
