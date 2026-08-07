import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/nav_tabs.dart';
import '../../../core/models/product.dart';
import '../../../core/models/shopping_list.dart';
import '../../../core/widgets/gradient_tile.dart';
import '../../../data/providers.dart';
import 'list_detail_sheet.dart';

/// One saved shopping list: name, item-count, a preview strip of its
/// products, and a one-tap "add all to cart". Tapping anywhere else on the
/// card opens the full list in a bottom sheet.
class ShoppingListCard extends ConsumerWidget {
  const ShoppingListCard({super.key, required this.list});

  final ShoppingList list;

  Future<void> _addAllToCart(BuildContext context, WidgetRef ref) async {
    await ref.read(cartItemsProvider.notifier).addProducts(list.productIds);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${list.productIds.length} items to your cart.'),
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
    final catalog = ref.watch(productsProvider);
    final productsById = <String, Product>{for (final product in catalog) product.id: product};
    final products = [
      for (final id in list.productIds)
        if (productsById.containsKey(id)) productsById[id]!,
    ];
    const previewCap = 5;

    return Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        key: Key('list-card-${list.id}'),
        borderRadius: BorderRadius.circular(18),
        onTap: () => showListDetailSheet(context, list.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(list.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(list.name, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        Text(
                          '${products.length} item${products.length == 1 ? '' : 's'}',
                          style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                ],
              ),
              if (products.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    for (final product in products.take(previewCap))
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: GradientTile(
                          emoji: product.emoji,
                          gradientIndex: product.gradientIndex,
                          size: 30,
                          borderRadius: 9,
                          emojiScale: 0.55,
                        ),
                      ),
                    if (products.length > previewCap)
                      Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text(
                          '+${products.length - previewCap}',
                          style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: Key('add-all-${list.id}'),
                  onPressed: products.isEmpty ? null : () => _addAllToCart(context, ref),
                  icon: const Icon(Icons.add_shopping_cart, size: 18),
                  label: const Text('Add all to cart'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
