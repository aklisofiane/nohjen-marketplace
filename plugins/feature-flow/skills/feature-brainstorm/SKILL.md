---
name: feature-brainstorm
description: Use when the user wants to add or change a feature and the approach isn't decided — "I want to add X", "how should we approach Y", "what's the best way to…", or any open design question. Explores the codebase and the stack's libraries, then lays out 2-3 grounded options with a recommendation on a page the user answers in place, or splits a big feature into an umbrella plan. Not for a decided approach, a mechanical change, a factual question, or a bug's root cause (bug-investigate).
---

# Feature Brainstorm

You are helping the user think through a feature or modification *before* writing any code. Your job is to make the decision space visible so the user can choose with confidence — not to pick for them and start implementing.

**Do not use** when the user has already decided the approach ("add a button that does X using Y"), the change has one sensible path (rename, typo, obvious fix), they want a bug investigated first (`bug-investigate`), or they're asking a factual question about the code. Unsure whether the path is obvious? Use the skill briefly — a one-option answer is fine (see "When there's no real tradeoff").

## The flow

> For quick picks in chat (the resume check, which sub-feature first), prefer `AskUserQuestion` if available. The main option pick happens on the page.

1. **Resume check.** Glob `.specs/*/SPEC_PLAN.md`. If one has unchecked items (`- [ ]`) and the request names something that overlaps it (user says "auth", `.specs/auth/` exists), ask whether they're continuing or starting something new. No overlap: stay silent.

2. **Understand the ask.** What's the goal behind the goal? If it's genuinely ambiguous ("add notifications" — to what? for whom?), ask one or two crisp questions first. Don't ask what the code can answer.

3. **Scope check (provisional).** Does the request smell like **several independent decisions** rather than 2-3 comparable options? "Add authentication" is a provider *and* a session strategy *and* UI flows *and* an authorization model. Flag it, but confirm only after step 4: "add auth" in a project already on Clerk collapses to one or two decisions. If it holds, decompose instead of presenting options — read `references/decomposition.md`.

