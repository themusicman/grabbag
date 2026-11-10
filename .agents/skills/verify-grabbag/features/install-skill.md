# Install a skill

A user installs one grabbag skill for their agent, and the skill's whole folder lands in that agent's project skill directory with the same files and the same executable scripts.

## Sub-features

- `install-copy` copies every file of `skills/<name>/`, including `references/`, `scripts/`, `agents/`, and `playbooks/`.
- `install-exec` keeps executable scripts executable, such as `statechart/scripts/statechart` and `poteto-mode/scripts/check-plan.mjs`.
- `install-agent-dir` writes to the directory the README names for each agent.

## How to get to it (user POV)

- Run `npx skills add themusicman/grabbag --skill <name> -a <agent>` in a project.
- Run `npx skills add themusicman/grabbag --all` to install everything for every agent.

## Driving it with drive.sh

Preconditions:

- `doctor.sh` exits 0.
- The skill has scripts or subfolders, so the proof covers more than one file. `statechart`, `poteto-mode`, and `babysit-pr` do.

- **Install for Amp.** Install `statechart`. Run `.agents/skills/verify-grabbag/scripts/drive.sh install statechart amp`. Output says `installed to ./.agents/skills/statechart`, then `installed tree matches skills/statechart, 1 executable file(s) kept executable` and `PASS`.
- **Install for Claude Code.** Run `.agents/skills/verify-grabbag/scripts/drive.sh install poteto-mode claude-code`. Output says `installed to ./.claude/skills/poteto-mode` and `PASS`.
- **Proof.** Open the evidence directory. `project-files.txt` lists the skill's files under the agent directory and `skills-lock.json`, and `content.diff` and `exec.diff` are empty.

## Gotchas

- Without `--copy`, the CLI symlinks into a shared directory, and the comparison would only prove the symlink. `drive.sh` always passes `--copy`.
- The CLI notices when Amp runs it and prints "Agent detected — installing non-interactively". That is expected.
- `diff -r` ignores file modes. The executable-bit check is the separate `exec.diff`.
- The install is compared with `skills/<name>/` in the same checkout, so it cannot see a script that lost its executable bit in the repo itself. `check-repo.mjs --base origin/main` catches that as a changed skill with no CHANGELOG entry, because git records the mode change.
