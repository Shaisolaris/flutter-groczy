import 'package:flutter/material.dart';

/// Shared gradient palette used to render product and category art - Groczy
/// has no product photography, so every tile is a colored gradient with an
/// emoji on top. Products in the same category share a gradient index
/// (see `data/seed_data.dart`), so the Shop grid reads as color-coded by
/// category.
///
/// This file imports Flutter and must never be imported from
/// `core/logic/` - only from widgets.
const List<List<Color>> _gradientPalette = <List<Color>>[
  [Color(0xFF4ADE80), Color(0xFF15803D)], // produce - green
  [Color(0xFF7DD3FC), Color(0xFF0369A1)], // dairy & eggs - sky blue
  [Color(0xFFFCD34D), Color(0xFFB45309)], // bakery - amber
  [Color(0xFFFB7185), Color(0xFFBE123C)], // meat & seafood - rose
  [Color(0xFFFDBA74), Color(0xFFC2410C)], // pantry - orange
  [Color(0xFFC4B5FD), Color(0xFF6D28D9)], // snacks - violet
  [Color(0xFF5EEAD4), Color(0xFF0F766E)], // beverages - teal
  [Color(0xFF67E8F9), Color(0xFF0E7490)], // frozen - icy cyan
];

/// The two colors used for gradient block [index], cycling through the
/// palette if there are more categories than palette entries.
List<Color> gradientColorsFor(int index) {
  final safeIndex = index % _gradientPalette.length;
  return _gradientPalette[safeIndex < 0 ? safeIndex + _gradientPalette.length : safeIndex];
}

/// A ready-to-use [LinearGradient] for gradient block [index].
LinearGradient gradientFor(int index) {
  return LinearGradient(
    colors: gradientColorsFor(index),
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
