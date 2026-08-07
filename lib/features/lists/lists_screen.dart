import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/empty_state.dart';
import '../../data/providers.dart';
import 'widgets/create_list_sheet.dart';
import 'widgets/shopping_list_card.dart';

/// The Lists tab: saved shopping lists (including Favorites), each with a
/// one-tap "add all to cart".
class ListsScreen extends ConsumerWidget {
  const ListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(shoppingListsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Lists')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCreateListSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('New list'),
      ),
      body: listsAsync.when(
        data: (lists) {
          if (lists.isEmpty) {
            return const EmptyState(
              icon: Icons.checklist_outlined,
              title: 'No lists yet',
              subtitle: 'Create a list to save your regulars for one-tap reordering.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: lists.length,
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemBuilder: (context, index) => ShoppingListCard(list: lists[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Could not load lists: $error')),
      ),
    );
  }
}
