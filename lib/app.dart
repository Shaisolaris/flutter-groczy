import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/nav_tabs.dart';
import 'data/providers.dart';
import 'features/cart/cart_screen.dart';
import 'features/lists/lists_screen.dart';
import 'features/orders/orders_screen.dart';
import 'features/shop/shop_screen.dart';

/// Groczy's Material 3 seed color: a fresh, grocery-green that reads as
/// "produce aisle" without tipping into neon.
const Color _seedColor = Color(0xFF16A34A);

/// Root app widget: Material 3 theming (light + dark, both seeded from the
/// same green) wrapping the bottom-navigation shell.
class GroczyApp extends StatelessWidget {
  const GroczyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Groczy',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const RootShell(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: _seedColor, brightness: brightness);
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: scheme.surface,
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.secondaryContainer,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        selectedColor: scheme.primaryContainer,
        labelStyle: TextStyle(color: scheme.onSurface),
        secondaryLabelStyle: TextStyle(color: scheme.onPrimaryContainer),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// Bottom-navigation shell hosting Shop, Cart, Orders, and Lists. Uses an
/// [IndexedStack] so switching tabs never rebuilds/loses the scroll
/// position of the other screens, and reads its active tab from
/// [rootTabIndexProvider] so any screen in the tree can switch tabs (e.g.
/// checkout confirmation jumping straight to Orders).
class RootShell extends ConsumerWidget {
  const RootShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(rootTabIndexProvider);
    final cartCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const <Widget>[
          ShopScreen(),
          CartScreen(),
          OrdersScreen(),
          ListsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => ref.read(rootTabIndexProvider.notifier).state = value,
        destinations: <NavigationDestination>[
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Shop',
          ),
          NavigationDestination(
            icon: _CartNavIcon(count: cartCount, selected: index == NavTab.cart),
            label: 'Cart',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          const NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'Lists',
          ),
        ],
      ),
    );
  }
}

class _CartNavIcon extends StatelessWidget {
  const _CartNavIcon({required this.count, required this.selected});

  final int count;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(selected ? Icons.shopping_cart : Icons.shopping_cart_outlined);
    if (count <= 0) return icon;
    return Badge(label: Text('$count'), child: icon);
  }
}
