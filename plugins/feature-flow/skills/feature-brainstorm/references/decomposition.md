# Decomposing a big feature

When the scope check (step 3, confirmed against the codebase in step 4) says a request is too big for one options page — several independent decisions in different dimensions — don't surface a 2-3 option set that papers over the complexity. Decompose the umbrella into sub-features that each get their own brainstorm → spec → implement → document cycle.

**Ask the library question first.** Before decomposing, run step 5 (Look outward) on the umbrella as a whole. A library choice can collapse the decomposition: picking Better Auth for an "auth" umbrella folds provider, session strategy, membership and roles into "configure + customize". If the user picks a library, the decomposition shrinks to the parts the library doesn't own (custom UI flows, app-specific authorization rules). If they pick roll-your-own, decompose normally.

## The plan file

Write `.specs/<feature>/SPEC_PLAN.md`:

```markdown
# <Feature name>

Umbrella: <one or two lines on what the whole feature is and why>

## Decomposition

- [ ] <sub-feature-1> — <one-line note on what this piece is>
- [ ] <sub-feature-2> — <one-line note>
- [ ] <sub-feature-3> — <one-line note>

## Cross-cutting notes

<anything that spans sub-features — e.g., "all sub-features must respect the existing CSRF token middleware">
```

Sub-features are decisions that can be made independently. For "add authentication" that's typically *provider choice*, *session strategy*, *UI flows*, *authorization model*. Aim for 3-6; more than 8 means the umbrella is itself several umbrellas.

When a cross-cutting fact clears the *You should know* bar (`../../../shared/answerable-page.md`) — e.g. every sub-feature rides on one breaking migration — put it in the chat message that presents the plan, as a `⚠` line.

## After the plan

Ask the user which sub-feature to brainstorm first (`AskUserQuestion` if available), then run the normal options flow on **that sub-feature only**. Each sub-feature's spec lands at `.specs/<feature>/<sub-feature>.md`.

A checkbox flips to `[x]` only when `doc-generator` confirms documentation has captured that sub-feature. This skill writes the plan and the unchecked items; it never flips them.

## Don't decompose when

- The decisions collapse into one obvious choice given the codebase ("add auth" in a project that already uses Clerk: no provider choice; the umbrella is smaller than it looked).
- The user says "I want one spec for the whole thing": respect that, produce a single spec via `feature-spec`.
