import 'package:flutter/material.dart';

/// The Shop screen's product search box - a plain [TextField] wired to
/// [searchQueryProvider] by the caller, with a clear button that only
/// shows once there's something to clear.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return TextField(
          controller: controller,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search Groczy...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClear,
                    tooltip: 'Clear search',
                  ),
          ),
        );
      },
    );
  }
}
