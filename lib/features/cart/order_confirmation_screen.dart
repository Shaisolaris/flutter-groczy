import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/money_format.dart';
import '../../core/constants/nav_tabs.dart';
import '../../core/models/order.dart';
import '../../data/providers.dart';

/// A short, human-friendly confirmation code derived from an order id, e.g.
/// "GRC-482910". Cosmetic only - the real identifier is [Order.id].
String _displayCode(String orderId) {
  final digitsOnly = orderId.replaceAll(RegExp(r'[^0-9]'), '');
  final tail = digitsOnly.length >= 6 ? digitsOnly.substring(digitsOnly.length - 6) : digitsOnly.padLeft(6, '0');
  return 'GRC-$tail';
}

/// Shown right after checkout: a success moment plus quick links to keep
/// shopping or jump straight to tracking the new order.
class OrderConfirmationScreen extends ConsumerWidget {
  const OrderConfirmationScreen({super.key, required this.order});

  final Order order;

  void _goToTab(BuildContext context, WidgetRef ref, int tab) {
    ref.read(rootTabIndexProvider.notifier).state = tab;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(color: scheme.primaryContainer, shape: BoxShape.circle),
                child: Icon(Icons.check_rounded, size: 52, color: scheme.onPrimaryContainer),
              ),
              const SizedBox(height: 24),
              Text(
                'Order placed!',
                style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Confirmation ${_displayCode(order.id)}',
                style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 28),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _InfoRow(icon: Icons.schedule, label: order.slotLabel),
                      const SizedBox(height: 12),
                      _InfoRow(icon: Icons.location_on_outlined, label: order.deliveryAddress),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(height: 1)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${order.itemCount} items', style: textTheme.bodyMedium),
                          Text(
                            formatPrice(order.total),
                            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _goToTab(context, ref, NavTab.orders),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Track your order'),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => _goToTab(context, ref, NavTab.shop),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Continue shopping'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: scheme.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
      ],
    );
  }
}
