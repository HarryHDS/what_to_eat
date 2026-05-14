import 'dart:math';

import '../models/question.dart';
import '../models/soul_food_score.dart';
import '../models/food_recommendation.dart';

class RecommendationEngine {
  // ============================================================
  // 维度到菜品的映射（用于匹配）
  // ============================================================
  static const Map<String, List<String>> _moodFoodMapping = {
    'happy': ['f01', 'f03', 'f05', 'f07', 'f08', 'f09', 'f10', 'f11', 'f13', 'f15', 'f17', 'f19', 'f21', 'f23', 'f25', 'f26', 'f27', 'f28', 'f29', 'f30', 'f31', 'f32', 'f33', 'f34', 'f35', 'f39', 'f40'],
    'tired': ['f02', 'f05', 'f06', 'f12', 'f13', 'f14', 'f16', 'f18', 'f20', 'f22', 'f24', 'f32', 'f36', 'f37', 'f38'],
    'adventurous': ['f01', 'f03', 'f04', 'f08', 'f11', 'f15', 'f17', 'f19', 'f21', 'f23', 'f25', 'f26', 'f29', 'f30', 'f33', 'f35', 'f39', 'f40'],
    'comfort': ['f02', 'f04', 'f05', 'f06', 'f07', 'f09', 'f10', 'f12', 'f14', 'f16', 'f17', 'f18', 'f19', 'f20', 'f22', 'f23', 'f24', 'f25', 'f27', 'f28', 'f31', 'f32', 'f33', 'f34', 'f35', 'f36', 'f37', 'f38', 'f39'],
    'social': ['f01', 'f03', 'f07', 'f08', 'f09', 'f10', 'f11', 'f15', 'f17', 'f19', 'f21', 'f26', 'f27', 'f28', 'f29', 'f30', 'f33', 'f34', 'f35'],
    'alone': ['f02', 'f04', 'f05', 'f06', 'f12', 'f13', 'f14', 'f16', 'f18', 'f20', 'f22', 'f24', 'f31', 'f32', 'f36', 'f37', 'f38', 'f40'],
  };

  // ============================================================
  // 人格匹配：主心情 + 次心情 → 人格标签
  // ============================================================
  static const Map<String, _PersonaDef> _personaMap = {
    'happy_social': _PersonaDef('社交悍匪型', '🎉', '你就是饭局的核心！热闹是美食的最佳调味料，一个人吃的是饭，一群人吃的是人间烟火。你相信：没有不好吃的菜，只有不够嗨的局。'),
    'tired_comfort': _PersonaDef('治愈系干饭人', '🍜', '累了就好好吃饭，这是你最温柔的自愈方式。一碗热汤、一份盖饭，不需要多华丽——够暖、够香、够舒服，就是最好的治愈。'),
    'adventurous_happy': _PersonaDef('美食探险家', '🗺️', '你的舌头永远在寻找下一个惊喜。新的餐厅、新的菜系、新的味道——你是朋友圈里的美食雷达，没人比你更懂哪里值得吃。'),
    'alone_comfort': _PersonaDef('独食享乐派', '🍽️', '一个人吃饭不是将就，是享受。不用迁就口味、不用找话题，只需专注食物本身。你把独食变成了一种精致的生活方式。'),
    'social_adventurous': _PersonaDef('聚餐发起者', '🥳', '发现新餐厅的第一反应是"拉群"！你不仅热爱美食，更热爱和人一起分享美食的快乐。你是那个总能组织起饭局的人。'),
    'tired_alone': _PersonaDef('自闭充电中', '😴', '别找我，我在和自己吃饭。独处不是孤独，而是给自己充电的最佳方式。一碗面配一部剧，就是最完美的 meal time。'),
    'happy_comfort': _PersonaDef('小确幸收藏家', '🌸', '你懂得在平凡食物中发现幸福。一杯奶茶、一份甜品、一碗热汤——这些小小的美好，就是照亮你一天的光。'),
    'adventurous_alone': _PersonaDef('孤独美食家', '🍣', '不需要人陪，也能吃出精彩。你是一个人的美食家，独自探店、独自品味、独自点评。美食不需要观众，好吃就是王道。'),
  };

  // ============================================================
  // 匹配理由文案模板
  // ============================================================
  static const Map<String, String> _matchReasonTemplates = {
    'happy': '你的灵魂充满活力，这份快乐值得被美食放大',
    'tired': '疲惫的灵魂需要温柔的抚慰，这份食物懂你的累',
    'adventurous': '你的灵魂渴望新鲜感，这份食物能带你探索味蕾新世界',
    'comfort': '温暖的灵魂值得被好好照顾，这份食物就是最好的拥抱',
    'social': '热爱社交的灵魂，这份食物会让你的饭局更加精彩',
    'alone': '享受独处的灵魂，这份食物是你最默契的陪伴',
  };

