import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cidpbuddy/l10n/generated/app_localizations.dart';

/// Holds the user's language choice and persists it across launches.
///
/// A null [locale] means "follow the system language"; [MaterialApp] then
/// resolves the device locale against [AppLocalizations.supportedLocales] and
/// falls back to English when the device speaks a language we don't ship.
class LocaleProvider extends ChangeNotifier {
  static const String prefsKey = 'app_locale';

  Locale? _locale;

  Locale? get locale => _locale;

  /// True while the app follows the device language instead of an explicit
  /// choice made in the settings screen.
  bool get followsSystem => _locale == null;

  /// Reads the stored choice. Called before `runApp` so the first frame
  /// already renders in the right language — no flash of the wrong locale.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(prefsKey);
      if (code != null && code.isNotEmpty) {
        _locale = _parse(code);
      }
    } catch (e) {
      debugPrint('LocaleProvider.load failed: $e');
    }
  }

  /// Stores [locale], or clears the choice when null ("follow system").
  Future<void> setLocale(Locale? locale) async {
    if (locale?.languageCode == _locale?.languageCode) return;
    _locale = locale;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (locale == null) {
        await prefs.remove(prefsKey);
      } else {
        await prefs.setString(prefsKey, locale.languageCode);
      }
    } catch (e) {
      debugPrint('LocaleProvider.setLocale failed: $e');
    }
  }

  /// Resolves the locale that background isolates (notifications, workers)
  /// should use. They have no [BuildContext], so they cannot read the widget
  /// tree and must repeat the resolution [MaterialApp] does for the UI.
  static Future<Locale> resolveForBackground() async {
    String? stored;
    try {
      final prefs = await SharedPreferences.getInstance();
      stored = prefs.getString(prefsKey);
    } catch (e) {
      debugPrint('LocaleProvider.resolveForBackground failed: $e');
    }
    if (stored != null && stored.isNotEmpty) {
      final parsed = _parse(stored);
      if (_isSupported(parsed)) return parsed;
    }
    // PlatformDispatcher rather than WidgetsBinding: background isolates
    // never run `ensureInitialized`, so the binding may not exist here.
    final system = PlatformDispatcher.instance.locale;
    if (_isSupported(system)) return Locale(system.languageCode);
    return const Locale('en');
  }

  /// The translated strings for an isolate that has no widget tree — used by
  /// the notification service, the background timer and the backup worker.
  static Future<AppLocalizations> l10nForBackground() async {
    final locale = await resolveForBackground();
    // Notification bodies format dates, and outside the widget tree nothing
    // else loads intl's locale data for us.
    await initializeDateFormatting(locale.languageCode);
    return lookupAppLocalizations(locale);
  }

  static bool _isSupported(Locale locale) => AppLocalizations.supportedLocales
      .any((l) => l.languageCode == locale.languageCode);

  static Locale _parse(String code) {
    final parts = code.split(RegExp(r'[_-]'));
    return parts.length > 1 ? Locale(parts[0], parts[1]) : Locale(parts[0]);
  }
}
