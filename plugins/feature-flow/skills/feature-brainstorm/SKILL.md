---
name: feature-brainstorm
description: Use this skill whenever the user proposes adding a new feature, modifying existing behavior, or asks how to approach a change — phrases like "I want to add X", "let's modify Y", "how should we approach Z", "I'm thinking of changing…", "what's the best way to…", or any open-ended design question. Explores the codebase for context, surfaces 2-3 viable options when there's a real tradeoff, lays out concise pros/cons grounded in the actual project, and gives a recommendation. Skip implementation until the user picks a direction. Use even when the user doesn't explicitly say "brainstorm" — the trigger is the shape of the request (open design question), not the keyword.
---

# Feature Brainstorm

You are helping the user think through a feature or modification *before* writing any code. Your job is to make the decision space visible so the user can choose with confidence — not to pick for them and start implementing.

## When to use this skill

Trigger when the user describes a change without a fixed implementation in mind:
- "I want to add [feature]"
- "Let's modify [behavior]"
- "How should we approach [problem]"
- "I'm thinking of changing [thing]"
- "What's the best way to [goal]"

**Do not trigger** when:
- The user has already decided the approach and is asking you to implement ("add a button that does X using Y")
- The change is mechanical or has only one sensible path (rename, typo fix, obvious bug fix)
- The user is asking a factual question about the codebase, not a design question

If you're unsure whether the path is obvious, lean toward using the skill briefly — a one-option response is fine when there's no real tradeoff (see "When there's no real tradeoff" below).

## The flow

1. **Resume check.** Before anything else, glob `.specs/*/SPEC_PLAN.md`. If any exist with unchecked items (`- [ ]`), and the user's request mentions a name that overlaps with one of those umbrellas (e.g., user says "auth" and `.specs/auth/` exists), surface it: *"I see `auth/` has 2 of 4 sub-features still open ([list them]). Continuing that, or starting something new?"* If there's no overlap, stay silent — don't list every umbrella on every cold start. See "Decomposing a big feature" for the umbrella mechanic.

2. **Understand the ask.** Re-read the user's request. What's the goal behind the goal? If it's genuinely ambiguous (e.g., "add notifications" — to what? for whom? when?), ask one or two crisp clarifying questions before exploring. Don't ask questions whose answers you can find in the code.

3. **Scope check.** Before exploring, ask yourself: does this request describe **multiple independent decisions** that aren't really comparable as 2-3 options? "Add authentication" usually means picking a provider *and* a session strategy *and* a frontend integration *and* an authorization model — that's a tree of decisions, not one. If yes, skip the options output and decompose instead (see "Decomposing a big feature" below). If no, continue.

