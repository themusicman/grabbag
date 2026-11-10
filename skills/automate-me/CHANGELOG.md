# Changelog

Changes from upstream `cursor/plugins` `pstack/skills/automate-me`.

- Step 0 also searches `.agents/skills/`, `.claude/skills/`, and `.grok/skills/`, in the project and in the harness's personal skill directory. Upstream searched only `.cursor/skills/`, so an existing mode skill in another harness was missed.
- Step 1 mines the harness's own chat history for this workspace outside Cursor, and falls back to step 2 when there is none to read. Upstream read only Cursor's `agent-transcripts/`.
- Added a fallback when the harness has no Cursor `Task` tool or rejects `subagent_type`.
- Steps 0 and 2: if AskQuestion is unavailable, ask in the conversation with the same options.
- If the harness has no Cursor `create-skill`, use its own skill-authoring skill, or write a standard Agent Skills `SKILL.md`. `create-skill` is a Cursor built-in and is not in `cursor/plugins`.
- New mode skills go in the directory the active harness loads: `.agents/skills/` for Amp, OpenCode, Codex, and T3 Code; `.claude/skills/` for Claude Code; `.grok/skills/` for Grok CLI. Cursor keeps `.cursor/skills/`.
