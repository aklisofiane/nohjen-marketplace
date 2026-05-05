---
name: feature-spec
description: Use this skill once a feature direction has been chosen and the user wants to formalize it before implementation — typically after `feature-brainstorm` selects an option, or when the user says things like "let's write the spec for this", "turn this into a spec", "spec this out", "write the design doc for X", or "I want to write this down before coding". Produces a medium-weight spec — heavier than a chat plan, lighter than a full design doc — that captures architecture, design principles, and explicit changes to API / data-model / UI without dropping into code. Asks clarifying questions in batch until the spec is unambiguous, then offers two paths: implement directly (small features) or save to `docs/specs/` for phased implementation later (big features). Trigger this skill whenever the user has decided on a direction but hasn't started coding yet — even if they don't explicitly say "spec".
---

# Feature Spec

You are turning a chosen direction into a written spec — heavier than a chat plan, lighter than a full design doc. The spec captures *what* will change and *why*, in enough detail that an implementor (you, the user, or another instance of you) can read it weeks later and execute confidently. It deliberately avoids code snippets — describe shape, not implementation.

## When to use this skill

Trigger when the direction is decided and the user wants to formalize before implementation:
- Right after `feature-brainstorm` resolves on an option
- "Let's write the spec for [X]"
- "Turn this into a spec" / "spec this out"
- "Write the design doc for [feature]"
- "I want to write this down before coding"
- The user has already chosen between options and is asking you to capture the decision

**Do not trigger** when:
- The decision isn't made yet — that's `feature-brainstorm`'s job
- The user wants to start coding right now without a written record (just do the work)
- The change is mechanical (rename, typo, obvious bug fix) — no spec needed

## The flow

1. **Capture the decision.** Re-read the conversation. What option did the user pick? What were the key reasons? You are *writing down* a decision that's already been made — don't re-litigate it. If the chosen direction is genuinely ambiguous (rare, mostly when the skill is invoked cold without a prior brainstorm), ask one question to confirm before drafting.

2. **Explore only what's needed.** If `feature-brainstorm` ran first, most of the codebase context is already in the conversation. Don't redo the whole exploration. Use Read/Grep only to confirm specific facts the spec needs to be precise about — file paths, function signatures, existing data shapes, naming conventions.

3. **Draft the full spec.** Use the structure below. Where something is genuinely unclear, mark it inline as `[?: question]` rather than guessing. These markers become the clarifying questions in step 4. Show the entire draft to the user before asking anything.

4. **Resolve clarifications in one batch.** If the draft has `[?]` markers, present the spec, then list the markers in a single numbered list:
   > "Before we finalize, here are the things I'm not sure about:
   > 1. [first question]
   > 2. [second question]
   > 3. [third question]"
   
   Wait for answers, revise the spec once, and re-display. Only if the revision *still* leaves real ambiguity should you fall back to one-question-at-a-time — and at that point the questions should be deep, not surface-level.

5. **Hand off.** Once the spec is clean, present both paths and let the user pick:
   > "Spec looks ready. Two ways to take this forward:
   > - **Implement now** — go straight into the work (good for small, contained features)
   > - **Save to `docs/specs/`** — write the spec to a file so we can phase the implementation later (good for bigger features)
   > 
   > Which one?"
   
   Both options are presented every time. Don't judge size for the user — they'll decide in a second.

## Spec structure

Every spec has these five sections, in this order. They are the spine of the document.

1. **Goal** — One or two lines: what the feature does + why it matters. The why is what makes this section earn its place.

2. **Approach** — The chosen direction at a high level. Architecture and design principles. The "shape" of the solution. Reference existing patterns/files when they ground the approach (e.g., "follows the `BackgroundJob` pattern in `apps/worker/src/jobs/`"). This is the longest section in most specs — it's where the actual thinking lives.

3. **Changes** — What's actually being modified. Use sub-sections when relevant: *API*, *Data model*, *UI*, *New modules*, *Affected files*. If something is a one-liner, mention it inline. **Don't add empty sub-sections.** A spec where "Changes" reads "Adds a single hover-revealed delete button to `WorkflowRow.tsx`" is better than one with five empty headers.

4. **Open questions** — Things still unresolved between you and the user. Ideally empty by the time the spec is finalized — anything here means the spec is not yet ready for implementation.

