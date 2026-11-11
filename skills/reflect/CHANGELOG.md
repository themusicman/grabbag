# Changelog

Changes from upstream `cursor/plugins` `pstack/skills/reflect`.

- Named where to read `pstack-models.mdc`: `~/.cursor/rules/pstack-models.mdc`, then `~/.pstack/pstack-models.mdc`.
- Added a fallback when the harness has no Cursor `Task` tool or rejects `subagent_type`.
- Skill edits now also name `.agents/skills/`, `.claude/skills/`, and `.grok/skills/` as destinations, alongside the Cursor paths.
- Reviewer prompts treat a `Read` of `SKILL.md` under those harness directories as a skill the transcript used.
- Step 1 tells Amp to skip the `agent-transcripts/` lookup and always pass a digest. Amp has no transcript directory, and Amp `Task` subagents cannot call `read_thread` (it fails with "read_thread is orchestrated by ThreadCoordinator and cannot execute directly"), so the thread URL is no use to them. The digest names the `SKILL.md` path of each skill loaded with Amp's `skill` tool, because the reviewer prompts route findings only to skills whose `SKILL.md` the transcript shows.
- Steps 2 and 3 tell Amp to call `Task` with only `description` and `prompt`, omitting `subagent_type`, `readonly`, `environment`, and `model`, and to skip the `pstack-models.mdc` lookup. Amp's `Task` tool does not accept those Cursor parameters.
- Step 5 routes the substantive-edit, description-tuning, and new-skill rows to Amp's `building-skills` skill when running on Amp, because Amp has no `create-skill`.
