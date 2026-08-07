import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/date_format.dart';
import '../../../core/constants/money_format.dart';
import '../../../core/constants/nav_tabs.dart';
import '../../../core/logic/order_status.dart';
import '../../../core/models/order.dart';
import '../../../core/widgets/gradient_tile.dart';
import '../../../data/providers.dart';
import 'order_status_view.dart';

/// One past order: a collapsed summary (date, total, item previews, live
/// status) that expands to the full line-item list and a Reorder action.
class OrderCard extends ConsumerWidget {
  const OrderCard({super.key, required this.order, required this.now});

  final Order order;
  final DateTime now;

  Future<void> _reorder(BuildContext context, WidgetRef ref) async {
    final catalog = ref.read(productsProvider);
    final result = await ref.read(cartItemsProvider.notifier).mergeOrder(order, catalog);
    if (!context.mounted) return;

    final message = result.hadUnavailableItems
        ? 'Added to cart - ${result.unavailableNames.length} item(s) no longer available.'
        : 'Added ${order.itemCount} items to your cart.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'View cart',
          onPressed: () => ref.read(rootTabIndexProvider.notifier).state = NavTab.cart,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final status = statusForOrder(order.placedAt, now);
    const previewCap = 4;

    return DecoratedBox(
      decoration: BoxDecoration(color: scheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(18)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            key: Key('order-card-${order.id}'),
            tilePadding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatMediumDate(order.placedAt),
                      style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      formatPrice(order.total),
                      style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${order.itemCount} items',
                  style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (final line in order.lines.take(previewCap))
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: GradientTile(
                          emoji: line.emoji,
                          gradientIndex: line.gradientIndex,
                          size: 32,
                          borderRadius: 10,
                          emojiScale: 0.55,
                        ),
                      ),
                    if (order.lines.length > previewCap)
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '+${order.lines.length - previewCap}',
                          style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                OrderStatusView(status: status),
              ],
            ),
            children: [
              for (final line in order.lines)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Text(line.emoji, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text('${line.name} × ${line.quantity}', style: textTheme.bodyMedium),
                      ),
                      Text(formatPrice(line.lineTotal), style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      order.deliveryAddress,
                      style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: Key('reorder-${order.id}'),
                  onPressed: () => _reorder(context, ref),
                  icon: const Icon(Icons.replay),
                  label: const Text('Reorder'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
