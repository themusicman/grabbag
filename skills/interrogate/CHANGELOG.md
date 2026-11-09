# Changelog

Changes from upstream `cursor/plugins` `pstack/skills/interrogate`.

- The `interrogate reviewers` line is read from `~/.cursor/rules/pstack-models.mdc`, then from `~/.pstack/pstack-models.mdc`.
- Added a fallback when the harness has no Cursor `Task` tool or rejects `subagent_type` for the `generalPurpose` adversaries.
