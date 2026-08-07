import 'package:flutter/material.dart';

import '../constants/gradients.dart';

/// A rounded gradient square with a big emoji centered on top - Groczy's
/// stand-in for product/category photography. Used at different sizes on
/// the Shop grid, cart lines, order history rows, and shopping list
/// previews, so a given [gradientIndex] always looks the same everywhere.
class GradientTile extends StatelessWidget {
  const GradientTile({
    super.key,
    required this.emoji,
    required this.gradientIndex,
    this.size = 56,
    this.borderRadius = 16,
    this.emojiScale = 0.5,
  });

  final String emoji;
  final int gradientIndex;
  final double size;
  final double borderRadius;

  /// Emoji font size as a fraction of [size].
  final double emojiScale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: gradientFor(gradientIndex),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: TextStyle(fontSize: size * emojiScale)),
    );
  }
}
