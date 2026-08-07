import 'package:flutter_groczy/core/logic/catalog_filter.dart';
import 'package:flutter_groczy/core/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const bananas = Product(
    id: 'p1',
    name: 'Bananas',
    categoryId: 'produce',
    price: 0.59,
    unit: 'per lb',
    emoji: '🍌',
    gradientIndex: 0,
  );
  const wholeMilk = Product(
    id: 'p2',
    name: 'Whole Milk',
    categoryId: 'dairy',
    price: 4.19,
    unit: '1 gal',
    emoji: '🥛',
    gradientIndex: 1,
  );
  const almondMilk = Product(
    id: 'p3',
    name: 'Almond Milk',
    categoryId: 'dairy',
    price: 3.49,
    unit: '64 oz',
    emoji: '🥛',
    gradientIndex: 1,
  );
  final catalog = [bananas, wholeMilk, almondMilk];

  List<String> idsOf(List<Product> products) => products.map((p) => p.id).toList();

  group('filterProducts', () {
    test('no category and no query returns every product, in order', () {
      expect(idsOf(filterProducts(catalog)), <String>['p1', 'p2', 'p3']);
    });

    test('allCategoriesId behaves the same as no category filter', () {
      expect(idsOf(filterProducts(catalog, categoryId: allCategoriesId)), <String>['p1', 'p2', 'p3']);
    });

    test('filters to a single category', () {
      expect(idsOf(filterProducts(catalog, categoryId: 'dairy')), <String>['p2', 'p3']);
    });

    test('a category with no matches returns an empty list', () {
      expect(filterProducts(catalog, categoryId: 'bakery'), isEmpty);
    });

    test('query matches case-insensitively', () {
      expect(idsOf(filterProducts(catalog, query: 'MILK')), <String>['p2', 'p3']);
      expect(idsOf(filterProducts(catalog, query: 'milk')), <String>['p2', 'p3']);
    });

    test('query matches a substring anywhere in the name', () {
      expect(idsOf(filterProducts(catalog, query: 'nan')), <String>['p1']); // baNANas
    });

    test('surrounding whitespace in the query is ignored', () {
      expect(idsOf(filterProducts(catalog, query: '  banana  ')), <String>['p1']);
    });

    test('an empty (or whitespace-only) query matches everything', () {
      expect(idsOf(filterProducts(catalog, query: '')), <String>['p1', 'p2', 'p3']);
      expect(idsOf(filterProducts(catalog, query: '   ')), <String>['p1', 'p2', 'p3']);
    });

    test('category and query combine with AND semantics', () {
      expect(idsOf(filterProducts(catalog, categoryId: 'dairy', query: 'almond')), <String>['p3']);
      expect(filterProducts(catalog, categoryId: 'produce', query: 'almond'), isEmpty);
    });

    test('a query matching nothing returns an empty list', () {
      expect(filterProducts(catalog, query: 'pizza'), isEmpty);
    });
  });
}
