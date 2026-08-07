import 'package:flutter_groczy/core/models/category.dart';
import 'package:flutter_groczy/core/models/order.dart';
import 'package:flutter_groczy/core/models/product.dart';
import 'package:flutter_groczy/core/models/shopping_list.dart';
import 'package:flutter_groczy/data/seed_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 8, 7, 9, 0);

  group('seedCategories', () {
    test('returns exactly 8 categories with unique ids, in display order', () {
      final categories = seedCategories();
      expect(categories, hasLength(8));
      expect(categories.map((c) => c.id).toSet(), hasLength(8));
      expect(categories.map((c) => c.name).toList(), <String>[
        'Produce',
        'Dairy & Eggs',
        'Bakery',
        'Meat & Seafood',
        'Pantry',
        'Snacks',
        'Beverages',
        'Frozen',
      ]);
    });
  });

  group('seedProducts', () {
    late List<Product> products;
    late Set<String> categoryIds;

    setUp(() {
      products = seedProducts();
      categoryIds = seedCategories().map((c) => c.id).toSet();
    });

    test('returns 33 products with unique ids', () {
      expect(products, hasLength(33));
      expect(products.map((p) => p.id).toSet(), hasLength(33));
    });

    test('every product belongs to a real seeded category', () {
      for (final product in products) {
        expect(categoryIds.contains(product.categoryId), isTrue, reason: '${product.id} has an unknown category');
      }
    });

    test('every product has a positive price and a non-empty unit/emoji', () {
      for (final product in products) {
        expect(product.price, greaterThan(0), reason: product.id);
        expect(product.unit, isNotEmpty, reason: product.id);
        expect(product.emoji, isNotEmpty, reason: product.id);
      }
    });

    test('gradientIndex is shared within a category (0-7, one per category)', () {
      final categories = seedCategories();
      for (var i = 0; i < categories.length; i++) {
        final inCategory = products.where((p) => p.categoryId == categories[i].id);
        expect(inCategory, isNotEmpty);
        for (final product in inCategory) {
          expect(product.gradientIndex, i, reason: '${product.id} in ${categories[i].name}');
        }
      }
    });

    test('spot check: Bananas is 0.59 per lb in Produce', () {
      final bananas = products.firstWhere((p) => p.id == productBananas);
      expect(bananas.name, 'Bananas');
      expect(bananas.price, 0.59);
      expect(bananas.unit, 'per lb');
      expect(bananas.categoryId, categoryProduce);
    });
  });

  group('seedShoppingLists', () {
    test('returns the 4 starter lists, each referencing real products', () {
      final lists = seedShoppingLists();
      final productIds = seedProducts().map((p) => p.id).toSet();

      expect(lists.map((l) => l.id).toList(), <String>[
        favoritesListId,
        staplesListId,
        tacoNightListId,
        breakfastListId,
      ]);

      for (final list in lists) {
        expect(list.productIds, isNotEmpty, reason: list.id);
        for (final productId in list.productIds) {
          expect(productIds.contains(productId), isTrue, reason: '${list.id} references unknown $productId');
        }
      }
    });

    test('Favorites seeds with Avocado, Sourdough, and Cold Brew', () {
      final favorites = seedShoppingLists().firstWhere((l) => l.id == favoritesListId);
      expect(favorites.productIds, <String>[productAvocado, productSourdough, productColdBrew]);
    });
  });

  group('seedOrders', () {
    late List<Order> orders;

    setUp(() {
      orders = seedOrders(seedProducts(), now: now);
    });

    test('returns 3 orders, most recent first', () {
      expect(orders, hasLength(3));
      expect(orders[0].placedAt, now.subtract(const Duration(days: 2)));
      expect(orders[1].placedAt, now.subtract(const Duration(days: 9)));
      expect(orders[2].placedAt, now.subtract(const Duration(days: 20)));
    });

    test('order 0 (milk/eggs/bananas/sourdough/chicken): hand-traced totals', () {
      final order = orders[0];
      expect(order.itemCount, 12);
      expect(order.subtotal, 33.38);
      expect(order.deliveryFee, 4.99); // below the $35 free-delivery threshold
      expect(order.tax, 2.67);
      expect(order.total, 41.04);
    });

    test('order 1 (pasta/oil/beef/spinach/cheddar): crosses the free-delivery threshold', () {
      final order = orders[1];
      expect(order.itemCount, 9);
      expect(order.subtotal, 39.81);
      expect(order.deliveryFee, 0.0); // at/above the $35 threshold
      expect(order.tax, 3.18);
      expect(order.total, 42.99);
    });

    test('order 2 (chips/popcorn/sparkling/coldbrew/icecream): hand-traced totals', () {
      final order = orders[2];
      expect(order.itemCount, 7);
      expect(order.subtotal, 33.83);
      expect(order.deliveryFee, 4.99);
      expect(order.tax, 2.71);
      expect(order.total, 41.53);
    });

    test('every order ships to the same saved address', () {
      for (final order in orders) {
        expect(order.deliveryAddress, defaultDeliveryAddress);
      }
    });

    test('is deterministic for the same "now" and product list', () {
      final again = seedOrders(seedProducts(), now: now);
      for (var i = 0; i < orders.length; i++) {
        expect(again[i].id, orders[i].id);
        expect(again[i].total, orders[i].total);
        expect(again[i].placedAt, orders[i].placedAt);
      }
    });
  });
}
