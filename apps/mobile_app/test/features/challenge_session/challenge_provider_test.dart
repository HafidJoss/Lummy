import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_app/features/challenge_session/data/challenge_repository.dart';
import 'package:mobile_app/features/challenge_session/domain/challenge_models.dart';
import 'package:mobile_app/features/challenge_session/presentation/providers/challenge_provider.dart';

class MockChallengeRepository extends Mock implements ChallengeRepository {}

void main() {
  late MockChallengeRepository mockRepository;
  late ChallengeNotifier notifier;

  setUp(() {
    mockRepository = MockChallengeRepository();
    notifier = ChallengeNotifier(mockRepository);
  });

  final mockQuestion1 = ChallengeQuestion(
    sessionQuestionId: 'sq1',
    order: 1,
    difficulty: 2,
    stem: 'Question 1',
    options: [
      QuestionOption(key: 'A', text: 'Option A'),
      QuestionOption(key: 'B', text: 'Option B'),
    ],
  );
  
  final mockQuestion2 = ChallengeQuestion(
    sessionQuestionId: 'sq2',
    order: 2,
    difficulty: 2,
    stem: 'Question 2',
    options: [
      QuestionOption(key: 'A', text: 'Option A'),
      QuestionOption(key: 'B', text: 'Option B'),
    ],
  );

  final mockSession = ChallengeSession(
    sessionId: 'sess123',
    totalQuestions: 2,
    questions: [mockQuestion1, mockQuestion2],
  );

  group('ChallengeNotifier', () {
    test('initial state is correct', () {
      expect(notifier.state.isLoading, false);
      expect(notifier.state.session, null);
      expect(notifier.state.currentIndex, 0);
      expect(notifier.state.lives, 3);
    });

    test('start() fetches session and updates state', () async {
      when(() => mockRepository.startSession()).thenAnswer((_) async => mockSession);

      final future = notifier.start();
      
      // Right after calling start, it should be loading
      expect(notifier.state.isLoading, true);
      
      await future;

      expect(notifier.state.isLoading, false);
      expect(notifier.state.session, mockSession);
      expect(notifier.state.questionStartTime, isNotNull);
      expect(notifier.state.lives, 3);
      verify(() => mockRepository.startSession()).called(1);
    });

    test('answer() updates result correctly when answer is correct', () async {
      // Setup state manually or by calling start()
      when(() => mockRepository.startSession()).thenAnswer((_) async => mockSession);
      await notifier.start();

      final answerResult = AnswerResult(
        isCorrect: true,
        correctOptionKey: 'A',
        xpAwarded: 5,
        feedback: 'Good job',
        livesRemaining: 3,
      );

      when(() => mockRepository.answerQuestion('sess123', 'sq1', 'A', any()))
          .thenAnswer((_) async => answerResult);

      await notifier.answer('A');

      expect(notifier.state.isLoading, false);
      expect(notifier.state.lastResult, answerResult);
      expect(notifier.state.lives, 3);
    });
    
    test('answer() updates result correctly when answer is wrong and loses a life', () async {
      when(() => mockRepository.startSession()).thenAnswer((_) async => mockSession);
      await notifier.start();

      final answerResult = AnswerResult(
        isCorrect: false,
        correctOptionKey: 'B',
        xpAwarded: -5,
        feedback: 'Wrong, it is B',
        livesRemaining: 2,
      );

      when(() => mockRepository.answerQuestion('sess123', 'sq1', 'A', any()))
          .thenAnswer((_) async => answerResult);

      await notifier.answer('A');

      expect(notifier.state.isLoading, false);
      expect(notifier.state.lastResult, answerResult);
      expect(notifier.state.lives, 2);
    });

    test('nextQuestion() increments index if questions remain', () async {
      when(() => mockRepository.startSession()).thenAnswer((_) async => mockSession);
      await notifier.start();

      await notifier.nextQuestion();

      expect(notifier.state.currentIndex, 1);
      expect(notifier.state.lastResult, null); // lastResult cleared
    });

    test('nextQuestion() finishes session if no questions remain', () async {
      when(() => mockRepository.startSession()).thenAnswer((_) async => mockSession);
      await notifier.start();
      await notifier.nextQuestion(); // Go to index 1

      final sessionResult = SessionResult(
        sessionId: 'sess123',
        correctAnswers: 1,
        wrongAnswers: 1,
        xpGained: 5,
        xpLost: 5,
        xpDelta: 0,
        levelUp: false,
        floorApplied: false,
        newXpTotal: 10,
        newLevelId: 1,
      );

      when(() => mockRepository.finishSession('sess123')).thenAnswer((_) async => sessionResult);

      await notifier.nextQuestion(); // Finish session

      expect(notifier.state.isLoading, false);
      expect(notifier.state.finalResult, sessionResult);
    });
  });
}
