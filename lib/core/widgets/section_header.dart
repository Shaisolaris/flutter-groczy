import 'package:flutter/material.dart';

/// A section title with an optional trailing action, e.g. "Delivery slot"
/// or "Order summary" headers on the Cart screen.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailingLabel,
    this.onTrailingPressed,
  });

  final String title;
  final String? trailingLabel;
  final VoidCallback? onTrailingPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (trailingLabel != null)
          TextButton(
            onPressed: onTrailingPressed,
            child: Text(trailingLabel!),
          ),
      ],
    );
  }
}
