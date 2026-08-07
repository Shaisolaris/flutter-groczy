/// A single persisted cart entry: which product, and how many of it.
///
/// This is the only cart data that's actually stored - [CartItem] is
/// resolved against the live product catalog into a renderable
/// `core/logic/cart.dart#CartLine` (product + quantity) wherever the UI
/// needs a name, price, or emoji to show.
class CartItem {
  const CartItem({required this.productId, required this.quantity});

  final String productId;
  final int quantity;

  CartItem copyWith({String? productId, int? quantity}) {
    return CartItem(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'productId': productId,
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        productId: json['productId'] as String,
        quantity: json['quantity'] as int,
      );

  /// Value equality (same product id and quantity) rather than identity -
  /// both the cart notifier's diffing and `core/logic/reorder.dart`'s tests
  /// compare [CartItem]s by value.
  @override
  bool operator ==(Object other) {
    return other is CartItem && other.productId == productId && other.quantity == quantity;
  }

  @override
  int get hashCode => Object.hash(productId, quantity);

  @override
  String toString() => 'CartItem($productId x$quantity)';
}
