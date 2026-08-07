import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers.dart';

const List<String> _emojiChoices = <String>['🛒', '🥦', '🍕', '🎉', '🧊', '🍳', '🌮', '🥗'];

/// Opens a bottom sheet form for naming and creating a new (initially
/// empty) shopping list.
Future<void> showCreateListSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (context) => const _CreateListSheet(),
  );
}

class _CreateListSheet extends ConsumerStatefulWidget {
  const _CreateListSheet();

  @override
  ConsumerState<_CreateListSheet> createState() => _CreateListSheetState();
}

class _CreateListSheetState extends ConsumerState<_CreateListSheet> {
  late final TextEditingController _nameController;
  String _selectedEmoji = _emojiChoices.first;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _create() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    ref.read(shoppingListsProvider.notifier).createList(name, _selectedEmoji);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(color: scheme.outlineVariant, borderRadius: BorderRadius.circular(999)),
            ),
          ),
          const SizedBox(height: 16),
          Text('New list', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'List name, e.g. "Game Night"'),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _create(),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final emoji in _emojiChoices)
                _EmojiChoice(
                  emoji: emoji,
                  selected: emoji == _selectedEmoji,
                  onTap: () => setState(() => _selectedEmoji = emoji),
                ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _nameController.text.trim().isEmpty ? null : _create,
              child: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Create list')),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmojiChoice extends StatelessWidget {
  const _EmojiChoice({required this.emoji, required this.selected, required this.onTap});

  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? scheme.primaryContainer : scheme.surfaceContainerHighest,
      shape: CircleBorder(side: BorderSide(color: selected ? scheme.primary : Colors.transparent, width: 1.5)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(emoji, style: const TextStyle(fontSize: 20)),
        ),
      ),
    );
  }
}
