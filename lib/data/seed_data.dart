import '../core/constants/date_format.dart';
import '../core/logic/cart.dart';
import '../core/models/category.dart';
import '../core/models/order.dart';
import '../core/models/product.dart';
import '../core/models/shopping_list.dart';

/// Groczy's deterministic demo catalog and starter data: 8 categories, 33
/// products, 3 past orders, and 4 starter shopping lists.
///
/// Categories and products are read-only reference data - rebuilt from
/// [seedCategories] / [seedProducts] on every launch rather than persisted.
/// Past orders and shopping lists genuinely are a person's own data: seeded
/// once on first run (see `data/providers.dart`), then persisted and
/// mutated from there.
///
/// [seedOrders] expresses `placedAt` as an offset from [now] (defaulting to
/// the current moment) so order history always reads as "recent enough to
/// be believable" no matter when the app is run, while staying fully
/// deterministic for any given [now]. Every seeded order's totals are
/// produced by the same `core/logic/cart.dart#calculateTotals` the live
/// cart uses, so seed data and pure logic can never drift apart.

/// The single saved address every seeded order (and the checkout default)
/// ships to.
const String defaultDeliveryAddress = '482 Maple Grove Lane, Springdale, TX 75019';

// Category ids ---------------------------------------------------------
const String categoryProduce = 'cat-produce';
const String categoryDairy = 'cat-dairy';
const String categoryBakery = 'cat-bakery';
const String categoryMeatSeafood = 'cat-meat-seafood';
const String categoryPantry = 'cat-pantry';
const String categorySnacks = 'cat-snacks';
const String categoryBeverages = 'cat-beverages';
const String categoryFrozen = 'cat-frozen';

List<Category> seedCategories() => const <Category>[
      Category(id: categoryProduce, name: 'Produce', emoji: '🥦'),
      Category(id: categoryDairy, name: 'Dairy & Eggs', emoji: '🥛'),
      Category(id: categoryBakery, name: 'Bakery', emoji: '🍞'),
      Category(id: categoryMeatSeafood, name: 'Meat & Seafood', emoji: '🥩'),
      Category(id: categoryPantry, name: 'Pantry', emoji: '🥫'),
      Category(id: categorySnacks, name: 'Snacks', emoji: '🍿'),
      Category(id: categoryBeverages, name: 'Beverages', emoji: '🧃'),
      Category(id: categoryFrozen, name: 'Frozen', emoji: '🧊'),
    ];

// Product ids ------------------------------------------------------------
const String productBananas = 'p-bananas';
const String productAvocado = 'p-avocado';
const String productSpinach = 'p-spinach';
const String productTomatoes = 'p-tomatoes';

const String productMilk = 'p-milk';
const String productEggs = 'p-eggs';
const String productYogurt = 'p-yogurt';
const String productCheddar = 'p-cheddar';

const String productSourdough = 'p-sourdough';
const String productBagels = 'p-bagels';
const String productCroissants = 'p-croissants';
const String productMuffins = 'p-muffins';
const String productTortillas = 'p-tortillas';

const String productChicken = 'p-chicken';
const String productGroundBeef = 'p-groundbeef';
const String productSalmon = 'p-salmon';
const String productBacon = 'p-bacon';

const String productRice = 'p-rice';
const String productOliveOil = 'p-oliveoil';
const String productPasta = 'p-pasta';
const String productPeanutButter = 'p-peanutbutter';

const String productChips = 'p-chips';
const String productPopcorn = 'p-popcorn';
const String productCookies = 'p-cookies';
const String productPretzels = 'p-pretzels';

const String productOrangeJuice = 'p-oj';
const String productSparklingWater = 'p-sparkling';
const String productColdBrew = 'p-coldbrew';
const String productGreenTea = 'p-greentea';

const String productBerries = 'p-berries';
const String productPizza = 'p-pizza';
const String productIceCream = 'p-icecream';
const String productBroccoli = 'p-broccoli';

