import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cidpbuddy/l10n/generated/app_localizations.dart';

void main() {
  group('localization', () {
    test('every shipped locale is reachable', () {
      expect(
        AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet(),
        {'en', 'de', 'fr', 'it', 'es'},
      );
    });

    test('lookup returns the right language for each locale', () {
      expect(lookupAppLocalizations(const Locale('en')).navSettings, 'Settings');
      expect(lookupAppLocalizations(const Locale('de')).navSettings, 'Einstellungen');
      expect(lookupAppLocalizations(const Locale('fr')).navSettings, 'Réglages');
      expect(lookupAppLocalizations(const Locale('it')).navSettings, 'Impostazioni');
      expect(lookupAppLocalizations(const Locale('es')).navSettings, 'Ajustes');
    });

    test('placeholders are substituted, not left as literals', () {
      final l10n = lookupAppLocalizations(const Locale('en'));
      expect(l10n.dashboardMarkedDone('Hyqvia'), 'Hyqvia done!');
      expect(l10n.frequencyEveryNDays(5), 'Every 5 days');
      expect(l10n.doseValue('10.0', 'ml'), contains('10.0 ml'));
    });

    testWidgets('widgets render in the locale MaterialApp is given',
        (WidgetTester tester) async {
      for (final entry in {
        'en': 'Settings',
        'de': 'Einstellungen',
        'fr': 'Réglages',
        'it': 'Impostazioni',
        'es': 'Ajustes',
      }.entries) {
        await tester.pumpWidget(MaterialApp(
          locale: Locale(entry.key),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Text(AppLocalizations.of(context).navSettings),
          ),
        ));
        expect(find.text(entry.value), findsOneWidget,
            reason: 'locale ${entry.key} should render "${entry.value}"');
      }
    });
  });
}
