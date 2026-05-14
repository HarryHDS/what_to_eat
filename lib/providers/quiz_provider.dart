import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_data.dart';
import '../models/question.dart';
import '../utils/quiz_selector.dart';

final currentStepProvider = StateProvider<int>((ref) => 0);

final selectedQuestionsProvider = StateProvider<List<Question>>((ref) {
  return QuizSelector.selectRandomQuestions(questionBank, count: 4);
});

final answersProvider = StateProvider<Map<String, Option>>((ref) => {});

final isLastQuestionProvider = Provider<bool>((ref) {
  final step = ref.watch(currentStepProvider);
  return step >= 3;
});

final isQuizCompletedProvider = Provider<bool>((ref) {
  final answers = ref.watch(answersProvider);
  final questions = ref.watch(selectedQuestionsProvider);
  if (questions.isEmpty) return false;
  return questions.every((q) => answers.containsKey(q.id));
});

