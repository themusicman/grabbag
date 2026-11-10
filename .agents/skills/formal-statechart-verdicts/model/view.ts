// View for reading StatechartVerdicts results with /statechart.
// Each state reads as what statechart's report would say so far, next to
// what is true of the spec under check.

type Vars = {
  space: string;
  pc: string;
  stopped: boolean;
  verdict: Record<string, string>;
  truth: Record<string, string>;
};

const TRUTH: Record<string, string> = {
  holds: "holds",
  early: "breaks before the bound",
  late: "breaks only past the bound",
  broken: "breaks (temporal)",
};

export const title = "statechart rule verdicts (run.ts judge())";

export const state = (v: Vars) => {
  const graph = v.space === "small" ? "graph under 100,000 states" : "graph over 100,000 states";
  const said = Object.keys(v.verdict)
    .filter((r) => v.verdict[r] !== "none")
    .map((r) => `${r} reported ${v.verdict[r]}, ${TRUTH[v.truth[r]]}`);
  const phase = v.pc === "done" ? "report written" : v.stopped ? "TLC failed" : "checking";
  return `${phase}; ${graph}${said.length ? "; " + said.join("; ") : ""}`;
};

const STEPS: Record<string, string | null> = {
  RuleBreaks: "TLC names a rule that breaks",
  BoundReached: "a rerun stops at 100,000 states",
  AllHold: "TLC finishes with no break",
  TemporalBreaks: "TLC reports an unnamed temporal break",
  GroupEmpty: "every rule in the group has a verdict",
  TlcErrors: "TLC fails",
  LoopEnds: "the rest are marked not checked",
  Returned: null,
};

export const step = (action: string) => (action in STEPS ? STEPS[action] : action);
