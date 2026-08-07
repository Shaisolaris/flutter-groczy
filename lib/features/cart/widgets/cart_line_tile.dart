import 'package:flutter/material.dart';

import '../../../core/constants/money_format.dart';
import '../../../core/logic/cart.dart';
import '../../../core/widgets/gradient_tile.dart';
import '../../../core/widgets/quantity_stepper.dart';

/// One row in the Cart screen's line-item list: product art, name/unit,
/// per-unit price, a quantity stepper, and the line total.
class CartLineTile extends StatelessWidget {
  const CartLineTile({
    super.key,
    required this.line,
    required this.onIncrement,
    required this.onDecrement,
  });

  final CartLine line;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final product = line.product;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GradientTile(emoji: product.emoji, gradientIndex: product.gradientIndex, size: 56, borderRadius: 14),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  '${formatPrice(product.price)} · ${product.unit}',
                  style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                QuantityStepper(
                  key: Key('cart-stepper-${product.id}'),
                  quantity: line.quantity,
                  compact: true,
                  decrementIcon: line.quantity == 1 ? Icons.delete_outline : Icons.remove,
                  onIncrement: onIncrement,
                  onDecrement: onDecrement,
                ),
              ],
            ),
          ),
          Text(
            formatPrice(line.lineTotal),
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
