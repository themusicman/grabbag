---- MODULE StatechartVerdicts ----
(***************************************************************************)
(* The rule loop in skills/statechart/scripts/run.ts: check() -> judge().  *)
(* judge() runs TLC again and again on the user's spec and gives each rule *)
(* one verdict: "broken", "holds", or "not checked". This model replaces   *)
(* TLC with every answer it can give, and checks that a verdict never      *)
(* claims more than TLC saw.                                               *)
(*                                                                         *)
(* One step of this model is one pass of the `for (let k = 1; ...)` loop:  *)
(* one TLC run and the branch of the if/else chain that reads its result.  *)
(***************************************************************************)
EXTENDS Naturals, Sequences, FiniteSets

\* The user's rules, as readChecks() and stateRules() list them.
Invariants == {"inv1", "inv2"}
Deadlock   == {"deadlock"}
Properties == {"prop1", "prop2"}
Rules      == Invariants \cup Deadlock \cup Properties

\* The spec under check, fixed in Init. RERUN_STATES (100,000) is "the bound".
\*   "holds" : the rule holds in every reachable state.
\*   "early" : a safety rule breaks in a state TLC reaches before the bound.
\*   "late"  : a safety rule breaks only in states past the bound.
\*   "broken": a temporal property breaks (TLC sees it only after it has
\*             explored the whole graph, because the run pins -lncheck final).
VARIABLES
  truth,     \* rule -> how the rule fares in the spec under check
  propKind,  \* property -> "safety" (named by TLC) or "temporal" (unnamed)
  space,     \* "small": fewer reachable states than the bound; "large": more
  verdict,   \* the `verdicts` map: rule -> "none" | "broken" | "holds" | "not checked"
  groups,    \* the `groups` queue of rule sets, as a sequence
  ran,       \* `first !== undefined`: TLC has run at least once
  complete,  \* `states.complete`
  stopped,   \* `stop` is set: a TLC run ended in exit class 2
  overwrote, \* some decide() replaced a verdict that a rule already had
  pc         \* "loop" while judge() runs, "done" after it returns

vars == <<truth, propKind, space, verdict, groups, ran, complete, stopped, overwrote, pc>>

Safety(r) == r \in Invariants \cup Deadlock \/ (r \in Properties /\ propKind[r] = "safety")
Temporal(r) == r \in Properties /\ propKind[r] = "temporal"

Init ==
  /\ space \in {"small", "large"}
  /\ propKind \in [Properties -> {"safety", "temporal"}]
  /\ truth \in [Rules -> {"holds", "early", "late", "broken"}]
  /\ \A r \in Rules :
       IF Temporal(r) THEN truth[r] \in {"holds", "broken"}
       ELSE truth[r] \in {"holds", "early"} \cup (IF space = "large" THEN {"late"} ELSE {})
  /\ verdict = [r \in Rules |-> "none"]
  /\ groups = <<Rules>>          \* `const groups = [all]`
  /\ ran = FALSE
  /\ complete = FALSE
  /\ stopped = FALSE
  /\ overwrote = FALSE
  /\ pc = "loop"

\* `group`: the rules of groups[0] that have no verdict yet.
Group == {r \in Head(groups) : verdict[r] = "none"}

\* `bounded`: every run after the first, until one run explored the whole graph.
Bounded == ran /\ ~complete

\* decide(rule, outcome) for each rule in S.
Decide(S, outcome) ==
  /\ verdict' = [r \in Rules |-> IF r \in S THEN outcome ELSE verdict[r]]
  /\ overwrote' = (overwrote \/ \E r \in S : verdict[r] # "none")

\* Safety rules in the group that this TLC run can report. -deadlock leaves
\* the deadlock rule out unless it is in the group. A bounded run on a large
\* graph stops at the bound and never reaches a "late" break.
Findable ==
  {r \in Group : Safety(r) /\ (truth[r] = "early" \/ (truth[r] = "late" /\ ~(Bounded /\ space = "large")))}

\* TLC explores the whole graph: the run is unbounded, or the graph fits the bound.
Whole == ~Bounded \/ space = "small"

BrokenTemporal == {p \in Group : Temporal(p) /\ truth[p] = "broken"}

\* --- One action per branch of the if/else chain after `runJava(name, "tlc2.TLC", ...)`.

\* `if (first && !group.length) { groups.shift(); continue; }`
GroupEmpty ==
  /\ pc = "loop" /\ groups # <<>> /\ ran /\ Group = {}
  /\ groups' = Tail(groups)
  /\ UNCHANGED <<truth, propKind, space, verdict, ran, complete, stopped, overwrote, pc>>

Runs == pc = "loop" /\ groups # <<>> /\ (~ran \/ Group # {})

\* `if (exitClass(r.status) === 2) { stop = stopOf(r); break; }`
TlcErrors ==
  /\ Runs
  /\ stopped' = TRUE
  /\ ran' = TRUE
  /\ groups' = <<>>
  /\ UNCHANGED <<truth, propKind, space, verdict, complete, overwrote, pc>>

\* `else if (rule) decide(rule, "broken", r);`
\* TLC stops at the first safety rule it sees break and names it.
RuleBreaks ==
  /\ Runs
  /\ \E r \in Findable : Decide({r}, "broken")
  /\ ran' = TRUE
  /\ UNCHANGED <<truth, propKind, space, groups, complete, stopped, pc>>

\* `else if (cut && (r.status === 0 || broke?.kind === "temporal"))`
\* A bounded run stopped at the bound: nothing past it was seen. TLC can exit 0
\* or report a temporal break on the cut graph; both take this branch.
BoundReached ==
  /\ Runs
  /\ Findable = {}
  /\ ~Whole
  /\ Decide(Group, "not checked")
  /\ ran' = TRUE
  /\ UNCHANGED <<truth, propKind, space, groups, complete, stopped, pc>>

\* `else if (r.status === 0) { states.complete = true; ... "holds" }`
AllHold ==
  /\ Runs
  /\ Findable = {}
  /\ Whole
  /\ BrokenTemporal = {}
  /\ Decide(Group, "holds")
  /\ complete' = TRUE
  /\ ran' = TRUE
  /\ UNCHANGED <<truth, propKind, space, groups, stopped, pc>>

\* `else if (broke && properties.length)` with `broke.kind === "temporal"`:
\* TLC explored the whole graph, so every non-property rule holds. With one
\* property in the group, that property broke. With more, each one runs alone.
SetToSeq(S) ==
  CHOOSE f \in [1..Cardinality(S) -> S] : \A i, j \in 1..Cardinality(S) : i # j => f[i] # f[j]

TemporalBreaks ==
  /\ Runs
  /\ Findable = {}
  /\ Whole
  /\ BrokenTemporal # {}
  /\ LET others  == Group \ Properties
         pending == Group \cap Properties
         single  == Cardinality(pending) = 1
         order   == SetToSeq(pending)
     IN /\ verdict' = [r \in Rules |->
                         IF r \in others THEN "holds"
                         ELSE IF single /\ r \in pending THEN "broken"
                         ELSE verdict[r]]
        /\ overwrote' = (overwrote \/ \E r \in others \cup (IF single THEN pending ELSE {}) :
                                         verdict[r] # "none")
        \* `groups.splice(0, 1, rest, ...pending)`; `rest` is read after the
        \* decide() calls above, so it holds only non-properties still undecided.
        /\ groups' = IF single THEN groups
                     ELSE <<{r \in others : verdict'[r] = "none"}>>
                          \o [i \in 1..Len(order) |-> {order[i]}] \o Tail(groups)
  /\ complete' = TRUE
  /\ ran' = TRUE
  /\ UNCHANGED <<truth, propKind, space, stopped, pc>>

\* `for (const rule of all) if (!verdicts.has(ruleKey(rule))) decide(rule, "not checked");`
LoopEnds ==
  /\ pc = "loop" /\ groups = <<>>
  /\ Decide({r \in Rules : verdict[r] = "none"}, "not checked")
  /\ pc' = "done"
  /\ UNCHANGED <<truth, propKind, space, groups, ran, complete, stopped>>

\* judge() has returned. The run is over; this step only keeps TLC from
\* calling the end state a deadlock.
Returned == pc = "done" /\ UNCHANGED vars

Next ==
  GroupEmpty \/ TlcErrors \/ RuleBreaks \/ BoundReached \/ AllHold \/ TemporalBreaks
  \/ LoopEnds \/ Returned

Spec == Init /\ [][Next]_vars /\ WF_vars(Next)

\* --- What the user reads in the report, and why they can trust it.

\* "Rules that hold": a rule statechart says holds holds in the spec.
HoldsMeansHolds == \A r \in Rules : verdict[r] = "holds" => truth[r] = "holds"

\* A rule statechart says breaks does break.
BrokenMeansBroken == \A r \in Rules : verdict[r] = "broken" => truth[r] # "holds"

\* Each rule gets one verdict. decide() never replaces an earlier one.
OneVerdictEach == ~overwrote

\* A rule that breaks before the bound is reported, unless TLC itself failed.
EarlyBreaksAreFound ==
  pc = "done" /\ ~stopped => \A r \in Rules : truth[r] = "early" => verdict[r] = "broken"

\* On a graph smaller than the bound, every rule gets a real answer.
SmallGraphsAreDecided ==
  pc = "done" /\ ~stopped /\ space = "small" => \A r \in Rules : verdict[r] \in {"holds", "broken"}

\* judge() returns, whatever TLC answers.
Terminates == <>(pc = "done")
====
