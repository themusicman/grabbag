# grabbag verification map

This directory is the maintained source for verifying what grabbag users see. Read the index before driving, then use the matching feature file as the recipe.

## Baseline preconditions

- A grabbag checkout with `skills/` and `sources.json`. `doctor.sh` exits 0.
- Network access to the npm registry for the first `npx -y skills@1.7.6` call.
- To verify the published repo, the change is pushed and the source is `themusicman/grabbag`. Otherwise the source is this checkout.

## Driving conventions

- Run every helper from inside the checkout. Paths are relative to the repo root.
- Run `doctor.sh` first.
- Always use `skills@1.7.6` through the helpers. Do not call a global `skills` binary.
- Run `check-repo.mjs` with `--base origin/main` on a branch.
- Never install into the checkout itself. `drive.sh install` creates its own scratch project.

## Proof and skip reporting

- CLI proof is the evidence directory that `drive.sh` prints: the command, its exit code, the plain output, and the comparison files.
- Metadata proof is the full stdout of `check-repo.mjs`.
- Name the feature and the entry point with every piece of evidence.
- When a path cannot be driven, such as the GitHub source before a push, report the command you tried and why it could not run. Do not count a checkout run as proof of the published repo.

## Feature entry contract

Each feature file starts with an H1 title and one paragraph describing what the user sees. It then has exactly four H2 sections in this order: `Sub-features`, `How to get to it (user POV)`, `Driving it with <harness>`, and `Gotchas`. The driving section starts with `Preconditions:` and pairs each user action with an exact command and the observable result.

## Features

- [List the skills](./list-skills.md): what `npx skills add themusicman/grabbag --list` shows.
- [Install a skill](./install-skill.md): one skill, copied into a project for one agent, byte for byte.
- [Provenance metadata](./provenance.md): SKILL.md, SOURCE.md, sources.json, README tables, and NOTICE agree.
- [Recorded local changes](./local-changes.md): every grabbag edit to a vendored skill is in its CHANGELOG.md.
