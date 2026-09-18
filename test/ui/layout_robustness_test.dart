// Renders every screen under the conditions that break layouts in the field
// — a narrow phone, a large system font, the longest of the five languages,
// a tablet — and fails on any RenderFlex overflow or build exception.
//
// The test font draws every glyph as a box as wide as the font size, which
// is wider than Outfit for Latin text. A layout that passes here has margin
// in the real app; one that fails here is at least close to failing there.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';
import '../support/page_catalog.dart';

class LayoutScenario {
  const LayoutScenario(
    this.name, {
    required this.size,
    required this.locale,
    this.textScale = 1.0,
    this.themeMode = ThemeMode.light,
  });

  final String name;
  final Size size;
  final Locale locale;
  final double textScale;
  final ThemeMode themeMode;

  @override
  String toString() => name;
}

/// What every page must survive. Ordered from the everyday case to the
/// harshest one, so the first failure in the output is the most embarrassing.
const scenarios = [
  LayoutScenario(
    'phone · en',
    size: AppHarness.phoneSize,
    locale: Locale('en'),
  ),
  LayoutScenario(
    'phone · de',
    size: AppHarness.phoneSize,
    locale: Locale('de'),
  ),
  LayoutScenario(
    'phone · fr',
    size: AppHarness.phoneSize,
    locale: Locale('fr'),
  ),
  LayoutScenario(
    'phone · it',
    size: AppHarness.phoneSize,
    locale: Locale('it'),
  ),
  LayoutScenario(
    'phone · es',
    size: AppHarness.phoneSize,
    locale: Locale('es'),
  ),
  LayoutScenario(
    'small phone · de',
    size: AppHarness.smallPhoneSize,
    locale: Locale('de'),
  ),
  LayoutScenario(
    'phone · de · large text (1.3)',
    size: AppHarness.phoneSize,
    locale: Locale('de'),
    textScale: 1.3,
  ),
  LayoutScenario(
    'tablet · en · dark',
    size: AppHarness.tabletSize,
    locale: Locale('en'),
    themeMode: ThemeMode.dark,
  ),
];

void main() {
  final app = AppHarness();
  setUpAll(app.setUpAll);
  setUp(app.setUp);
  tearDown(app.tearDown);

  for (final scenario in scenarios) {
    group(scenario.name, () {
      for (final page in allPages) {
        testWidgets(page.name, (tester) async {
          final errors = await collectFlutterErrors(() async {
            await app.pumpPage(
              tester,
              page.build(app.seeded),
              locale: scenario.locale,
              size: scenario.size,
              textScale: scenario.textScale,
              themeMode: scenario.themeMode,
            );
          });
          final thrown = tester.takeException();

          final summary = summarizeErrors(errors);
          expect(
            summary,
            isEmpty,
            reason:
                '${page.name} raised ${summary.length} distinct error(s) at '
                '${scenario.name}:\n${describeErrors(errors)}',
          );
          expect(thrown, isNull, reason: '${page.name} threw: $thrown');
        });
      }
    });
  }
}
