---
name: feature-implement
description: Use this skill when a spec exists in `.specs/` and the user wants to turn it into code — phrases like "implement this spec", "implement `.specs/foo`", "let's build the spec", "start coding the auth umbrella", "kick off implementation", or right after `feature-spec` saves a spec and the user says "let's go". Resolves the target spec (from an explicit argument or by listing `.specs/`), reads it to count phases and gauge complexity, then surfaces two execution modes — a team of background agents (large multi-phase work) or single-session implementation (small focused changes) — with a recommendation grounded in the spec itself. Always offers both options; never silently picks. Skip when no spec exists yet (route the user to `feature-spec`) or when the change is mechanical enough to just do.
---

# Feature Implement

You are turning a written spec in `.specs/` into shipped code. The spec is the authority — your job is to execute it faithfully, not re-design it. Before any code, you decide *how* the work runs: as a team of background agents (parallel or sequential phases) or in this session, top-to-bottom. The choice is real; both are normal.

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
   - Otherwise glob `.specs/*.md` (standalone) and `.specs/*/SPEC_PLAN.md` (umbrellas). One match → use it; multiple matches → ask which one to implement; none → tell the user there's nothing in `.specs/` and recommend `feature-spec` first.
   - If the resolved target is an **umbrella** (`SPEC_PLAN.md`), ask whether to implement a single sub-spec, a contiguous slice, or the whole umbrella. Before doing the whole umbrella in one go, recommend `feature-spec-audit` first — drift across siblings is much cheaper to fix in prose than in code.

2. **Read everything that matters.** The spec is the brief.
   - Standalone spec: read the one file.
   - Umbrella whole or slice: read `SPEC_PLAN.md` plus every sub-spec in scope. Skip files starting with `_`.
   - Note: explicit *Phases* section, *Out of scope*, *Open questions*, *Migration / rollout*, *Dependencies*. Phases are the single most important signal — `feature-spec` adds them deliberately when its confidence was below ~90%, which means the spec author *already* split the work for you.
   - If *Open questions* is non-empty or any `[?: …]` markers remain, stop and tell the user — the spec is not ready for implementation. Offer to loop back to `feature-spec` to resolve them.

3. **Plan the implementation.** Produce two numbers and one judgement:
   - **Phases (P)**: if the spec has a *Phases* section, use it verbatim. If not, infer phases from the *Changes* sub-sections (data model → API → UI is the canonical ordering when more than one is present); a single-subsystem change is P=1.
   - **Independent work units within each phase (W)**: how many pieces inside a phase could a separate agent own without stepping on another's edits? Different packages, different files, clearly disjoint scopes = W>1. Anything sharing a file or a tightly-coupled module = W=1.
   - **Risk shape**: migrations, public-API changes, auth/security, async/queue logic, and cross-package refactors all push toward fewer agents and more verification between phases. Pure additive UI or new endpoint with no migration pushes the other way.

   Translate (P, W, risk) into an agent count for the *team-of-agents* option: agents needed ≈ sum of W across phases, capped at the parallelism the project can actually handle without conflict. For single-session mode, this is just "you do all of it in order."

4. **Present the plan and recommend.** One compact summary in chat, then a picker. Shape:

   ```
   **Spec:** `.specs/<path>` (<umbrella | standalone>)
   **Phases:** <P> — <one short line per phase: name and what ships at the end>
   **Agent count (if team mode):** <N>  (<parallel | sequential | mixed>)
   **Risk notes:** <1-2 bullets only when there's real risk; omit otherwise>

   **Recommendation:** <team | session> — <one sentence why, grounded in the spec>
   ```

   Then offer both options via `AskUserQuestion` (Header: `Approach`):
   - **Team of agents** — spawn agents to do the work; this session coordinates.
   - **Current session** — implement here, phase by phase, with todo tracking.

   The recommendation rule of thumb (use judgement, not a checklist):
   - **Single session** when P=1 and W=1, or when the whole change is <~5 files and tightly coupled (refactors, careful migrations, security-sensitive code).
   - **Team of agents** when P≥3, when W>1 within phases (genuinely parallel work), or when the spec is long enough that one session will burn its context window before finishing.
   - **Mixed** (start in session, hand off later) is fine — say so explicitly if you're recommending it.

5. **Execute the chosen mode.** See *Execution modes* below. Whichever path runs, end the session with a short report (what shipped, what didn't, what to verify) and remind the user about `doc-generator` to close the spec loop.

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

### Current session

You do the work here, phase by phase. Use `TaskCreate` to capture **one task per phase** (or per work unit if P=1 but the change is non-trivial) — the phase framing is what makes session mode tractable on a multi-phase spec.

The trade-off: session mode gives the user full visibility on every edit, but a long spec can exhaust the context window. If you start in session mode and realize halfway it's larger than estimated, surface that and offer to hand the remaining phases to a team of agents.

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
- **Honest recommendation.** Say which mode you'd pick and why in one sentence. Don't hedge between both.
- **Both options always offered.** Even when you recommend session strongly, present team as a valid pick; even when you recommend team, leave session on the table.
- **Verification, not vibes.** When a phase finishes, you ran the project's tests or did a real check before saying "done."

## What to avoid

- **Re-designing the spec.** If you find yourself disagreeing with the *Approach*, stop and route back to `feature-spec` or `feature-brainstorm` — don't quietly substitute your design.
- **Spawning agents for trivial work.** A two-file UI tweak gets a single session, not a team of three. The team-of-agents option is for real scope, not theatre.
- **Parallel agents on overlapping files.** This causes silent edit collisions. When in doubt, go sequential.
- **Trusting an agent's "done" report blindly.** Always verify against the spec's *Changes* and run the project's tests/typecheck before you tell the user a phase is shipped.
- **Closing the loop yourself.** When implementation lands, remind the user about `doc-generator` — that's the skill that updates `docs/` and flips umbrella checkboxes. This skill writes code; it doesn't write docs.
- **Skipping the plan summary.** Even when the recommendation is obvious, show the user P, agent count, and the per-phase one-liners before executing. The picker without context is opaque.

## Saving state across sessions

If implementation pauses partway (team mode finishes phase 1 but not phase 2; the user closes the session and resumes tomorrow), leave the spec file *unchanged* — it is the source of truth. State that lives only in this conversation (which phase ran, which agent finished what) is fine to let go: the next invocation re-reads the spec, sees which phase the code reflects, and picks up. Do not edit the spec to add "[done]" markers — that's `doc-generator`'s job once the change ships and is documented.

For umbrella specs, the `SPEC_PLAN.md` checkboxes also stay untouched here — they flip when `doc-generator` confirms documentation has captured the sub-feature, not when code lands.

## Why this exists

`feature-brainstorm` decides *what* to build. `feature-spec` writes it down. `doc-generator` records what shipped. This skill is the missing middle — *how* to actually run the implementation, given the spec already exists. The interesting decision isn't whether to implement (the user has decided that by invoking the skill); it's whether to do it inline or hand it to a team of agents. That choice matters because it determines context usage, parallelism, and how much the user gets to watch — and getting it wrong (one mega session for a four-phase umbrella, or a team of three for a one-file tweak) wastes time. This skill exists to make that call deliberately, with the spec itself as the evidence.
