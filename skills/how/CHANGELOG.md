# Changelog

Changes from upstream `cursor/plugins` `pstack/skills/how`.

- Named where to read `pstack-models.mdc`: `~/.cursor/rules/pstack-models.mdc`, then `~/.pstack/pstack-models.mdc`. Cursor injects the first file. Other harnesses can read either file. The skill already used its defaults when the rule was missing.
- Added a fallback when the harness has no Cursor `Task` tool or rejects `subagent_type`. Do the same work in the current session, or with that harness's subagent tool, and ignore Cursor-only fields.