  // ============================================================
  // 核心方法：计算灵魂食分
  // ============================================================
  static SoulFoodScore calculateScore(
    List<Question> answeredQuestions,
    List<Option> answers,
  ) {
    // 1. 累加各维度得分
    final Map<String, int> totalScores = {
      'happy': 0,
      'tired': 0,
      'adventurous': 0,
      'comfort': 0,
      'social': 0,
      'alone': 0,
    };

    for (final answer in answers) {
      for (final entry in answer.moodScores.entries) {
        totalScores[entry.key] = (totalScores[entry.key] ?? 0) + entry.value;
      }
    }

    // 2. 找出得分最高的两个维度
    final sortedEntries = totalScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final primaryMood = sortedEntries[0].key;
    final secondaryMood = sortedEntries[1].key;

    // 3. 查找人格类型（尝试两种顺序）
    final lookupKey = '${primaryMood}_$secondaryMood';
    final altKey = '${secondaryMood}_$primaryMood';
    final persona = _personaMap[lookupKey] ?? _personaMap[altKey] ??
        _PersonaDef('神秘美食家', '🎭', '你的口味独特而不可归类——这正是灵魂有趣的表现。随心而食，不被定义。');

    return SoulFoodScore(
      primaryMood: primaryMood,
      secondaryMood: secondaryMood,
      scoreMap: totalScores,
      description: persona.description,
      foodPersona: persona.label,
      emoji: persona.emoji,
      questionCount: answeredQuestions.length,
    );
  }

  // ============================================================
  // 核心方法：根据食分推荐菜品
  // ============================================================
  static List<FoodRecommendation> recommendFoods(
    SoulFoodScore score,
    List<FoodRecommendation> allFoods,
  ) {
    final primarySet = _moodFoodMapping[score.primaryMood] ?? <String>[];
    final secondarySet = _moodFoodMapping[score.secondaryMood] ?? <String>[];

    // 计算每个菜品的匹配度
    final List<_ScoredFood> scored = [];
    for (final food in allFoods) {
      int matchScore = 0;

      // 主心情匹配 +60 分
      if (primarySet.contains(food.id)) matchScore += 60;
      // 次心情匹配 +40 分
      if (secondarySet.contains(food.id)) matchScore += 40;
      // 主心情命中数 + 次心情命中数（防止同分时无排序依据）
      matchScore += (primarySet.contains(food.id) ? 1 : 0) +
          (secondarySet.contains(food.id) ? 1 : 0);

      if (matchScore > 0) {
        // 生成匹配理由
        final reasonKey = primarySet.contains(food.id)
            ? score.primaryMood
            : score.secondaryMood;
        final reason = _matchReasonTemplates[reasonKey] ?? '这份食物和你的灵魂产生了共鸣';

        scored.add(_ScoredFood(food: food, matchScore: matchScore, matchReason: reason));
      }
    }

    // 按匹配度降序排列
    scored.sort((a, b) => b.matchScore.compareTo(a.matchScore));

    // 同分段内随机打乱，保证每次推荐结果有变化
    final rng = Random();
    int groupStart = 0;
    for (int i = 1; i <= scored.length; i++) {
      if (i == scored.length || scored[i].matchScore != scored[groupStart].matchScore) {
        final group = scored.sublist(groupStart, i);
        group.shuffle(rng);
        scored.setRange(groupStart, i, group);
        groupStart = i;
      }
    }

    // 归一化分数到 0-100
    final int maxScore = scored.isNotEmpty ? scored.first.matchScore : 1;
    for (final s in scored) {
      s.matchScore = ((s.matchScore / maxScore) * 100).round();
    }

    // 返回前3个
    return scored.take(3).map((s) {
      return FoodRecommendation(
        id: s.food.id,
        name: s.food.name,
        description: s.food.description,
        tags: s.food.tags,
        matchReason: s.matchReason,
        emoji: s.food.emoji,
        matchScore: s.matchScore,
      );
    }).toList();
  }
}

// ---- 内部辅助类型 ----

class _PersonaDef {
  final String label;
  final String emoji;
  final String description;
  const _PersonaDef(this.label, this.emoji, this.description);
}

class _ScoredFood {
  final FoodRecommendation food;
  int matchScore;
  final String matchReason;
  _ScoredFood({required this.food, required this.matchScore, required this.matchReason});
}
