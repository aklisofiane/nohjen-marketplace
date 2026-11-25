---
name: feature-spec-audit
description: Use to check an umbrella spec (`.specs/<umbrella>/` with a SPEC_PLAN.md and several sub-specs) for contradictions, gaps, plan drift and open questions — "audit my umbrella spec", "do my specs contradict each other", "check .specs/auth for drift", "is anything missing", or before implementing a whole umbrella. Read-only: a chat report with file paths and quoted excerpts; saves it to `_audit.md` only on request. Not for a single standalone spec, or for spec-vs-code or spec-vs-docs drift.
---

# Feature Spec Audit

You are auditing an umbrella spec tree — `SPEC_PLAN.md` plus several sub-spec files at `.specs/<umbrella>/` — for coherence between the parts. Sub-specs are written one at a time and often across sessions, so two of them can disagree on the data model, on what's in or out of scope, on naming, or on assumptions about each other. This skill reads them all together and reports the inconsistencies.

The skill is **read-only**. It produces a chat report. It does not edit spec files; the only write it may perform is saving the report itself to `.specs/<umbrella>/_audit.md`, and only when the user asks. After the report, the user can ask the model to fix the issues — that's a normal follow-up, not part of the audit.

## When to use this skill

Trigger when the user asks to audit, sanity-check, or coherence-check an umbrella, or when an umbrella is about to enter implementation:
- "Audit `.specs/auth`" / "audit my umbrella spec"
- "Check coherence across the sub-specs"
- "Do these specs contradict each other?"
- "Is anything missing in `.specs/<umbrella>`?"
- "Review `.specs/<name>` for drift before I implement it"
- After the user signals they're about to start coding across an umbrella ("let's start implementing the auth umbrella"): recommend an audit pass first, then run only if they confirm.

**Do not trigger** when:
- The user has a single standalone spec at `.specs/<feature>.md` (no `SPEC_PLAN.md`, no siblings) — there's nothing cross-spec to check.
- The user wants to compare specs against the codebase or `docs/` — that's `doc-generator`'s territory (specs vs. shipped behaviour) or normal code review (code vs. spec).
- The user wants to re-litigate a decision inside one sub-spec — that's `feature-brainstorm` if a direction needs revisiting.
- The umbrella has only one sub-spec written besides the plan — there's nothing to compare yet; say so and stop.

## The flow

1. **Resolve the target umbrella.** If the user named one (e.g., "audit `.specs/auth`"), use it. Otherwise glob `.specs/*/SPEC_PLAN.md`. One match → use it. Multiple matches → ask which umbrella to audit. No matches → tell the user there's no umbrella spec at `.specs/` and stop.

2. **Load every relevant file.** Read `SPEC_PLAN.md` and every `*.md` sibling under `.specs/<umbrella>/`. Skip files starting with `_` (a convention for user notes/drafts excluded from the audit). If only one sub-spec is present besides the plan, tell the user there's nothing to cross-check yet and stop.

3. **Run the four passes** (see *What it checks* below). Collect findings.

4. **Render the report in chat.** Use the format under *Output format*. Number findings globally so the user can reference them ("fix 1 and 3"). Cite file path, section heading, and quoted excerpts for every finding. Tag confidence when a finding depends on assumptions.

5. **Stop.** End with one line: *"Want me to fix any of these, or save this report to `.specs/<umbrella>/_audit.md` for later?"* Do not propose specific fixes, do not auto-edit spec files. Saving the report is the one write the skill may perform, and only on request — the `_` prefix keeps it out of future audits and out of `feature-implement`'s reads, so the findings survive across sessions without polluting the spec tree. If the user says yes to fixing, fix as a normal follow-up.

## What it checks

Run these four passes in order. **Favor precision over recall**: if a finding is ambiguous, mark it as `confidence: medium` rather than asserting it. A confident report of three real contradictions beats a noisy report of twelve possibles.

### Pass 1 — Contradictions

Two sub-specs make incompatible factual claims about the same thing.
- **Data shape.** `provider-choice.md` says sessions are JWTs in cookies; `session-strategy.md` says sessions are server-side rows keyed by an opaque token.
- **Naming.** One spec uses `users.email`, another `users.email_address` for the same field.
- **Identifier types.** One says user IDs are UUIDs, another says auto-increment integers.
- **Scope boundaries.** Sub-spec A's *Out of scope* declares X; sub-spec B's *Approach* assumes X exists.

### Pass 2 — Gaps

A sub-spec depends on something that no other sub-spec (or `SPEC_PLAN.md` cross-cutting note) actually defines.
- A sub-spec references an entity, table, endpoint, module, or capability that no sibling specifies.
- A sub-spec assumes behaviour ("once the user has logged in…") that another sub-spec was supposed to cover but is absent or unfinished.

### Pass 3 — Plan ↔ sub-spec alignment

