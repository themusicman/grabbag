# Changelog

Changes from upstream `cursor/plugins` `pstack/skills/reflect`.

- Named where to read `pstack-models.mdc`: `~/.cursor/rules/pstack-models.mdc`, then `~/.pstack/pstack-models.mdc`.
- Added a fallback when the harness has no Cursor `Task` tool or rejects `subagent_type`.
- Skill edits now also name `.agents/skills/`, `.claude/skills/`, and `.grok/skills/` as destinations, alongside the Cursor paths.
- Reviewer prompts treat a `Read` of `SKILL.md` under those harness directories as a skill the transcript used.
