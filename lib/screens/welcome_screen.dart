import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/mock_data.dart';
import '../utils/constants.dart';
import '../utils/quiz_selector.dart';
import '../providers/quiz_provider.dart';
import '../widgets/animated_button.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _startQuiz() {
    ref.read(currentStepProvider.notifier).state = 0;
    ref.read(answersProvider.notifier).state = {};
    ref.read(selectedQuestionsProvider.notifier).state =
        QuizSelector.selectRandomQuestions(questionBank, count: 4);
    context.push('/quiz');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isSmall = constraints.maxHeight < 600;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),
                      // Emoji circle
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                        builder: (_, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: child,
                          );
                        },
                        child: Container(
                          width: isSmall ? 100 : 140,
                          height: isSmall ? 100 : 140,
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.10),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text('🍜',
                                style: TextStyle(
                                    fontSize: isSmall ? 44 : 64)),
                          ),
                        ),
                      ),
                      SizedBox(height: isSmall ? 20 : 32),
                      Text(
                        appTitle,
                        style: GoogleFonts.notoSansSc(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '不知道吃什么？让灵魂告诉你',
                        style: GoogleFonts.notoSansSc(
                          fontSize: 16,
                          color: textMedium,
                        ),
                      ),
                      if (!isSmall) const Spacer(),
                      SizedBox(height: isSmall ? 32 : 0),
                      AnimatedButton(label: '开始灵魂测试', onTap: _startQuiz),
                      const SizedBox(height: 14),
                      Text(
                        '只需回答 4 道题，找到你的灵魂美食',
                        style: GoogleFonts.notoSansSc(
                          fontSize: 13,
                          color: textLight,
                        ),
                      ),
                      const Spacer(),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