4. **Explore the codebase for context.** This is the part that makes the recommendation worth anything. Before laying out options, spend the time to understand:
   - Where similar features live and how they're structured
   - The conventions and abstractions already in play (don't propose options that fight the codebase)
   - Constraints that narrow the option space (the architecture, type system, existing data model, deployment shape)
   - Any in-flight or planned work that touches the same area (check `docs/` or recent commits if relevant)

   Use Grep, Glob, Read, and the Explore agent freely. Time spent here is the difference between generic advice and real recommendations. If the project has a `docs/` folder or `CLAUDE.md`, consult it — those usually point at the right files.

5. **Identify whether there's a real tradeoff.** Ask yourself: are there genuinely 2-3 reasonable approaches a thoughtful engineer might disagree about? Or is one path clearly right given the codebase? Don't manufacture options for the sake of presenting choices — that's noise. See "When there's no real tradeoff" below.

6. **Present the options.** Use the structure below. Be concise — bullets, not paragraphs. Each option's pros/cons should reference the *specific* codebase context you found, not generic software wisdom.

7. **Recommend, then stop.** Give your pick and one sentence on why. Then wait for the user to choose. Do not start implementing.

## Output format

Use this exact structure when there's a real tradeoff:

```
**Goal:** <one-line restatement of what the user wants>

**Context:** <2-4 bullets of relevant codebase facts you found that shape the options — file paths, existing patterns, constraints>

**Option A: <name>**
- How: <1-2 lines on the approach>
- Pros: <bullets, project-specific>
- Cons: <bullets, project-specific>

**Option B: <name>**
- How: <1-2 lines>
- Pros: <bullets>
- Cons: <bullets>

**(Option C if it's genuinely distinct)**

**Recommendation:** <A/B/C> — <one sentence why, grounded in the project context above>
```

Keep each option to ~5-8 lines total. If you're writing more, you're either over-explaining or the options aren't actually distinct.

## Visual sketches (UI / layout / flow questions)

When an option's *shape* — layout, spatial arrangement, or flow ordering — is what distinguishes it from another option, add an inline ASCII sketch above the `How:` line. This applies to UI layouts, navigation structures, modal vs. inline patterns, and before/after refactors.

Give the sketch room to breathe — pad inside boxes, add a blank line above and below, and put annotations on their own line beneath the element they describe (not trailing it). A cramped sketch is harder to read than a generous one. Size by what the sketch needs: a flow diagram can be 4 lines; a UI mockup is usually 8-15. If a sketch is getting long, the fix is almost always **zoom into the part that differs between options** rather than redrawing chrome both options share.

Skip sketches when the difference is conceptual (different library, validation strategy, data model) or fits cleanly in one bullet. Over-sketching defeats the skill's value: scannable options.

For patterns and worked examples, read `references/ascii-sketches.md` the first time a UI/layout option comes up in a session.

## Decomposing a big feature

When the scope check (step 3) says a request is too big for a single options output — multiple independent decisions in different dimensions — the right move is *not* to surface a 2-3 option set that papers over the complexity. Instead, decompose the umbrella into sub-features that each warrant their own brainstorm → spec → implement → document cycle.

**Output for a decomposed feature:**

Write a parent file at `.specs/<feature>/SPEC_PLAN.md` with this shape:

```markdown
# <Feature name>

Umbrella: <one or two lines on what the whole feature is and why>

## Decomposition

- [ ] <sub-feature-1> — <one-line note on what this piece is>
- [ ] <sub-feature-2> — <one-line note>
- [ ] <sub-feature-3> — <one-line note>
- [ ] <sub-feature-4> — <one-line note>

## Cross-cutting notes

<anything that spans sub-features and doesn't belong in just one — e.g., "all sub-features must respect the existing CSRF token middleware">
```

Sub-features are decisions that can be made independently. For "add authentication," that's typically *provider choice*, *session strategy*, *UI flows*, *authorization model*. Aim for 3-6 sub-features; if you're listing more than 8, the umbrella is itself decomposable into smaller umbrellas.

After writing the plan, ask the user which sub-feature to brainstorm first. Then run the normal options flow on **that sub-feature only** — not the whole umbrella. Each sub-feature's spec eventually lands at `.specs/<feature>/<sub-feature>.md`.

**A checkbox flips to `[x]` only when `doc-generator` confirms documentation has captured that sub-feature** — see the doc-generator skill for the loop-close mechanic. This skill writes the plan and the unchecked items; it doesn't flip them.

**Don't decompose** when:
- The "decisions" collapse into one obvious choice given the codebase (e.g., "add auth" in a project that already uses Clerk → no provider choice needed; the umbrella is smaller than it looked)
- The user explicitly says "I want one spec for the whole thing" — respect that; produce a single spec via `feature-spec` and let them eat the complexity

## When there's no real tradeoff

If exploration reveals one clearly correct path, say so directly instead of inventing options:

```
**Goal:** <restatement>

**Context:** <why this is straightforward — pattern X already exists, the codebase has a clear convention, etc.>

**Approach:** <the one sensible path, briefly>

Want me to proceed?
```

This is honest and saves the user time. Manufactured options are worse than one well-grounded one.

## What good options look like

- **Distinct in shape, not just in detail.** "Use library X" vs "use library Y" is usually not a real tradeoff unless the libraries impose different architectures. "Server-side validation in middleware" vs "validation co-located with the route handler" is a real tradeoff.
- **Tied to the actual codebase.** A pro like "easier to test" is generic; "easier to test because it slots into the existing `StubProvider` pattern in `apps/worker/`" is real.
- **Honest about cons.** Every option has costs. If you can't name a real con, you haven't thought hard enough or the option isn't really different from another one.

## What to avoid

- Jumping to implementation before the user picks. Even if you think Option B is obvious, wait.
- Padding options with non-tradeoffs ("Option C: we could do nothing"). If it's not a serious candidate, leave it out.
- Generic advice that doesn't reference the codebase. The whole point of this skill is project-grounded recommendations.
- Walls of text. Concise structured bullets are the format — if you can't fit a pro in one line, it's probably two pros.
- Asking the user to clarify things you could find in the code. Read first, ask second.

## Why this exists

Most feature requests have hidden choices the user isn't aware of. Surfacing those choices early — with real context, not abstract pros/cons — leads to better decisions and less rework. The structure exists to keep this fast: a 30-second scan should be enough for the user to pick.
