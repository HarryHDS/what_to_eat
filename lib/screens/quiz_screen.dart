import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import '../providers/quiz_provider.dart';
import '../widgets/option_card.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = -1;
  bool _isTransitioning = false;

  // Fade animation for question transitions
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
    _fadeCtrl.value = 1.0;
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectOption(int index) async {
    if (_isTransitioning) return;
    setState(() {
      _selectedIndex = index;
      _isTransitioning = true;
    });

    final questions = ref.read(selectedQuestionsProvider);
    final step = ref.read(currentStepProvider);
    final question = questions[step];

    ref.read(answersProvider.notifier).state = {
      ...ref.read(answersProvider),
      question.id: question.options[index],
    };

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;
    final nextStep = step + 1;
    if (nextStep >= 4) {
      if (mounted) context.go('/loading');
    } else {
      // Fade out → update question → fade in
      await _fadeCtrl.reverse();
      ref.read(currentStepProvider.notifier).state = nextStep;
      setState(() {
        _selectedIndex = -1;
        _isTransitioning = false;
      });
      _fadeCtrl.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = ref.watch(selectedQuestionsProvider);
    final step = ref.watch(currentStepProvider);

    if (questions.length < 4) {
      return Scaffold(
        backgroundColor: bgColor,
        body: const Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    final question = questions[step];

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            _ProgressBar(step: step),
            const SizedBox(height: 48),
            // Category tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                question.category,
                style: GoogleFonts.notoSansSc(
                  fontSize: 13,
                  color: primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Question text with fade transition
            FadeTransition(
              opacity: _fadeAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  question.questionText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansSc(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Options with fade transition
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: question.options.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: OptionCard(
                        option: question.options[index],
                        isSelected: _selectedIndex == index,
                        onTap: () => _selectOption(index),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int step;
  const _ProgressBar({required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '第 ${step + 1} / 4 题',
                style: GoogleFonts.notoSansSc(
                  fontSize: 14,
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/'),
                child: Text(
                  '退出',
                  style: GoogleFonts.notoSansSc(fontSize: 14, color: textLight),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: (step + 1) / 4),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              builder: (_, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: const Color(0xFFE8E3D3),
                  color: primaryColor,
                  minHeight: 6,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