List<Product> seedProducts() => const <Product>[
      // Produce - gradient 0
      Product(
        id: productBananas,
        name: 'Bananas',
        categoryId: categoryProduce,
        price: 0.59,
        unit: 'per lb',
        emoji: '🍌',
        gradientIndex: 0,
      ),
      Product(
        id: productAvocado,
        name: 'Hass Avocado',
        categoryId: categoryProduce,
        price: 1.79,
        unit: 'each',
        emoji: '🥑',
        gradientIndex: 0,
      ),
      Product(
        id: productSpinach,
        name: 'Baby Spinach',
        categoryId: categoryProduce,
        price: 3.49,
        unit: '5 oz bag',
        emoji: '🥬',
        gradientIndex: 0,
      ),
      Product(
        id: productTomatoes,
        name: 'Roma Tomatoes',
        categoryId: categoryProduce,
        price: 2.29,
        unit: 'per lb',
        emoji: '🍅',
        gradientIndex: 0,
      ),

      // Dairy & Eggs - gradient 1
      Product(
        id: productMilk,
        name: 'Whole Milk',
        categoryId: categoryDairy,
        price: 4.19,
        unit: '1 gal',
        emoji: '🥛',
        gradientIndex: 1,
      ),
      Product(
        id: productEggs,
        name: 'Large Grade A Eggs',
        categoryId: categoryDairy,
        price: 3.99,
        unit: 'dozen',
        emoji: '🥚',
        gradientIndex: 1,
      ),
      Product(
        id: productYogurt,
        name: 'Plain Greek Yogurt',
        categoryId: categoryDairy,
        price: 5.49,
        unit: '32 oz tub',
        emoji: '🥣',
        gradientIndex: 1,
      ),
      Product(
        id: productCheddar,
        name: 'Sharp Cheddar Block',
        categoryId: categoryDairy,
        price: 4.79,
        unit: '8 oz',
        emoji: '🧀',
        gradientIndex: 1,
      ),

      // Bakery - gradient 2
      Product(
        id: productSourdough,
        name: 'Sourdough Loaf',
        categoryId: categoryBakery,
        price: 4.49,
        unit: 'each',
        emoji: '🍞',
        gradientIndex: 2,
      ),
      Product(
        id: productBagels,
        name: 'Everything Bagels',
        categoryId: categoryBakery,
        price: 3.29,
        unit: '6-pack',
        emoji: '🥯',
        gradientIndex: 2,
      ),
      Product(
        id: productCroissants,
        name: 'Butter Croissants',
        categoryId: categoryBakery,
        price: 5.29,
        unit: '4-pack',
        emoji: '🥐',
        gradientIndex: 2,
      ),
      Product(
        id: productMuffins,
        name: 'Blueberry Muffins',
        categoryId: categoryBakery,
        price: 4.99,
        unit: '4-pack',
        emoji: '🧁',
        gradientIndex: 2,
      ),
      Product(
        id: productTortillas,
        name: 'Flour Tortillas',
        categoryId: categoryBakery,
        price: 3.49,
        unit: '10-pack',
        emoji: '🫓',
        gradientIndex: 2,
      ),

      // Meat & Seafood - gradient 3
      Product(
        id: productChicken,
        name: 'Boneless Chicken Breast',
        categoryId: categoryMeatSeafood,
        price: 6.49,
        unit: 'per lb',
        emoji: '🍗',
        gradientIndex: 3,
      ),
      Product(
        id: productGroundBeef,
        name: 'Ground Beef 85/15',
        categoryId: categoryMeatSeafood,
        price: 5.99,
        unit: 'per lb',
        emoji: '🥩',
        gradientIndex: 3,
      ),
      Product(
        id: productSalmon,
        name: 'Atlantic Salmon Fillet',
        categoryId: categoryMeatSeafood,
        price: 9.99,
        unit: 'per lb',
        emoji: '🐟',
        gradientIndex: 3,
      ),
      Product(
        id: productBacon,
        name: 'Applewood Smoked Bacon',
        categoryId: categoryMeatSeafood,
        price: 6.29,
        unit: '12 oz',
        emoji: '🥓',
        gradientIndex: 3,
      ),

      // Pantry - gradient 4
      Product(
        id: productRice,
        name: 'Jasmine Rice',
        categoryId: categoryPantry,
        price: 8.49,
        unit: '5 lb bag',
        emoji: '🍚',
        gradientIndex: 4,
      ),
      Product(
        id: productOliveOil,
        name: 'Extra Virgin Olive Oil',
        categoryId: categoryPantry,
        price: 9.49,
        unit: '500 ml',
        emoji: '🫒',
        gradientIndex: 4,
      ),
      Product(
        id: productPasta,
        name: 'Penne Pasta',
        categoryId: categoryPantry,
        price: 2.19,
        unit: '16 oz box',
        emoji: '🍝',
        gradientIndex: 4,
      ),
      Product(
        id: productPeanutButter,
        name: 'Creamy Peanut Butter',
        categoryId: categoryPantry,
        price: 4.29,
        unit: '16 oz jar',
        emoji: '🥜',
        gradientIndex: 4,
      ),

      // Snacks - gradient 5
      Product(
        id: productChips,
        name: 'Sea Salt Kettle Chips',
        categoryId: categorySnacks,
        price: 3.79,
        unit: '8 oz bag',
        emoji: '🥔',
        gradientIndex: 5,
      ),
      Product(
        id: productPopcorn,
        name: 'Butter Popcorn',
        categoryId: categorySnacks,
        price: 4.49,
        unit: '3-pack',
        emoji: '🍿',
        gradientIndex: 5,
      ),
      Product(
        id: productCookies,
        name: 'Chocolate Chip Cookies',
        categoryId: categorySnacks,
        price: 3.99,
        unit: '14 oz',
        emoji: '🍪',
        gradientIndex: 5,
      ),
      Product(
        id: productPretzels,
        name: 'Honey Mustard Pretzels',
        categoryId: categorySnacks,
        price: 3.49,
        unit: '10 oz',
        emoji: '🥨',
        gradientIndex: 5,
      ),

      // Beverages - gradient 6
      Product(
        id: productOrangeJuice,
        name: 'Fresh Orange Juice',
        categoryId: categoryBeverages,
        price: 4.99,
        unit: '52 oz',
        emoji: '🧃',
        gradientIndex: 6,
      ),
      Product(
        id: productSparklingWater,
        name: 'Sparkling Water 8-Pack',
        categoryId: categoryBeverages,
        price: 5.49,
        unit: '8x12 oz',
        emoji: '🫧',
        gradientIndex: 6,
      ),
      Product(
        id: productColdBrew,
        name: 'Cold Brew Coffee',
        categoryId: categoryBeverages,
        price: 4.79,
        unit: '32 oz',
        emoji: '☕',
        gradientIndex: 6,
      ),
      Product(
        id: productGreenTea,
        name: 'Green Tea Bags',
        categoryId: categoryBeverages,
        price: 3.29,
        unit: '20-count',
        emoji: '🍵',
        gradientIndex: 6,
      ),

      // Frozen - gradient 7
      Product(
        id: productBerries,
        name: 'Frozen Mixed Berries',
        categoryId: categoryFrozen,
        price: 5.29,
        unit: '16 oz',
        emoji: '🫐',
        gradientIndex: 7,
      ),
      Product(
        id: productPizza,
        name: 'Frozen Pepperoni Pizza',
        categoryId: categoryFrozen,
        price: 6.99,
        unit: '12 in',
        emoji: '🍕',
        gradientIndex: 7,
      ),
      Product(
        id: productIceCream,
        name: 'Vanilla Bean Ice Cream',
        categoryId: categoryFrozen,
        price: 5.99,
        unit: '1.5 qt',
        emoji: '🍦',
        gradientIndex: 7,
      ),
      Product(
        id: productBroccoli,
        name: 'Frozen Broccoli Florets',
        categoryId: categoryFrozen,
        price: 2.99,
        unit: '12 oz',
        emoji: '🥦',
        gradientIndex: 7,
      ),
    ];

