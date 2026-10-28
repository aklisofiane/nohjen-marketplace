---
name: feature-implement
description: Use this skill when a spec exists in `.specs/` and the user wants to turn it into code — phrases like "implement this spec", "implement `.specs/foo`", "let's build the spec", "start coding the auth umbrella", "kick off implementation", or right after `feature-spec` saves a spec and the user says "let's go". Resolves the target spec (from an explicit argument or by listing `.specs/`), reads it to count phases and gauge complexity, then surfaces the execution modes — a dynamic workflow (scripted orchestration for complex multi-phase work), a team of background agents (large sequential work), or single-session implementation (small focused changes) — with a recommendation grounded in the spec itself. Always offers the options; never silently picks. Skip when no spec exists yet (route the user to `feature-spec`) or when the change is mechanical enough to just do.
---

# Feature Implement

You are turning a written spec in `.specs/` into shipped code. The spec is the authority — your job is to execute it faithfully, not re-design it. Before any code, you decide *how* the work runs: as a scripted dynamic workflow, as a team of background agents, or in this session, top-to-bottom. The choice is real; all three are normal.

## When to use this skill

Trigger when there is (or could be) a spec at `.specs/` and the user wants to start building:
- "Implement the spec for [X]" / "Let's implement `.specs/<name>`"
- "Build the auth umbrella" / "Start coding what we just spec'd"
- Right after `feature-spec` writes a file and the user says "let's go" / "implement it now"
- "Kick off implementation" / "Get a team of agents on this"

**Do not trigger** when:
- `.specs/` is empty or the named spec doesn't exist — point the user at `feature-spec` instead.
- The change is mechanical (rename, typo, obvious one-line fix) — just do it; no spec to follow.
- The user wants to *change* the spec, not implement it — that's back to `feature-spec` or `feature-brainstorm`.
- The user is mid-implementation and wants help finishing a single piece — just help them; this skill is for kickoff.

## The flow

> When asking the user to pick between specs or execution modes, prefer `AskUserQuestion` if available. Keep option labels short; put the recommendation reason in the chat text above the picker.

1. **Resolve the target spec.**
   - If the user named one (`.specs/auth/session-strategy.md`, "the workflow-row-actions spec", "the auth umbrella"), use it. Resolve umbrella names by globbing `.specs/<name>/SPEC_PLAN.md`.
   - Otherwise glob `.specs/*.md` (standalone) and `.specs/*/SPEC_PLAN.md` (umbrellas), skipping files that start with `_` (drafts and notes — a `_<slug>.draft.md` is a spec still in review). One match → use it; multiple matches → ask which one to implement; none → tell the user there's nothing in `.specs/` and recommend `feature-spec` first.
   - If the resolved target is an **umbrella** (`SPEC_PLAN.md`), ask whether to implement a single sub-spec, a contiguous slice, or the whole umbrella. Before doing the whole umbrella in one go, recommend `feature-spec-audit` first — drift across siblings is much cheaper to fix in prose than in code.

2. **Read everything that matters.** The spec is the brief.
   - Standalone spec: read the one file.
   - Umbrella whole or slice: read `SPEC_PLAN.md` plus every sub-spec in scope. Skip files starting with `_`.
   - Note: explicit *Phases* section, *Out of scope*, *Open questions*, *Migration / rollout*, *Dependencies*. Phases are the single most important signal — `feature-spec` adds them deliberately when its confidence was below ~90%, which means the spec author *already* split the work for you.
   - If *Open questions* is non-empty or any `[?: …]` markers remain, stop and tell the user — the spec is not ready for implementation. Offer to loop back to `feature-spec` to resolve them.

3. **Plan the implementation.** Produce three numbers and one judgement:
   - **Phases (P)**: if the spec has a *Phases* section, use it verbatim. If not, infer phases from the *Changes* sub-sections (data model → API → UI is the canonical ordering when more than one is present); a single-subsystem change is P=1.
   - **Independent work units within each phase (W)**: how many pieces inside a phase could a separate agent own without stepping on another's edits? Different packages, different files, clearly disjoint scopes = W>1. Anything sharing a file or a tightly-coupled module = W=1.
   - **Files touched (F)**: a rough count of files the *Changes* sub-sections imply creating or editing. A spec-grounded estimate is enough — don't audit the codebase for precision.
   - **Risk shape**: migrations, public-API changes, auth/security, async/queue logic, and cross-package refactors all push toward fewer agents and more verification between phases. Pure additive UI or new endpoint with no migration pushes the other way.

   Translate (P, W, risk) into an agent count for the *team-of-agents* and *workflow* options: agents needed ≈ sum of W across phases (plus one verify agent per phase in workflow mode), capped at the parallelism the project can actually handle without conflict. For single-session mode, this is just "you do all of it in order."

