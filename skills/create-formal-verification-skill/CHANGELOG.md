# Changelog

Changes from upstream `cursor/plugins` `pstack/skills/create-formal-verification-skill`.

- The generated project skill is written under the directory the active harness loads: `.agents/skills/` for Amp, Cursor, OpenCode, Codex, and T3 Code; `.claude/skills/` for Claude Code; `.grok/skills/` for Grok CLI. Upstream said "project-local" and did not name a directory, so other harnesses never registered the skill.
