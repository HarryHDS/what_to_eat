import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class MoodTag extends StatelessWidget {
  final String label;
  final String emoji;
  final bool filled;

  const MoodTag({
    super.key,
    required this.label,
    required this.emoji,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? primaryColor : primaryColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$emoji $label',
        style: GoogleFonts.notoSansSc(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: filled ? Colors.white : primaryColor,
        ),
      ),
    );
  }
}
