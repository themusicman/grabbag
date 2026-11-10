#!/bin/sh
# Model-check the statechart verdict loop with TLC.
# Usage: check.sh [MODEL_DIR]
#   MODEL_DIR defaults to this skill's model/ folder. Pass a scratch copy to
#   check an edited model without touching the committed one.
# Exit 0: every invariant and Terminates hold. Exit 1: TLC found a violation
# or could not run. TLC's full output is saved in $OUT (printed at the end).
set -eu

skill=$(cd "$(dirname "$0")/.." && pwd)
repo=$(git -C "$skill" rev-parse --show-toplevel)
model=$(cd "${1:-$skill/model}" && pwd)

TLC_VERSION=1.7.4
TLC_SHA256=936a262061c914694dfd669a543be24573c45d5aa0ff20a8b96b23d01e050e88
cache=${XDG_CACHE_HOME:-$HOME/.cache}/grabbag-formal
jar=$cache/tla2tools-$TLC_VERSION.jar

sha() { if command -v sha256sum >/dev/null; then sha256sum "$1"; else shasum -a 256 "$1"; fi | cut -d' ' -f1; }

if [ ! -f "$jar" ] || [ "$(sha "$jar")" != "$TLC_SHA256" ]; then
  mkdir -p "$cache"
  echo "Downloading tla2tools.jar $TLC_VERSION to $jar" >&2
  curl -fsSL -o "$jar.part" "https://github.com/tlaplus/tlaplus/releases/download/v$TLC_VERSION/tla2tools.jar"
  [ "$(sha "$jar.part")" = "$TLC_SHA256" ] || { echo "tla2tools.jar checksum mismatch" >&2; rm -f "$jar.part"; exit 1; }
  mv "$jar.part" "$jar"
fi

java_ok() { "$1" -version 2>&1 | sed -n '1s/.*version "\([0-9]*\).*/\1/p' | awk '{ exit !($1 >= 11) }'; }
if [ -n "${JAVA:-}" ]; then
  set -- "$JAVA"
elif command -v java >/dev/null && java_ok java; then
  set -- java
elif command -v mise >/dev/null; then
  set -- mise exec java@temurin-21 -- java
else
  echo "Need Java 11 or later: set JAVA, put java on PATH, or install mise." >&2
  exit 1
fi

# Coverage record: warn when covered code changed after the sync commit.
sync=$(sed -n 's/^Sync commit: `\([0-9a-f]*\)`.*/\1/p' "$skill/SKILL.md")
covered=$(grep -o '^| `skills/[^`]*`' "$skill/SKILL.md" | tr -d '|` ' | sort -u)
# shellcheck disable=SC2086
changed=$(git -C "$repo" diff --name-only "$sync" -- $covered 2>/dev/null || echo "(cannot diff against $sync)")
if [ -n "$changed" ]; then
  echo "WARNING: covered code changed since sync commit $sync:" >&2
  echo "$changed" | sed 's/^/  /' >&2
  echo "The model may no longer describe the code. See 'When the code changes' in SKILL.md." >&2
fi

OUT=${OUT:-$(mktemp -d "${TMPDIR:-/tmp}/statechart-verdicts.XXXXXX")}
mkdir -p "$OUT"
start=$(date +%s)
set +e
(cd "$model" && "$@" -XX:+UseParallelGC -cp "$jar" tlc2.TLC \
  -workers auto -coverage 60 -metadir "$OUT/states" -config StatechartVerdicts.cfg StatechartVerdicts.tla) >"$OUT/tlc.out" 2>&1
status=$?
set -e
if [ "$status" -eq 0 ]; then
  grep -E 'distinct states found|No error has been found' "$OUT/tlc.out" || true
else
  # The violation and its whole trace, without TLC's progress and coverage lines.
  sed -n '/^Error:/,$p' "$OUT/tlc.out" | grep -vE '^(Progress|<|Starting|Checking|Finished computing|The coverage|End of statistics)|^ *\|' || true
fi
echo "TLC exit $status in $(( $(date +%s) - start ))s. Full output: $OUT/tlc.out"
# A branch that never runs checks nothing. Fail when a Next action never fires.
dead=$(sed -n 's/^<\([A-Za-z]*\) line .*>: [0-9]*:0$/\1/p' "$OUT/tlc.out")
if [ "$status" -eq 0 ] && [ -n "$dead" ]; then
  echo "FAIL: these actions never fire, so the model does not exercise them: $dead"
  exit 1
fi
[ "$status" -eq 0 ] && echo "PASS" || { echo "FAIL"; exit 1; }