/// Shopping list ids.
const String favoritesListId = 'list-favorites';
const String staplesListId = 'list-staples';
const String tacoNightListId = 'list-taco';
const String breakfastListId = 'list-breakfast';

List<ShoppingList> seedShoppingLists() => const <ShoppingList>[
      ShoppingList(
        id: favoritesListId,
        name: 'Favorites',
        emoji: '❤️',
        productIds: <String>[productAvocado, productSourdough, productColdBrew],
      ),
      ShoppingList(
        id: staplesListId,
        name: 'Weekly Staples',
        emoji: '🛒',
        productIds: <String>[
          productMilk,
          productEggs,
          productBananas,
          productSourdough,
          productChicken,
          productRice,
        ],
      ),
      ShoppingList(
        id: tacoNightListId,
        name: 'Taco Night',
        emoji: '🌮',
        productIds: <String>[
          productGroundBeef,
          productTortillas,
          productCheddar,
          productTomatoes,
          productAvocado,
        ],
      ),
      ShoppingList(
        id: breakfastListId,
        name: 'Breakfast Basics',
        emoji: '🍳',
        productIds: <String>[productEggs, productBacon, productMilk, productMuffins, productOrangeJuice],
      ),
    ];

/// Builds one seeded [Order] from a [quantitiesByProductId] map (insertion
/// order becomes line order) placed [daysAgo] before [now], delivered in a
/// window with the given [startLabel]/[endLabel]. Totals are computed by
/// the same pure `calculateTotals` the live cart uses.
Order _seedOrder({
  required String id,
  required DateTime now,
  required int daysAgo,
  required List<Product> products,
  required Map<String, int> quantitiesByProductId,
  required String startLabel,
  required String endLabel,
}) {
  final productsById = <String, Product>{for (final product in products) product.id: product};
  final placedAt = now.subtract(Duration(days: daysAgo));

  final lines = <OrderLine>[
    for (final entry in quantitiesByProductId.entries)
      OrderLine(
        productId: entry.key,
        name: productsById[entry.key]!.name,
        unit: productsById[entry.key]!.unit,
        emoji: productsById[entry.key]!.emoji,
        gradientIndex: productsById[entry.key]!.gradientIndex,
        price: productsById[entry.key]!.price,
        quantity: entry.value,
      ),
  ];

  final cartLines = <CartLine>[
    for (final entry in quantitiesByProductId.entries)
      CartLine(product: productsById[entry.key]!, quantity: entry.value),
  ];
  final totals = calculateTotals(cartLines);

  return Order(
    id: id,
    placedAt: placedAt,
    lines: lines,
    deliveryAddress: defaultDeliveryAddress,
    slotLabel: '${formatWeekdayAndShortDate(placedAt)} · $startLabel – $endLabel',
    subtotal: totals.subtotal,
    deliveryFee: totals.deliveryFee,
    tax: totals.tax,
    total: totals.total,
  );
}

