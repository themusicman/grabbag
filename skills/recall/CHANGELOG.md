# Changelog

Changes from upstream `cursor/plugins` `pstack/skills/recall`.

- Outside Cursor, read the harness's own chat history for this workspace. If there is none to read, say so and build the brief from the shared record and live state. Upstream read only `~/.cursor/projects/<slug>/agent-transcripts/`.
- Added a fallback when the harness has no Cursor `Task` tool or rejects `subagent_type`.
