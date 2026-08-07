import 'package:flutter_groczy/core/logic/cart.dart';
import 'package:flutter_groczy/core/models/cart_item.dart';
import 'package:flutter_groczy/core/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const productA = Product(
    id: 'a',
    name: 'Product A',
    categoryId: 'cat',
    price: 2.50,
    unit: 'each',
    emoji: '🅰️',
    gradientIndex: 0,
  );
  const productB = Product(
    id: 'b',
    name: 'Product B',
    categoryId: 'cat',
    price: 1.25,
    unit: 'each',
    emoji: '🅱️',
    gradientIndex: 0,
  );
  const productExpensive = Product(
    id: 'c',
    name: 'Product C',
    categoryId: 'cat',
    price: 40.0,
    unit: 'each',
    emoji: '💰',
    gradientIndex: 0,
  );

  group('roundToCents', () {
    test('rounds down below the half-cent', () {
      // 19.994 * 100 = 1999.4 -> rounds to 1999 -> 19.99
      expect(roundToCents(19.994), 19.99);
    });

    test('rounds up above the half-cent', () {
      // 19.996 * 100 = 1999.6 -> rounds to 2000 -> 20.00
      expect(roundToCents(19.996), 20.0);
    });
  });

  group('calculateSubtotal', () {
    test('sums line totals: 2.50 x3 (7.50) + 1.25 x2 (2.50) = 10.00', () {
      final lines = [
        const CartLine(product: productA, quantity: 3),
        const CartLine(product: productB, quantity: 2),
      ];
      expect(calculateSubtotal(lines), 10.0);
    });

    test('an empty line list has a zero subtotal', () {
      expect(calculateSubtotal(const []), 0.0);
    });
  });

  group('calculateDeliveryFee', () {
    test('charges the fee below the free threshold', () {
      expect(calculateDeliveryFee(34.99), defaultDeliveryFee);
    });

    test('is free exactly at the threshold', () {
      expect(calculateDeliveryFee(35.0), 0.0);
    });

    test('is free above the threshold', () {
      expect(calculateDeliveryFee(40.0), 0.0);
    });

    test('a zero or negative subtotal never charges a fee', () {
      expect(calculateDeliveryFee(0.0), 0.0);
      expect(calculateDeliveryFee(-5.0), 0.0);
    });

    test('honors custom threshold/fee overrides', () {
      expect(calculateDeliveryFee(10.0, freeThreshold: 20.0, feeAmount: 2.99), 2.99);
      expect(calculateDeliveryFee(20.0, freeThreshold: 20.0, feeAmount: 2.99), 0.0);
    });
  });

  group('calculateTax', () {
    test('10.00 at the default 8% rate is 0.80', () {
      expect(calculateTax(10.0), 0.80);
    });

    test('a zero subtotal has zero tax', () {
      expect(calculateTax(0.0), 0.0);
    });

    test('throws for a negative tax rate', () {
      expect(() => calculateTax(10.0, taxRate: -0.01), throwsArgumentError);
    });
  });

  group('totalItemCount', () {
    test('sums quantities across lines, not the number of lines', () {
      final lines = [
        const CartLine(product: productA, quantity: 3),
        const CartLine(product: productB, quantity: 2),
      ];
      expect(totalItemCount(lines), 5);
    });
  });

  group('calculateTotals', () {
    test('an empty cart returns CartTotals.empty', () {
      expect(calculateTotals(const []), same(CartTotals.empty));
    });

    test('below-threshold cart: subtotal 10.00, fee 4.99, tax 0.80, total 15.79', () {
      final lines = [
        const CartLine(product: productA, quantity: 3),
        const CartLine(product: productB, quantity: 2),
      ];
      final totals = calculateTotals(lines);

      expect(totals.itemCount, 5);
      expect(totals.subtotal, 10.0);
      expect(totals.deliveryFee, 4.99);
      expect(totals.tax, 0.80);
      expect(totals.total, 15.79);
      expect(totals.amountToFreeDelivery, 25.0); // 35.00 - 10.00
      expect(totals.qualifiesForFreeDelivery, isFalse);
    });

    test('at-or-above-threshold cart has free delivery and zero amountToFreeDelivery', () {
      final lines = [const CartLine(product: productExpensive, quantity: 1)]; // 40.00
      final totals = calculateTotals(lines);

      expect(totals.subtotal, 40.0);
      expect(totals.deliveryFee, 0.0);
      expect(totals.amountToFreeDelivery, 0.0);
      expect(totals.qualifiesForFreeDelivery, isTrue);
      // tax: 40.00 * 0.08 = 3.20; total: 40.00 + 0 + 3.20 = 43.20
      expect(totals.tax, 3.20);
      expect(totals.total, 43.20);
    });
  });

  group('resolveCartLines', () {
    const catalog = [productA, productB];

    test('resolves items against the catalog, preserving quantity', () {
      const items = [CartItem(productId: 'a', quantity: 4), CartItem(productId: 'b', quantity: 1)];
      final lines = resolveCartLines(items, catalog);

      expect(lines, hasLength(2));
      expect(lines[0].product.id, 'a');
      expect(lines[0].quantity, 4);
      expect(lines[1].product.id, 'b');
      expect(lines[1].quantity, 1);
    });

    test('drops an item whose product id is no longer in the catalog', () {
      const items = [CartItem(productId: 'a', quantity: 1), CartItem(productId: 'discontinued', quantity: 2)];
      final lines = resolveCartLines(items, catalog);

      expect(lines, hasLength(1));
      expect(lines.single.product.id, 'a');
    });

    test('drops an item with a zero or negative quantity', () {
      const items = [CartItem(productId: 'a', quantity: 0), CartItem(productId: 'b', quantity: -1)];
      expect(resolveCartLines(items, catalog), isEmpty);
    });
  });
}
