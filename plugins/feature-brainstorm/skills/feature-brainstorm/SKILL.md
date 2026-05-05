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

1. **Understand the ask.** Re-read the user's request. What's the goal behind the goal? If it's genuinely ambiguous (e.g., "add notifications" — to what? for whom? when?), ask one or two crisp clarifying questions before exploring. Don't ask questions whose answers you can find in the code.

2. **Explore the codebase for context.** This is the part that makes the recommendation worth anything. Before laying out options, spend the time to understand:
   - Where similar features live and how they're structured
   - The conventions and abstractions already in play (don't propose options that fight the codebase)
   - Constraints that narrow the option space (the architecture, type system, existing data model, deployment shape)
   - Any in-flight or planned work that touches the same area (check `docs/` or recent commits if relevant)

   Use Grep, Glob, Read, and the Explore agent freely. Time spent here is the difference between generic advice and real recommendations. If the project has a `docs/` folder or `CLAUDE.md`, consult it — those usually point at the right files.

3. **Identify whether there's a real tradeoff.** Ask yourself: are there genuinely 2-3 reasonable approaches a thoughtful engineer might disagree about? Or is one path clearly right given the codebase? Don't manufacture options for the sake of presenting choices — that's noise. See "When there's no real tradeoff" below.

4. **Present the options.** Use the structure below. Be concise — bullets, not paragraphs. Each option's pros/cons should reference the *specific* codebase context you found, not generic software wisdom.

5. **Recommend, then stop.** Give your pick and one sentence on why. Then wait for the user to choose. Do not start implementing.

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

When an option's *shape* — layout, spatial arrangement, or flow ordering — is what distinguishes it from another option, add a small inline ASCII sketch (≤10 lines) above the `How:` line. This applies to UI layouts, navigation structures, modal vs. inline patterns, and before/after refactors.

Skip sketches when the difference is conceptual (different library, validation strategy, data model) or fits cleanly in one bullet. Over-sketching defeats the skill's value: scannable options.

For patterns and worked examples, read `references/ascii-sketches.md` the first time a UI/layout option comes up in a session.

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
