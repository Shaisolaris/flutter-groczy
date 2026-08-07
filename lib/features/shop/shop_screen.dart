import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/empty_state.dart';
import '../../data/providers.dart';
import 'widgets/category_chip_row.dart';
import 'widgets/product_card.dart';
import 'widgets/search_field.dart';

/// The Shop tab: search, category chips, and a product grid. The entry
/// point for building a cart.
class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(searchQueryProvider.notifier).state = value;
  }

  void _onClearSearch() {
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final selectedCategoryId = ref.watch(selectedCategoryIdProvider);
    final products = ref.watch(filteredProductsProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Groczy'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SearchField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onClear: _onClearSearch,
              ),
            ),
            CategoryChipRow(
              categories: categories,
              selectedCategoryId: selectedCategoryId,
              onSelect: (id) => ref.read(selectedCategoryIdProvider.notifier).state = id,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: products.isEmpty
                  ? EmptyState(
                      icon: Icons.search_off,
                      title: 'No products found',
                      subtitle: query.isEmpty
                          ? 'Try a different category.'
                          : 'Nothing matches "$query". Try a different search.',
                    )
                  : GridView.builder(
                      key: const PageStorageKey<String>('shop-grid'),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.66,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) => ProductCard(product: products[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
