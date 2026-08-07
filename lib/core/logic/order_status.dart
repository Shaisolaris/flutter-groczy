/// Pure "live" order-status math. An [Order] (see `core/models/order.dart`)
/// has no stored status field - its status is derived from how much time
/// has passed since it was placed, so a freshly checked-out order visibly
/// progresses across the four delivery stages while a person keeps the
/// Orders screen open, and any order placed more than [deliveredAfter] ago
/// (every seeded past order) always resolves to [OrderStatus.delivered].
library;

enum OrderStatus { placed, preparing, outForDelivery, delivered }

extension OrderStatusLabel on OrderStatus {
  String get label => switch (this) {
        OrderStatus.placed => 'Order placed',
        OrderStatus.preparing => 'Preparing your order',
        OrderStatus.outForDelivery => 'Out for delivery',
        OrderStatus.delivered => 'Delivered',
      };

  /// 0.0-1.0 across the four stages, for a linear progress indicator.
  double get progress => switch (this) {
        OrderStatus.placed => 0.25,
        OrderStatus.preparing => 0.5,
        OrderStatus.outForDelivery => 0.75,
        OrderStatus.delivered => 1.0,
      };
}

/// How long an order stays in the "placed" stage before moving to
/// "preparing".
const Duration preparingAfter = Duration(minutes: 2);

/// How long after being placed an order moves to "out for delivery".
const Duration outForDeliveryAfter = Duration(minutes: 6);

/// How long after being placed an order is considered "delivered".
const Duration deliveredAfter = Duration(minutes: 16);

/// The fixed sequence every order moves through, for rendering a
/// step-by-step tracker.
const List<OrderStatus> orderStatusSequence = <OrderStatus>[
  OrderStatus.placed,
  OrderStatus.preparing,
  OrderStatus.outForDelivery,
  OrderStatus.delivered,
];

/// The status [placedAt] implies as of [asOf]. An [asOf] before [placedAt]
/// (clock skew, or a stray future timestamp) is treated the same as no
/// time having passed at all: [OrderStatus.placed].
OrderStatus statusForOrder(DateTime placedAt, DateTime asOf) {
  final elapsed = asOf.difference(placedAt);
  if (elapsed >= deliveredAfter) return OrderStatus.delivered;
  if (elapsed >= outForDeliveryAfter) return OrderStatus.outForDelivery;
  if (elapsed >= preparingAfter) return OrderStatus.preparing;
  return OrderStatus.placed;
}
