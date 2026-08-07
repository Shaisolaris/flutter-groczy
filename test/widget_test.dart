import 'package:flutter/material.dart';
import 'package:flutter_groczy/app.dart';
import 'package:flutter_groczy/core/constants/nav_tabs.dart';
import 'package:flutter_groczy/data/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pumps a fresh [GroczyApp] backed by an in-memory (mocked)
/// SharedPreferences instance, so every test starts from the same
/// first-run, freshly-seeded state.
Future<void> pumpGroczyApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const GroczyApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('launches on Shop with a 4-tab bottom nav and the seeded catalog', (tester) async {
    await pumpGroczyApp(tester);

    expect(find.text('Groczy'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    expect(find.widgetWithText(NavigationDestination, 'Shop'), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, 'Cart'), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, 'Orders'), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, 'Lists'), findsOneWidget);

    // A seeded category and a seeded product not referenced by any past
    // order (see seed_data_test.dart) - so this is unambiguous even though
    // every tab's screen is simultaneously mounted under the IndexedStack.
    expect(find.text('Produce'), findsWidgets);
    expect(find.text('Roma Tomatoes'), findsOneWidget);
  });

  testWidgets('search narrows the grid, and clearing it restores the full catalog', (tester) async {
    await pumpGroczyApp(tester);

    expect(find.text('Roma Tomatoes'), findsOneWidget);
    expect(find.text('Flour Tortillas'), findsNothing);

    await tester.enterText(find.byType(TextField).first, 'tortilla');
    await tester.pumpAndSettle();

    expect(find.text('Flour Tortillas'), findsOneWidget);
    expect(find.text('Roma Tomatoes'), findsNothing);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('Roma Tomatoes'), findsOneWidget);
  });

  testWidgets('category chips filter the grid to a single category', (tester) async {
    await pumpGroczyApp(tester);

    expect(find.text('Roma Tomatoes'), findsOneWidget);
    expect(find.text('Flour Tortillas'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Bakery'));
    await tester.pumpAndSettle();

    expect(find.text('Flour Tortillas'), findsOneWidget);
    expect(find.text('Roma Tomatoes'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'All'));
    await tester.pumpAndSettle();

    expect(find.text('Roma Tomatoes'), findsOneWidget);
  });

  testWidgets('adding a product swaps its Add button for a quantity stepper', (tester) async {
    await pumpGroczyApp(tester);

    expect(find.byKey(const Key('add-to-cart-p-avocado')), findsOneWidget);
    expect(find.byKey(const Key('quantity-stepper-p-avocado')), findsNothing);

    await tester.tap(find.byKey(const Key('add-to-cart-p-avocado')));
    await tester.pump();

    expect(find.byKey(const Key('add-to-cart-p-avocado')), findsNothing);
    expect(find.byKey(const Key('quantity-stepper-p-avocado')), findsOneWidget);
  });

  testWidgets('checkout flow: add an item, pick a slot, place the order, and track it', (tester) async {
    await pumpGroczyApp(tester);

    await tester.tap(find.byKey(const Key('add-to-cart-p-avocado')));
    await tester.pump();

    await tester.tap(find.widgetWithText(NavigationDestination, 'Cart'));
    await tester.pumpAndSettle();

    expect(find.text('Hass Avocado'), findsOneWidget);
    expect(find.text('Select a delivery slot to continue'), findsOneWidget);

    // Tomorrow's first window is always open (never time-filtered, never
    // full - see slots_test.dart's hand-traced capacity table), so this key
    // is stable no matter when this test happens to run.
    await tester.tap(find.byKey(const Key('slot-slot-1-0')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Checkout ·'), findsOneWidget);

    await tester.tap(find.textContaining('Checkout ·'));
    await tester.pumpAndSettle();

    expect(find.text('Order placed!'), findsOneWidget);

    await tester.tap(find.text('Track your order'));
    await tester.pumpAndSettle();

    // Actually landed on the Orders tab (IndexedStack keeps every tab
    // mounted, so checking selectedIndex - not just presence of Orders
    // content - is what proves the tab switch itself happened).
    final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navBar.selectedIndex, NavTab.orders);

    // The brand-new order is on top, freshly "placed".
    expect(find.text('Order placed'), findsWidgets);
  });

  testWidgets('Orders tab shows seeded order history', (tester) async {
    await pumpGroczyApp(tester);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Orders'));
    await tester.pumpAndSettle();

    // Most recent seeded order (see seed_data_test.dart for the full
    // hand-traced breakdown) - always at the top, so never scrolled away.
    expect(find.text('\$41.04'), findsOneWidget);
  });

  testWidgets('Lists tab shows the starter shopping lists', (tester) async {
    await pumpGroczyApp(tester);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Lists'));
    await tester.pumpAndSettle();

    expect(find.text('Favorites'), findsOneWidget);
  });
}
