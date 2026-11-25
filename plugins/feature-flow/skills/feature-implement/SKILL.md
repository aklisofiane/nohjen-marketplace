---
name: feature-implement
description: Use when a spec in `.specs/` should become code — "implement this spec", "build `.specs/foo`", "kick off implementation", or "let's go" right after feature-spec saves one. Plans phases from the spec, offers to run in this session or with a team of agents, gates every phase on the read-only spec-verifier agent, and ends with a whole-diff check, a code review and a report page of what shipped. Not when no spec exists (feature-spec), to change a spec, or for mechanical edits.
---

# Feature Implement

You are turning a written spec in `.specs/` into shipped code. The spec is the authority — execute it faithfully, don't re-design it. Before any code, you decide *how* the work runs: in this session, or with a team of agents this session coordinates. Either way, an agent that can't edit checks the result against the spec, and the run ends with a report page that proves what shipped.

**Do not use** when `.specs/` has no matching spec (point to `feature-spec`), the change is mechanical, the user wants to *change* the spec (`feature-spec` or `feature-brainstorm`), or they're mid-implementation and want help with one piece.

## The flow

> When asking the user to pick between specs or modes, prefer `AskUserQuestion` if available. Short option labels; the reason goes in the chat text above the picker.

1. **Resolve the target spec.**
   - If the user named one (`.specs/auth/session-strategy.md`, "the auth umbrella"), use it; umbrellas resolve via `.specs/<name>/SPEC_PLAN.md`.
   - Otherwise glob `.specs/*.md` and `.specs/*/SPEC_PLAN.md`, skipping files that start with `_` (drafts and notes). One match → use it; several → ask; none → recommend `feature-spec`.
   - For an **umbrella**, ask whether to implement one sub-spec, a contiguous slice, or all of it. Before the whole umbrella, recommend `feature-spec-audit`: drift between siblings is cheaper to fix in prose than in code.

2. **Read everything in scope:** the spec, or `SPEC_PLAN.md` plus every sub-spec in scope (skip `_` files). Note *Phases*, *Out of scope*, *Open questions*, *Migration / rollout*, *Dependencies*. Phases matter most: `feature-spec` adds them when its confidence was below ~90%. If *Open questions* is non-empty or a `[?: …]` marker remains, stop: the spec isn't ready. Offer to resolve them with `feature-spec`.

3. **Plan.** Three numbers and one judgement:
   - **Phases (P):** the *Phases* section verbatim, or inferred from *Changes* (data model → API → UI); a single-subsystem change is P=1.
   - **Independent work units per phase (W):** pieces a separate agent could own without touching another's files. Anything sharing a file or a tightly coupled module is W=1.
   - **Files touched (F):** a rough count from *Changes*.
   - **Risk shape:** migrations, public-API changes, auth/security, async/queue logic and cross-package refactors call for care inside each phase and never run in parallel with what depends on them.

   **Mode rule:** **session** for a small spec — P=1, about 8 files or fewer, tightly coupled; **team** for everything else. A team is the implementers (the sum of W) plus one verifier per phase and one for the whole diff.

4. **Present the plan and recommend**, then offer the modes via `AskUserQuestion` (header `Approach`):

   ```
   **Spec:** `.specs/<path>` (<umbrella | standalone>)
   **Phases:** <P> — <one short line per phase: name and what ships>
   **Est. files touched:** <F>
   **Agents (team mode):** <N> — <implementers, parallel or sequential> + <verifiers>
   **Risk notes:** <1-2 bullets only when there's real risk>
   **Recommendation:** <session | team> — <one sentence why, grounded in the spec>
   ```

   - **Current session** — implement here, phase by phase, with the project's checks after each.
   - **Team of agents** — implementers build each phase, `spec-verifier` checks it; this session coordinates and writes no code.

   If the spec commits to something that clears the *You should know* bar (`<this skill's directory>/../../shared/answerable-page.md`) — a breaking change, an irreversible migration, a manual deploy step — lead the plan with a `**⚠ You should know**` block, so the user sees it before choosing.

   A user who asks for a scripted workflow in their own words gets one under the Workflow tool's own rules, outside this skill.

5. **Kick off.** Record the base commit (`git rev-parse HEAD`): every verifier diffs against it. If the working tree already has changes, name them to the user and list them to the verifiers as there before the run. The run never commits or stashes.

6. **Execute** the chosen mode, phase by phase, each through the *Verification gate*.

7. **Final check**, in both modes.

8. **Build the report page** whenever the run ends, finished or stopped. Read `references/report-page.md`. Its next step offers `doc-generator`.

## Team of agents

This session coordinates: it spawns agents, routes findings and reads verdicts; it writes no code, so its context lasts the whole run. Name each agent (`impl-1`, `impl-2a`, `verify-1`) so follow-ups reach it with `SendMessage`, which resumes it with its history.

