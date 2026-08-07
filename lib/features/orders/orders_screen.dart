import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/empty_state.dart';
import '../../data/providers.dart';
import 'widgets/order_card.dart';

/// The Orders tab: order history, most recent first, each with a live
/// status tracker and a Reorder shortcut.
///
/// Status is never stored (see `core/logic/order_status.dart`) - it's
/// derived from "now" fresh every time this screen rebuilds, which happens
/// whenever [ordersProvider] changes (most notably, right after checkout,
/// so a freshly-placed order always opens showing "Order placed").
class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No orders yet',
              subtitle: 'Orders you place will show up here, with live tracking.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: OrderCard(order: orders[index], now: now),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Could not load orders: $error')),
      ),
    );
  }
}
