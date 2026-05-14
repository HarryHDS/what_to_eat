class SoulFoodScore {
  final String primaryMood;
  final String secondaryMood;
  final Map<String, int> scoreMap;
  final String description;
  final String foodPersona;
  final String emoji;
  final int questionCount;

  const SoulFoodScore({
    required this.primaryMood,
    required this.secondaryMood,
    required this.scoreMap,
    required this.description,
    required this.foodPersona,
    required this.emoji,
    required this.questionCount,
  });
}
