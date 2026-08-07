import 'package:flutter_groczy/core/logic/order_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final placedAt = DateTime(2026, 8, 7, 12, 0);

  group('statusForOrder', () {
    test('the instant it is placed, status is placed', () {
      expect(statusForOrder(placedAt, placedAt), OrderStatus.placed);
    });

    test('1 minute in is still placed (preparingAfter is 2 minutes)', () {
      expect(statusForOrder(placedAt, placedAt.add(const Duration(minutes: 1))), OrderStatus.placed);
    });

    test('exactly at preparingAfter (2 minutes), status flips to preparing', () {
      expect(statusForOrder(placedAt, placedAt.add(preparingAfter)), OrderStatus.preparing);
    });

    test('5 minutes in is still preparing (outForDeliveryAfter is 6 minutes)', () {
      expect(statusForOrder(placedAt, placedAt.add(const Duration(minutes: 5))), OrderStatus.preparing);
    });

    test('exactly at outForDeliveryAfter (6 minutes), status flips to outForDelivery', () {
      expect(statusForOrder(placedAt, placedAt.add(outForDeliveryAfter)), OrderStatus.outForDelivery);
    });

    test('15 minutes in is still outForDelivery (deliveredAfter is 16 minutes)', () {
      expect(statusForOrder(placedAt, placedAt.add(const Duration(minutes: 15))), OrderStatus.outForDelivery);
    });

    test('exactly at deliveredAfter (16 minutes), status flips to delivered', () {
      expect(statusForOrder(placedAt, placedAt.add(deliveredAfter)), OrderStatus.delivered);
    });

    test('a past order (days old) is always delivered', () {
      expect(statusForOrder(placedAt, placedAt.add(const Duration(days: 9))), OrderStatus.delivered);
    });

    test('a timestamp before placedAt (clock skew) is treated as just-placed', () {
      expect(statusForOrder(placedAt, placedAt.subtract(const Duration(minutes: 5))), OrderStatus.placed);
    });
  });

  group('OrderStatusLabel', () {
    test('every status has a distinct, human-readable label', () {
      final labels = orderStatusSequence.map((status) => status.label).toSet();
      expect(labels, hasLength(orderStatusSequence.length));
    });

    test('progress increases strictly through the sequence and ends at 1.0', () {
      final progressValues = orderStatusSequence.map((status) => status.progress).toList();
      for (var i = 1; i < progressValues.length; i++) {
        expect(progressValues[i], greaterThan(progressValues[i - 1]));
      }
      expect(progressValues.last, 1.0);
    });
  });

  group('orderStatusSequence', () {
    test('is the 4 stages in delivery order', () {
      expect(orderStatusSequence, <OrderStatus>[
        OrderStatus.placed,
        OrderStatus.preparing,
        OrderStatus.outForDelivery,
        OrderStatus.delivered,
      ]);
    });
  });
}
