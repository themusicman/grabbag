# Changelog

Changes from upstream `cursor/plugins` `pstack/skills/poteto-help`.

- Links to the pstack README and `docs/` pages now use their `https://github.com/cursor/plugins/blob/main/pstack/` URLs. Upstream used `../../` paths into the plugin, and those files are not in this repo or in a skills CLI install.
- The `/setup-pstack` check also looks for `~/.pstack/pstack-models.mdc`, which `setup-pstack` writes for harnesses other than Cursor.
- Named the sibling skill paths for `deslop`, `control-cli`, and `control-ui`, which this repo vendors from `cursor-team-kit`.
- Said how other harnesses install the skills (`npx skills add themusicman/grabbag -a <agent>`) and that subagent steps fall back to the current session or the harness's own subagent tool.
