# Changelog

Changes from upstream `cursor/plugins` `pstack/skills/no-comments`.

- Vendored `pstack/agents/comment-sicko.md` verbatim at `agents/comment-sicko.md` in this skill. Step 1 now says to read that file when `comment-sicko` is not an installed agent type, so the skill works outside a Cursor or Claude plugin install.
- Added a fallback when the harness has no Cursor `Task` tool or rejects `subagent_type`.
