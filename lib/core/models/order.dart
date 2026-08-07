/// One product line inside a placed [Order].
///
/// Every field is a snapshot taken at the moment of purchase (rather than a
/// live lookup against the catalog), so order history stays accurate even
/// if a product's price ever changes or it's discontinued.
class OrderLine {
  const OrderLine({
    required this.productId,
    required this.name,
    required this.unit,
    required this.emoji,
    required this.gradientIndex,
    required this.price,
    required this.quantity,
  });

  final String productId;
  final String name;
  final String unit;
  final String emoji;
  final int gradientIndex;
  final double price;
  final int quantity;

  double get lineTotal => price * quantity;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'productId': productId,
        'name': name,
        'unit': unit,
        'emoji': emoji,
        'gradientIndex': gradientIndex,
        'price': price,
        'quantity': quantity,
      };

  factory OrderLine.fromJson(Map<String, dynamic> json) => OrderLine(
        productId: json['productId'] as String,
        name: json['name'] as String,
        unit: json['unit'] as String,
        emoji: json['emoji'] as String,
        gradientIndex: json['gradientIndex'] as int,
        price: (json['price'] as num).toDouble(),
        quantity: json['quantity'] as int,
      );

  @override
  String toString() => 'OrderLine($name x$quantity)';
}

/// A placed order: a snapshot of its line items and price breakdown, plus
/// when and where it's headed.
///
/// Deliberately has no stored `status` field. Order status is *live* -
/// derived from [placedAt] by `core/logic/order_status.dart#statusForOrder`
/// every time it's displayed, so a freshly checked-out order visibly
/// progresses from Placed to Delivered while a person keeps the Orders
/// screen open, and every seeded past order (placed well outside that
/// window) always resolves to Delivered.
class Order {
  const Order({
    required this.id,
    required this.placedAt,
    required this.lines,
    required this.deliveryAddress,
    required this.slotLabel,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.total,
  });

  final String id;
  final DateTime placedAt;
  final List<OrderLine> lines;
  final String deliveryAddress;

  /// Display label for the delivery window chosen at checkout, e.g.
  /// "Fri, Aug 7 · 2:00 PM – 4:00 PM". A snapshot string rather than a
  /// [DeliverySlot] reference, since slots aren't persisted.
  final String slotLabel;

  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double total;

  /// Sum of every line's quantity.
  int get itemCount => lines.fold<int>(0, (sum, line) => sum + line.quantity);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'placedAt': placedAt.toIso8601String(),
        'lines': lines.map((line) => line.toJson()).toList(),
        'deliveryAddress': deliveryAddress,
        'slotLabel': slotLabel,
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'tax': tax,
        'total': total,
      };

  factory Order.fromJson(Map<String, dynamic> json) {
    final rawLines = json['lines'] as List<dynamic>? ?? const <dynamic>[];
    return Order(
      id: json['id'] as String,
      placedAt: DateTime.parse(json['placedAt'] as String),
      lines: rawLines.map((dynamic e) => OrderLine.fromJson(e as Map<String, dynamic>)).toList(),
      deliveryAddress: json['deliveryAddress'] as String,
      slotLabel: json['slotLabel'] as String,
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
    );
  }

  @override
  String toString() => 'Order($id, ${lines.length} lines, total: \$$total)';
}
