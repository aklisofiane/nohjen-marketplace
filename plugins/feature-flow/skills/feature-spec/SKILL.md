---
name: feature-spec
description: Use once a feature's direction is chosen and the user wants it written down before coding — right after feature-brainstorm, or "spec this out", "write the spec / design doc for X" — and to revise a saved spec in `.specs/`. Writes a medium-weight markdown spec (goal, approach, changes, open questions, out of scope), shows it on a page the user answers in place, then saves it or hands off to feature-implement. Not for an undecided direction (feature-brainstorm) or a mechanical change.
---

# Feature Spec

You are turning a chosen direction into a written spec — heavier than a chat plan, lighter than a full design doc. The spec captures *what* will change and *why*, in enough detail that an implementor (you, the user, or another agent) can execute it weeks later. It avoids code: describe shape, not implementation.

The spec is a markdown file; `feature-implement`, `feature-spec-audit` and `doc-generator` read only that. The user reviews it on a page built from it.

**Do not use** when the decision isn't made yet (`feature-brainstorm`), the user wants to code now without a written record, or the change is mechanical.

## The flow

1. **Capture the decision.** Re-read the conversation: which option was picked, and why? You are *writing down* a decision, not re-litigating it. If the direction is genuinely ambiguous (mostly when invoked cold), ask one question before drafting.

2. **Explore only what's needed.** After a brainstorm, most context is already in the conversation. Read/Grep only to pin facts the spec must be precise about: file paths, signatures, data shapes, naming.

   **In an existing umbrella** (`.specs/<umbrella>/SPEC_PLAN.md` with sibling `*.md` files), read the plan and every sibling first, to keep data shapes, naming and scope consistent. Where the new spec would contradict a sibling, flag it as a `[?]` marker — siblings can be wrong too, so surface conflicts rather than absorbing them. More than two or three real contradictions: pause and recommend `feature-spec-audit` on the umbrella first.

3. **Draft and show the page.**
   - Write the draft to `.specs/_<slug>.draft.md` (in an umbrella, `.specs/<umbrella>/_<slug>.draft.md`) in the structure below. Where something is genuinely unclear, mark it inline as `[?: question]` instead of guessing; each marker becomes a question on the page.
   - Run the confidence check. Below 90%, fold a *Phases* section into the draft.
   - Write the page's layer (key points, explainers, a card per `[?]` with discrete answers, *You should know* if anything clears the bar, the next step), build the page and show it with a short chat summary. Read `references/spec-page.md` the first time in a session.

   If the draft turns into a tree of unmade decisions (several `[?]` about *which approach*, not *which detail*), stop and recommend going back to `feature-brainstorm` to decompose.

4. **Read the response** (page or plain chat). Each answer resolves its marker; notes are answered in chat or folded into the draft. If a revision still leaves real ambiguity, the new markers go on the revised page.

5. **Hand off.** The next step preselects *Apply my answers and save*: writing a spec uses much of the session's context, so implementation usually goes better in a new session that reads the saved spec. Preselect *implement* only for a very small change: unphased, ~90% sure or more, a few files.
   - *Show me the revised spec* — apply the answers and notes, rebuild, show it again, say in chat what changed. Back to step 4.
   - *Apply my answers and save* — apply them, rename the draft to `<slug>.md`, and rebuild the page from it without the answered cards and the next step, so the page beside the md matches it. Confirm the path and say how to start: `feature-implement` on the saved spec, in a new session.
   - *Apply my answers and implement* — save as above, then implement. A phased or multi-subsystem spec goes through `feature-implement`, which decides how the run goes and reads your *Phases*; implement inline only the small, unphased, high-confidence case.

## Confidence check

Before the page goes up, and whenever a revision changes scope or approach: how likely is it that the implementation lands correctly in one pass? Weigh open questions, the number of subsystems touched, how well the relevant code is explored, and integration points (external APIs, async flows, migrations).

- **≥90%** → one pass.
- **Less** → split the work into a few phases, each verifiable before the next (e.g. "1. data model + migration, 2. API, 3. UI"), and **fold them into the spec as *Phases***, where future sessions can pick them up.
- **≪70%** → say so plainly: phasing won't save a wobbly spec. Refine it, or go back to `feature-brainstorm`.

