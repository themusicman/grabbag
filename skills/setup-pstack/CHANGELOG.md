# Changelog

Changes from upstream `cursor/plugins` `pstack/skills/setup-pstack`.

- Writes the same rule body to `~/.cursor/rules/pstack-models.mdc` and `~/.pstack/pstack-models.mdc`. On a re-run, the Cursor file is read first, then the `~/.pstack` file.
- If the harness has no Task subagent, ask the user which model slugs they can select.
- If AskQuestion is unavailable, ask in the conversation with the same options.
