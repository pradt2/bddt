# Behaviour-driven design testing (BDDT)

## Experiment

Use the familiar workflows of htop, an interactive Linux process monitor, to
test a design methodology before applying it to less well-understood domains.

1. **Phase 1 (this repository):** specify user needs, starting conditions and
   success criteria as executable, intentionally failing Behave scenarios.
2. **Phase 2 (not started):** design an interaction model and demonstrate that
   a user can achieve each goal with it.
3. **Phase 3 (not started):** review the design and the quality of the
   demonstrated workflows, not just their ability to pass the tests.

No application, interaction design, production code or simulated UI is
provided in phase 1.

## What a scenario specifies

Each scenario separates three kinds of information.

- **Private system fixture (Given):** synthetic, authoritative facts about
  the machine, its processes, the user's permissions, initial preferences,
  external events and constraints, as relevant. They are available to the
  test harness and future simulated operating system, not magically to the
  person using the application. Missing fields are not assertions that
  these properties are zero or unavailable.
- **User task brief (And):** the information the user legitimately starts
  with and the goal they want to achieve. It specifies what to accomplish,
  not the operations, interface or route to follow.
- **Independent evaluation (Then):** the result or observable state the
  harness must check. It is an oracle, not another user input.

For example, a user's task may be to identify and gracefully terminate the
highest-CPU encode job. The fixture knows several jobs' PIDs and CPU usage;
the user does not. The oracle specifies which job should receive SIGTERM
and which jobs should survive. Nothing prescribes a sort, search, keyboard
shortcut, menu or confirmation dialog.

The JSON is test data, not an application API or proposed domain model.
The generic When step is intentionally unimplemented. Do not infer an
interaction design from the names of the oracle's result fields.

## Phase 2 ground rules

A passing scenario must have a replayable workflow witness: a concrete
sequence of human-equivalent interactions and observations using the
candidate design. A witness may select actions based on observations.

- A witness starts with the task brief, not the private fixture or expected
  outcome. Every additional fact it uses must come from an available
  simulated user-facing observation or from an explicit external input.
  The simulated system may know the fixture, but must not expose its
  internals as a convenience channel for the witness.
- The independent harness controls the fixture, simulated time and external
  events. The witness cannot change those except through legitimate
  design interactions. The evaluator does not give hints or disclose
  expected values to the witness or application.
- Evaluate actual answers, observations, presentation state and simulated
  system effects from the executed witness; do not accept claimed success,
  canned results, direct assignments to oracle fields, or programs that
  encode hidden PIDs/answers in advance. The fact that a witness can be
  written does not establish that a real person can discover it easily.
- The oracle checks semantic outcomes, not visual layout or action count.
  For sets, order is immaterial unless the task requests a ranking, lineage
  or time sequence; canonicalise unordered collections before comparison.
  Use consistent units as given in the fixtures and briefs. Process effects
  are checked against an independent simulated system, including absence
  of unintended changes. Record successful signals in causal order
  (independent bulk targets can be sorted by PID); nice and affinity
  effects specify final permitted changes, not the number of interactions.
  For temporal scenarios check the actual observation at the relevant
  simulated time, not just the final state. A process that exits externally
  is not a process terminated by the user.
- Never send real signals or change real host processes in these tests.
- Do not silently weaken scenarios to accommodate a design. Any revision
  should be justified by the original user need and recorded for review.
  Later, change hidden fixtures (without changing the user goal) to check
  whether a workflow relies on accidentally memorised answers.

These are rules of the experiment, not a selection of the phase 2 design.
The current harness only establishes that the scenarios load and go red;
it does not yet enforce information isolation or replay evidence.

## Scope

52 scenarios across seven goal areas:

| Feature | Scenarios |
|---|---:|
| Understand the machine's current condition | 6 |
| Find and compare processes | 12 |
| Understand relationships and inspect details | 9 |
| Monitor a changing machine | 4 |
| Safely control processes | 12 |
| Personalise and reuse monitoring | 7 |
| Recognise capability limits | 2 |

The baseline is representative Linux htop functionality, not a claim of
complete compatibility or identical terminal presentation. Tags identify
extended capabilities (`@extended`), failure/safety cases (`@edge`), and
environment constraints (`@constraint`). Some extended/safety cases are
desired properties of the candidate design rather than verified guarantees
of htop itself. All are included by default.

Not in scope: exhaustively reproducing every key binding, CLI option,
platform-specific metric, external debugging command, or visual detail.
Sources for capability selection: [htop README](https://github.com/htop-dev/htop/blob/main/README.md),
[htop manual](https://github.com/htop-dev/htop/blob/main/htop.1.in) and
[htop FAQ](https://htop.dev/faq.html). These are references for the problem
domain, not the candidate design.

## Run the red suite

```sh
python -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
python -m behave
```

Expected in phase 1: all 52 scenarios fail at the independent evaluation
step with `PHASE_1_RED: no candidate workflow has been implemented`; no
undefined or erroneous steps. The nonzero exit status is intentional.
Use `python -m behave --dry-run` to check step binding without executing.
