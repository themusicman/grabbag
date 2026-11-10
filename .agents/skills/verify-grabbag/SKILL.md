---
name: verify-grabbag
description: "Verify the grabbag skills repo the way its users meet it: list and install skills with the skills CLI (npx skills add themusicman/grabbag), and check the vendoring metadata (SKILL.md and SOURCE.md in every skills/<name>/, sources.json, CHANGELOG.md for modified skills, README tables, NOTICE). Use after adding, re-vendoring, editing, or removing anything under skills/, or before opening a grabbag PR."
metadata:
  internal: true
---

# Verify grabbag

grabbag has no app to start. Users reach it in two ways:

- **The skills CLI.** `npx skills add themusicman/grabbag --list` shows what the repo publishes, and `npx skills add themusicman/grabbag --skill <name> -a <agent>` copies `skills/<name>/` into a project. This is the primary surface.
- **Provenance files.** `README.md`, each `skills/<name>/SOURCE.md` and `CHANGELOG.md`, `sources.json`, and `NOTICE` tell a user where each skill came from, at which upstream commit, under which license, and what grabbag changed.

The feature map in [`features/README.md`](features/README.md) lists every user-facing feature and how to prove it. Read it before you drive anything.

All paths below are relative to the repo root. Every helper finds the repo root itself, so you can run them from any directory in the checkout.

## Launch

There is nothing to keep running. Each drive is one short `npx` call in its own scratch project.

- Pin the CLI to `skills@1.7.6`. The helpers already do. A newer CLI can change how it discovers skills or prints its output.
- The first `npx -y skills@1.7.6` call downloads the CLI from the npm registry. Later calls use the npm cache.
- Drive the working tree of this checkout by default. To verify what users get from GitHub, pass `themusicman/grabbag` as the source after the change is pushed.

## Doctor

Run this first, and again whenever a result looks wrong:

```sh
.agents/skills/verify-grabbag/scripts/doctor.sh
```

It is read-only. It confirms the checkout has `sources.json` and `skills/`, Node is 18 or later, and `npx skills@1.7.6 --version` prints `1.7.6`. It also reports how many paths are uncommitted, because the checks read the working tree, not `HEAD`. Exit 0 means the checkout is fit to verify.

## Drive

```sh
# Invariants of the metadata. Add --base origin/main on a branch to also check changed skills.
.agents/skills/verify-grabbag/scripts/check-repo.mjs --base origin/main

# What the skills CLI lists for this checkout (or pass themusicman/grabbag).
.agents/skills/verify-grabbag/scripts/drive.sh list

# Install one skill for one agent into a scratch project and compare it with skills/<name>/.
.agents/skills/verify-grabbag/scripts/drive.sh install statechart amp
```

`check-repo.mjs` prints one `FAIL <check>: <problem>` line for each broken invariant, then which checks passed, and exits 1 if any failed. The checks are `skill-files`, `frontmatter`, `sources-json`, `source-md`, `changelog`, `readme`, `notice`, and with `--base REF` also `changed-skills`. [`features/`](features/README.md) says what each one proves.

`drive.sh list` compares the names the CLI lists with the `skills/<name>/` folders, and the CLI's "Found N skills" with the folder count. `drive.sh install SKILL [AGENT] [SOURCE]` runs `npx skills add SOURCE --skill SKILL -a AGENT -y --copy` in a new git project under `$TMPDIR`. It finds where the CLI says it installed the skill and diffs that tree, and its executable bits, against `skills/SKILL/`. Both print `PASS` or `FAIL` and exit 0 or 1.

Choose the agent from the README table: `amp`, `cursor`, `opencode`, and `codex` install to `.agents/skills/`, `claude-code` to `.claude/skills/`, and `grok` to `.grok/skills/`.

## Evidence

Each `drive.sh` run writes to `$VERIFY_GRABBAG_OUT/<UTC time>-<command>/` (default `/tmp/verify-grabbag/`) and prints that path:

- `run.txt`: the source, CLI version, grabbag commit, the exact command, and its exit code.
- `list`: `list.txt` (CLI output without colors), `listed.txt`, `expected.txt`, `names.diff`.
- `install`: `install.txt`, `project-files.txt` (every file the CLI wrote, including `skills-lock.json`), `content.diff`, `exec-src.txt`, `exec-installed.txt`, `exec.diff`.

`check-repo.mjs` writes only to stdout. Save it with `| tee` when you need it as evidence.

Proof standards:

- Drive the real CLI against the real checkout. Do not copy files into `.agents/skills/` by hand to stand in for an install.
- An install proves itself by comparing the installed tree with `skills/<name>/`, not by the CLI's "Installation complete" line.
- A metadata change is proven by `check-repo.mjs` and by the CLI output it affects. A new skill must show up in `drive.sh list`. A removed skill must disappear from it.
- `--list` is safe. It writes nothing outside npm's cache. `install` writes only inside its scratch project, so check `project-files.txt` for files outside the agent directory.

## Cleanup

`drive.sh install` deletes its scratch project on exit, including on failure or Ctrl-C. Evidence directories are never deleted by the helpers. Remove old ones yourself with `rm -rf /tmp/verify-grabbag/<run>` when you no longer need them. Nothing runs in the background, so there is no process to kill.

## Helpers

| Script | Invocation | Writes |
| --- | --- | --- |
| `scripts/doctor.sh` | `.agents/skills/verify-grabbag/scripts/doctor.sh` | nothing |
| `scripts/check-repo.mjs` | `.agents/skills/verify-grabbag/scripts/check-repo.mjs [--root DIR] [--base REF]` | nothing |
| `scripts/drive.sh` | `.agents/skills/verify-grabbag/scripts/drive.sh list [SOURCE]` and `... install SKILL [AGENT] [SOURCE]` | evidence directory, scratch project (removed) |

## Known findings

On `main` at `2e3905d`, `check-repo.mjs` fails only on `notice` for `control-cli`, `control-ui`, and `deslop`. They come from `cursor/plugins` `cursor-team-kit/`, whose upstream `LICENSE` is MIT, Copyright (c) 2026 Cursor. Their `SOURCE.md` says Lauren Tan, and `NOTICE` has no `cursor-team-kit/` section. Until that is fixed, treat those 3 lines as the baseline and any other failure as new.

## This skill is not published

This folder sets `metadata.internal: true`, so `npx skills add themusicman/grabbag --list` and `--all` skip it, and the published count stays equal to the `skills/` folder count. Amp still loads it from `.agents/skills/`. Keep the flag if you copy this skill.
