import 'package:flutter/material.dart';

import '../../../core/logic/catalog_filter.dart';
import '../../../core/models/category.dart';

/// A horizontally-scrolling row of category chips, with a leading "All"
/// chip. Purely presentational - [onSelect] is handed the tapped
/// category's id (or [allCategoriesId] for "All").
class CategoryChipRow extends StatelessWidget {
  const CategoryChipRow({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelect,
  });

  final List<Category> categories;
  final String selectedCategoryId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return ChoiceChip(
              label: const Text('All'),
              selected: selectedCategoryId == allCategoriesId,
              onSelected: (_) => onSelect(allCategoriesId),
            );
          }
          final category = categories[index - 1];
          return ChoiceChip(
            avatar: Text(category.emoji, style: const TextStyle(fontSize: 14)),
            label: Text(category.name),
            selected: selectedCategoryId == category.id,
            onSelected: (_) => onSelect(category.id),
          );
        },
      ),
    );
  }
}
