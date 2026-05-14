import 'dart:math';
import '../models/question.dart';

class QuizSelector {
  static final Random _random = Random();

  /// 从题库中随机抽取指定数量的题目
  /// [allQuestions] - 全部题目
  /// [count] - 抽取数量，默认4道
  /// [ensureCategories] - 确保每个分类至少有一道题
  static List<Question> selectRandomQuestions(
    List<Question> allQuestions, {
    int count = 4,
    bool ensureCategories = true,
  }) {
    if (allQuestions.length <= count) {
      return allQuestions;
    }

    if (ensureCategories) {
      return _selectWithCategoryBalance(allQuestions, count);
    }

    final shuffled = List<Question>.from(allQuestions)..shuffle(_random);
    return shuffled.take(count).toList();
  }

  /// 确保各分类平衡的随机选择
  static List<Question> _selectWithCategoryBalance(
    List<Question> allQuestions,
    int count,
  ) {
    final Map<String, List<Question>> byCategory = {};
    for (final q in allQuestions) {
      byCategory.putIfAbsent(q.category, () => []).add(q);
    }

    final List<Question> selected = [];

    // 优先从每个分类各抽1道，确保多样性
    final categories = byCategory.keys.toList()..shuffle(_random);
    for (int i = 0; i < count && i < categories.length; i++) {
      final categoryQuestions = byCategory[categories[i]]!;
      final pick = categoryQuestions[_random.nextInt(categoryQuestions.length)];
      selected.add(pick);
    }

    // 如果还不够，从剩余题目中随机补充
    if (selected.length < count) {
      final remaining = allQuestions
          .where((q) => !selected.contains(q))
          .toList()
        ..shuffle(_random);
      selected.addAll(remaining.take(count - selected.length));
    }

    // 打乱最终顺序
    selected.shuffle(_random);
    return selected;
  }
}
