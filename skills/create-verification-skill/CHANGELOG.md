# Changelog

Changes from upstream `cursor/plugins` `pstack/skills/create-verification-skill`.

- The generated `verify-<app>` skill is written to the directory the active harness loads: `.agents/skills/` for Amp, Cursor, OpenCode, Codex, and T3 Code; `.claude/skills/` for Claude Code; `.grok/skills/` for Grok CLI. Unknown harnesses use `.agents/skills/`. Upstream wrote only `.cursor/skills/verify-<app>/`.
