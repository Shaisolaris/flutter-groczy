# Groczy

A grocery delivery app built with Flutter. Groczy turns browsing a grocery aisle
into a few taps: shop by category, build a cart, pick a delivery slot, and watch
your order move from placed to delivered - live.

**Live preview:** https://shaisolaris.github.io/flutter-groczy/

## Screens

| Screen | What it does |
| --- | --- |
| **Shop** | Category chips plus a searchable product grid - gradient-and-emoji tiles standing in for photography, each with a price, unit, and an "Add" button that becomes a quantity stepper once it's in the cart. Tap the heart to favorite a product. |
| **Cart** | Line items with quantity steppers, a day-by-day delivery slot picker (open/limited/full color-coded from live seed capacity), an editable delivery address, and an order summary - subtotal, delivery fee (free over $35), tax, and total, with a nudge banner showing how much more unlocks free delivery. Checkout books the order and opens a confirmation screen. |
| **Orders** | Past orders, most recent first, each with a live status tracker (Placed → Preparing → Out for delivery → Delivered) derived from how long ago it was placed - so a fresh order visibly progresses while a seeded past order always reads Delivered. Expand an order for its full receipt, or tap Reorder to merge it straight back into the cart. |
| **Lists** | Saved shopping lists - including Favorites, populated by the Shop screen's heart toggle - each with a preview strip and a one-tap "Add all to cart". Create new lists, or open one to remove individual items. |

Navigation is a bottom bar with four tabs: **Shop**, **Cart**, **Orders**, **Lists**
(the Cart tab carries a live item-count badge).

## Architecture

```
lib/
  main.dart                  Entry point - loads SharedPreferences, wires ProviderScope
  app.dart                   MaterialApp, Material 3 theme (light + dark), bottom-nav shell
  core/
    models/                  Plain, JSON-serializable data classes (Product, CartItem, Order, ShoppingList, ...)
    logic/                   Pure, Flutter-free business logic (see Testing below)
    constants/                Gradient palette, date/money formatting, nav tab indices
    widgets/                  Small shared UI (gradient tile, quantity stepper, empty state, section header)
    utils/                    Dependency-free ID generation
  data/
    groczy_repository.dart    Storage interface + a shared_preferences-backed implementation
    seed_data.dart             Deterministic catalog + starter orders/lists (pure functions of "now")
    providers.dart             Riverpod providers/notifiers wiring the repository to the UI
  features/
    shop/     screen + widgets   Search, category chips, product grid
    cart/     screen + widgets   Line items, slot picker, order summary, checkout, confirmation
    orders/   screen + widgets   Order history, live status tracker, reorder
    lists/    screen + widgets   Saved lists, list detail sheet, create-list sheet
```

State management is [flutter_riverpod], using `AsyncNotifier`s that load from - and
persist back to - a small `GroczyRepository` abstraction. The UI never talks to
`shared_preferences` directly, which keeps the storage layer swappable and easy to
fake in tests. The cart, order history, and shopping lists are stored as JSON, each
under its own key; the product catalog itself is read-only reference data rebuilt
from `seed_data.dart` on every launch rather than persisted.

The **cart totals, delivery-slot availability, order-status, reorder-merge, and
catalog-filter math are all pure Dart** with no Flutter dependency - they live
entirely under `lib/core/logic/` and are exercised directly by unit tests,
independent of widgets or storage. Notably, an `Order` has no stored status field
at all: `core/logic/order_status.dart` derives it fresh from `placedAt` every time
it's displayed, so a freshly-checked-out order visibly advances through delivery
stages purely from elapsed time.

## Testing

```
test/
  core/logic/
    cart_test.dart             Subtotal, threshold-based delivery fee, tax, totals, cart-line resolution
    slots_test.dart             Deterministic slot generation, capacity/availability, day-relative labels
    reorder_test.dart           Merging a past order into the cart, including unavailable-product handling
    order_status_test.dart      Elapsed-time -> status thresholds, and the 4-stage progress sequence
    catalog_filter_test.dart    Category + search-query filtering, combined and independently
  data/
    seed_data_test.dart         The seeded catalog/orders/lists are deterministic and match a
                                 fully hand-traced breakdown (including exact order totals)
  widget_test.dart              App launches, search/category filtering, add-to-cart, and a full
                                 add -> pick a slot -> checkout -> confirmation -> track order flow
```

Every pure-logic test asserts a **hand-traced expected value** - for example, the
first seeded order's total is checked against `$41.04`, computed by hand in the
test's comments (subtotal `$33.38` + delivery fee `$4.99` + tax `$2.67`) rather than
just against whatever the function happens to return.

```bash
flutter test
```

## Run it

```bash
flutter pub get
flutter run                          # any connected device/simulator
flutter run -d chrome                # web
flutter build web --base-href /flutter-groczy/
```

## Tech stack

- Flutter 3.24+, null-safe Dart, Material 3 (seed color `#16A34A`, light + dark)
- [flutter_riverpod] for state management
- `shared_preferences` for local, on-device persistence
- Zero third-party UI or date-formatting dependencies

[flutter_riverpod]: https://pub.dev/packages/flutter_riverpod

## License

MIT - see [LICENSE](LICENSE).

---

Author: **Shai**
