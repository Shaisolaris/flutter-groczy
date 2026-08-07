import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/models/cart_item.dart';
import '../core/models/order.dart';
import '../core/models/shopping_list.dart';

/// Persistence contract for a person's own Groczy data: their cart, their
/// order history, and their saved shopping lists. The UI and Riverpod
/// notifiers only ever talk to this interface, never to
/// `shared_preferences` directly - that keeps the storage mechanism
/// swappable (and easy to fake in tests).
///
/// The product catalog itself (categories, products) is *not* part of this
/// contract - it's read-only reference data rebuilt from
/// `data/seed_data.dart` on every launch, never persisted.
abstract class GroczyRepository {
  Future<List<CartItem>> loadCartItems();
  Future<void> saveCartItems(List<CartItem> items);

  Future<List<Order>> loadOrders();
  Future<void> saveOrders(List<Order> orders);

  Future<List<ShoppingList>> loadShoppingLists();
  Future<void> saveShoppingLists(List<ShoppingList> lists);

  /// Wipes every stored Groczy key, restoring the app to a first-run state.
  Future<void> clearAll();
}

/// [GroczyRepository] backed by `shared_preferences`, with each record type
/// stored as a single JSON-encoded string under its own key.
class SharedPreferencesGroczyRepository implements GroczyRepository {
  SharedPreferencesGroczyRepository(this._prefs);

  final SharedPreferences _prefs;

  static const String cartItemsKey = 'groczy.cart_items.v1';
  static const String ordersKey = 'groczy.orders.v1';
  static const String shoppingListsKey = 'groczy.shopping_lists.v1';

  @override
  Future<List<CartItem>> loadCartItems() async {
    final decoded = _readList(cartItemsKey);
    if (decoded == null) return const <CartItem>[];
    return decoded.map((json) => CartItem.fromJson(json)).toList();
  }

  @override
  Future<void> saveCartItems(List<CartItem> items) {
    return _writeList(cartItemsKey, items.map((item) => item.toJson()).toList());
  }

  @override
  Future<List<Order>> loadOrders() async {
    final decoded = _readList(ordersKey);
    if (decoded == null) return const <Order>[];
    return decoded.map((json) => Order.fromJson(json)).toList();
  }

  @override
  Future<void> saveOrders(List<Order> orders) {
    return _writeList(ordersKey, orders.map((order) => order.toJson()).toList());
  }

  @override
  Future<List<ShoppingList>> loadShoppingLists() async {
    final decoded = _readList(shoppingListsKey);
    if (decoded == null) return const <ShoppingList>[];
    return decoded.map((json) => ShoppingList.fromJson(json)).toList();
  }

  @override
  Future<void> saveShoppingLists(List<ShoppingList> lists) {
    return _writeList(shoppingListsKey, lists.map((list) => list.toJson()).toList());
  }

  @override
  Future<void> clearAll() async {
    await _prefs.remove(cartItemsKey);
    await _prefs.remove(ordersKey);
    await _prefs.remove(shoppingListsKey);
  }

  List<Map<String, dynamic>>? _readList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((entry) => entry as Map<String, dynamic>).toList();
  }

  Future<void> _writeList(String key, List<Map<String, dynamic>> value) {
    return _prefs.setString(key, jsonEncode(value));
  }
}
