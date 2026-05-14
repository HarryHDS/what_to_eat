import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/soul_food_score.dart';
import '../models/food_recommendation.dart';
import '../utils/recommendation_engine.dart';
import '../data/mock_data.dart';
import 'quiz_provider.dart';

final soulFoodScoreProvider = Provider<SoulFoodScore?>((ref) {
  final questions = ref.watch(selectedQuestionsProvider);
  final answers = ref.watch(answersProvider);

  if (questions.length != 4) return null;
  for (final q in questions) {
    if (!answers.containsKey(q.id)) return null;
  }

  final answeredOptions = questions.map((q) => answers[q.id]!).toList();
  return RecommendationEngine.calculateScore(questions, answeredOptions);
});

final recommendedFoodsProvider = Provider<List<FoodRecommendation>>((ref) {
  final score = ref.watch(soulFoodScoreProvider);
  if (score == null) return [];
  return RecommendationEngine.recommendFoods(score, foodRecommendations);
});
