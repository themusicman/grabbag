# Changelog

Changes from upstream `cursor/plugins` `pstack/skills/statechart`.

- Removed `scripts/test/` (unit tests and the TLC corpus). Those files are not used when `scripts/statechart` runs.
- Removed the `test` npm script and the `fast-check` devDependency from `scripts/package.json`. They existed only for that corpus.
- `scripts/statechart` is unchanged. Run it from this skill directory, as the skill describes.
