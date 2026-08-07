import 'package:flutter_groczy/core/logic/reorder.dart';
import 'package:flutter_groczy/core/models/cart_item.dart';
import 'package:flutter_groczy/core/models/order.dart';
import 'package:flutter_groczy/core/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const productA = Product(
    id: 'p1',
    name: 'Milk',
    categoryId: 'dairy',
    price: 4.19,
    unit: '1 gal',
    emoji: '🥛',
    gradientIndex: 1,
  );
  const productB = Product(
    id: 'p2',
    name: 'Eggs',
    categoryId: 'dairy',
    price: 3.99,
    unit: 'dozen',
    emoji: '🥚',
    gradientIndex: 1,
  );
  const catalog = [productA, productB];

  OrderLine line({required String productId, required String name, required int quantity}) {
    return OrderLine(
      productId: productId,
      name: name,
      unit: 'each',
      emoji: '🛒',
      gradientIndex: 0,
      price: 1.0,
      quantity: quantity,
    );
  }

  Order orderWithLines(List<OrderLine> lines) {
    return Order(
      id: 'order-1',
      placedAt: DateTime(2026, 7, 20),
      lines: lines,
      deliveryAddress: '1 Test St',
      slotLabel: 'Today · 2:00 PM – 4:00 PM',
      subtotal: 0,
      deliveryFee: 0,
      tax: 0,
      total: 0,
    );
  }

  group('mergeOrderIntoCart', () {
    test('merges into an empty cart, one CartItem per available line', () {
      final order = orderWithLines([
        line(productId: 'p1', name: 'Milk', quantity: 2),
        line(productId: 'p2', name: 'Eggs', quantity: 1),
      ]);

      final result = mergeOrderIntoCart(currentCart: const [], order: order, catalog: catalog);

      expect(result.hadUnavailableItems, isFalse);
      expect(result.unavailableNames, isEmpty);
      expect(result.items, hasLength(2));
      expect(result.items[0], const CartItem(productId: 'p1', quantity: 2));
      expect(result.items[1], const CartItem(productId: 'p2', quantity: 1));
    });

    test('adds to (never overwrites) a quantity already in the cart', () {
      const currentCart = [CartItem(productId: 'p1', quantity: 3)];
      final order = orderWithLines([line(productId: 'p1', name: 'Milk', quantity: 2)]);

      final result = mergeOrderIntoCart(currentCart: currentCart, order: order, catalog: catalog);

      expect(result.items, hasLength(1));
      expect(result.items.single, const CartItem(productId: 'p1', quantity: 5));
    });

    test('a discontinued product is reported as unavailable, not added', () {
      final order = orderWithLines([
        line(productId: 'p1', name: 'Milk', quantity: 1),
        line(productId: 'ghost', name: 'Discontinued Snack', quantity: 3),
      ]);

      final result = mergeOrderIntoCart(currentCart: const [], order: order, catalog: catalog);

      expect(result.hadUnavailableItems, isTrue);
      expect(result.unavailableNames, <String>['Discontinued Snack']);
      expect(result.items, hasLength(1));
      expect(result.items.single, const CartItem(productId: 'p1', quantity: 1));
    });

    test('every line unavailable: cart is untouched, every name is reported', () {
      const currentCart = [CartItem(productId: 'p1', quantity: 1)];
      final order = orderWithLines([line(productId: 'ghost', name: 'Discontinued Snack', quantity: 1)]);

      final result = mergeOrderIntoCart(currentCart: currentCart, order: order, catalog: catalog);

      expect(result.items, currentCart);
      expect(result.unavailableNames, <String>['Discontinued Snack']);
    });

    test('cart items unrelated to the order are preserved unchanged', () {
      const currentCart = [CartItem(productId: 'p2', quantity: 4)];
      final order = orderWithLines([line(productId: 'p1', name: 'Milk', quantity: 1)]);

      final result = mergeOrderIntoCart(currentCart: currentCart, order: order, catalog: catalog);

      expect(result.items, hasLength(2));
      expect(result.items, contains(const CartItem(productId: 'p2', quantity: 4)));
      expect(result.items, contains(const CartItem(productId: 'p1', quantity: 1)));
    });

    test('an order with no lines leaves the cart unchanged and reports nothing', () {
      const currentCart = [CartItem(productId: 'p1', quantity: 2)];
      final order = orderWithLines(const []);

      final result = mergeOrderIntoCart(currentCart: currentCart, order: order, catalog: catalog);

      expect(result.items, currentCart);
      expect(result.hadUnavailableItems, isFalse);
    });
  });
}
