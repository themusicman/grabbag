# Changelog

Changes from upstream `cursor/plugins` `pstack/skills/swarm`.

- The `swarm workers` line is read from `~/.cursor/rules/pstack-models.mdc`, then from `~/.pstack/pstack-models.mdc` when the Cursor path is missing.
- Added a fallback when the harness has no Cursor `Task` tool or rejects `subagent_type`. Cursor-only fields such as `environment` are ignored in that fallback.
