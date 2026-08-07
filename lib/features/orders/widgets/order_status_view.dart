import 'package:flutter/material.dart';

import '../../../core/logic/order_status.dart';

Color _colorFor(OrderStatus status, ColorScheme scheme) => switch (status) {
      OrderStatus.placed => const Color(0xFF64748B),
      OrderStatus.preparing => const Color(0xFFF59E0B),
      OrderStatus.outForDelivery => const Color(0xFF6366F1),
      OrderStatus.delivered => scheme.primary,
    };

String _shortLabel(OrderStatus status) => switch (status) {
      OrderStatus.placed => 'Placed',
      OrderStatus.preparing => 'Preparing',
      OrderStatus.outForDelivery => 'On the way',
      OrderStatus.delivered => 'Delivered',
    };

/// A live status label, progress bar, and 4-stage tracker for an order -
/// the visual heart of the Orders screen. [status] is expected to be
/// recomputed by the caller from `statusForOrder` on a timer, so this
/// widget itself stays a plain, stateless function of its input.
class OrderStatusView extends StatelessWidget {
  const OrderStatusView({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = _colorFor(status, scheme);
    final currentIndex = orderStatusSequence.indexOf(status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(status.label, style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: status.progress,
            minHeight: 6,
            backgroundColor: scheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final stage in orderStatusSequence)
              Text(
                _shortLabel(stage),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: stage == status ? FontWeight.w700 : FontWeight.w500,
                  color: orderStatusSequence.indexOf(stage) <= currentIndex ? color : scheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
