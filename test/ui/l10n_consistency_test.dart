// Cross-checks the five ARB files against each other. `flutter gen-l10n`
// only reports keys that are missing entirely; these checks catch the
// mistakes that still compile: a placeholder dropped or renamed in one
// translation, an empty string, an ICU plural missing its `other` branch,
// and metadata gaps in the template.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const template = 'en';
const translations = ['de', 'fr', 'it', 'es'];

Map<String, dynamic> readArb(String code) =>
    jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync())
        as Map<String, dynamic>;

Iterable<String> messageKeys(Map<String, dynamic> arb) =>
    arb.keys.where((k) => !k.startsWith('@'));

final placeholderPattern = RegExp(r'\{([a-zA-Z0-9_]+)(?:[,}])');

Set<String> placeholdersIn(String message) =>
    placeholderPattern.allMatches(message).map((m) => m.group(1)!).toSet();

void main() {
  final en = readArb(template);
  final others = {for (final code in translations) code: readArb(code)};

  test('every message in the template has a description', () {
    final missing = messageKeys(en).where((key) {
      final meta = en['@$key'];
      return meta is! Map || (meta['description'] as String? ?? '').isEmpty;
    }).toList();
    expect(
      missing,
      isEmpty,
      reason: 'Add an @key entry with a description for: $missing',
    );
  });

  test('no translation carries keys the template does not have', () {
    final templateKeys = messageKeys(en).toSet();
    for (final entry in others.entries) {
      final orphans = messageKeys(
        entry.value,
      ).where((k) => !templateKeys.contains(k)).toList();
      expect(
        orphans,
        isEmpty,
        reason:
            'app_${entry.key}.arb has keys that app_en.arb lacks (stale '
            'after a rename?): $orphans',
      );
    }
  });

  test('no message is empty', () {
    for (final entry in {template: en, ...others}.entries) {
      final empty = messageKeys(
        entry.value,
      ).where((k) => (entry.value[k] as String).trim().isEmpty).toList();
      expect(empty, isEmpty, reason: 'app_${entry.key}.arb: $empty');
    }
  });

  test('placeholders match the template in every translation', () {
    final problems = <String>[];
    for (final key in messageKeys(en)) {
      final expected = placeholdersIn(en[key] as String);
      for (final entry in others.entries) {
        final message = entry.value[key];
        if (message is! String) continue; // gen-l10n reports missing keys
        final actual = placeholdersIn(message);
        if (actual.length != expected.length || !actual.containsAll(expected)) {
          problems.add(
            '$key (${entry.key}): expected $expected, found $actual',
          );
        }
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('declared placeholders are all used by the template message', () {
    final problems = <String>[];
    for (final key in messageKeys(en)) {
      final meta = en['@$key'];
      if (meta is! Map) continue;
      final declared = (meta['placeholders'] as Map?)?.keys.cast<String>();
      if (declared == null) continue;
      final used = placeholdersIn(en[key] as String);
      final unused = declared.where((p) => !used.contains(p)).toList();
      if (unused.isNotEmpty) problems.add('$key: unused $unused');
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('ICU plurals and selects keep an `other` branch', () {
    final icu = RegExp(r'\{\s*[a-zA-Z0-9_]+\s*,\s*(plural|select)\s*,');
    final problems = <String>[];
    for (final entry in {template: en, ...others}.entries) {
      for (final key in messageKeys(entry.value)) {
        final message = entry.value[key] as String;
        if (icu.hasMatch(message) && !message.contains('other')) {
          problems.add('$key (${entry.key})');
        }
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('translations are not left identical to English', () {
    // Short strings (units, proper nouns, "OK") are legitimately identical.
    // Anything longer that matches the template word for word was skipped.
    final suspicious = <String>[];
    for (final key in messageKeys(en)) {
      final source = en[key] as String;
      if (source.length < 16 || source.startsWith('{')) continue;
      final untouched = others.entries
          .where((e) => e.value[key] == source)
          .map((e) => e.key)
          .toList();
      if (untouched.length == translations.length) {
        suspicious.add('$key: $untouched');
      }
    }
    expect(suspicious, isEmpty, reason: suspicious.join('\n'));
  });
}
