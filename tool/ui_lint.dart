// Static UI-quality checks that the Dart analyzer cannot express.
//
//   dart run tool/ui_lint.dart            # check lib/
//   dart run tool/ui_lint.dart --explain  # also print what each rule guards
//
// Every rule encodes something the accessibility or layout test suites can
// only catch after the fact, or not at all (a tooltip on a button no test
// taps, a colour that is unreadable in dark mode). Exit code 1 on any hit,
// so `tool/verify.sh` — and therefore CI — fails.
//
// Suppress a single line with a trailing `// ui-lint: allow <rule>` comment
// when the rule is wrong for that line; say why in the same comment.

import 'dart:io';

/// One rule: a name, what it guards, and a scanner returning hits.
class Rule {
  const Rule(this.name, this.rationale, this.scan);

  final String name;
  final String rationale;
  final List<Hit> Function(SourceFile file) scan;
}

class Hit {
  const Hit(this.file, this.line, this.rule, this.message);

  final String file;
  final int line;
  final String rule;
  final String message;

  @override
  String toString() => '$file:$line • $rule • $message';
}

class SourceFile {
  SourceFile(this.path, this.text) : lines = text.split('\n');

  final String path;
  final String text;
  final List<String> lines;

  /// Whether the given 1-based line opts out of [rule].
  bool allows(int line, String rule) =>
      lines[line - 1].contains('ui-lint: allow $rule');

  int lineOf(int offset) =>
      '\n'.allMatches(text.substring(0, offset)).length + 1;

  /// The argument list starting at the `(` at [open], or null when it does
  /// not close within the file (which would not compile anyway).
  String? argumentList(int open) {
    var depth = 0;
    for (var i = open; i < text.length; i++) {
      final c = text[i];
      if (c == '(') depth++;
      if (c == ')') {
        depth--;
        if (depth == 0) return text.substring(open + 1, i);
      }
    }
    return null;
  }
}

/// Files under the UI layer: pages, widgets, the shell. The rules that are
/// about what a patient sees only apply here.
bool isUiFile(String path) =>
    path.startsWith('lib/features/') && !path.contains('/services/') ||
    path == 'lib/main_screen.dart';

List<Hit> regexRule(
  SourceFile file,
  String rule,
  RegExp pattern,
  String message, {
  bool uiOnly = false,
}) {
  if (uiOnly && !isUiFile(file.path)) return const [];
  final hits = <Hit>[];
  for (final match in pattern.allMatches(file.text)) {
    final line = file.lineOf(match.start);
    if (file.allows(line, rule)) continue;
    hits.add(Hit(file.path, line, rule, message));
  }
  return hits;
}

