# grabbag

Curated agent skills you can install with the [skills CLI](https://github.com/vercel-labs/skills).

Each skill lives at `skills/<name>/`. `sources.json` records the upstream repo, path, and commit for every skill and agent. `NOTICE` holds the upstream MIT licenses.

## Install

Install every skill. The CLI asks which skills and agents to install:

```bash
npx skills add themusicman/grabbag
```

Install every skill for every agent, without prompts (`--all` is `--skill '*' --agent '*' -y`):

```bash
npx skills add themusicman/grabbag --all
```

Install one skill. The flag is `--skill` (short form `-s`):

```bash
npx skills add themusicman/grabbag --skill how
```

Choose agents with `-a` (long form `--agent`). Repeat the flag for more than one agent:

```bash
npx skills add themusicman/grabbag --skill how -a amp -a grok -a cursor -a claude-code -a opencode -a codex
```

Agent names for the harnesses this repo targets:

| Harness | `-a` name | Project directory |
| --- | --- | --- |
| Amp | `amp` | `.agents/skills/` |
| Grok CLI | `grok` | `.grok/skills/` |
| Cursor | `cursor` | `.agents/skills/` |
| Claude Code | `claude-code` | `.claude/skills/` |
| OpenCode | `opencode` | `.agents/skills/` |
| Codex | `codex` | `.agents/skills/` |

### T3 Code

T3 Code has no `-a` name in the skills CLI. It does not keep its own skill directory. It runs Codex, Claude Code, Cursor, Grok, and OpenCode, and those providers read their own directories.

Codex inside T3 Code reads project skills from `.agents/skills/`. Install there with an agent that uses that directory:

```bash
npx skills add themusicman/grabbag -a codex
```

`amp` and `universal` write to the same project directory. A Claude Code thread in T3 Code needs `-a claude-code`. A Grok thread needs `-a grok`.

## Skills

| Skill | Upstream |
| --- | --- |
| [architect](skills/architect) | [cursor/plugins `pstack/skills/architect`](https://github.com/cursor/plugins/tree/00b14f1df36b32a8dd1529324a3a459f6563b127/pstack/skills/architect) |
| [arena](skills/arena) | [cursor/plugins `pstack/skills/arena`](https://github.com/cursor/plugins/tree/ab1f702ce8e8b6557edb56b09f52cde8bfb83f17/pstack/skills/arena) |
| [babysit-pr](skills/babysit-pr) | [t3dotgg/tstack `skills/babysit-pr`](https://github.com/t3dotgg/tstack/tree/6efae364201abc9d9f07443e9caa461f42e51090/skills/babysit-pr) |
| [benchmark-checklist](skills/benchmark-checklist) | [cursor/plugins `pstack/skills/benchmark-checklist`](https://github.com/cursor/plugins/tree/00b14f1df36b32a8dd1529324a3a459f6563b127/pstack/skills/benchmark-checklist) |
| [blast-radius](skills/blast-radius) | [cursor/plugins `pstack/skills/blast-radius`](https://github.com/cursor/plugins/tree/df581122cde17e6e27686b5a448bde23e4ad4318/pstack/skills/blast-radius) |
| [bro](skills/bro) | [cursor/plugins `pstack/skills/bro`](https://github.com/cursor/plugins/tree/99559f2f52047978602ef365589275831e76af07/pstack/skills/bro) |
| [council](skills/council) | [t3dotgg/tstack `skills/council`](https://github.com/t3dotgg/tstack/tree/1085050f3baed1ac724caa4a8166145fb2ac88af/skills/council) |
| [control-cli](skills/control-cli) | [cursor/plugins `cursor-team-kit/skills/control-cli`](https://github.com/cursor/plugins/tree/d018dc4d9161cc5bfa6be12fcf330445970a6b7c/cursor-team-kit/skills/control-cli) |
| [control-ui](skills/control-ui) | [cursor/plugins `cursor-team-kit/skills/control-ui`](https://github.com/cursor/plugins/tree/d018dc4d9161cc5bfa6be12fcf330445970a6b7c/cursor-team-kit/skills/control-ui) |
| [create-formal-verification-skill](skills/create-formal-verification-skill) | [cursor/plugins `pstack/skills/create-formal-verification-skill`](https://github.com/cursor/plugins/tree/34b1b7c96f09f81a21a6c78f65b7833f7dcb5b24/pstack/skills/create-formal-verification-skill) |
| [create-verification-skill](skills/create-verification-skill) | [cursor/plugins `pstack/skills/create-verification-skill`](https://github.com/cursor/plugins/tree/c49b37a2c0e7bede60a71ad7322e3f12c337a3da/pstack/skills/create-verification-skill) |
| [deslop](skills/deslop) | [cursor/plugins `cursor-team-kit/skills/deslop`](https://github.com/cursor/plugins/tree/b21ab167c8d6aad6e4d91bc0de429eedd49665ed/cursor-team-kit/skills/deslop) |
| [figure-it-out](skills/figure-it-out) | [cursor/plugins `pstack/skills/figure-it-out`](https://github.com/cursor/plugins/tree/ce649c03ac3b75b6ae80cbd15b7e2c536caedb5a/pstack/skills/figure-it-out) |
| [how](skills/how) | [cursor/plugins `pstack/skills/how`](https://github.com/cursor/plugins/tree/ce649c03ac3b75b6ae80cbd15b7e2c536caedb5a/pstack/skills/how) |
| [in-your-own-words](skills/in-your-own-words) | [cursor/plugins `pstack/skills/in-your-own-words`](https://github.com/cursor/plugins/tree/dbf49813a39c1a5389c5e28cb8e4c1c2379e2454/pstack/skills/in-your-own-words) |
| [interrogate](skills/interrogate) | [cursor/plugins `pstack/skills/interrogate`](https://github.com/cursor/plugins/tree/ab1f702ce8e8b6557edb56b09f52cde8bfb83f17/pstack/skills/interrogate) |
| [ketchup](skills/ketchup) | [cursor/plugins `pstack/skills/ketchup`](https://github.com/cursor/plugins/tree/bc1443790cc980d0ea857663260a831299884508/pstack/skills/ketchup) |
| [leaving-pr-comments](skills/leaving-pr-comments) | [t3dotgg/tstack `skills/leaving-pr-comments`](https://github.com/t3dotgg/tstack/tree/6efae364201abc9d9f07443e9caa461f42e51090/skills/leaving-pr-comments) |
| [maintain-formal-verification-skill](skills/maintain-formal-verification-skill) | [cursor/plugins `pstack/skills/maintain-formal-verification-skill`](https://github.com/cursor/plugins/tree/7b353f78f6ec193bdbe48ed8059444eb09b6878e/pstack/skills/maintain-formal-verification-skill) |
| [maintain-verification-skill](skills/maintain-verification-skill) | [cursor/plugins `pstack/skills/maintain-verification-skill`](https://github.com/cursor/plugins/tree/6714489fa233263f00e419f6cfc4759b07c81056/pstack/skills/maintain-verification-skill) |
| [no-comments](skills/no-comments) | [cursor/plugins `pstack/skills/no-comments`](https://github.com/cursor/plugins/tree/ce649c03ac3b75b6ae80cbd15b7e2c536caedb5a/pstack/skills/no-comments) |
| [poteto-mode](skills/poteto-mode) | [cursor/plugins `pstack/skills/poteto-mode`](https://github.com/cursor/plugins/tree/c742dd61706fbacc1b95f1a20b7b988cf096ce6c/pstack/skills/poteto-mode) |
| [principle-attack-the-premise](skills/principle-attack-the-premise) | [cursor/plugins `pstack/skills/principle-attack-the-premise`](https://github.com/cursor/plugins/tree/e5136d82418d2db3165ea1050d17577cd618cc05/pstack/skills/principle-attack-the-premise) |
| [principle-boundary-discipline](skills/principle-boundary-discipline) | [cursor/plugins `pstack/skills/principle-boundary-discipline`](https://github.com/cursor/plugins/tree/d7cde2b84eadbcd6fd890302c876f4436ccb6d82/pstack/skills/principle-boundary-discipline) |
| [principle-build-the-lever](skills/principle-build-the-lever) | [cursor/plugins `pstack/skills/principle-build-the-lever`](https://github.com/cursor/plugins/tree/00b14f1df36b32a8dd1529324a3a459f6563b127/pstack/skills/principle-build-the-lever) |
| [principle-encode-lessons-in-structure](skills/principle-encode-lessons-in-structure) | [cursor/plugins `pstack/skills/principle-encode-lessons-in-structure`](https://github.com/cursor/plugins/tree/08bd59b37834550f5e8fa0bb5e8852204a7534cf/pstack/skills/principle-encode-lessons-in-structure) |
| [principle-exhaust-the-design-space](skills/principle-exhaust-the-design-space) | [cursor/plugins `pstack/skills/principle-exhaust-the-design-space`](https://github.com/cursor/plugins/tree/08bd59b37834550f5e8fa0bb5e8852204a7534cf/pstack/skills/principle-exhaust-the-design-space) |
| [principle-experience-first](skills/principle-experience-first) | [cursor/plugins `pstack/skills/principle-experience-first`](https://github.com/cursor/plugins/tree/d7cde2b84eadbcd6fd890302c876f4436ccb6d82/pstack/skills/principle-experience-first) |
| [principle-explain-the-number](skills/principle-explain-the-number) | [cursor/plugins `pstack/skills/principle-explain-the-number`](https://github.com/cursor/plugins/tree/ab1f702ce8e8b6557edb56b09f52cde8bfb83f17/pstack/skills/principle-explain-the-number) |
| [principle-fix-root-causes](skills/principle-fix-root-causes) | [cursor/plugins `pstack/skills/principle-fix-root-causes`](https://github.com/cursor/plugins/tree/e5136d82418d2db3165ea1050d17577cd618cc05/pstack/skills/principle-fix-root-causes) |
| [principle-foundational-thinking](skills/principle-foundational-thinking) | [cursor/plugins `pstack/skills/principle-foundational-thinking`](https://github.com/cursor/plugins/tree/d7cde2b84eadbcd6fd890302c876f4436ccb6d82/pstack/skills/principle-foundational-thinking) |
| [principle-guard-the-context-window](skills/principle-guard-the-context-window) | [cursor/plugins `pstack/skills/principle-guard-the-context-window`](https://github.com/cursor/plugins/tree/08bd59b37834550f5e8fa0bb5e8852204a7534cf/pstack/skills/principle-guard-the-context-window) |
| [principle-laziness-protocol](skills/principle-laziness-protocol) | [cursor/plugins `pstack/skills/principle-laziness-protocol`](https://github.com/cursor/plugins/tree/08bd59b37834550f5e8fa0bb5e8852204a7534cf/pstack/skills/principle-laziness-protocol) |
| [principle-make-operations-idempotent](skills/principle-make-operations-idempotent) | [cursor/plugins `pstack/skills/principle-make-operations-idempotent`](https://github.com/cursor/plugins/tree/e5136d82418d2db3165ea1050d17577cd618cc05/pstack/skills/principle-make-operations-idempotent) |
| [principle-migrate-callers-then-delete-legacy-apis](skills/principle-migrate-callers-then-delete-legacy-apis) | [cursor/plugins `pstack/skills/principle-migrate-callers-then-delete-legacy-apis`](https://github.com/cursor/plugins/tree/99743e9c151c8537cbbf1f98bb38f34ef3368453/pstack/skills/principle-migrate-callers-then-delete-legacy-apis) |
| [principle-minimize-reader-load](skills/principle-minimize-reader-load) | [cursor/plugins `pstack/skills/principle-minimize-reader-load`](https://github.com/cursor/plugins/tree/00b14f1df36b32a8dd1529324a3a459f6563b127/pstack/skills/principle-minimize-reader-load) |
| [principle-model-the-domain](skills/principle-model-the-domain) | [cursor/plugins `pstack/skills/principle-model-the-domain`](https://github.com/cursor/plugins/tree/00b14f1df36b32a8dd1529324a3a459f6563b127/pstack/skills/principle-model-the-domain) |
| [principle-never-block-on-the-human](skills/principle-never-block-on-the-human) | [cursor/plugins `pstack/skills/principle-never-block-on-the-human`](https://github.com/cursor/plugins/tree/00b14f1df36b32a8dd1529324a3a459f6563b127/pstack/skills/principle-never-block-on-the-human) |
| [principle-outcome-oriented-execution](skills/principle-outcome-oriented-execution) | [cursor/plugins `pstack/skills/principle-outcome-oriented-execution`](https://github.com/cursor/plugins/tree/b0b9c7a0baf8b6aa1d00bf77d4101e577d4ba411/pstack/skills/principle-outcome-oriented-execution) |
| [principle-prove-it-works](skills/principle-prove-it-works) | [cursor/plugins `pstack/skills/principle-prove-it-works`](https://github.com/cursor/plugins/tree/b0b9c7a0baf8b6aa1d00bf77d4101e577d4ba411/pstack/skills/principle-prove-it-works) |
| [principle-redesign-from-first-principles](skills/principle-redesign-from-first-principles) | [cursor/plugins `pstack/skills/principle-redesign-from-first-principles`](https://github.com/cursor/plugins/tree/00b14f1df36b32a8dd1529324a3a459f6563b127/pstack/skills/principle-redesign-from-first-principles) |
| [principle-separate-before-serializing-shared-state](skills/principle-separate-before-serializing-shared-state) | [cursor/plugins `pstack/skills/principle-separate-before-serializing-shared-state`](https://github.com/cursor/plugins/tree/d7cde2b84eadbcd6fd890302c876f4436ccb6d82/pstack/skills/principle-separate-before-serializing-shared-state) |
| [principle-sequence-verifiable-units](skills/principle-sequence-verifiable-units) | [cursor/plugins `pstack/skills/principle-sequence-verifiable-units`](https://github.com/cursor/plugins/tree/70b2dc8b4b85c8d5648624ca40d692c421fff32f/pstack/skills/principle-sequence-verifiable-units) |
| [principle-subtract-before-you-add](skills/principle-subtract-before-you-add) | [cursor/plugins `pstack/skills/principle-subtract-before-you-add`](https://github.com/cursor/plugins/tree/00b14f1df36b32a8dd1529324a3a459f6563b127/pstack/skills/principle-subtract-before-you-add) |
| [principle-test-behavior-not-implementation](skills/principle-test-behavior-not-implementation) | [cursor/plugins `pstack/skills/principle-test-behavior-not-implementation`](https://github.com/cursor/plugins/tree/e5136d82418d2db3165ea1050d17577cd618cc05/pstack/skills/principle-test-behavior-not-implementation) |
| [principle-type-system-discipline](skills/principle-type-system-discipline) | [cursor/plugins `pstack/skills/principle-type-system-discipline`](https://github.com/cursor/plugins/tree/99743e9c151c8537cbbf1f98bb38f34ef3368453/pstack/skills/principle-type-system-discipline) |
| [reflect](skills/reflect) | [cursor/plugins `pstack/skills/reflect`](https://github.com/cursor/plugins/tree/7054003c3723e82d099fb7620e3bc8d7d63eebc6/pstack/skills/reflect) |
| [setup-pstack](skills/setup-pstack) | [cursor/plugins `pstack/skills/setup-pstack`](https://github.com/cursor/plugins/tree/ab1f702ce8e8b6557edb56b09f52cde8bfb83f17/pstack/skills/setup-pstack) |
| [show-me-your-work](skills/show-me-your-work) | [cursor/plugins `pstack/skills/show-me-your-work`](https://github.com/cursor/plugins/tree/ce649c03ac3b75b6ae80cbd15b7e2c536caedb5a/pstack/skills/show-me-your-work) |
| [statechart](skills/statechart) | [cursor/plugins `pstack/skills/statechart`](https://github.com/cursor/plugins/tree/519d36aa98955bf680db01bcde5fdfba686dc901/pstack/skills/statechart) |
| [swarm](skills/swarm) | [cursor/plugins `pstack/skills/swarm`](https://github.com/cursor/plugins/tree/e73df471cd4bd918367e99f3dd9c51bd53ddf5f0/pstack/skills/swarm) |
| [tdd](skills/tdd) | [cursor/plugins `pstack/skills/tdd`](https://github.com/cursor/plugins/tree/b0b9c7a0baf8b6aa1d00bf77d4101e577d4ba411/pstack/skills/tdd) |
| [technical-writing](skills/technical-writing) | [cursor/plugins `pstack/skills/technical-writing`](https://github.com/cursor/plugins/tree/00b14f1df36b32a8dd1529324a3a459f6563b127/pstack/skills/technical-writing) |
| [typescript-best-practices](skills/typescript-best-practices) | [cursor/plugins `pstack/skills/typescript-best-practices`](https://github.com/cursor/plugins/tree/0317eb8b858c991c57721358daaee19dbe8c814d/pstack/skills/typescript-best-practices) |
| [unslop](skills/unslop) | [cursor/plugins `pstack/skills/unslop`](https://github.com/cursor/plugins/tree/bc697d0a5a163cec979e362b601e36f5616083fd/pstack/skills/unslop) |
| [why](skills/why) | [cursor/plugins `pstack/skills/why`](https://github.com/cursor/plugins/tree/ce649c03ac3b75b6ae80cbd15b7e2c536caedb5a/pstack/skills/why) |

## Agents

These agents are shipped inside the skill that runs them. They are not separate skills.

| Agent | Upstream |
| --- | --- |
| [comment-sicko](skills/no-comments/agents/comment-sicko.md) | [cursor/plugins `pstack/agents/comment-sicko.md`](https://github.com/cursor/plugins/blob/de2dba6ffa001bc3c97acf1f58bc7ab29d5fdc7a/pstack/agents/comment-sicko.md) |
| [poteto-agent](skills/poteto-mode/agents/poteto-agent.md) | [cursor/plugins `pstack/agents/poteto-agent.md`](https://github.com/cursor/plugins/blob/b93e8117880f695bc49ef7b1ef72c09bfcc7c1de/pstack/agents/poteto-agent.md) |
