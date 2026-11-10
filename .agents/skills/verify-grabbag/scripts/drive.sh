#!/bin/sh
# Drive grabbag the way a user does: through the skills CLI.
# Usage:
#   drive.sh list [SOURCE]                 list the skills SOURCE publishes
#   drive.sh install SKILL [AGENT] [SOURCE] install SKILL for AGENT (default amp)
#                                           into a scratch project and compare it
# SOURCE defaults to this checkout. Pass themusicman/grabbag for the published repo.
# Evidence goes to $VERIFY_GRABBAG_OUT/<UTC time>-<command>[-SKILL]/ (default
# /tmp/verify-grabbag) and survives cleanup. Exit 0 when the proof holds.
set -eu

SKILLS_CLI=skills@1.7.6
repo=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
cmd=${1:?usage: drive.sh list [SOURCE] | install SKILL [AGENT] [SOURCE]}
shift

case $cmd in
  list) source=${1:-$repo}; tag=list ;;
  install) skill=${1:?install needs a skill name}; agent=${2:-amp}; source=${3:-$repo}; tag=install-$skill-$agent ;;
  *) echo "unknown command: $cmd" >&2; exit 2 ;;
esac

out=${VERIFY_GRABBAG_OUT:-/tmp/verify-grabbag}/$(date -u +%Y%m%dT%H%M%SZ)-$tag
mkdir -p "$out"
plain() { sed 's/\x1b\[[0-9;?]*[a-zA-Z]//g; s/\x1b\[[0-9]*G//g'; }
expected() { find "$repo/skills" -mindepth 2 -maxdepth 2 -name SKILL.md | awk -F/ '{print $(NF-1)}' | sort; }
{ echo "source: $source"; echo "cli: $SKILLS_CLI"; echo "commit: $(git -C "$repo" rev-parse HEAD)"; } >"$out/run.txt"

if [ "$cmd" = list ]; then
  set -- npx -y "$SKILLS_CLI" add "$source" --list
  echo "command: $*" >>"$out/run.txt"
  status=0; "$@" >"$out/list.raw" 2>&1 || status=$?
  echo "exit: $status" >>"$out/run.txt"
  plain <"$out/list.raw" >"$out/list.txt"
  # Skill names are the lines indented exactly four spaces after the bar.
  sed -n 's/^│    \([a-z0-9][a-z0-9-]*\)$/\1/p' "$out/list.txt" | sort >"$out/listed.txt"
  found=$(sed -n 's/.*Found \([0-9]*\) skills.*/\1/p' "$out/list.txt" | tail -1)
  expected >"$out/expected.txt"
  diff -u "$out/expected.txt" "$out/listed.txt" >"$out/names.diff" && same=yes || same=no
  echo "CLI says: Found ${found:-?} skills; parsed $(wc -l <"$out/listed.txt") names; skills/ has $(wc -l <"$out/expected.txt") folders"
  [ "$same" = yes ] && echo "listed names match skills/<name>/ folders" || { echo "listed names differ from skills/ folders:"; cat "$out/names.diff"; }
  echo "evidence: $out"
  [ "$status" -eq 0 ] && [ "$same" = yes ] && [ "${found:-0}" -eq "$(wc -l <"$out/expected.txt")" ] && echo PASS && exit 0
  echo FAIL; exit 1
fi

project=$(mktemp -d "${TMPDIR:-/tmp}/grabbag-install.XXXXXX")
trap 'rm -rf "$project"' EXIT INT TERM
git -C "$project" init -q
set -- npx -y "$SKILLS_CLI" add "$source" --skill "$skill" -a "$agent" -y --copy
echo "command: (cd <scratch project> && $*)" >>"$out/run.txt"
status=0; (cd "$project" && "$@") >"$out/install.raw" 2>&1 || status=$?
echo "exit: $status" >>"$out/run.txt"
plain <"$out/install.raw" >"$out/install.txt"
dest=$(sed -n 's/^│ *→ \(\.\/[^ ]*\) *│$/\1/p' "$out/install.txt" | head -1)
(cd "$project" && find . -path ./.git -prune -o -type f -print | sort) >"$out/project-files.txt"
[ -f "$project/skills-lock.json" ] && cp "$project/skills-lock.json" "$out/"
ok=yes
if [ -z "$dest" ] || [ ! -d "$project/$dest" ]; then
  echo "the CLI did not report an installed directory"; ok=no
else
  echo "installed to $dest"
  diff -r "$repo/skills/$skill" "$project/$dest" >"$out/content.diff" || { echo "installed files differ from skills/$skill:"; cat "$out/content.diff"; ok=no; }
  (cd "$repo/skills/$skill" && find . -type f -perm -u+x | sort) >"$out/exec-src.txt"
  (cd "$project/$dest" && find . -type f -perm -u+x | sort) >"$out/exec-installed.txt"
  diff -u "$out/exec-src.txt" "$out/exec-installed.txt" >"$out/exec.diff" || { echo "executable bits differ:"; cat "$out/exec.diff"; ok=no; }
  [ "$ok" = yes ] && echo "installed tree matches skills/$skill, $(wc -l <"$out/exec-src.txt") executable file(s) kept executable"
fi
echo "evidence: $out"
[ "$status" -eq 0 ] && [ "$ok" = yes ] && echo PASS && exit 0
echo FAIL; exit 1
