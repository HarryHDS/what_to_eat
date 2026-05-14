import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({super.key});

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _spinCtrl;
  late final AnimationController _pulseCtrl;
  int _textIdx = 0;
  Timer? _textTimer;
  Timer? _navTimer;

  static const _foods = ['🍜', '🍣', '🍕', '🍲', '🥘', '🍛', '🍗', '🧋'];
  static const _texts = [
    '正在分析你的灵魂…',
    '计算美食匹配度…',
    '寻找最适合你的味道…',
    '即将揭晓…',
  ];

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _textTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) {
        setState(() => _textIdx = (_textIdx + 1) % _texts.length);
      }
    });

    _navTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) context.go('/result');
    });
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    _pulseCtrl.dispose();
    _textTimer?.cancel();
    _navTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Spinning food emoji
              AnimatedBuilder(
                animation: _spinCtrl,
                builder: (_, child) {
                  return Transform.rotate(
                    angle: _spinCtrl.value * 2 * pi,
                    child: child,
                  );
                },
                child: AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, child) {
                    return Transform.scale(
                      scale: 1.0 + _pulseCtrl.value * 0.15,
                      child: child,
                    );
                  },
                  child: Text(
                    _foods[DateTime.now().millisecond % _foods.length],
                    style: const TextStyle(fontSize: 72),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Animated dots
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  _texts[_textIdx],
                  key: ValueKey(_textIdx),
                  style: GoogleFonts.notoSansSc(
                    fontSize: 16,
                    color: textMedium,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  color: primaryColor.withValues(alpha: 0.5),
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