4. **Explore the codebase.** This is what makes the recommendation worth anything:
   - where similar features live and how they're structured;
   - the conventions and abstractions in play (don't propose options that fight them);
   - constraints that narrow the space (architecture, types, data model, deployment);
   - in-flight work in the same area (`docs/`, `CLAUDE.md`, recent commits).

   Scale it to the blast radius: a contained UI tweak needs a couple of targeted reads; an architectural choice earns the Explore agent and a wider sweep.

5. **Look outward — stack & libraries.** Before locking the option set, check whether a library owns this domain in the project's stack.
   - **Detect the stack** from the root manifest (`package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `pom.xml`, `Gemfile`, `composer.json`, `*.csproj`, `pubspec.yaml`, …) and the framework in play.
   - **Installed first.** A dependency that already covers the domain is almost always Option A.
   - **Library-owned domains:** auth, payments, search, queues/jobs, ORM, validation, uploads, email, observability, feature flags, i18n, rate limiting, RBAC. There, "use a library" is a first-class option.
   - **Search when unsure.** `WebSearch` with the current year (*"NestJS auth library <year>"*), then `WebFetch` the top result or two to confirm it's maintained and fits. Don't recommend from training data alone.

6. **Is there a real tradeoff?** Are there 2-3 approaches a thoughtful engineer might disagree about, or is one clearly right here? Don't manufacture options.

7. **Present the options** on a page (see "The options page"): short bullets, each pro and con tied to what you found.

8. **Recommend, then stop.** Mark your pick with one sentence why, preselect the next step (step 9), post the chat summary, and wait. Don't implement.

9. **After the pick, act on the next step.** Preselect *Write the spec* for anything non-trivial: `feature-spec` is the next stage and works best while this context is in the conversation. Preselect *Implement directly* only when a spec would be ceremony (a few files, no open design question).
   - *Write the spec* — hand the decision, the answers and the notes to `feature-spec`.
   - *Implement directly* — implement it.
   - *Revise the options* — apply the notes, rebuild the page, show it again.

   Paths with no page (no real tradeoff, a decomposition) route in chat: offer `feature-spec` for anything non-trivial, or to implement a small change, and let the user confirm.

## The options page

Read `<this skill's directory>/../../shared/answerable-page.md` the first time you build a page in a session: how to build and show it, the markup rules, *You should know*, and how to read the response. Build with `<this skill's directory>/../../shared/build-page.sh .specs/<slug>.brainstorm.html` (`<slug>`: a short kebab-case name for the feature). The content:

```html
<!doctype html>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><2-4 word name></title>

<h1><what is being decided, in a few words></h1>
<p class="goal"><one-line restatement of what the user wants></p>

<ul class="know">   <!-- optional, rare: what clears the bar whichever option is picked -->
  <li><b>Breaking:</b> <…></li>
</ul>

<ul class="context">
  <li><a codebase fact that shapes the options — a file path, an existing pattern, a constraint></li>
</ul>

<section class="option" id="A">
  <h2><option name></h2>
  <figure class="explain">…</figure>   <!-- optional; see "Pictures" -->
  <p class="how"><1-2 lines on the approach></p>
  <ul class="pros"><li><project-specific pro></li></ul>
  <ul class="cons"><li><project-specific con></li></ul>
  <ul class="know"><li><b>Irreversible:</b> <only if this option is picked></li></ul>   <!-- optional, rare -->
  <p class="effort">Small: <one clause on what drives it></p>
</section>
<!-- Option B, and C only if it's genuinely distinct -->

<p class="recommendation" data-option="A"><one sentence why, grounded in the context above></p>

<fieldset class="ask">   <!-- optional: 1-3 follow-ups whose answer changes what gets built -->
  <legend><question></legend>
  <label><input type="radio" name="<unique-name>" value="x" checked> <answer> <small><consequence></small></label>
  <label><input type="radio" name="<unique-name>" value="y"> <answer></label>
</fieldset>

<fieldset class="next">
  <p><one line on why: how big the change is, what is still open></p>
  <label><input type="radio" name="next" value="spec" checked> Write the spec <small>with <code>feature-spec</code>, while this brainstorm is in context</small></label>
  <label><input type="radio" name="next" value="implement"> Implement directly <small><what it touches: a few files, no open design question></small></label>
  <label><input type="radio" name="next" value="revise"> Revise the options <small>I apply your notes and show this page again</small></label>
</fieldset>
```

**Chat summary:**

```
⚠ <label>: <item>                     (one per You-should-know item, if any)
<Goal, in one line>
A  <name> · <effort>  ★ recommended
B  <name> · <effort>
Suggested next: <Write the spec | Implement directly>
Page: .specs/<slug>.brainstorm.html — pick there and press Respond, or reply with a letter.
```

A plain letter reply ("B") is the pick with every suggested answer and the suggested next step kept.

### Pictures

When an option's *shape* — a flow's order, a structure, a layout — is what distinguishes it, give it a sketch above `.how`:

- **A flow or structure** (data between stores, sync vs. async, before/after a refactor): an SVG in `<figure class="explain">`. Read `<this skill's directory>/../../shared/explainers.md` the first time; its "In a brainstorm option" section covers sizing (a `viewBox` about 360 wide) and drawing every option the same way, so only the difference changes.
- **A UI layout** (split pane vs. stacked): a small HTML mockup in `<div class="sketch">`.
- **Code or terminal output:** ASCII in `<pre class="sketch">`.

Skip sketches when the difference is conceptual (different library, validation strategy) or fits in one bullet. If a picture grows big, zoom into the part that differs.

## When there's no real tradeoff

Say so in chat, no page:

```
**Goal:** <restatement>
**Context:** <why this is straightforward — pattern X exists, the convention is clear>
**Approach:** <the one sensible path, briefly>
Want me to proceed?
```

If something clears the *You should know* bar, lead with a `**⚠ You should know**` block. Manufactured options are worse than one well-grounded one.

## What good options look like

- **Distinct in shape, not detail.** Middleware validation vs. validation in the route handler is a real tradeoff. **Library vs. roll-your-own** is too (ownership, upgrade path, escape hatch). **Library vs. library** is only one when they impose different architectures (table shapes, request lifecycle, mental model).
- **Tied to the codebase.** Not "easier to test", but "easier to test because it slots into the `StubProvider` pattern in `apps/worker/`".
- **Honest about cons.** If you can't name a real con, the option isn't different enough or you haven't thought hard enough.

## What to avoid

- Implementing before the user picks, even when B looks obvious.
- Padding with non-options ("C: do nothing").
- Generic advice that doesn't reference the codebase.
- Walls of text: a pro that needs two lines is two pros.
- Asking what the code could answer. Read first, ask second.
