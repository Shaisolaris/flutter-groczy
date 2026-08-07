import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/logic/cart.dart';
import '../core/logic/catalog_filter.dart';
import '../core/logic/reorder.dart';
import '../core/logic/slots.dart';
import '../core/models/cart_item.dart';
import '../core/models/category.dart';
import '../core/models/delivery_slot.dart';
import '../core/models/order.dart';
import '../core/models/product.dart';
import '../core/models/shopping_list.dart';
import '../core/utils/id_generator.dart';
import 'groczy_repository.dart';
import 'seed_data.dart';

/// Overridden with a real instance in `main.dart` once
/// `SharedPreferences.getInstance()` resolves. Left unimplemented here so
/// any accidental read before that override is applied fails loudly
/// instead of silently returning bad data.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden with a real SharedPreferences '
    'instance before the app runs - see main().',
  );
});

/// Which bottom-nav tab is showing on [RootShell]. A provider rather than
/// local widget state so any screen can jump to another tab - e.g.
/// checkout confirmation jumping to Orders, or a snackbar's "View cart"
/// action jumping to Cart.
final rootTabIndexProvider = StateProvider<int>((ref) => 0);

final groczyRepositoryProvider = Provider<GroczyRepository>((ref) {
  return SharedPreferencesGroczyRepository(ref.watch(sharedPreferencesProvider));
});

// Catalog (read-only reference data, rebuilt every launch) ----------------

final categoriesProvider = Provider<List<Category>>((ref) => seedCategories());

final productsProvider = Provider<List<Product>>((ref) => seedProducts());

/// Looks up a single product by id, or `null` if it doesn't exist.
final productByIdProvider = Provider.family<Product?, String>((ref, id) {
  for (final product in ref.watch(productsProvider)) {
    if (product.id == id) return product;
  }
  return null;
});

// Shop screen: category + search filter -----------------------------------

final selectedCategoryIdProvider = StateProvider<String>((ref) => allCategoriesId);

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredProductsProvider = Provider<List<Product>>((ref) {
  final products = ref.watch(productsProvider);
  final categoryId = ref.watch(selectedCategoryIdProvider);
  final query = ref.watch(searchQueryProvider);
  return filterProducts(products, categoryId: categoryId, query: query);
});

// Cart ----------------------------------------------------------------------

class CartItemsNotifier extends AsyncNotifier<List<CartItem>> {
  @override
  Future<List<CartItem>> build() async {
    final repository = ref.watch(groczyRepositoryProvider);
    return repository.loadCartItems();
  }

  Future<void> _persist(List<CartItem> items) async {
    state = AsyncData<List<CartItem>>(items);
    await ref.read(groczyRepositoryProvider).saveCartItems(items);
  }

  int quantityOf(String productId) {
    final items = state.valueOrNull ?? const <CartItem>[];
    for (final item in items) {
      if (item.productId == productId) return item.quantity;
    }
    return 0;
  }

  /// Sets [productId]'s quantity to exactly [quantity]. A [quantity] of `0`
  /// or less removes it from the cart entirely.
  Future<void> setQuantity(String productId, int quantity) async {
    final current = state.valueOrNull ?? const <CartItem>[];
    final withoutProduct = current.where((item) => item.productId != productId).toList();
    final updated = quantity <= 0
        ? withoutProduct
        : <CartItem>[...withoutProduct, CartItem(productId: productId, quantity: quantity)];
    await _persist(updated);
  }

  Future<void> increment(String productId) => setQuantity(productId, quantityOf(productId) + 1);

  Future<void> decrement(String productId) => setQuantity(productId, quantityOf(productId) - 1);

  Future<void> removeItem(String productId) => setQuantity(productId, 0);

  Future<void> clearCart() => _persist(const <CartItem>[]);

  /// Adds one of each product id in [productIds] (incrementing, not
  /// overwriting, any quantity already in the cart) - used by "add all to
  /// cart" on a shopping list.
  Future<void> addProducts(Iterable<String> productIds) async {
    final quantities = <String, int>{
      for (final item in state.valueOrNull ?? const <CartItem>[]) item.productId: item.quantity,
    };
    for (final id in productIds) {
      quantities[id] = (quantities[id] ?? 0) + 1;
    }
    final updated = <CartItem>[
      for (final entry in quantities.entries) CartItem(productId: entry.key, quantity: entry.value),
    ];
    await _persist(updated);
  }

  /// Merges a past [order]'s lines into the cart (see
  /// `core/logic/reorder.dart`) and returns the result so the caller can
  /// surface any unavailable items.
  Future<ReorderResult> mergeOrder(Order order, List<Product> catalog) async {
    final current = state.valueOrNull ?? const <CartItem>[];
    final result = mergeOrderIntoCart(currentCart: current, order: order, catalog: catalog);
    await _persist(result.items);
    return result;
  }
}

final cartItemsProvider = AsyncNotifierProvider<CartItemsNotifier, List<CartItem>>(CartItemsNotifier.new);

/// The live quantity of [productId] in the cart, `0` if it isn't there -
/// watched by Shop product tiles to decide between an "Add" button and a
/// quantity stepper.
final cartQuantityForProductProvider = Provider.family<int, String>((ref, productId) {
  final items = ref.watch(cartItemsProvider).valueOrNull ?? const <CartItem>[];
  for (final item in items) {
    if (item.productId == productId) return item.quantity;
  }
  return 0;
});

final cartLinesProvider = Provider<List<CartLine>>((ref) {
  final items = ref.watch(cartItemsProvider).valueOrNull ?? const <CartItem>[];
  final products = ref.watch(productsProvider);
  return resolveCartLines(items, products);
});

final cartTotalsProvider = Provider<CartTotals>((ref) {
  return calculateTotals(ref.watch(cartLinesProvider));
});

