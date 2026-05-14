import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/mock_data.dart';
import '../models/mood_dimensions.dart';
import '../utils/constants.dart';
import '../utils/quiz_selector.dart';
import '../providers/quiz_provider.dart';
import '../providers/recommendation_provider.dart';
import '../widgets/food_card.dart';
import '../widgets/mood_tag.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen>
    with TickerProviderStateMixin {
  late final AnimationController _staggerCtrl;
  late final Animation<double> _emojiAnim;
  late final Animation<double> _nameAnim;
  late final Animation<double> _tagsAnim;
  late final Animation<double> _descAnim;
  late final Animation<double> _barsAnim;
  late final List<Animation<double>> _foodAnims;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _emojiAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerCtrl,
        curve: const Interval(0.0, 0.25, curve: Curves.elasticOut),
      ),
    );
    _nameAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerCtrl,
        curve: const Interval(0.15, 0.4, curve: Curves.easeOut),
      ),
    );
    _tagsAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerCtrl,
        curve: const Interval(0.3, 0.55, curve: Curves.easeOut),
      ),
    );
    _descAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerCtrl,
        curve: const Interval(0.45, 0.7, curve: Curves.easeOut),
      ),
    );
    _barsAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggerCtrl,
        curve: const Interval(0.6, 0.85, curve: Curves.easeOut),
      ),
    );

    const foodIntervals = [
      Interval(0.75, 0.90, curve: Curves.easeOutCubic),
      Interval(0.83, 0.96, curve: Curves.easeOutCubic),
      Interval(0.90, 1.0, curve: Curves.easeOutCubic),
    ];
    _foodAnims = List.generate(3, (i) {
      return Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _staggerCtrl, curve: foodIntervals[i]),
      );
    });

    _staggerCtrl.forward();
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  void _retake() {
    ref.read(currentStepProvider.notifier).state = 0;
    ref.read(answersProvider.notifier).state = {};
    ref.read(selectedQuestionsProvider.notifier).state =
        QuizSelector.selectRandomQuestions(questionBank, count: 4);
    context.go('/quiz');
  }

  @override
  Widget build(BuildContext context) {
    final score = ref.watch(soulFoodScoreProvider);
    final foods = ref.watch(recommendedFoodsProvider);

    if (score == null) {
          return Scaffold(
            backgroundColor: bgColor,
            body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        color: primaryColor,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '正在解读你的灵魂…',
                      style: GoogleFonts.notoSansSc(
                        fontSize: 16,
                        color: textMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final sortedMoods = score.scoreMap.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: AnimatedBuilder(
              animation: _staggerCtrl,
              builder: (_, _) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        '你的灵魂食分',
                        style: GoogleFonts.notoSansSc(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // ---- Personality Card (staggered) ----
                      _PersonalityCard(
                        score: score,
                        sortedMoods: sortedMoods,
                        emojiAnim: _emojiAnim,
                        nameAnim: _nameAnim,
                        tagsAnim: _tagsAnim,
                        descAnim: _descAnim,
                        barsAnim: _barsAnim,
                      ),
                      const SizedBox(height: 32),
                      // ---- Recommendations ----
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '🍽️  为你推荐',
                          style: GoogleFonts.notoSansSc(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...List.generate(foods.length, (i) {
                        final anim = i < _foodAnims.length
                            ? _foodAnims[i]
                            : _foodAnims.last;
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.25),
                            end: Offset.zero,
                          ).animate(anim),
                          child: FadeTransition(
                            opacity: anim,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: FoodCard(food: foods[i]),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 24),
                      // ---- Footer ----
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: _retake,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: const BorderSide(
                                color: primaryColor, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(radiusButton),
                            ),
                          ),
                          child: Text(
                            '再测一次',
                            style: GoogleFonts.notoSansSc(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => context.go('/'),
                        child: Text(
                          '返回首页',
                          style: GoogleFonts.notoSansSc(
                            fontSize: 14,
                            color: textLight,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                );
              },
            ),
          ),
        );
  }
}

class _PersonalityCard extends StatelessWidget {
  final dynamic score;
  final List<MapEntry<String, int>> sortedMoods;
  final Animation<double> emojiAnim;
  final Animation<double> nameAnim;
  final Animation<double> tagsAnim;
  final Animation<double> descAnim;
  final Animation<double> barsAnim;

  const _PersonalityCard({
    required this.score,
    required this.sortedMoods,
    required this.emojiAnim,
    required this.nameAnim,
    required this.tagsAnim,
    required this.descAnim,
    required this.barsAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(radiusCard),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Emoji with bounce
          ScaleTransition(
            scale: emojiAnim,
            child: Text(score.emoji, style: const TextStyle(fontSize: 64)),
          ),
          const SizedBox(height: 14),
          // Name
          FadeTransition(
            opacity: nameAnim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(nameAnim),
              child: Text(
                score.foodPersona,
                style: GoogleFonts.notoSansSc(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Mood tags
          FadeTransition(
            opacity: tagsAnim,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MoodTag(
                  label: '主：${getMoodLabel(score.primaryMood)}',
                  emoji: getMoodEmoji(score.primaryMood),
                  filled: true,
                ),
                const SizedBox(width: 10),
                MoodTag(
                  label: '次：${getMoodLabel(score.secondaryMood)}',
                  emoji: getMoodEmoji(score.secondaryMood),
                  filled: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Description
          FadeTransition(
            opacity: descAnim,
            child: Text(
              score.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansSc(
                fontSize: 15,
                height: 1.7,
                color: textMedium,
              ),
            ),
          ),
          const SizedBox(height: 22),
          // Mood bars
          FadeTransition(
            opacity: barsAnim,
            child: Column(
              children: sortedMoods.map((entry) {
                final maxVal = sortedMoods.first.value;
                final ratio = maxVal > 0 ? entry.value / maxVal : 0.0;
                final isTop = entry.key == score.primaryMood ||
                    entry.key == score.secondaryMood;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 72,
                        child: Text(
                          '${getMoodEmoji(entry.key)} ${getMoodLabel(entry.key)}',
                          style: GoogleFonts.notoSansSc(
                            fontSize: 12,
                            fontWeight:
                                isTop ? FontWeight.w600 : FontWeight.w400,
                            color: isTop ? textDark : textLight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: ratio),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOut,
                            builder: (_, value, _) {
                              return LinearProgressIndicator(
                                value: value,
                                backgroundColor: const Color(0xFFE8E3D3),
                                color: isTop
                                    ? primaryColor
                                    : primaryColor.withValues(alpha: 0.35),
                                minHeight: 6,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 24,
                        child: Text(
                          '${entry.value}',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.notoSansSc(
                            fontSize: 12,
                            fontWeight:
                                isTop ? FontWeight.w600 : FontWeight.w400,
                            color: isTop ? textDark : textLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
