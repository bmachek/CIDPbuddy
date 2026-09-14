import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'package:cidpbuddy/l10n/generated/app_localizations.dart';

/// Shorthand for the two things nearly every localized widget needs.
extension L10nContext on BuildContext {
  /// The translated strings for the locale this subtree renders in.
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// The locale tag to hand to [DateFormat] and [NumberFormat] so numbers and
  /// dates follow the same language as the surrounding text.
  String get localeTag => Localizations.localeOf(this).toLanguageTag();
}

/// Locale-aware replacements for the date patterns this app used to hard-code.
///
/// The old patterns (`dd.MM.yyyy`, `HH:mm`) were German conventions baked into
/// the widgets. Every helper here asks [DateFormat] for the *skeleton* instead,
/// so an English user sees `9/14/2026, 2:30 PM` while a German one still sees
/// `14.09.2026, 14:30` — from one call site.
class AppDateFormat {
  const AppDateFormat._();

  /// Numeric date: `14.09.2026` / `9/14/2026`.
  static String date(BuildContext context, DateTime value) =>
      DateFormat.yMd(context.localeTag).format(value);

  /// Numeric date and time: `14.09.2026, 14:30` / `9/14/2026, 2:30 PM`.
  static String dateTime(BuildContext context, DateTime value) =>
      DateFormat.yMd(context.localeTag).add_jm().format(value);

  /// Long date: `14. September 2026` / `September 14, 2026`.
  static String longDate(BuildContext context, DateTime value) =>
      DateFormat.yMMMMd(context.localeTag).format(value);

  /// Time of day: `14:30` / `2:30 PM`.
  static String time(BuildContext context, DateTime value) =>
      DateFormat.jm(context.localeTag).format(value);

  /// Day and month without the year: `14.09.` / `9/14`.
  static String dayMonth(BuildContext context, DateTime value) =>
      DateFormat.Md(context.localeTag).format(value);

  /// Day, month and time — used where the year is obvious from context.
  static String dayMonthTime(BuildContext context, DateTime value) =>
      DateFormat.Md(context.localeTag).add_jm().format(value);

  /// Weekday headline: `Montag, 14. September` / `Monday, September 14`.
  static String weekdayLongDate(BuildContext context, DateTime value) =>
      DateFormat.MMMMEEEEd(context.localeTag).format(value);

  /// Compact month label for chart axes: `09/26`.
  static String monthAxis(BuildContext context, DateTime value) =>
      DateFormat('MM/yy', context.localeTag).format(value);

  /// Same as [dayMonthTime] but for isolates that have no [BuildContext].
  static String dayMonthTimeIn(String localeTag, DateTime value) =>
      DateFormat.Md(localeTag).add_jm().format(value);

  /// Same as [time] but for isolates that have no [BuildContext].
  static String timeIn(String localeTag, DateTime value) =>
      DateFormat.jm(localeTag).format(value);

  /// Same as [date] but for isolates that have no [BuildContext].
  static String dateIn(String localeTag, DateTime value) =>
      DateFormat.yMd(localeTag).format(value);
}
