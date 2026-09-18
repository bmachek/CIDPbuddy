# Test fonts

Roboto (Regular, Medium, Bold), copied from the Flutter SDK's material
fonts. Copyright Google Inc., licensed under the Apache License 2.0 — the
same license as this repository; the font's own notice is `LICENSE.txt` here.

The widget tests load these under the family names `Outfit` and `Roboto`
(see `test/support/app_harness.dart`). Without a real font, Flutter's test
binding draws every glyph as a box as wide as the font size, which makes
overflow checks pessimistic and trips the contrast guideline on the
anti-aliased box edges. Roboto's metrics are close to Outfit's, so what
passes here passes on a device.
