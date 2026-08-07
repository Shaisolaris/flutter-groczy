/// A top-level product category shown as a filter chip on the Shop screen
/// (e.g. "Produce", "Dairy & Eggs").
///
/// Categories are read-only reference data - see
/// `data/seed_data.dart#seedCategories`.
class Category {
  const Category({required this.id, required this.name, required this.emoji});

  final String id;
  final String name;

  /// Shown on the category chip alongside [name].
  final String emoji;

  @override
  String toString() => 'Category($id, $name)';
}
