/// A saved shopping list: a named group of product ids a person reuses
/// often (e.g. "Weekly Staples"), with a one-tap "add all to cart".
///
/// Favorites is modeled as an ordinary [ShoppingList] with the well-known
/// id `favoritesListId` - the heart toggle on a Shop product tile just adds
/// or removes that product from this one list. See
/// `data/providers.dart#favoriteProductIdsProvider`.
class ShoppingList {
  const ShoppingList({
    required this.id,
    required this.name,
    required this.emoji,
    required this.productIds,
  });

  final String id;
  final String name;
  final String emoji;
  final List<String> productIds;

  ShoppingList copyWith({String? id, String? name, String? emoji, List<String>? productIds}) {
    return ShoppingList(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      productIds: productIds ?? this.productIds,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'emoji': emoji,
        'productIds': productIds,
      };

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    final rawIds = json['productIds'] as List<dynamic>? ?? const <dynamic>[];
    return ShoppingList(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      productIds: rawIds.map((dynamic e) => e as String).toList(),
    );
  }

  @override
  String toString() => 'ShoppingList($id, $name, ${productIds.length} items)';
}