- Items in `SPEC_PLAN.md` § *Decomposition* with no corresponding sub-spec file (the umbrella names a piece nobody has written).
- Sub-spec files that don't correspond to any *Decomposition* item (a stray sub-spec — possibly renamed, possibly added without updating the plan).
- Cross-cutting notes in `SPEC_PLAN.md` that one or more sub-specs appear to violate.

### Pass 4 — Open-question hygiene

Surface unresolved blockers that `feature-spec` itself flags as blocking implementation:
- Any unresolved `[?: …]` markers in any sub-spec.
- Any non-empty *Open questions* section in any sub-spec.

## Output format

Render a chat report grouped by pass, with **global numbering across all findings**:

```
**⚠ You should know**                       (only when a finding clears the bar; otherwise leave it out)
- <label>: <one line> — see <finding number>

**Umbrella:** .specs/<name>/  (<N> sub-specs reviewed)

## Contradictions (<count>)

1. **<short label>** — <one-line description>. <"These can't both be true." or "Possible contradiction." with confidence>
   - <path>: "<quoted excerpt>"
   - <path>: "<quoted excerpt>"

## Gaps (<count>)

<N>. **<entity/capability> referenced but not defined.** <which sub-spec uses it, briefly>
   - <path>: "<quoted excerpt>"

## Plan ↔ sub-spec alignment (<count>)

<N>. **<missing|stray|violated cross-cut>.** <one-line note>
   - <path>: "<quoted excerpt if relevant>"

## Open questions still pending (<count>)

<N>. **<file> § Open questions** has <K> unresolved items — these block implementation per the spec.

---
<total> findings across <N> sub-specs. <If findings differ in impact: "Findings <a, b> block implementation; <c, d> are cosmetic."> Want me to fix any of these, or save this report to `_audit.md`?
```

**Severity is not confidence.** Confidence says how sure you are the finding is real; severity says whether it blocks implementation. A high-confidence naming mismatch (`users.email` vs `users.email_address`) is cosmetic — easy to fix, unlikely to derail anything. A data-shape contradiction (JWT sessions vs server-side rows) is blocking — implementing either side bakes in a decision the specs never made. When findings differ in impact, say which are blocking in the closing line so the user can prioritize; that's triage, not a proposed fix.

**You should know** is a step past blocking: a finding that would hurt if implemented as written. Two sub-specs planning incompatible migrations on one table (**Irreversible**), a sub-spec changing an API another treats as stable (**Breaking**), a cross-cutting security rule one sub-spec ignores (**Security**). At most three, each pointing at its finding by number, with the bar and labels from `<this skill's directory>/../../shared/answerable-page.md`. Most audits have none.

If a section has zero findings, **omit it entirely** — don't print empty headers. If all four sections have zero findings, output one line and stop:

```
No contradictions or gaps found across the <N> sub-specs in `.specs/<umbrella>/`.
```

Don't pad an empty audit with reassurance or summary tables.

## What good output looks like

- **Specific.** Every finding cites file, section, and a quoted excerpt. "There's a contradiction in your auth specs" is not a finding.
- **Tight excerpts.** Quote the shortest span that shows the conflict — one or two lines per side. Half-paragraph quotes bury the actual disagreement and make the report unscannable.
- **Numbered globally.** The user should be able to say "fix 1, 3, and 5" without ambiguity.
- **Honest about ambiguity.** If two excerpts *might* contradict but the resolution depends on context the specs don't fix, flag it as a *possible* contradiction with `confidence: medium` rather than asserting it.
- **Quiet on a clean tree.** Zero findings is a single line, not a victory lap.

## What to avoid

- **Editing spec files.** This skill doesn't touch the specs. The user fixes after the report; if they ask the model to fix, that's a normal follow-up, not part of the skill. (Saving the report to `_audit.md` on request is the one allowed write — it adds a file, never modifies one.)
- **Proposing specific fixes.** "I think `provider-choice.md` is right and `data-model.md` is wrong" is a judgment call the skill shouldn't make. Surface the contradiction; let the user decide which side wins.
- **Grading prose or completeness.** This isn't a quality reviewer for individual specs — it's a cross-spec coherence checker. Bad prose in one spec is not a finding; bad prose that contradicts another spec is.
- **Drift checks against code or `docs/`.** Out of scope. `doc-generator` covers spec-vs-shipped; the audit covers spec-vs-spec.
- **Padding empty audits.** If there's nothing to report, say so in one line.

## Why this exists

`feature-brainstorm` decomposes umbrellas into sub-features. `feature-spec` writes one sub-spec at a time, often across sessions. By the time three or four sub-specs exist under `.specs/<umbrella>/`, nobody has read them together — and the data model, naming, and scope assumptions in spec #1 may no longer match what got written in spec #4. This skill closes that loop. It runs once, on demand, before implementation, and surfaces the disagreements while they're still cheap to fix in prose rather than expensive to fix in code.