final rules = <Rule>[
  Rule(
    'icon-button-tooltip',
    'An IconButton has no visible text; the tooltip is what a screen reader '
        'announces and what long-press shows. Without it the button is '
        '"Button" to a blind patient.',
    (file) {
      if (!isUiFile(file.path)) return const [];
      final hits = <Hit>[];
      final pattern = RegExp(
        r'\bIconButton(\.filled|\.filledTonal|\.outlined)?\(',
      );
      for (final match in pattern.allMatches(file.text)) {
        final args = file.argumentList(match.end - 1);
        if (args == null) continue;
        final line = file.lineOf(match.start);
        if (file.allows(line, 'icon-button-tooltip')) continue;
        if (!RegExp(r'\btooltip:').hasMatch(args)) {
          hits.add(
            Hit(
              file.path,
              line,
              'icon-button-tooltip',
              'IconButton without tooltip: — add one from context.l10n',
            ),
          );
        }
      }
      return hits;
    },
  ),
  Rule(
    'dead-handler',
    'A tappable control whose handler does nothing looks broken and wastes a '
        'tap that costs a motor-impaired user real effort.',
    (file) => regexRule(
      file,
      'dead-handler',
      RegExp(
        r'\b(onPressed|onTap|onChanged|onSubmitted):\s*\((\s*\w+\s*)?\)\s*\{\s*\}',
      ),
      'empty handler — wire it up or remove the control',
      uiOnly: true,
    ),
  ),
  Rule(
    'compact-icon-button',
    'VisualDensity.compact shrinks the tap target below 48 dp. CIDP affects '
        'fine motor control; adjacent edit/delete pairs become a data-loss '
        'risk.',
    (file) => regexRule(
      file,
      'compact-icon-button',
      RegExp(r'visualDensity:\s*VisualDensity\.compact'),
      'compact density on a control — keep the 48 dp target',
      uiOnly: true,
    ),
  ),
  Rule(
    'tiny-font',
    'Text below 11 logical pixels is unreadable for the low-vision share of '
        'this app\'s users, and the system font-size setting scales '
        'hierarchy, not legibility.',
    (file) => regexRule(
      file,
      'tiny-font',
      RegExp(r'fontSize:\s*(?:[0-9]|10)(?:\.\d+)?\b(?![.\d])'),
      'fontSize below 11',
      uiOnly: true,
    ),
  ),
  Rule(
    'hardcoded-palette',
    'Colors.grey / red / green / orange / blue ignore the theme: they do '
        'not adapt to dark mode and several fail WCAG contrast on the app '
        'surfaces. Use colorScheme.onSurfaceVariant, .error, .tertiary, '
        '.primary or AppTheme.warningGold.',
    (file) => regexRule(
      file,
      'hardcoded-palette',
      RegExp(r'\bColors\.(grey|red|green|orange|blue|amber|blueGrey)\b'),
      'hard-coded Material palette colour — use the theme',
      uiOnly: true,
    ),
  ),
  Rule(
    'hardcoded-text',
    'User-visible text must come from context.l10n so all five languages '
        'stay complete. Units and short labels count too.',
    (file) {
      if (!isUiFile(file.path)) return const [];
      final hits = <Hit>[];
      final slot = RegExp(
        r"""(\bText\(|\b(label|hintText|labelText|helperText|suffixText|prefixText|tooltip|semanticLabel|semanticsLabel|title|content|message):\s*(const\s+)?(Text\()?)\s*(const\s+)?(['"])((?:\\.|(?!\6).)*)\6""",
      );
      for (final match in slot.allMatches(file.text)) {
        final literal = match.group(7)!;
        // Interpolated values are data, not copy: `'$m'` is fine, `'$m min'`
        // is not.
        final copy = literal
            .replaceAll(RegExp(r'\$\{[^}]*\}'), '')
            .replaceAll(RegExp(r'\$\w+'), '');
        if (!RegExp(r'[A-Za-zÄÖÜäöüß]{2,}').hasMatch(copy)) continue;
        if (copy.startsWith('assets/')) continue;
        final line = file.lineOf(match.start);
        if (file.allows(line, 'hardcoded-text')) continue;
        hits.add(
          Hit(
            file.path,
            line,
            'hardcoded-text',
            'string literal with letters in a user-visible slot — use context.l10n',
          ),
        );
      }
      return hits;
    },
  ),
  Rule(
    'date-format-literal',
    'A literal DateFormat pattern bakes one locale\'s convention into every '
        'language. AppDateFormat has skeleton-based helpers.',
    (file) {
      if (file.path == 'lib/core/l10n/l10n_ext.dart') return const [];
      return regexRule(
        file,
        'date-format-literal',
        RegExp(r'''DateFormat\(\s*['"]'''),
        'literal DateFormat pattern — use AppDateFormat',
        uiOnly: true,
      );
    },
  ),
  Rule(
    'deprecated-opacity',
    'Color.withOpacity is deprecated; withValues(alpha:) is the replacement.',
    (file) => regexRule(
      file,
      'deprecated-opacity',
      RegExp(r'\.withOpacity\('),
      'withOpacity — use withValues(alpha: …)',
    ),
  ),
  Rule(
    'const-of-context',
    'Theme.of / MediaQuery.of are not constant expressions.',
    (file) => regexRule(
      file,
      'const-of-context',
      RegExp(r'\bconst\s+(Theme|MediaQuery)\.of\('),
      'const applied to an .of(context) lookup',
    ),
  ),
  Rule(
    'print',
    'print() ends up in release logs; debugPrint is stripped and throttled.',
    (file) => regexRule(
      file,
      'print',
      RegExp(r'(^|[^A-Za-z_.])print\('),
      'print — use debugPrint',
    ),
  ),
];

void main(List<String> args) {
  final explain = args.contains('--explain');
  final root = Directory('lib');
  if (!root.existsSync()) {
    stderr.writeln('run from the repository root');
    exit(2);
  }

  final files =
      root
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .where((f) => !f.path.endsWith('.g.dart'))
          .where((f) => !f.path.contains('/l10n/generated/'))
          .map((f) => SourceFile(f.path, f.readAsStringSync()))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  final hits = <Hit>[];
  for (final file in files) {
    for (final rule in rules) {
      hits.addAll(rule.scan(file));
    }
  }
  hits.sort((a, b) {
    final byFile = a.file.compareTo(b.file);
    return byFile != 0 ? byFile : a.line.compareTo(b.line);
  });

  for (final hit in hits) {
    stdout.writeln(hit);
  }

  final counts = <String, int>{};
  for (final hit in hits) {
    counts.update(hit.rule, (n) => n + 1, ifAbsent: () => 1);
  }
  if (hits.isEmpty) {
    stdout.writeln('ui-lint: no findings in ${files.length} files.');
  } else {
    stdout.writeln();
    stdout.writeln('ui-lint: ${hits.length} finding(s):');
    for (final entry in counts.entries) {
      stdout.writeln('  ${entry.value.toString().padLeft(4)}  ${entry.key}');
    }
  }
  if (explain) {
    stdout.writeln();
    for (final rule in rules) {
      stdout.writeln('${rule.name}: ${rule.rationale}');
    }
  }
  exit(hits.isEmpty ? 0 : 1);
}
