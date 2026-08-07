# Groczy — Grocery Delivery App

Grocery delivery app in an interactive phone frame.

**[Live Demo](https://shaisolaris.github.io/flutter-groczy/)**

## Features

- **Aisle browsing** — 12 products across 5 categories with in-card add buttons that morph into quantity steppers
- **Cart** — per-line quantities, substitution preference (best match / refund / call me), delivery-slot picker with per-slot fees
- **Live totals** — items + delivery recalculating on every change, cart tab badge
- **Order tracking** — four-stage timeline (received → picking → out for delivery → delivered) with simulate-update control and the chosen substitution rule surfaced at completion

## Structure

Single self-contained page: Flutter-style mobile patterns in pure HTML/CSS/JS. No frameworks, no build step.

## Author

Shai

## License

MIT

## Architecture notes

Cart, substitution prefs and slot fees share one order state; the tracking timeline replays it. Lighthouse: Performance 100 · Accessibility 86 · Best Practices 96 · SEO 100.
