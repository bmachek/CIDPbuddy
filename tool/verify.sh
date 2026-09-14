#!/usr/bin/env bash
#
# Verify the project the way CI does: generated code is current, the formatting
# matches `dart format`, the analyzer is clean, every user-visible string is
# translated, and the tests pass.
#
#   tool/verify.sh                  # local run
#   tool/verify.sh --check-generated  # also fail if generated code is stale
#
# Noisy sub-command output is captured and only printed when a step fails, so
# the summary stays readable (and cheap to feed to an agent).

set -euo pipefail

cd "$(dirname "$0")/.."

FLUTTER="${FLUTTER_BIN:-}"
if [[ -z "$FLUTTER" ]]; then
  FLUTTER="$(command -v flutter || true)"
fi
if [[ -z "$FLUTTER" && -x /opt/homebrew/bin/flutter ]]; then
  FLUTTER=/opt/homebrew/bin/flutter
fi
if [[ -z "$FLUTTER" ]]; then
  echo "error: flutter not found on PATH (set FLUTTER_BIN to override)" >&2
  exit 1
fi
DART="$(dirname "$FLUTTER")/dart"

CHECK_GENERATED=0
[[ "${CI:-}" == "true" ]] && CHECK_GENERATED=1
for arg in "$@"; do
  case "$arg" in
    --check-generated) CHECK_GENERATED=1 ;;
    --no-check-generated) CHECK_GENERATED=0 ;;
    *) echo "error: unknown argument '$arg'" >&2; exit 2 ;;
  esac
done

LOG="$(mktemp "${TMPDIR:-/tmp}/cidpbuddy-verify.XXXXXX")"
trap 'rm -f "$LOG"' EXIT

run() { # run <description> <command...>
  local desc="$1"; shift
  printf '  %s ... ' "$desc"
  if "$@" >"$LOG" 2>&1; then
    echo "ok"
  else
    echo "FAILED"
    echo
    cat "$LOG"
    exit 1
  fi
}

fail() {
  echo "FAILED"
  echo
  echo "$1"
  exit 1
}

echo "CIDPbuddy verify ($("$FLUTTER" --version 2>/dev/null | head -1))"

run "pub get                " "$FLUTTER" pub get
run "build_runner           " "$DART" run build_runner build --delete-conflicting-outputs
run "gen-l10n               " "$FLUTTER" gen-l10n

printf '  %s ... ' "translations complete  "
UNTRANSLATED="$(cat l10n-untranslated.json 2>/dev/null || echo '{}')"
if [[ "$(echo "$UNTRANSLATED" | tr -d '[:space:]')" == "{}" ]]; then
  echo "ok"
else
  fail "Untranslated messages (see l10n-untranslated.json):
$UNTRANSLATED

Add the missing keys to lib/l10n/app_de.arb, app_fr.arb, app_it.arb and
app_es.arb, then run 'flutter gen-l10n'."
fi

if [[ "$CHECK_GENERATED" == "1" ]]; then
  printf '  %s ... ' "generated code current "
  if git diff --quiet -- 'lib/l10n/generated' '*.g.dart'; then
    echo "ok"
  else
    fail "Generated code is out of date. Run:

  dart run build_runner build --delete-conflicting-outputs
  flutter gen-l10n

and commit the result.

$(git --no-pager diff --stat -- 'lib/l10n/generated' '*.g.dart')"
  fi
fi

printf '  %s ... ' "formatting             "
if git ls-files -z '*.dart' | xargs -0 "$DART" format --output=none --set-exit-if-changed >"$LOG" 2>&1; then
  echo "ok"
else
  fail "$(grep '^Changed ' "$LOG" || cat "$LOG")

Run 'dart format .' (or format just the files above) and commit the result."
fi

run "analyze                " "$FLUTTER" analyze --fatal-infos
run "test                   " "$FLUTTER" test

echo
echo "All checks passed."
