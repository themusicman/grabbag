# Changelog

Changes from upstream `mattpocock/skills` `skills/productivity/teach`.

- Renamed the skill from `teach` to `mp-teach`: the folder is `skills/mattpocock/mp-teach/` and the `SKILL.md` frontmatter `name` is `mp-teach`. grabbag already ships pstack's `teach` at `skills/teach/`, and the skills CLI and every agent key skills by `name`, so two skills named `teach` would collide on install.
- `SKILL.md` names the command it runs under as `/mp-teach` instead of `/teach`, so the workspace-path note matches the renamed command.
