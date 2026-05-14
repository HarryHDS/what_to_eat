class Option {
  final String id;
  final String text;
  final Map<String, int> moodScores;
  final String emoji;

  const Option({
    required this.id,
    required this.text,
    required this.moodScores,
    required this.emoji,
  });
}

class Question {
  final String id;
  final String questionText;
  final List<Option> options;
  final String category;

  const Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.category,
  });
}