**One loop per phase:**

1. **Implementers** — `general-purpose` agents. Each prompt gives the exact spec path(s) (agents read the spec themselves; don't paraphrase it), the scope they own by name and *Changes* items, what they must not touch (*Out of scope*, other phases, other units' files), and to report back the files they changed. Disjoint units run in parallel, sent in one message. **Parallel agents never edit overlapping files** — if you can't guarantee that, go sequential.
2. **Verifier** — a `feature-flow:spec-verifier` agent (prompt below), never given the implementer's report.
3. **Fail** — forward the verdict's *Findings* (the blocking ones) word for word to the same implementer with `SendMessage`, then ask the same verifier to check again. Up to 2 fix rounds; after that the run stops and the report shows the failing phase.
4. **Pass** — next phase, with anything learned (a convention, a moved file) folded into its implementers' prompts.

Keep a map of which implementer changed which files (their reports, and `git status --porcelain` after each phase): fixes go to the file's owner.

## Current session

You do the work here, one task per phase in the task list (or per work unit if P=1 but non-trivial). After each phase, run the gate yourself; the independent read comes from the whole-diff verifier. The user sees every edit, but a long spec can exhaust the context window: if the spec turns out larger than estimated, say so and offer to hand the remaining phases to a team.

## The verifier

`feature-flow:spec-verifier` checks code against a spec. It can't edit, keeps Bash for the project's checks and whatever browser tool the session has for screenshots, and returns a fixed verdict: pass or fail, each *Changes* item as done, partial or missing with `file:line`, edits outside the scope, checks run, proof, blocking *Findings*, non-blocking *Noted*, and *You should know*. On a phase it runs the related tests; on the whole spec, the full suite.

```
Spec: <path>
Scope: Phase <N> · <name> — <its Changes items> | the whole spec, grouped by phase
Base commit: <sha>
Proof folder: .specs/_<slug>.proof/
Earlier phases: <names, or none>
There before the run: <files, or none>
```

`<slug>` names the run's files: the spec's file name without `.md`, or for an umbrella run, the umbrella's name (with the sub-spec's for a single one: `auth-session-strategy`). The proof folder's leading `_` keeps the other skills out of it.

## Verification gate

A phase isn't done until it passes this gate, whoever did the work:

- **Team mode:** the verifier's verdict is the gate. You read verdicts; an implementer's "done" is a claim, not evidence.
- **Session mode:** run the project's analyze, typecheck and lint, the tests related to the changed files (the full suite waits for the final check), and confirm each of the phase's *Changes* items exists.

If the gate fails, fix within the phase — never stack a new phase on unverified work.

## Final check

1. **Whole-diff verifier** on the whole spec, grouped by phase. It catches what one phase broke in another; in session mode it's the only independent read. A fail gets up to 2 fix rounds.
2. **`/code-review` once** on the run's changes (the current diff, since nothing was committed); keep only findings in files the run changed. Fix its high-confidence findings before the report — team mode: send each to the file's implementer, or to a new `general-purpose` agent if that one can't be resumed; session mode: fix them here. No `/code-review` in the session: say so on the report.
3. **Whole-diff verifier once more**, by `SendMessage` to the same one, only if a review fix changed a file. If a review fix broke something, it gets what's left of the 2 fix rounds; then the run stops.

In session mode, the report's phase cards come from this verdict, grouped by phase.

## How to read a spec

- ***Approach*** is the shape — match it.
- ***Changes*** is the work list; an absent sub-section means no change there.
- **A `mockup`** is the UI's target arrangement, wording and states — build it with the project's own components, don't copy its markup. The verifier screenshots each state it names.
- ***Open questions*** and `[?: …]` markers are blockers.
- ***Out of scope*** is the fence.
- ***Migration / rollout*** pushes toward sequential phases; never run a migration in parallel with what depends on it.

## What to avoid

- **Re-designing the spec.** Disagree with the *Approach*? Stop and route back to `feature-spec` or `feature-brainstorm`.
- **Agents for trivial work.** A two-file tweak is a session, not a team of three.
- **Parallel agents on overlapping files.**
- **Writing code as the coordinator** in team mode.
- **Giving the verifier the implementer's report**, or paraphrasing findings to the implementer.
- **Writing docs by hand** — that's `doc-generator`, from the report's next step.
- **A report built from claims.** Every card, count, screenshot and *You should know* item comes from a verdict or the spec.

## Pausing across sessions

If implementation stops partway, leave the spec *unchanged*: the next run re-reads it, sees which phases the code reflects, and picks up. No "[done]" markers in the spec and no `SPEC_PLAN.md` checkboxes here — `doc-generator` owns those once the change ships.
