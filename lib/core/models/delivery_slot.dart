/// One bookable delivery window on a given date, e.g. "Today, 2:00 PM -
/// 4:00 PM".
///
/// Slots are generated fresh from "now" rather than persisted - see
/// `core/logic/slots.dart#generateSlots` - since they're always relative to
/// the current date rather than being a person's own data.
class DeliverySlot {
  const DeliverySlot({
    required this.id,
    required this.date,
    required this.startHour24,
    required this.startLabel,
    required this.endLabel,
    required this.capacity,
    required this.bookedCount,
  });

  final String id;

  /// Date-only (midnight local time) - the calendar day this window falls
  /// on.
  final DateTime date;

  /// [startLabel] expressed as a 24-hour hour-of-day, used to compare a
  /// window against the current time without parsing [startLabel].
  final int startHour24;

  final String startLabel;
  final String endLabel;

  /// How many deliveries this window's courier shift can fulfill.
  final int capacity;

  /// How many of [capacity] are already spoken for.
  final int bookedCount;

  String get timeRangeLabel => '$startLabel – $endLabel';

  @override
  String toString() => 'DeliverySlot($id, $date $timeRangeLabel, $bookedCount/$capacity)';
}
