# Changelog

Changes from upstream `cursor/plugins` `pstack/skills/poteto-mode` and `pstack/agents/poteto-agent.md`.

- Vendored `poteto-agent.md` at `agents/poteto-agent.md`. The Subagents section now says to read that file when `poteto-agent` is not an installed agent type.
- Added a fallback when the harness has no Cursor `Task` tool or rejects `subagent_type`.
- `agents/poteto-agent.md` reads `../SKILL.md` relative to itself before searching `~/.cursor/plugins/`. The plugin search remains the fallback when the relative file is absent.
- `deslop`, `control-cli`, and `control-ui` are sibling skills in this repo. References that named the `cursor-team-kit` plugin now point at `../<name>/SKILL.md` from this file, and at `../../<name>/SKILL.md` from a playbook.
- `playbooks/babysit.md` and `playbooks/shipping.md` locate the `watch-pr` watcher relative to the poteto-mode skill directory instead of the project root, note that it needs Bun, and give a `gh` fallback when Bun is missing.
