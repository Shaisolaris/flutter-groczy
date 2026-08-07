import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/money_format.dart';
import '../../core/constants/nav_tabs.dart';
import '../../core/logic/slots.dart';
import '../../core/models/order.dart';
import '../../core/utils/id_generator.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/section_header.dart';
import '../../data/providers.dart';
import '../../data/seed_data.dart';
import 'order_confirmation_screen.dart';
import 'widgets/cart_line_tile.dart';
import 'widgets/delivery_slot_picker.dart';
import 'widgets/order_summary_card.dart';

/// The Cart tab: line items, delivery slot picker, delivery address, order
/// summary, and checkout.
class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: ref.read(deliveryAddressProvider));
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _checkout() async {
    final lines = ref.read(cartLinesProvider);
    final totals = ref.read(cartTotalsProvider);
    final slot = ref.read(selectedSlotProvider);
    if (lines.isEmpty || slot == null) return;

    final now = DateTime.now();
    final address = _addressController.text.trim().isEmpty ? defaultDeliveryAddress : _addressController.text.trim();

    final order = Order(
      id: generateId('order'),
      placedAt: now,
      lines: [
        for (final line in lines)
          OrderLine(
            productId: line.product.id,
            name: line.product.name,
            unit: line.product.unit,
            emoji: line.product.emoji,
            gradientIndex: line.product.gradientIndex,
            price: line.product.price,
            quantity: line.quantity,
          ),
      ],
      deliveryAddress: address,
      slotLabel: slotDisplayLabel(slot, now),
      subtotal: totals.subtotal,
      deliveryFee: totals.deliveryFee,
      tax: totals.tax,
      total: totals.total,
    );

    await ref.read(ordersProvider.notifier).placeOrder(order);
    await ref.read(cartItemsProvider.notifier).clearCart();
    ref.read(selectedSlotIdProvider.notifier).state = null;

    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => OrderConfirmationScreen(order: order)));
  }

  @override
  Widget build(BuildContext context) {
    final lines = ref.watch(cartLinesProvider);
    final totals = ref.watch(cartTotalsProvider);
    final slots = ref.watch(availableSlotsProvider);
    final selectedSlotId = ref.watch(selectedSlotIdProvider);
    final cartNotifier = ref.read(cartItemsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: lines.isEmpty
          ? EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              subtitle: 'Add items from the Shop tab to get started.',
              actionLabel: 'Start shopping',
              onAction: () => ref.read(rootTabIndexProvider.notifier).state = NavTab.shop,
            )
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      children: [
                        for (var i = 0; i < lines.length; i++) ...[
                          if (i > 0) const Divider(height: 1),
                          CartLineTile(
                            line: lines[i],
                            onIncrement: () => cartNotifier.increment(lines[i].product.id),
                            onDecrement: () => cartNotifier.decrement(lines[i].product.id),
                          ),
                        ],
                        const SizedBox(height: 12),
                        const SectionHeader(title: 'Delivery slot'),
                        const SizedBox(height: 10),
                        DeliverySlotPicker(
                          slots: slots,
                          selectedSlotId: selectedSlotId,
                          now: DateTime.now(),
                          onSelect: (id) => ref.read(selectedSlotIdProvider.notifier).state = id,
                        ),
                        const SizedBox(height: 4),
                        const SectionHeader(title: 'Deliver to'),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _addressController,
                          maxLines: 2,
                          minLines: 1,
                          onChanged: (value) => ref.read(deliveryAddressProvider.notifier).state = value,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.location_on_outlined),
                            hintText: 'Delivery address',
                          ),
                        ),
                        const SizedBox(height: 20),
                        OrderSummaryCard(totals: totals),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: selectedSlotId == null ? null : _checkout,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Text(
                            selectedSlotId == null
                                ? 'Select a delivery slot to continue'
                                : 'Checkout · ${formatPrice(totals.total)}',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