/// The 3 seeded past orders, most recent first. Built against [products]
/// (defaulting to [seedProducts]) so a test can pass a custom catalog.
List<Order> seedOrders(List<Product> products, {DateTime? now}) {
  final effectiveNow = now ?? DateTime.now();

  return <Order>[
    _seedOrder(
      id: 'order-seed-1',
      now: effectiveNow,
      daysAgo: 2,
      products: products,
      quantitiesByProductId: <String, int>{
        productMilk: 2,
        productEggs: 1,
        productBananas: 6,
        productSourdough: 1,
        productChicken: 2,
      },
      startLabel: '2:00 PM',
      endLabel: '4:00 PM',
    ),
    _seedOrder(
      id: 'order-seed-2',
      now: effectiveNow,
      daysAgo: 9,
      products: products,
      quantitiesByProductId: <String, int>{
        productPasta: 3,
        productOliveOil: 1,
        productGroundBeef: 2,
        productSpinach: 2,
        productCheddar: 1,
      },
      startLabel: '9:00 AM',
      endLabel: '11:00 AM',
    ),
    _seedOrder(
      id: 'order-seed-3',
      now: effectiveNow,
      daysAgo: 20,
      products: products,
      quantitiesByProductId: <String, int>{
        productChips: 2,
        productPopcorn: 1,
        productSparklingWater: 2,
        productColdBrew: 1,
        productIceCream: 1,
      },
      startLabel: '6:00 PM',
      endLabel: '8:00 PM',
    ),
  ];
}
