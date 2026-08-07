/// Lightweight date formatting for the UI layer. Deliberately dependency-free
/// (no `intl` package) - Groczy only ever needs a handful of short, English
/// date labels. Pure Dart, safe to import from `core/logic/`.
const List<String> _monthAbbreviations = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const List<String> _weekdayAbbreviations = <String>[
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

/// e.g. "Aug 20, 2026".
String formatMediumDate(DateTime date) {
  return '${_monthAbbreviations[date.month - 1]} ${date.day}, ${date.year}';
}

/// e.g. "Aug 20" - used when the year is shown separately, or is the current
/// year and would be redundant.
String formatShortDate(DateTime date) {
  return '${_monthAbbreviations[date.month - 1]} ${date.day}';
}

/// e.g. "Fri, Aug 7" - used for delivery slot dates.
String formatWeekdayAndShortDate(DateTime date) {
  return '${_weekdayAbbreviations[date.weekday - 1]}, ${formatShortDate(date)}';
}

/// A relative-to-today label for a date: "Today", "Tomorrow", "N days ago"
/// close to today, and a weekday + short date once it's far enough away
/// that a relative label stops being useful.
String formatRelativeToToday(DateTime date, DateTime today) {
  final normalizedDate = DateTime(date.year, date.month, date.day);
  final normalizedToday = DateTime(today.year, today.month, today.day);
  final diff = normalizedDate.difference(normalizedToday).inDays;

  if (diff == 0) return 'Today';
  if (diff == 1) return 'Tomorrow';
  if (diff == -1) return 'Yesterday';
  if (diff > 1 && diff <= 7) return formatWeekdayAndShortDate(date);
  if (diff < -1 && diff >= -7) return '${-diff} days ago';
  return formatMediumDate(date);
}
