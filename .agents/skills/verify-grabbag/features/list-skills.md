# List the skills

A user runs `npx skills add themusicman/grabbag --list` and sees every published skill with its description, and only those. Today that is 64 skills, one for each `skills/<name>/` folder.

## Sub-features

- `list-names` lists exactly the `skills/<name>/` folders.
- `list-count` reports "Found N skills", where N is the folder count.
- `list-hidden` hides project-local skills under `.agents/skills/`, `.claude/skills/`, and `.grok/skills/` that set `metadata.internal: true`.

## How to get to it (user POV)

- Run `npx skills add themusicman/grabbag --list` in a terminal.
- Run `npx skills add themusicman/grabbag` with no flags. The CLI shows the same list as a picker before it installs.

## Driving it with drive.sh

Preconditions:

- `doctor.sh` exits 0.

- **Checkout list.** List the working tree. Run `.agents/skills/verify-grabbag/scripts/drive.sh list`. Output says `Found 64 skills; parsed 64 names; skills/ has 64 folders`, then `listed names match skills/<name>/ folders` and `PASS`.
- **Published list.** List what GitHub serves. Run `.agents/skills/verify-grabbag/scripts/drive.sh list themusicman/grabbag`. Same result for the pushed default branch.
- **Hidden local skills.** Confirm the generated skills stay out. In the evidence directory, `listed.txt` contains neither `verify-grabbag` nor `formal-statechart-verdicts`.

## Gotchas

- The CLI scans hidden agent directories too. A project-local skill without `metadata.internal: true` raises the count.
- `--json` cannot be combined with `--list` in CLI 1.7.6. `drive.sh` parses the plain output instead.
- The CLI warns "Skipped ... missing required frontmatter" for a SKILL.md it cannot read, and the count drops. Check `list.txt` for `Skipped`.
- `INSTALL_INTERNAL_SKILLS=1` in the environment makes the CLI show internal skills. Unset it before you trust the count.