4. **Present the plan and recommend.** One compact summary in chat, then a picker. Shape:

   ```
   **Spec:** `.specs/<path>` (<umbrella | standalone>)
   **Phases:** <P> — <one short line per phase: name and what ships at the end>
   **Est. files touched:** <F>
   **Agent count (if team / workflow mode):** <N>  (<parallel | sequential | mixed>)
   **Risk notes:** <1-2 bullets only when there's real risk; omit otherwise>

   **Recommendation:** <session | team | workflow> — <one sentence why, grounded in the spec>
   ```

   Then offer the options via `AskUserQuestion` (Header: `Approach`):
   - **Current session** — implement here, phase by phase, with todo tracking.
   - **Team of agents** — spawn agents to do the work; this session coordinates.
   - **Dynamic workflow** — a scripted `Workflow` run: sequential phases, parallel work units, a verify stage per phase. Only offer this when the `Workflow` tool is available in the session.

   The recommendation rule of thumb (use judgement, not a checklist):
   - **Single session** when P=1 and W=1, or when the whole change is <~5 files and tightly coupled (refactors, careful migrations, security-sensitive code).
   - **Team of agents** when P≥2 and the phases are mostly sequential hand-offs (W≈1) — too big for one session, but without real internal parallelism to script.
   - **Dynamic workflow** when P≥3, or W>1 inside phases (genuinely parallel units), or the run is likely to be interrupted and retried — scripted verify stages and cached resume earn their setup cost there.
   - **Context proxy** for "too big for one session": use F. Up to ~8 files a session is comfortable; ~8–15 is borderline (lean team or workflow); beyond ~15 files — or more than ~500 lines of in-scope spec prose — one session will likely exhaust its context before finishing, so recommend team or workflow.
   - **Mixed** (start in session, hand off later) is fine — say so explicitly if you're recommending it.

5. **Execute the chosen mode.** See *Execution modes* below. Every phase, in every mode, ends with the *Verification gate* before the next phase starts. Whichever path runs, end with a short report: what shipped, what didn't, what to verify manually.

6. **Close the loop with `doc-generator`.** Once the final phase passes the verification gate, offer to document the implementation now (`AskUserQuestion`, Header: `Docs` — *Document now* / *Later*). If the user picks now, invoke the `doc-generator` skill scoped to the files this implementation touched (or the resulting commit). This matters most in workflow and team modes: the coordinating session knows exactly which files changed, and that scope is lost by the next session. If the user defers, remind them that `doc-generator` is also what flips umbrella checkboxes — the spec stays open until it runs.

## Execution modes

### Team of agents

This session coordinates; agents do the work. The skill-specific guidance is *what to put in their prompts* and *what shape the team takes* — the rest is normal Agent-tool usage.

Every spawned agent's prompt must include:
- **The exact spec file path(s)** — agents read the spec themselves; don't paraphrase it for them.
- **An explicit scope** — which phase or work unit they own, and what they *must not* touch (usually the *Out of scope* section plus any sibling phases).

Pick the right shape:
- **Sequential phases** (most common). One Agent per phase, await its result, then spawn the next. Each phase's report informs the next phase's prompt. Default to `subagent_type=general-purpose` unless a project-specific specialist fits.
- **Parallel within a phase**. When W>1 and the work units are genuinely disjoint (different files, different packages), spawn multiple Agents in a **single message** to run concurrently. **Hard rule: parallel agents must not edit overlapping files.** If you can't guarantee that, go sequential.
- **Worktree isolation**. Use `isolation: "worktree"` only when parallel agents would otherwise collide and the user explicitly wants to merge later. Default is shared workspace — simpler, fewer surprises.

### Dynamic workflow

For complex specs — P≥3, real parallelism inside phases, or a run you expect to pause and retry — orchestrate with the `Workflow` tool instead of hand-managing agents: you write a script once, and the runtime handles sequencing, fan-out, and caching. The user picking this mode in the picker is the explicit opt-in the tool requires. If the `Workflow` tool isn't available in the session, don't offer the mode; if the user asks for it anyway, say so and fall back to team mode.

Shape the script from the spec:

- **One `phase()` per spec phase**, using the spec's phase names verbatim (mirrored in `meta.phases`).
- **Sequential between phases, parallel within.** Await each phase before starting the next; inside a phase, fan out over work units with `parallel()` or `pipeline()`. The same hard rule as team mode applies: parallel agents must not edit overlapping files — use `isolation: 'worktree'` only when collision is otherwise unavoidable.
- **A verify stage at the end of each phase** — a verification agent running the *Verification gate* below, so the script can't advance past a broken phase. Have it return a pass/fail verdict via the `schema` option and stop the script (or re-run the phase once) on failure.
- **Agent prompts follow the same rules as team mode**: exact spec path(s), explicit scope, explicit out-of-scope.
- **Return structured results** so the final report cites what each phase actually shipped rather than paraphrasing agent claims.

