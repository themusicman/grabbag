---
name: formal-statechart-verdicts
description: "Model-check the rule loop in grabbag's vendored statechart script (skills/statechart/scripts/run.ts, judge() in check()), which decides whether each TLA+ rule is reported as broken, holds, or not checked. Use before and after any change to run.ts, backends/cfg.ts, or frontends/verdict.ts under skills/statechart/scripts/, including a re-vendor of statechart from upstream."
metadata:
  internal: true
---

# Formal check: statechart rule verdicts

`/statechart` tells its reader which rules of their TLA+ spec break, which hold, and which it did not check. It gets those verdicts from `judge()` in `check()` in [`skills/statechart/scripts/run.ts`](../../../skills/statechart/scripts/run.ts). `judge()` runs TLC more than once: after the first break it removes the broken rule and reruns TLC on the rest, and those reruns stop at 100,000 distinct states.

**Property.** Every verdict `judge()` gives is backed by what TLC actually saw: "holds" only for a rule that holds in the whole state graph, "broken" only for a rule that breaks, one verdict per rule, and the loop always ends.

**Harm if it breaks.** A reader is told "Rules that hold: X" when TLC stopped at the 100,000-state bound before it reached the state where X breaks. They ship the bug the tool was meant to find.

Tests do not reach this. Upstream's statechart tests and TLC corpus were removed when it was vendored (see `skills/statechart/CHANGELOG.md`), and the bound branch needs a spec with more than 100,000 states to run at all.

## Run the check

```sh
.agents/skills/formal-statechart-verdicts/scripts/check.sh
```

Run it from anywhere in the grabbag checkout. It takes about 2 seconds after the first run. The first run downloads `tla2tools.jar` 1.7.4 (checked against its SHA-256) into `~/.cache/grabbag-formal/`, and uses `$JAVA`, `java` on `PATH` (11 or later), or `mise exec java@temurin-21`, in that order. It needs the network once.

It prints `PASS` and exits 0 when every rule below holds and every model action fires at least once. Otherwise it prints the violated rule with TLC's full trace, then `FAIL`, and exits 1. TLC's full output is kept at the path it prints. `check.sh MODEL_DIR` checks a copy of `model/` instead of the committed one.

Read every result, pass or fail, with the pstack `/statechart` skill: give it `model/StatechartVerdicts.tla` and use `model/view.ts` as its view module. It tells a violation as its shortest path in plain words, such as "TLC names a rule that breaks → a rerun stops at 100,000 states → prop2 reported holds, breaks only past the bound". The model has about 21,600 states, more than `/statechart` draws, so expect bug paths and no chart.

## What the model checks

`model/StatechartVerdicts.tla`, configured by `model/StatechartVerdicts.cfg`:

| Rule | Plain sentence |
| --- | --- |
| `HoldsMeansHolds` | A rule reported as holding holds in the spec. |
| `BrokenMeansBroken` | A rule reported as broken does break. |
| `OneVerdictEach` | `decide()` never replaces a verdict a rule already has. |
| `EarlyBreaksAreFound` | A safety rule that breaks before the bound is reported broken, unless a TLC run failed. |
| `SmallGraphsAreDecided` | On a graph under the bound, every rule gets "holds" or "broken", never "not checked", unless a TLC run failed. |
| `Terminates` | `judge()` returns. |

The model replaces TLC with every answer TLC can give. The spec under check is chosen in `Init`: two invariants, the deadlock rule, and two properties that are each a safety property (TLC names it when it breaks) or a temporal one (TLC reports an unnamed temporal break after it explores the whole graph). Each rule holds, breaks before the bound, breaks only past the bound, or (temporal) breaks. The graph is under or over the bound. When several rules can break, TLC may name any of them first.

One model step is one pass of the `for (let k = 1; groups.length;)` loop: one TLC run and the branch of the if/else chain that reads its result. That run is one indivisible step in the code, because the loop awaits it.

## Coverage record

Sync commit: `2e3905dea79e5e548b372f70936fb87a84ee1156`

At this commit the model was confirmed to describe this code:

