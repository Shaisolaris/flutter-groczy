import 'package:flutter_groczy/core/logic/slots.dart';
import 'package:flutter_groczy/core/models/delivery_slot.dart';
import 'package:flutter_test/flutter_test.dart';

/// (id, capacity, bookedCount) - enough to prove two runs produced
/// identical slots without relying on [DeliverySlot] having value equality.
List<(String, int, int)> _fingerprint(List<DeliverySlot> slots) {
  return [for (final slot in slots) (slot.id, slot.capacity, slot.bookedCount)];
}

DeliverySlot _find(List<DeliverySlot> slots, int dayOffset, int windowIndex) {
  return slots.firstWhere((slot) => slot.id == 'slot-$dayOffset-$windowIndex');
}

void main() {
  // "Today" for every test below - matches the seeded catalog's anchor date.
  final today = DateTime(2026, 8, 7);

  group('generateSlots', () {
    test('produces 6 windows/day for the default 4-day horizon (24 total)', () {
      expect(generateSlots(today), hasLength(24));
    });

    test('is deterministic: two calls with the same "now" produce identical slots', () {
      final first = generateSlots(DateTime(2026, 8, 7, 10, 30));
      final second = generateSlots(DateTime(2026, 8, 7, 10, 30));
      expect(_fingerprint(first), _fingerprint(second));
    });

    test('hand-traced capacities and booked counts for today (day offset 0)', () {
      final slots = generateSlots(today);

      // Base capacities [6,8,8,8,6,4], today runs one courier short: -1 each.
      // Window 0 (7-9am) is deliberately booked solid.
      expect(_find(slots, 0, 0), _matches(capacity: 5, booked: 5));
      expect(_find(slots, 0, 1), _matches(capacity: 7, booked: 5));
      expect(_find(slots, 0, 2), _matches(capacity: 7, booked: 6));
      expect(_find(slots, 0, 3), _matches(capacity: 7, booked: 5));
      expect(_find(slots, 0, 4), _matches(capacity: 5, booked: 4));
      expect(_find(slots, 0, 5), _matches(capacity: 3, booked: 3));
    });

    test('hand-traced capacities and booked counts 3 days out', () {
      final slots = generateSlots(today);

      // Full base capacities [6,8,8,8,6,4]; demand pattern [2,5,6,5,4,3] - 3,
      // clamped at 0.
      expect(_find(slots, 3, 0), _matches(capacity: 6, booked: 0));
      expect(_find(slots, 3, 1), _matches(capacity: 8, booked: 2));
      expect(_find(slots, 3, 5), _matches(capacity: 4, booked: 0));
    });
  });

  group('remainingSpots / isSlotAvailable / classifySlot', () {
    test('a fully-booked slot has 0 remaining and is unavailable', () {
      final slot = _find(generateSlots(today), 0, 0);
      expect(remainingSpots(slot), 0);
      expect(isSlotAvailable(slot), isFalse);
      expect(classifySlot(slot), SlotAvailability.full);
    });

    test('overbooked (defensive) never reports negative remaining spots', () {
      // Not `const`: DateTime has no const constructor.
      final slot = DeliverySlot(
        id: 'x',
        date: DateTime(2026, 8, 7),
        startHour24: 9,
        startLabel: '9:00 AM',
        endLabel: '11:00 AM',
        capacity: 5,
        bookedCount: 9,
      );
      expect(remainingSpots(slot), 0);
      expect(classifySlot(slot), SlotAvailability.full);
    });

    test('2 of 7 remaining (day0 window1) is limited', () {
      final slot = _find(generateSlots(today), 0, 1);
      expect(remainingSpots(slot), 2);
      expect(classifySlot(slot), SlotAvailability.limited);
      expect(isSlotAvailable(slot), isTrue);
    });

    test('6 of 6 remaining (day2 window0) is open', () {
      final slot = _find(generateSlots(today), 2, 0);
      expect(remainingSpots(slot), 6);
      expect(classifySlot(slot), SlotAvailability.open);
    });

    test('exactly at the limited threshold (4 remaining) still reads as limited', () {
      final slot = _find(generateSlots(today), 1, 1); // capacity 8, booked 4 -> remaining 4
      expect(remainingSpots(slot), limitedSpotsThreshold);
      expect(classifySlot(slot), SlotAvailability.limited);
    });
  });

  group('availableSlots', () {
    test('mid-morning "now": excludes full slots and windows already started today', () {
      final now = DateTime(2026, 8, 7, 10, 0); // 10:00 AM
      final available = availableSlots(generateSlots(today), now);

      // Today: window0 (7am, full) and window1 (9am, already started) are
      // both excluded; window2/3/4 (12pm/2pm/4pm) remain. Window5 (6pm) is
      // full, also excluded.
      final todaysAvailable = available.where((s) => s.date == DateTime(2026, 8, 7)).toList();
      expect(todaysAvailable.map((s) => s.id).toList(), <String>['slot-0-2', 'slot-0-3', 'slot-0-4']);

      // Every later day contributes its non-full windows (5 of 6 each,
      // since none of day 1/2/3's windows are full).
      expect(available, hasLength(3 + 6 + 6 + 6));
    });

    test('midnight "now": only the fully-booked windows are excluded today', () {
      final now = DateTime(2026, 8, 7); // midnight
      final available = availableSlots(generateSlots(today), now);
      final todaysAvailable = available.where((s) => s.date == DateTime(2026, 8, 7)).toList();

      expect(todaysAvailable.map((s) => s.id).toList(), <String>['slot-0-1', 'slot-0-2', 'slot-0-3', 'slot-0-4']);
    });

    test('a slot dated yesterday never shows up, regardless of time', () {
      final pastSlots = [
        DeliverySlot(
          id: 'past',
          date: DateTime(2026, 8, 6),
          startHour24: 9,
          startLabel: '9:00 AM',
          endLabel: '11:00 AM',
          capacity: 10,
          bookedCount: 0,
        ),
      ];
      expect(availableSlots(pastSlots, DateTime(2026, 8, 7, 23, 0)), isEmpty);
    });
  });

  group('slotDisplayLabel', () {
    test('formats a today slot as "Today · <range>"', () {
      final slot = _find(generateSlots(today), 0, 3);
      expect(slotDisplayLabel(slot, DateTime(2026, 8, 7, 10)), 'Today · 2:00 PM – 4:00 PM');
    });

    test('formats a slot 2 days out with its weekday label', () {
      final slot = _find(generateSlots(today), 2, 1);
      // Aug 7, 2026 is a Friday, so +2 days is Sunday Aug 9.
      expect(slotDisplayLabel(slot, today), 'Sun, Aug 9 · 9:00 AM – 11:00 AM');
    });
  });
}

/// Small matcher helper for asserting a slot's capacity/bookedCount pair
/// without repeating field-by-field `expect` calls at every call site.
Matcher _matches({required int capacity, required int booked}) {
  return isA<DeliverySlot>()
      .having((slot) => slot.capacity, 'capacity', capacity)
      .having((slot) => slot.bookedCount, 'bookedCount', booked);
}
