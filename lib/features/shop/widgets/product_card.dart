import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/gradients.dart';
import '../../../core/constants/money_format.dart';
import '../../../core/models/product.dart';
import '../../../core/widgets/quantity_stepper.dart';
import '../../../data/providers.dart';

/// One product tile on the Shop grid: gradient + emoji art, a favorite
/// heart, name, unit, price, and either an "Add" button (quantity 0) or a
/// quantity stepper (quantity 1+).
class ProductCard extends ConsumerWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quantity = ref.watch(cartQuantityForProductProvider(product.id));
    final isFavorite = ref.watch(favoriteProductIdsProvider).contains(product.id);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final cartNotifier = ref.read(cartItemsProvider.notifier);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(gradient: gradientFor(product.gradientIndex)),
                      child: Center(
                        child: Text(product.emoji, style: const TextStyle(fontSize: 40)),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: _FavoriteButton(
                      isFavorite: isFavorite,
                      onPressed: () => ref.read(shoppingListsProvider.notifier).toggleFavorite(product.id),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  product.unit,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatPrice(product.price),
                      style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: scheme.primary),
                    ),
                    if (quantity <= 0)
                      _AddButton(
                        key: Key('add-to-cart-${product.id}'),
                        onPressed: () => cartNotifier.increment(product.id),
                      )
                    else
                      QuantityStepper(
                        key: Key('quantity-stepper-${product.id}'),
                        quantity: quantity,
                        compact: true,
                        decrementIcon: quantity == 1 ? Icons.delete_outline : Icons.remove,
                        onIncrement: () => cartNotifier.increment(product.id),
                        onDecrement: () => cartNotifier.decrement(product.id),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.primary,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(Icons.add, size: 18, color: scheme.onPrimary),
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.isFavorite, required this.onPressed});

  final bool isFavorite;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.28),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            size: 17,
            color: isFavorite ? const Color(0xFFFB7185) : Colors.white,
          ),
        ),
      ),
    );
  }
}