| File | What the model covers |
| --- | --- |
| `skills/statechart/scripts/run.ts` | `check()` → `judge()`: the `groups` queue, the `group` filter on `verdicts`, `bounded`, `-deadlock`, `cut`, the if/else chain on each TLC result, `groups.splice(0, 1, rest, ...pending)`, and the final "not checked" loop. Also `exitClass()` and `brokenRule()`. |
| `skills/statechart/scripts/backends/cfg.ts` | `boundRun()`: the `ChartBound` constraint that stops a rerun at `RERUN_STATES`. |
| `skills/statechart/scripts/frontends/verdict.ts` | `readVerdict()`: which TLC messages count as a named break, a deadlock, or an unnamed temporal break. |
| `skills/statechart/scripts/ir.ts` | `RERUN_STATES` (100,000), `stateRules()`. |

Map from code to model:

| Code in `judge()` | Model |
| --- | --- |
| `const groups = [all]` | `groups = <<Rules>>` in `Init` |
| `group` = rules of `groups[0]` without a verdict | `Group` |
| `if (first && !group.length) groups.shift()` | `GroupEmpty` |
| `bounded = first !== undefined && !states.complete` | `Bounded` |
| `-deadlock` unless the group has the deadlock rule; TLC stops at the first safety break | `Findable` |
| `exitClass(r.status) === 2` → `stop`, `break` | `TlcErrors` |
| `else if (rule) decide(rule, "broken")` | `RuleBreaks` |
| `else if (cut && (status 0 \|\| temporal))` → "not checked" | `BoundReached` |
| `else if (r.status === 0)` → complete, "holds" | `AllHold` |
| `else if (broke && properties.length)`, temporal: non-properties "holds", then one property "broken" or one group per property | `TemporalBreaks` |
| final `for (const rule of all)` → "not checked" | `LoopEnds` |

`check.sh` compares the covered files with the sync commit on every run and prints a `WARNING` listing any that changed.

## When the code changes

1. If `check.sh` warns that covered code changed, read the diff: `git diff <sync commit> -- skills/statechart/scripts/`.
2. Find each changed branch in the map above and change the matching action in a copy of the model so it does what the new code does. A new branch in the if/else chain is a new action, added to `Next`. Keep one action per branch.
3. Run `check.sh` on the copy. If it fails, read the trace with `/statechart`.
   - **Real bug:** the path is something TLC can really do. Each step is a TLC run whose result is possible for some spec. Report it in the code's terms, as in "the first run names inv1, the rerun stops at the bound, and inv2 is reported as holding". Do not weaken a rule or the model to make it pass, and do not change `run.ts` unless the user asks.
   - **Modeling error:** a step does something TLC or the code cannot do, such as a bounded run on a small graph that stops at the bound. Fix the model and say what you fixed.
4. When the change is intended and the model now matches the code, copy the model back, run `check.sh` until it passes or fails only on reported findings, and move the `Sync commit` line above to the commit you checked. Move it only after you have read the new code and confirmed the model describes it.

To confirm the check still catches a break, delete the `else if (cut && ...)` branch in `run.ts` in a scratch worktree, change `BoundReached` in a model copy to decide "holds" and set `complete' = TRUE` as `AllHold` does, and run `check.sh` on the copy. It must fail on `HoldsMeansHolds` with a 3-state trace. Then drop the scratch change.

## What this does not cover

- The bound is abstract: "breaks before the bound" and "breaks only past the bound" stand for TLC's breadth-first order. The model does not check that `ChartBound` really stops TLC at 100,000 states.
- TLC is trusted to report a break it sees with the right name. A broken rule whose name `brokenRule()` cannot match is not modeled.
- The chart pass after `judge()` (`ChartRun`, `mark()`, `addPast()`, the 500-state chart budget) and the report text are not modeled.
- Five rules: two invariants, the deadlock rule, two properties. Bugs that need three or more properties in one group are outside this bound.
- `check()` throws when the first TLC run fails, so the user sees an error and no verdicts. The model treats that as `TlcErrors`.
