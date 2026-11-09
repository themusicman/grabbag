# Changelog

Changes from upstream `cursor/plugins` `pstack/skills/poteto-mode` and `pstack/agents/poteto-agent.md`.

- Vendored `poteto-agent.md` at `agents/poteto-agent.md`. The Subagents section now says to read that file when `poteto-agent` is not an installed agent type.
- Added a fallback when the harness has no Cursor `Task` tool or rejects `subagent_type`.
- `agents/poteto-agent.md` reads `../SKILL.md` relative to itself before searching `~/.cursor/plugins/`. The plugin search remains the fallback when the relative file is absent.
