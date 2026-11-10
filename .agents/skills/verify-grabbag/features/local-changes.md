# Recorded local changes

A user who reads a vendored skill can tell whether grabbag changed it from upstream and how: `Modified: yes` in SOURCE.md and `"modified": true` in `sources.json` always come with a `CHANGELOG.md` that lists every change, and an unmodified skill has none.

## Sub-features

- `changelog`: `modified: true` in `sources.json` if and only if `skills/<name>/CHANGELOG.md` exists. A modified bundled agent is named in its skill's CHANGELOG.md.
- `changed-skills`: on a branch, every existing skill whose files changed since the base, with the same upstream SHA, also changed its `CHANGELOG.md` and is `modified: true`. A re-vendor (new upstream SHA) and a new skill are exempt.

## How to get to it (user POV)

- Open `skills/<name>/CHANGELOG.md`, which SOURCE.md links to with "See `CHANGELOG.md` for every change from upstream."
- Compare `Modified:` in SOURCE.md with the README upstream link.

## Driving it with check-repo.mjs

Preconditions:

- `doctor.sh` exits 0.
- `origin/main` is fetched: `git fetch origin main`.

- **Whole repo.** Run `.agents/skills/verify-grabbag/scripts/check-repo.mjs`. The `changelog` check is in `checks passed`.
- **This branch.** Run `.agents/skills/verify-grabbag/scripts/check-repo.mjs --base origin/main`. The `changed-skills` check is in `checks passed`. It reads committed, staged, unstaged, and untracked changes under `skills/`.

## Gotchas

- Editing only `SOURCE.md` or `CHANGELOG.md` does not require a CHANGELOG entry. Those are grabbag's own files.
- `changed-skills` compares with the merge base of `--base` and `HEAD`, so a stale `origin/main` can hide or invent changes. Fetch first.
- The check cannot tell whether the CHANGELOG entry describes the change. Read the entry.
