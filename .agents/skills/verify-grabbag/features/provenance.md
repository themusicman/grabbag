# Provenance metadata

A user can trace every skill to its upstream repo, path, and commit, and to its license, from the files grabbag ships: the README tables, `skills/<name>/SOURCE.md`, `sources.json`, and `NOTICE`. All four agree.

## Sub-features

- `skill-files`: every `skills/<name>/` has `SKILL.md` and `SOURCE.md`.
- `frontmatter`: every `SKILL.md` starts with YAML frontmatter whose `name` is the folder name and whose `description` is not empty. Without it the CLI skips the skill.
- `sources-json`: `sources.json` lists each folder once as a `skill` with `local_path: skills/<name>`, each upstream SHA is 40 hex characters, and each `agent` entry points at an existing `skills/<skill>/agents/*.md`.
- `source-md`: each SOURCE.md block (the skill's, and each `## Bundled agent` block) repeats its `sources.json` entry exactly.
- `readme`: the README `Skills` and `Agents` tables have one row per entry, linking the local path and `https://github.com/<repo>/tree|blob/<sha>/<path>`.
- `notice`: `NOTICE` has a `Skills from \`<repo>\` (\`<top dir>/\`)` section for every upstream source, and each SOURCE.md names that section's copyright holder.

## How to get to it (user POV)

- Read the `Skills` and `Agents` tables in `README.md` and follow the upstream links.
- Open `skills/<name>/SOURCE.md` in an installed skill.
- Read `sources.json` or `NOTICE` at the repo root.

## Driving it with check-repo.mjs

Preconditions:

- `doctor.sh` exits 0.

- **All invariants.** Run `.agents/skills/verify-grabbag/scripts/check-repo.mjs`. Output ends with `checks passed: ...` and `PASS`, or lists each broken invariant as `FAIL <check>: <problem>`. Today the only failures are the three `notice` lines in Gotchas.
- **Another checkout.** Run `.agents/skills/verify-grabbag/scripts/check-repo.mjs --root /path/to/checkout` to check a scratch copy.

## Gotchas

- `control-cli`, `control-ui`, and `deslop` fail `notice` on `main` at `2e3905d`: they come from `cursor-team-kit/`, whose upstream license is Copyright (c) 2026 Cursor, but `NOTICE` has only `pstack/` and tstack sections, and their SOURCE.md says Lauren Tan. Report it; do not count it as a new failure.
- Agents are not skills. They live in `skills/<skill>/agents/` and are listed in the README `Agents` table, not the `Skills` table.
- README links use `tree/` for skill folders and `blob/` for agent files.
