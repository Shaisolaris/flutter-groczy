import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/product.dart';

/// Pure "reorder" math: merging a past [Order]'s line items back into the
/// current cart. Nothing here depends on Flutter or storage.

/// The result of merging a past order into the current cart: the new cart
/// contents, plus the names of any lines that could not be re-added
/// because that product no longer exists in the live catalog (e.g. it was
/// discontinued since the order was placed).
class ReorderResult {
  const ReorderResult({required this.items, required this.unavailableNames});

  final List<CartItem> items;
  final List<String> unavailableNames;

  bool get hadUnavailableItems => unavailableNames.isNotEmpty;

  @override
  String toString() => 'ReorderResult(${items.length} items, unavailable: $unavailableNames)';
}

/// Merges every line of [order] into [currentCart]: a product already in
/// the cart has [OrderLine.quantity] *added* to its existing quantity
/// (rather than being overwritten), and a product not yet in the cart is
/// added fresh. Order lines whose product id is no longer present in
/// [catalog] are skipped and reported back via
/// [ReorderResult.unavailableNames] instead of silently disappearing.
///
/// [currentCart] is left untouched; a new list is returned.
ReorderResult mergeOrderIntoCart({
  required List<CartItem> currentCart,
  required Order order,
  required List<Product> catalog,
}) {
  final catalogIds = <String>{for (final product in catalog) product.id};
  final quantityByProductId = <String, int>{
    for (final item in currentCart) item.productId: item.quantity,
  };
  final unavailableNames = <String>[];

  for (final line in order.lines) {
    if (!catalogIds.contains(line.productId)) {
      unavailableNames.add(line.name);
      continue;
    }
    final existingQuantity = quantityByProductId[line.productId] ?? 0;
    quantityByProductId[line.productId] = existingQuantity + line.quantity;
  }

  final mergedItems = <CartItem>[
    for (final entry in quantityByProductId.entries) CartItem(productId: entry.key, quantity: entry.value),
  ];

  return ReorderResult(items: mergedItems, unavailableNames: unavailableNames);
}
