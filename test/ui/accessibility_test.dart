// Runs Flutter's built-in accessibility guidelines over every screen in both
// themes:
//
//  * androidTapTargetGuideline — every tappable node is at least 48×48 dp.
//    CIDP affects fine motor control, so this is the guideline that matters
//    most for this app's users.
//  * labeledTapTargetGuideline — every tappable node has a label a screen
//    reader can announce (icon-only buttons need a tooltip).
//  * textContrastGuideline — text meets WCAG AA contrast against what is
//    actually drawn behind it.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';
import '../support/page_catalog.dart';

void main() {
  final app = AppHarness();
  setUpAll(app.setUpAll);
  setUp(app.setUp);
  tearDown(app.tearDown);

  for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
    group(themeMode.name, () {
      for (final page in allPages) {
        testWidgets(page.name, (tester) async {
          // Semantics must be on before the first frame, and the handle has
          // to be released before the test body returns — the framework
          // checks for leaked handles before any `addTearDown` runs.
          final semantics = tester.ensureSemantics();
          try {
            await app.pumpPage(
              tester,
              page.build(app.seeded),
              locale: const Locale('de'),
              themeMode: themeMode,
            );

            await expectLater(
              tester,
              meetsGuideline(androidTapTargetGuideline),
            );
            await expectLater(
              tester,
              meetsGuideline(labeledTapTargetGuideline),
            );
            await expectLater(tester, meetsGuideline(textContrastGuideline));
          } finally {
            semantics.dispose();
            await app.unmount(tester);
          }
        });
      }
    });
  }
}
