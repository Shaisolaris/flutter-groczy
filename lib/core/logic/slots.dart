import '../constants/date_format.dart';
import '../models/delivery_slot.dart';

/// Pure delivery-slot math: which bookable windows exist over the next few
/// days, how full each one is, and which are still available to choose at
/// checkout. Nothing here depends on Flutter or storage.

/// How full a [DeliverySlot] is, used to color/label it in the picker.
enum SlotAvailability { open, limited, full }

/// Once this many spots or fewer remain, a slot reads as "limited" rather
/// than fully "open" - it's still bookable, but the picker calls that out.
const int limitedSpotsThreshold = 4;

/// Spots left in [slot] before it's fully booked. Never negative.
int remainingSpots(DeliverySlot slot) {
  final remaining = slot.capacity - slot.bookedCount;
  return remaining < 0 ? 0 : remaining;
}

/// Whether [slot] still has at least one open spot.
bool isSlotAvailable(DeliverySlot slot) => remainingSpots(slot) > 0;

/// Classifies how full [slot] is for display purposes.
SlotAvailability classifySlot(DeliverySlot slot) {
  final remaining = remainingSpots(slot);
  if (remaining <= 0) return SlotAvailability.full;
  if (remaining <= limitedSpotsThreshold) return SlotAvailability.limited;
  return SlotAvailability.open;
}

/// The slots in [allSlots] that are still bookable as of [now]: not full,
/// and not a window that has already started today (a slot on a future
/// date is always eligible regardless of time of day).
List<DeliverySlot> availableSlots(List<DeliverySlot> allSlots, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  return allSlots.where((slot) {
    final slotDate = DateTime(slot.date.year, slot.date.month, slot.date.day);
    if (slotDate.isBefore(today)) return false;
    if (slotDate.isAtSameMomentAs(today) && slot.startHour24 <= now.hour) return false;
    return isSlotAvailable(slot);
  }).toList();
}

/// A day-and-time display label for [slot] relative to [now], e.g.
/// "Today · 2:00 PM – 4:00 PM" or "Fri, Aug 7 · 9:00 AM – 11:00 AM".
String slotDisplayLabel(DeliverySlot slot, DateTime now) {
  return '${formatRelativeToToday(slot.date, now)} · ${slot.timeRangeLabel}';
}

/// (start hour in 24h time, start label, end label) for every window
/// offered each day.
const List<(int, String, String)> _timeWindows = <(int, String, String)>[
  (7, '7:00 AM', '9:00 AM'),
  (9, '9:00 AM', '11:00 AM'),
  (12, '12:00 PM', '2:00 PM'),
  (14, '2:00 PM', '4:00 PM'),
  (16, '4:00 PM', '6:00 PM'),
  (18, '6:00 PM', '8:00 PM'),
];

/// Every window's fixed capacity (how many courier deliveries that shift
/// can fulfill). Evening runs a smaller fleet than midday, and "today"
/// always runs one courier short across every window (today's roster is
/// already partly locked in).
const List<int> _baseCapacityByWindow = <int>[6, 8, 8, 8, 6, 4];

/// A fixed (not random) booked-count pattern so demand looks realistic -
/// busiest around midday and tapering toward evening, and easing off the
/// further out a day is - while staying perfectly deterministic.
const List<int> _baseBookedByWindow = <int>[2, 5, 6, 5, 4, 3];

int _capacityFor(int dayOffset, int windowIndex) {
  final capacity = _baseCapacityByWindow[windowIndex];
  return dayOffset == 0 ? capacity - 1 : capacity;
}

/// Booked count for [dayOffset]/[windowIndex], clamped to `[0, capacity]`.
/// Today's very first window is deliberately booked solid, so the picker's
/// "full" state is visible from the first launch without waiting for
/// demand to build up.
int _bookedFor(int dayOffset, int windowIndex, int capacity) {
  if (dayOffset == 0 && windowIndex == 0) return capacity;
  final booked = _baseBookedByWindow[windowIndex] - dayOffset;
  if (booked < 0) return 0;
  return booked > capacity ? capacity : booked;
}

/// Deterministically generates the next [dayCount] days of delivery
/// windows starting from [now]'s date, each day offering the same fixed
/// set of time windows. Capacity and how many spots are already booked
/// follow a fixed, repeatable pattern keyed off the day offset and window
/// index (never [DateTime.now()] or [Random]), so the same [now] always
/// produces the exact same slots - which is what makes this testable.
List<DeliverySlot> generateSlots(DateTime now, {int dayCount = 4}) {
  final today = DateTime(now.year, now.month, now.day);
  final slots = <DeliverySlot>[];

  for (var dayOffset = 0; dayOffset < dayCount; dayOffset++) {
    final date = today.add(Duration(days: dayOffset));
    for (var windowIndex = 0; windowIndex < _timeWindows.length; windowIndex++) {
      final window = _timeWindows[windowIndex];
      final capacity = _capacityFor(dayOffset, windowIndex);
      final booked = _bookedFor(dayOffset, windowIndex, capacity);
      slots.add(DeliverySlot(
        id: 'slot-$dayOffset-$windowIndex',
        date: date,
        startHour24: window.$1,
        startLabel: window.$2,
        endLabel: window.$3,
        capacity: capacity,
        bookedCount: booked,
      ));
    }
  }

  return slots;
}