The payoff over team mode is determinism and resumability: if a late phase fails or you refine the script mid-run, relaunch with `resumeFromRunId` — completed phases return cached results and only the remaining work re-runs (same session only; across sessions the code plus spec remain the source of truth, as always).

### Current session

You do the work here, phase by phase. Use `TaskCreate` to capture **one task per phase** (or per work unit if P=1 but the change is non-trivial) — the phase framing is what makes session mode tractable on a multi-phase spec.

The trade-off: session mode gives the user full visibility on every edit, but a long spec can exhaust the context window. If you start in session mode and realize halfway it's larger than estimated, surface that and offer to hand the remaining phases to a team of agents or a workflow.

### Verification gate (all modes)

A phase is not done until it passes this gate, no matter who did the work:

1. **Run the project's checks** — tests, typecheck, lint; whatever the repo actually uses.
2. **Diff against the spec** — walk the phase's *Changes* items and confirm each exists in the code. An agent's "done" report is a claim, not evidence.
3. **Only then report the phase as shipped**, and feed anything learned into the next phase's prompt or todo.

If the gate fails, fix within the phase before moving on — never stack a new phase on unverified work.

## How to read a spec well

The spec author wrote things in specific places for a reason. Lean on the structure rather than re-reading top-to-bottom for every decision:

- ***Approach*** tells you the shape — match it; don't reinvent.
- ***Changes*** is the work list. If a sub-section is empty, the spec is saying "no change in that dimension."
- ***Open questions*** and `[?: …]` markers are blockers. Do not implement past them.
- ***Out of scope*** is the fence. If an agent or you start drifting into out-of-scope territory, stop.
- ***Phases*** is your work breakdown — already done for you when present.
- ***Migration / rollout*** changes the recommended mode toward session or sequential agents; never run a migration phase in parallel with anything that depends on its outcome.

## What good output looks like

- **Spec-grounded plan.** The plan you present cites the spec — phases come from the *Phases* section by name, agent counts from the actual *Changes* sub-sections. Generic "looks medium-sized, 3 agents" is not enough.
- **Honest recommendation.** Say which mode you'd pick and why in one sentence. Don't hedge between them.
- **All options always offered.** Even when you recommend session strongly, present team and workflow as valid picks; even when you recommend a workflow, leave session on the table.
- **Verification, not vibes.** Every phase went through the *Verification gate* — checks ran and the *Changes* items were confirmed in code — before you said "done."

## What to avoid

- **Re-designing the spec.** If you find yourself disagreeing with the *Approach*, stop and route back to `feature-spec` or `feature-brainstorm` — don't quietly substitute your design.
- **Spawning agents for trivial work.** A two-file UI tweak gets a single session, not a team of three. The team-of-agents option is for real scope, not theatre.
- **Parallel agents on overlapping files.** This causes silent edit collisions. When in doubt, go sequential.
- **Trusting an agent's "done" report blindly.** The *Verification gate* exists precisely because agents over-report; in workflow mode, encode it as a verify stage rather than trusting the implementation agents' returns.
- **Writing docs by hand.** This skill writes code; documentation goes through `doc-generator` (step 6) — that's the skill that updates `docs/` and flips umbrella checkboxes. Offer to invoke it when implementation lands; don't reproduce its job inline.
- **Spawning a workflow without the pick.** The workflow mode runs only when the user selects it in the picker (or asked for it outright) — never launch `Workflow` just because the spec looks big.
- **Skipping the plan summary.** Even when the recommendation is obvious, show the user P, agent count, and the per-phase one-liners before executing. The picker without context is opaque.

## Saving state across sessions

If implementation pauses partway (team mode finishes phase 1 but not phase 2; the user closes the session and resumes tomorrow), leave the spec file *unchanged* — it is the source of truth. Within a session, a paused or failed workflow run resumes via `resumeFromRunId`; across sessions there is no such shortcut — the next invocation re-reads the spec and the code as below. State that lives only in this conversation (which phase ran, which agent finished what) is fine to let go: the next invocation re-reads the spec, sees which phase the code reflects, and picks up. Do not edit the spec to add "[done]" markers — that's `doc-generator`'s job once the change ships and is documented.

For umbrella specs, the `SPEC_PLAN.md` checkboxes also stay untouched here — they flip when `doc-generator` confirms documentation has captured the sub-feature, not when code lands.

## Why this exists

`feature-brainstorm` decides *what* to build. `feature-spec` writes it down. `doc-generator` records what shipped. This skill is the missing middle — *how* to actually run the implementation, given the spec already exists. The interesting decision isn't whether to implement (the user has decided that by invoking the skill); it's whether to do it inline, hand it to a team of agents, or script it as a workflow. That choice matters because it determines context usage, parallelism, resumability, and how much the user gets to watch — and getting it wrong (one mega session for a four-phase umbrella, or a scripted workflow for a one-file tweak) wastes time. This skill exists to make that call deliberately, with the spec itself as the evidence.
