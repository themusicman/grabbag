---
name: reflect
description: Spawn three parallel review subagents over the active transcript, surface learnings, and route each to a concrete edit on an existing skill. Use when the user says reflect.
disable-model-invocation: true
---

# Reflect

Mine the current conversation for durable learnings, then route them into skill edits.

Invoke when the user says "reflect" or "/reflect". Skip when the conversation is trivial, off-topic, or already covered by an existing skill the parent followed correctly. One-offs are not learnings.

## 1. Locate the active transcript

On Amp, the transcript is this thread, and reviewers read it with `read_thread`. You are on Amp when the system prompt names Amp or you have the `create_thread`, `read_thread`, and `send_thread_message` tools. Take the thread URL from `Amp Thread URL` in the system prompt's environment section, or build it as `https://ampcode.com/threads/<thread ID>`. Skip the file lookup below. If you have neither the URL nor the thread ID, pass a digest.

Elsewhere, before fanning out, find this conversation's transcript in the `agent-transcripts/` directory the system prompt names. Do not glob across `~/.cursor/projects/*/`. That crosses workspace boundaries and reads private chats from unrelated projects.

```bash
ls -t <agent-transcripts>/*.jsonl <agent-transcripts>/*/*.jsonl <agent-transcripts>/*/subagents/*.jsonl 2>/dev/null | head -10
```

That covers the legacy flat (`<id>.jsonl`), current nested (`<id>/<id>.jsonl`), and subagent (`<parent>/subagents/<child>.jsonl`) layouts. For each candidate, read the first JSONL line. Take the file whose `message.content[0].text` contains the conversation's opening user prompt. If the system prompt names no `agent-transcripts/` directory, or no file matches, pass a tight digest of the session instead.

## 2. Spawn three reviewers in parallel

One message, three `Task` calls, `subagent_type: generalPurpose`, agent mode (`readonly: false`). Reviewers need MCP access to look up the tickets, chat threads, and observability traces the transcript references, and readonly strips MCPs. If this harness has no Cursor Task tool, or it rejects `subagent_type`, do that work in this session or with the harness's own subagent tool. Keep the same prompt and defaults. Ignore Cursor-only fields such as `subagent_type`, `environment`, and model slugs the harness rejects.

Each reviewer and the synthesizer name a role line in the `pstack-models.mdc` rule and a default. Look for the `pstack-models.mdc` rule at `~/.cursor/rules/pstack-models.mdc`, then at `~/.pstack/pstack-models.mdc`. Set `model` to that line's value, or to the default if the rule or the line is missing. Leave `model` unset when the value is `auto` or `inherit-parent`. If the Task tool rejects a slug, use the default and say so. If it rejects the default, use the closest valid slug of the same family from its error message. Pick each subagent's reasoning level and fast or standard speed for the job, per the Subagents section of the **poteto-mode** skill.

| Lens | Role line | Default `model` | Prompt template |
|---|---|---|---|
| Judgment | `reflect judgment, divergent, synthesizer` | `claude-opus-5-5-xhigh` | `references/judgment-reviewer.md` |
| Tooling | `reflect tooling` | `grok-4.7-xhigh-fast` | `references/tooling-reviewer.md` |
| Divergent | `reflect judgment, divergent, synthesizer` | `claude-opus-5-5-xhigh` | `references/divergent-reviewer.md` |

Pass each template verbatim, substituting the transcript path or digest where marked. Reviewers return findings in the `Task` response body.

### On Amp: child threads that report back

On Amp, run each reviewer as a child thread instead of a `Task` subagent. Child threads keep the user's MCP servers, can call `read_thread` on this thread from their own orb, and their work stays out of this thread's context. A child orb checks out the project's default branch, not this thread's uncommitted work, so the transcript is the record of what changed.

