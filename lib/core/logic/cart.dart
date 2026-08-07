import '../models/cart_item.dart';
import '../models/product.dart';

/// Pure cart math: subtotal, threshold-based delivery fee, tax, and the
/// final total. Nothing here depends on Flutter, Riverpod, or storage - it
/// only ever operates on plain [CartLine]s (a product joined with the
/// quantity requested) and numeric config, so the whole module is fully
/// unit-testable in isolation.

/// A cart entry resolved against the product catalog: a [product] and how
/// many of it are in the cart, plus its computed [lineTotal].
class CartLine {
  const CartLine({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  double get lineTotal => roundToCents(product.price * quantity);

  @override
  String toString() => 'CartLine(${product.name} x$quantity)';
}

/// The itemized cost of a cart, ready to render line-by-line at checkout.
class CartTotals {
  const CartTotals({
    required this.itemCount,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.total,
    required this.amountToFreeDelivery,
  });

  /// Sum of every line's quantity (drives the bottom-nav cart badge).
  final int itemCount;

  final double subtotal;
  final double deliveryFee;
  final double tax;

  /// `subtotal + deliveryFee + tax`.
  final double total;

  /// How much more a person needs to spend to unlock free delivery on this
  /// order; `0` once [deliveryFee] is already `0`.
  final double amountToFreeDelivery;

  bool get qualifiesForFreeDelivery => deliveryFee <= 0 && subtotal > 0;

  static const CartTotals empty = CartTotals(
    itemCount: 0,
    subtotal: 0,
    deliveryFee: 0,
    tax: 0,
    total: 0,
    amountToFreeDelivery: 0,
  );

  @override
  String toString() =>
      'CartTotals(items: $itemCount, subtotal: $subtotal, deliveryFee: $deliveryFee, tax: $tax, total: $total)';
}

/// Default delivery pricing, shared by [calculateTotals] and any screen
/// that needs to show "how it's calculated" copy.
const double defaultFreeDeliveryThreshold = 35.0;
const double defaultDeliveryFee = 4.99;
const double defaultTaxRate = 0.08; // 8%

/// Rounds a currency amount to the nearest cent. Chained floating-point
/// arithmetic can land a hair off an exact cent value; rounding at every
/// step - rather than only at the very end - is what guarantees the
/// itemized lines always sum exactly to the total.
double roundToCents(double amount) => (amount * 100).round() / 100;

/// Sum of every line's [CartLine.lineTotal].
double calculateSubtotal(List<CartLine> lines) {
  var subtotal = 0.0;
  for (final line in lines) {
    subtotal = roundToCents(subtotal + line.lineTotal);
  }
  return subtotal;
}

/// `0` once [subtotal] reaches [freeThreshold] (an empty/zero cart never
/// pays a delivery fee either); [feeAmount] otherwise.
double calculateDeliveryFee(
  double subtotal, {
  double freeThreshold = defaultFreeDeliveryThreshold,
  double feeAmount = defaultDeliveryFee,
}) {
  if (subtotal <= 0) return 0;
  if (subtotal >= freeThreshold) return 0;
  return feeAmount;
}

/// [subtotal] taxed at [taxRate]. Delivery fees are not taxed.
double calculateTax(double subtotal, {double taxRate = defaultTaxRate}) {
  if (taxRate < 0) throw ArgumentError.value(taxRate, 'taxRate', 'must not be negative');
  return roundToCents(subtotal * taxRate);
}

/// Sum of every line's quantity.
int totalItemCount(List<CartLine> lines) => lines.fold<int>(0, (sum, line) => sum + line.quantity);

/// Computes the full price breakdown for a cart made up of [lines].
CartTotals calculateTotals(
  List<CartLine> lines, {
  double freeDeliveryThreshold = defaultFreeDeliveryThreshold,
  double deliveryFee = defaultDeliveryFee,
  double taxRate = defaultTaxRate,
}) {
  if (lines.isEmpty) return CartTotals.empty;

  final subtotal = calculateSubtotal(lines);
  final fee = calculateDeliveryFee(subtotal, freeThreshold: freeDeliveryThreshold, feeAmount: deliveryFee);
  final tax = calculateTax(subtotal, taxRate: taxRate);
  final total = roundToCents(subtotal + fee + tax);
  final amountToFree = fee <= 0 ? 0.0 : roundToCents(freeDeliveryThreshold - subtotal);

  return CartTotals(
    itemCount: totalItemCount(lines),
    subtotal: subtotal,
    deliveryFee: fee,
    tax: tax,
    total: total,
    amountToFreeDelivery: amountToFree,
  );
}

/// Resolves persisted [items] against the product [catalog] into
/// renderable [CartLine]s, silently dropping any item whose product id no
/// longer exists in the catalog (e.g. a discontinued product) or whose
/// quantity has dropped to zero or below.
List<CartLine> resolveCartLines(List<CartItem> items, List<Product> catalog) {
  final productsById = <String, Product>{for (final product in catalog) product.id: product};
  final lines = <CartLine>[];
  for (final item in items) {
    final product = productsById[item.productId];
    if (product == null || item.quantity <= 0) continue;
    lines.add(CartLine(product: product, quantity: item.quantity));
  }
  return lines;
}
