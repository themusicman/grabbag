#!/bin/sh
# Read-only: is this checkout and toolchain fit to verify? Exit 0 when yes.
set -u
ok=0
say() { printf '%-8s %s\n' "$1" "$2"; }
repo=$(git -C "$(dirname "$0")" rev-parse --show-toplevel 2>/dev/null) || { say FAIL "not inside a git checkout"; exit 1; }
if [ -f "$repo/sources.json" ] && [ -d "$repo/skills" ]; then say ok "grabbag checkout: $repo ($(git -C "$repo" rev-parse --short HEAD) on $(git -C "$repo" branch --show-current))"; else say FAIL "$repo has no sources.json or skills/"; ok=1; fi
if command -v node >/dev/null; then
  major=$(node -p 'process.versions.node.split(".")[0]')
  [ "$major" -ge 18 ] && say ok "node $(node --version)" || { say FAIL "node $(node --version) is older than 18"; ok=1; }
else say FAIL "node is not on PATH"; ok=1; fi
v=$(npx -y skills@1.7.6 --version 2>/dev/null | tail -1)
[ "$v" = 1.7.6 ] && say ok "skills CLI $v (npx skills@1.7.6)" || { say FAIL "npx skills@1.7.6 did not run (got '$v'); it needs the npm registry"; ok=1; }
dirty=$(git -C "$repo" status --porcelain | wc -l)
say info "$dirty uncommitted path(s); check-repo.mjs and drive.sh read the working tree"
exit $ok