- One message, three `create_thread` calls with `intent: independent-review`, the default orb executor, and `archive_when_done: true`, so each child archives itself after it reports.
- Set `agent_mode` to the Amp model key of the same family as the role's model (for example `anthropic/claude-opus-5-5` or `xai/grok-4.7`; `list_agent_modes` lists them), or to this thread's mode when none matches. The Cursor slugs in the table do not apply.
- The prompt is the template with the thread URL in place of `<ABSOLUTE_PATH>`, followed by this reply block, with `<LENS>` (`judgment`, `tooling`, or `divergent`) and `<PARENT_THREAD_ID>` (this thread's ID) filled in:

  > When you finish, call `send_thread_message` with thread `<PARENT_THREAD_ID>`. The message is the line `reflect <LENS> findings: <N>`, then your numbered list exactly as specified above, with nothing after the first line when N is 0. End with the same text as your final response. Do the review yourself: create no threads, message no other thread, and edit no files.

After the three calls, tell the user that three reviewers are running and their findings will arrive in this thread. Each child's reply arrives as a message from its thread. Wait for all three before step 3. If a child settles without replying, read its final response with `read_thread`. If `create_thread` is unavailable, run the reviewers as `Task` subagents and pass a digest, because subagents cannot call `read_thread`.

## 3. Synthesize

One `Task` call, `subagent_type: generalPurpose`, `model` from the `reflect judgment, divergent, synthesizer` line (default `claude-opus-5-5-xhigh`), agent mode (`readonly: false`). It spot-verifies citations through MCP, and readonly strips MCPs. Pass `references/synthesizer.md` verbatim, with each reviewer's full output inlined where marked. It returns an Accepted / Rejected / Backlog list. On Amp, use the `Task` tool without `subagent_type` or `model`, and inline each child's reply, without its first line, as that reviewer's output.

## 4. Structural enforcement check

Move any Accepted item that a lint rule, script, metadata flag, or runtime check would enforce more reliably to Backlog. See the **encode-lessons-in-structure** principle skill.

## 5. Apply

Present the synthesizer's full Accepted / Rejected / Backlog output and wait for explicit approval before applying any Accepted edit. The user picks the subset and may redirect routings. Skill changes affect every future agent in the org. Do not auto-apply.

File each Backlog item to your team's devex or backlog tracker without waiting. Only the Accepted list waits for approval.

Never edit a skill under `plugins/cache/` or Amp's read-only `~/.cache/amp/global-skills/`. Before approval, show its destination, `.cursor/skills/<skill>/` or `~/.cursor/skills/<skill>/`. After approval, copy the skill folder there and edit the copy. Never open a PR or push. On Amp, Cursor, OpenCode, Codex, or T3 Code, the project destination is `.agents/skills/<skill>/`. Claude Code uses `.claude/skills/<skill>/`. Grok CLI uses `.grok/skills/<skill>/`.

Follow each approved row's Routing exactly:

- Trivial existing-skill edit (a one-line bullet, a tightened sentence, a stale fact corrected): the parent does it directly.
- Substantive existing-skill edit (a new section, a new pattern table, more than ~10 lines): hand to Cursor's built-in `create-skill` skill and run its draft / test / iterate loop.
- `tune description: <skill path>` (the skill exists but didn't trigger when it should have): hand to `create-skill` and run its description-optimization loop.
- `new skill via create-skill: <kebab-name>`: hand creation to `create-skill`. Do not invent the shape ad hoc.

On Amp, which has no `create-skill`, load the `building-skills` skill for the last three routings instead and follow its frontmatter, description, and layout rules. After applying edits on Amp, call `reload_skills` so this session sees them.

If your environment ships a SKILL.md validator, run it on every touched skill before declaring done.

## 6. Summarize for the user

Short list, no preamble:

- Edits applied: `<skill path>`. What changed, one line each.
- New skills created: `<skill path>`. One line each (rare).
- Backlog filed to the devex tracker: `<issue title>` (`<tags>`). One line each.
- Dropped: one line per rejected finding + reason from the synthesizer.
