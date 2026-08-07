import 'package:flutter/material.dart';

import '../../../core/constants/money_format.dart';
import '../../../core/logic/cart.dart';

/// The subtotal / delivery fee / tax / total breakdown, plus a nudge
/// banner encouraging a person to add a bit more for free delivery.
class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({super.key, required this.totals});

  final CartTotals totals;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!totals.qualifiesForFreeDelivery) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: scheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_shipping_outlined, size: 18, color: scheme.onTertiaryContainer),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Add ${formatPrice(totals.amountToFreeDelivery)} more for free delivery',
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onTertiaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
            _SummaryRow(label: 'Subtotal', value: formatPrice(totals.subtotal)),
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Delivery fee',
              value: totals.deliveryFee <= 0 ? 'FREE' : formatPrice(totals.deliveryFee),
              valueColor: totals.deliveryFee <= 0 ? scheme.primary : null,
            ),
            const SizedBox(height: 8),
            _SummaryRow(label: 'Tax', value: formatPrice(totals.tax)),
            const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
            _SummaryRow(
              label: 'Total',
              value: formatPrice(totals.total),
              emphasize: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool emphasize;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final labelStyle = emphasize
        ? textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)
        : textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant);

    final valueStyle = (emphasize ? textTheme.titleMedium : textTheme.bodyMedium)?.copyWith(
      fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
      color: valueColor ?? scheme.onSurface,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(value, style: valueStyle),
      ],
    );
  }
}
