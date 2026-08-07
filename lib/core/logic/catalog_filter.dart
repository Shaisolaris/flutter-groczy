import '../models/product.dart';

/// Pure product search/filter for the Shop screen. Nothing here depends on
/// Flutter or storage.

/// Sentinel category id meaning "no category filter" - every category.
const String allCategoriesId = 'all';

/// Products in [products] whose category matches [categoryId] (every
/// product, when [categoryId] is `null` or [allCategoriesId]) AND whose
/// name contains [query], case-insensitively. Leading/trailing whitespace
/// in [query] is ignored, and an empty query matches every product.
List<Product> filterProducts(
  List<Product> products, {
  String? categoryId,
  String query = '',
}) {
  final normalizedQuery = query.trim().toLowerCase();
  return products.where((product) {
    final matchesCategory =
        categoryId == null || categoryId == allCategoriesId || product.categoryId == categoryId;
    final matchesQuery = normalizedQuery.isEmpty || product.name.toLowerCase().contains(normalizedQuery);
    return matchesCategory && matchesQuery;
  }).toList();
}
