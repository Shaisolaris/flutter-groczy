/// A single item in Groczy's catalog.
///
/// Products are read-only reference data - see
/// `data/seed_data.dart#seedProducts`. Groczy has no product photography;
/// every product tile renders [emoji] over the gradient looked up by
/// [gradientIndex] (see `core/constants/gradients.dart`).
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.price,
    required this.unit,
    required this.emoji,
    required this.gradientIndex,
  });

  final String id;
  final String name;
  final String categoryId;

  /// Price in US dollars for one [unit].
  final double price;

  /// The quantity [price] buys, e.g. "per lb", "each", "1 gal", "dozen".
  final String unit;

  final String emoji;

  /// Index into the shared gradient palette. Products in the same category
  /// share a gradient, so the Shop grid reads as color-coded by category.
  final int gradientIndex;

  @override
  String toString() => 'Product($id, $name, \$$price/$unit)';
}
