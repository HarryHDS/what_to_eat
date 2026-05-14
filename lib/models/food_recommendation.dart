class FoodRecommendation {
  final String id;
  final String name;
  final String description;
  final List<String> tags;
  final String matchReason;
  final String emoji;
  final int matchScore;

  const FoodRecommendation({
    required this.id,
    required this.name,
    required this.description,
    required this.tags,
    required this.matchReason,
    required this.emoji,
    required this.matchScore,
  });
}
