import 'package:flutter/material.dart';

/// A pill-shaped -/quantity/+ control, used on Shop product tiles and Cart
/// line items alike.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.compact = false,
    this.decrementIcon = Icons.remove,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  /// Smaller footprint for tight spaces like a grid tile.
  final bool compact;

  /// [Icons.remove] for "decrease quantity", or [Icons.delete_outline] when
  /// the caller wants decrementing from 1 to read as "remove".
  final IconData decrementIcon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final iconSize = compact ? 16.0 : 20.0;
    final buttonSize = compact ? 28.0 : 36.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: decrementIcon,
            iconSize: iconSize,
            buttonSize: buttonSize,
            color: scheme.onPrimaryContainer,
            onPressed: onDecrement,
          ),
          SizedBox(
            width: compact ? 18 : 24,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: scheme.onPrimaryContainer,
                fontSize: compact ? 13 : 15,
              ),
            ),
          ),
          _StepperButton(
            icon: Icons.add,
            iconSize: iconSize,
            buttonSize: buttonSize,
            color: scheme.onPrimaryContainer,
            onPressed: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.iconSize,
    required this.buttonSize,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final double iconSize;
  final double buttonSize;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: iconSize,
        color: color,
        icon: Icon(icon),
        onPressed: onPressed,
      ),
    );
  }
}