5. **Out of scope** — Explicit non-goals. What the user has agreed *not* to handle in this spec. This is the highest-leverage section in a medium-weight spec — it prevents scope creep without needing tons of detail elsewhere. Include even one or two bullets when relevant; a missing "Out of scope" is a common cause of spec drift.

## Visual sketches (UI changes only, when shape isn't obvious from prose)

For specs that change a UI, an inline ASCII sketch can make the *spatial arrangement* of the chosen design legible at a glance. The bar is higher than in `feature-brainstorm` because the option is already chosen — there's nothing to contrast. Add a sketch only when the layout is the substance of the change and a reader couldn't reconstruct it from the prose alone.

- **Sketch when:** introducing a new multi-panel layout, a non-trivial modal flow, or a structural rearrangement where "where things go" is the point of the change.
- **Don't sketch when:** the change is described well in one bullet ("add a hover-revealed delete icon to existing rows" — no sketch needed), or when the layout is unchanged from what's already in the codebase.

For sketch patterns and constraints (sizing, breathing room, "zoom in on what differs"), read `../feature-brainstorm/references/ascii-sketches.md` the first time a UI sketch comes up. The patterns are the same as the ones the brainstorming skill uses — the two skills share this reference deliberately.

## Optional sections

Add these only when the feature genuinely needs them. **A section earns its place when it has more than one paragraph of distinct content** — otherwise the info goes inline in *Changes* and the section stays absent. No empty headers.

- **Data model** — full call-out section if introducing new entities, relationships, or non-trivial migrations
- **API surface** — when adding/modifying public endpoints or contracts that consumers depend on
- **UI states** — when interaction states/edge cases matter (loading, empty, error, optimistic updates, focus/keyboard behavior)
- **Migration / rollout** — when the change has phasing, feature flags, backfills, or breaking-change concerns
- **Dependencies** — only when introducing or changing external services, libraries, or new infrastructure

The rule of thumb: if the section would have one paragraph or fewer, fold it into *Changes* instead.

## What good specs look like

- **No code snippets.** Describe shape: "a new `WorkflowQueue` service that batches webhook events into 5-second windows," not the function body. Code is the implementation's job — and code in a spec ages faster than prose.
- **Explicit about changes.** When the API or data model changes, name the change. "Adds field `runs.status_reason: string | null` to the `runs` table" beats "tracks why a run failed." Specificity is what makes a spec actionable later.
- **Grounded in the codebase.** When the spec references existing patterns, name them with file paths. "Follows the `BackgroundJob` interface in `apps/worker/src/jobs/`" is informative; "follows our existing job pattern" is not.
- **Honest about uncertainty.** Use `[?: question]` markers liberally while drafting. Resolved questions turn into clear sentences in the next pass; unresolved ones stay in *Open questions* until the user weighs in.
- **Adapts the section set to the feature.** Backend feature with a new endpoint? Probably warrants *API surface*. UI-only tweak? Skip it. The structure is fixed at the top level (5 core sections), flexible inside.

## What to avoid

- Writing implementation code. If you're tempted to drop in a function body or a SQL migration, it belongs in the implementation, not the spec.
- Padding sections to feel complete. Empty or single-line sub-sections are worse than missing ones — they signal effort that isn't there.
- Re-running the brainstorm. The option is chosen; the spec captures the *what* and the *why*, not the comparison of alternatives.
- Asking clarifying questions one at a time when you can batch them. The user reasons better when they see the whole draft and a numbered list at once.
- Writing the spec to a file before the user has reviewed and approved the content. Show first, save after — saving is the *terminal* action of step 5, not a side-effect of drafting.

## Saving to `docs/specs/`

When the user picks the "save to docs/specs" path:
- Default file path: `docs/specs/<short-kebab-topic>.md`
- If the project already has a `docs/specs/` (or similar) convention with dated filenames or a different structure, **follow the project's convention** — check what's there first
- Filename is the feature name in kebab-case (e.g., `workflow-row-actions.md`), no date prefix unless the project already uses dated specs
- Create the directory if it doesn't exist
- After writing, briefly confirm the path and let the user know the spec is saved — don't continue into implementation unless they explicitly ask

## Why this exists

Specs sit in an awkward middle ground: too formal for a chat conversation that scrolls away, too lightweight for a real design doc with stakeholder reviews. This skill targets that middle. The output is useful for features that are bigger than "just do it" but smaller than "needs a full design review" — the bulk of real work in most projects. Writing the decision down means future-you (or another agent on a different day) can implement it without losing the reasoning that led there.
