# Changelog

Changes from upstream `cursor/plugins` `pstack/skills/why`.

- Named where to read `pstack-models.mdc`: `~/.cursor/rules/pstack-models.mdc`, then `~/.pstack/pstack-models.mdc`.
- Added a fallback when the harness has no Cursor `Task` tool or rejects `subagent_type`.
- If the session has no Cursor `mcps/` directory, use the tools already available and record evidence categories that have no source.