/// Total item count across the cart, driving the bottom-nav Cart badge.
final cartItemCountProvider = Provider<int>((ref) => ref.watch(cartTotalsProvider).itemCount);

// Delivery slots (generated fresh from "now", never persisted) ------------

final deliverySlotsProvider = Provider<List<DeliverySlot>>((ref) => generateSlots(DateTime.now()));

final availableSlotsProvider = Provider<List<DeliverySlot>>((ref) {
  return availableSlots(ref.watch(deliverySlotsProvider), DateTime.now());
});

/// The delivery slot chosen on the Cart screen, `null` until a person picks
/// one - checkout stays disabled until then.
final selectedSlotIdProvider = StateProvider<String?>((ref) => null);

final selectedSlotProvider = Provider<DeliverySlot?>((ref) {
  final id = ref.watch(selectedSlotIdProvider);
  if (id == null) return null;
  for (final slot in ref.watch(availableSlotsProvider)) {
    if (slot.id == id) return slot;
  }
  return null;
});

/// Deliver-to address shown (and editable) on the Cart screen, prefilled
/// with Groczy's one saved address.
final deliveryAddressProvider = StateProvider<String>((ref) => defaultDeliveryAddress);

// Orders ----------------------------------------------------------------

class OrdersNotifier extends AsyncNotifier<List<Order>> {
  @override
  Future<List<Order>> build() async {
    final repository = ref.watch(groczyRepositoryProvider);
    final existing = await repository.loadOrders();
    if (existing.isNotEmpty) return existing;

    final seeded = seedOrders(ref.watch(productsProvider), now: DateTime.now());
    await repository.saveOrders(seeded);
    return seeded;
  }

  /// Prepends a freshly-placed [order] (most recent first) and persists it.
  Future<void> placeOrder(Order order) async {
    final current = state.valueOrNull ?? const <Order>[];
    final updated = <Order>[order, ...current];
    state = AsyncData<List<Order>>(updated);
    await ref.read(groczyRepositoryProvider).saveOrders(updated);
  }
}

final ordersProvider = AsyncNotifierProvider<OrdersNotifier, List<Order>>(OrdersNotifier.new);

// Shopping lists ------------------------------------------------------------

class ShoppingListsNotifier extends AsyncNotifier<List<ShoppingList>> {
  @override
  Future<List<ShoppingList>> build() async {
    final repository = ref.watch(groczyRepositoryProvider);
    final existing = await repository.loadShoppingLists();
    if (existing.isNotEmpty) return existing;

    final seeded = seedShoppingLists();
    await repository.saveShoppingLists(seeded);
    return seeded;
  }

  Future<void> _persist(List<ShoppingList> lists) async {
    state = AsyncData<List<ShoppingList>>(lists);
    await ref.read(groczyRepositoryProvider).saveShoppingLists(lists);
  }

  Future<void> createList(String name, String emoji) async {
    final current = state.valueOrNull ?? const <ShoppingList>[];
    final newList = ShoppingList(id: generateId('list'), name: name, emoji: emoji, productIds: const <String>[]);
    await _persist(<ShoppingList>[...current, newList]);
  }

  /// Removes [listId]. A no-op for [favoritesListId] - Favorites is always
  /// present so the Shop screen's heart toggle always has somewhere to
  /// write to.
  Future<void> deleteList(String listId) async {
    if (listId == favoritesListId) return;
    final current = state.valueOrNull ?? const <ShoppingList>[];
    await _persist(current.where((list) => list.id != listId).toList());
  }

  Future<void> addProductToList(String listId, String productId) async {
    final current = state.valueOrNull ?? const <ShoppingList>[];
    final updated = <ShoppingList>[
      for (final list in current)
        if (list.id == listId && !list.productIds.contains(productId))
          list.copyWith(productIds: <String>[...list.productIds, productId])
        else
          list,
    ];
    await _persist(updated);
  }

  Future<void> removeProductFromList(String listId, String productId) async {
    final current = state.valueOrNull ?? const <ShoppingList>[];
    final updated = <ShoppingList>[
      for (final list in current)
        if (list.id == listId)
          list.copyWith(productIds: list.productIds.where((id) => id != productId).toList())
        else
          list,
    ];
    await _persist(updated);
  }

  /// Adds [productId] to Favorites if it isn't already there, or removes it
  /// if it is - creating the Favorites list itself if it's somehow missing.
  Future<void> toggleFavorite(String productId) async {
    final current = state.valueOrNull ?? const <ShoppingList>[];
    final favoritesIndex = current.indexWhere((list) => list.id == favoritesListId);

    if (favoritesIndex == -1) {
      final favorites = ShoppingList(
        id: favoritesListId,
        name: 'Favorites',
        emoji: '❤️',
        productIds: <String>[productId],
      );
      await _persist(<ShoppingList>[...current, favorites]);
      return;
    }

    final favorites = current[favoritesIndex];
    final ids = List<String>.from(favorites.productIds);
    if (!ids.remove(productId)) ids.add(productId);
    final updated = <ShoppingList>[
      for (final list in current) list.id == favoritesListId ? favorites.copyWith(productIds: ids) : list,
    ];
    await _persist(updated);
  }
}

final shoppingListsProvider = AsyncNotifierProvider<ShoppingListsNotifier, List<ShoppingList>>(
  ShoppingListsNotifier.new,
);

/// Product ids currently in the Favorites list, watched by Shop product
/// tiles to decide whether the heart renders filled.
final favoriteProductIdsProvider = Provider<Set<String>>((ref) {
  final lists = ref.watch(shoppingListsProvider).valueOrNull ?? const <ShoppingList>[];
  for (final list in lists) {
    if (list.id == favoritesListId) return list.productIds.toSet();
  }
  return const <String>{};
});