The result is the page's confidence line; it doesn't change the default next step.

## Spec structure

Five sections, in this order. For the target *weight*, read `references/example-spec.md` the first time you draft in a session.

1. **Goal** — one or two lines: what the feature does and why it matters.
2. **Approach** — the chosen direction: architecture, design principles, the shape of the solution, grounded in existing patterns by path ("follows the `BackgroundJob` pattern in `apps/worker/src/jobs/`"). Usually the longest section.
3. **Changes** — what's modified, with sub-sections only where they earn it: *API*, *Data model*, *UI*, *New modules*, *Affected files*. No empty sub-sections.
4. **Open questions** — unresolved items. Anything here means the spec isn't ready to implement.
5. **Out of scope** — explicit non-goals. The highest-leverage section: a missing one is a common cause of drift.

**Optional sections**, only with more than a paragraph of distinct content (otherwise fold into *Changes*): *Data model*, *API surface*, *UI states*, *Phases* (from the confidence check: one or two lines per phase, what ships and is verified), *Migration / rollout* (production rollout, flags, backfills, breaking changes), *Dependencies*.

Write markdown the page can render: headings, paragraphs, nested lists, quotes, fenced blocks and `mockup` fences, rules; bold, italic, code, links. No tables. A `[?: …]` inside a code span is text.

## UI mockups and sketches

A spec that adds or changes a UI carries an HTML mockup: a fenced block whose info string starts with `mockup`, the rest being its caption (`mockup Archived run`). The page renders it live; the implementor builds from it.

- **Mockup** any new or changed component, screen or layout, zoomed into the part that changes. **None** for copy-, color- or behavior-only changes.
- **A wireframe, not a design:** theme variables for colors, plain flex/grid, fluid widths, text and Unicode icons. `feature-implement` builds it with the project's own components.
- **States:** the default plus each state the spec names, one block per state. None invented.

Read `references/ui-mockups.md` the first time a mockup comes up. Flows, before/after structures and terminal output stay ASCII in plain fenced blocks, only when the prose can't carry the shape — see `references/ascii-sketches.md`. Mockups and sketches live in the md; explainers live only on the page.

## Saving to `.specs/`

`.specs/` at the repo root holds in-flight specs; `docs/` is the durable record `doc-generator` writes from shipped code. Once a spec is implemented and documented, its file can go.

- **Standalone:** `.specs/_<slug>.draft.md` → `.specs/<slug>.md`, with `.specs/<slug>.spec.html` beside it. Kebab-case, no date prefix.
- **Umbrella sub-feature:** the same files in `.specs/<umbrella>/`. Never modify `SPEC_PLAN.md` (`doc-generator` flips its checkboxes) and don't build a page for it.
- **A leading `_` means not a spec** (drafts, notes, audit reports): the other skills skip those files, which keeps a draft out of their way until it's approved. Never save a spec under one.
- Create `.specs/` (and the umbrella folder) if missing.

## Revising an existing spec

When the user asks to change a saved spec, or `feature-implement` routes back here:

- Read it first; in an umbrella, re-read the siblings (step 2's conflict check applies).
- Copy `<slug>.md` to `_<slug>.draft.md` and edit there; `<slug>.md` stays the approved version until the user approves the revision.
- Edit surgically: touch the sections the change affects. Untouched sections were already approved.
- Re-run the confidence check if scope or approach changed.
- Update the layer, rebuild the page (a spec without one gets its first now), and on approval move the draft back over `<slug>.md` and rebuild.

## What to avoid

- **Code.** Not "the function body" but "a `WorkflowQueue` service that batches webhook events into 5-second windows". A `mockup` is a picture, not a snippet.
- **Vague changes.** "Adds `runs.status_reason: string | null`" beats "tracks why a run failed".
- **Padding.** Empty or one-line sub-sections are worse than missing ones.
- **Re-running the brainstorm.** The option is chosen.
- **Clarifying questions in chat** when the page can carry them beside their text.
- **A spec name before approval.** Only *save* or *implement* renames the draft.
- **Decorative explainers** or key points that restate the section in full.
