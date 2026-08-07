import 'package:flutter/material.dart';

import '../../../core/constants/date_format.dart';
import '../../../core/logic/slots.dart';
import '../../../core/models/delivery_slot.dart';

/// A day-by-day picker of bookable [DeliverySlot]s. Only ever shown
/// *available* slots (already filtered by `core/logic/slots.dart`), so
/// every chip here is either open or limited - never full.
class DeliverySlotPicker extends StatelessWidget {
  const DeliverySlotPicker({
    super.key,
    required this.slots,
    required this.selectedSlotId,
    required this.onSelect,
    required this.now,
  });

  final List<DeliverySlot> slots;
  final String? selectedSlotId;
  final ValueChanged<String> onSelect;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return Text(
        'No delivery windows left today or tomorrow - check back soon.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error),
      );
    }

    final byDate = <DateTime, List<DeliverySlot>>{};
    for (final slot in slots) {
      final dateKey = DateTime(slot.date.year, slot.date.month, slot.date.day);
      byDate.putIfAbsent(dateKey, () => <DeliverySlot>[]).add(slot);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in byDate.entries) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 4),
            child: Text(
              formatRelativeToToday(entry.key, now),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final slot in entry.value)
                _SlotChip(
                  slot: slot,
                  selected: slot.id == selectedSlotId,
                  onTap: () => onSelect(slot.id),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({required this.slot, required this.selected, required this.onTap});

  final DeliverySlot slot;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final availability = classifySlot(slot);
    final remaining = remainingSpots(slot);

    return Material(
      color: selected ? scheme.primaryContainer : scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        key: Key('slot-${slot.id}'),
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? scheme.primary : Colors.transparent, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                slot.timeRangeLabel,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: selected ? scheme.onPrimaryContainer : scheme.onSurface,
                ),
              ),
              if (availability == SlotAvailability.limited) ...[
                const SizedBox(height: 2),
                Text(
                  'Only $remaining left',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selected ? scheme.onPrimaryContainer : scheme.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
