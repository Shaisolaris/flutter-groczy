import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/money_format.dart';
import '../../../core/models/product.dart';
import '../../../core/models/shopping_list.dart';
import '../../../core/widgets/gradient_tile.dart';
import '../../../core/constants/nav_tabs.dart';
import '../../../data/providers.dart';
import '../../../data/seed_data.dart' show favoritesListId;

ShoppingList? _findList(List<ShoppingList> lists, String id) {
  for (final list in lists) {
    if (list.id == id) return list;
  }
  return null;
}

/// Opens a bottom sheet showing every product in the list identified by
/// [listId], with per-item removal and a one-tap "add all to cart".
Future<void> showListDetailSheet(BuildContext context, String listId) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (context) => _ListDetailSheet(listId: listId),
  );
}

class _ListDetailSheet extends ConsumerWidget {
  const _ListDetailSheet({required this.listId});

  final String listId;

  Future<void> _addAllToCart(BuildContext context, WidgetRef ref, ShoppingList list) async {
    await ref.read(cartItemsProvider.notifier).addProducts(list.productIds);
    if (!context.mounted) return;
    Navigator.of(context).pop();
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
    final lists = ref.watch(shoppingListsProvider).valueOrNull ?? const <ShoppingList>[];
    final list = _findList(lists, listId);

    if (list == null) {
      return const SizedBox(height: 120, child: Center(child: Text('This list was deleted.')));
    }

    final catalog = ref.watch(productsProvider);
    final productsById = <String, Product>{for (final product in catalog) product.id: product};
    final products = [
      for (final id in list.productIds)
        if (productsById.containsKey(id)) productsById[id]!,
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.outlineVariant,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(list.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(list.name, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              ),
              if (list.id != favoritesListId)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete list',
                  onPressed: () {
                    Navigator.of(context).pop();
                    ref.read(shoppingListsProvider.notifier).deleteList(list.id);
                  },
                ),
            ],
          ),
          Text('${products.length} items', style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          if (products.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No items in this list yet. Add some from the Shop tab.',
                style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: products.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: GradientTile(
                      emoji: product.emoji,
                      gradientIndex: product.gradientIndex,
                      size: 44,
                      borderRadius: 12,
                    ),
                    title: Text(product.name),
                    subtitle: Text('${formatPrice(product.price)} · ${product.unit}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Remove from list',
                      onPressed: () => ref.read(shoppingListsProvider.notifier).removeProductFromList(list.id, product.id),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: products.isEmpty ? null : () => _addAllToCart(context, ref, list),
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Add all to cart'),
            ),
          ),
        ],
      ),
    );
  }
}
