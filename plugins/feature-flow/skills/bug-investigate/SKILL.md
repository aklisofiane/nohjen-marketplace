---
name: bug-investigate
description: Use when the user wants a bug's root cause found before anything changes — "investigate this", "find the root cause", "why is X happening", "don't fix it yet". Investigates read-only (code, the failing test, git history, a bisect in a temporary worktree), names the cause with a confidence, offers 1-3 fixes on a page or in chat, and changes nothing until a pick. Not for a plain "fix this error" or design questions (feature-brainstorm).
---

# Bug Investigate

You are finding why a bug happens *before* anyone changes code. A hard bug tempts the agent to edit while still guessing: a guard here, a log line there, until the symptom goes away and the cause stays. This skill separates the two: trace the bug to its root cause without touching the project, present the ways to fix it, and stop until the user picks one.

**Do not use** when the user asks for a fix ("fix this error", "make the test pass") — fix it directly; when the question is about new or changed behavior (`feature-brainstorm`); or when the cause is already known and agreed.

## The read-only rule

**Until the user picks a fix, nothing in the project changes.** A hard stop, not a preference.

- **Allowed:** reading and searching code, and commands whose only side effects are caches and build output — the failing test or command, the test suite, `git log`, `git blame`, `git show`, `git diff`.
- **Bisect in a temporary worktree** outside the repo, removed afterwards, so the user's checkout never moves:

  ```bash
  W="$(mktemp -d)/bisect" && git worktree add --detach "$W" <bad> && git -C "$W" bisect start <bad> <good> && git -C "$W" bisect run <test command>
  git -C "$W" bisect reset; git worktree remove --force "$W"
  ```

- **Off limits:** anything that writes to the repo, a database or a remote service — installs, migrations, formatters, `git checkout`, `stash` or `reset`, temporary logging or any other instrumentation.
- **When only an off-limits step would confirm the cause**, don't take it: the report names it as the next thing to try.
- **The one file written** is the fix page, `.specs/<slug>.bug.html`.

## The flow

1. **Pin the symptom:** expected vs actual, the error text, how to trigger it. Take what you can from the message, logs and code; ask once, in one message, only for what they can't tell you.

2. **Reproduce** with the failing test or command. A bug that won't reproduce is still traced, but its cause can be *likely* at best.

3. **Trace back** from where it fails to where it goes wrong:
   - **Read the path** backwards from the failure — the stack trace, then each caller — to where the bad value or state first appears.
   - **Compare with a similar path that works:** a sibling handler, the same call with another input. The difference is often the cause.
   - **Check recent changes** to the lines involved: `git log -L`, `git blame`, `git show`.
   - **Bisect** when it's a regression with a known good commit.

   One hypothesis at a time: state it, collect evidence for and against, settle it before the next.

4. **Name the root cause**, apart from where the failure surfaces (the view crashes on a missing field; the cause is the serializer that drops it), with a confidence: *confirmed* (reproduced and explained), *likely* (explained, not reproduced) or *not found*.

5. **Present, then stop.** Change nothing until the user picks.

## What it presents

Every outcome can carry *You should know* (the bar and labels are in `<this skill's directory>/../../shared/answerable-page.md`): damage the bug already did (bad rows written, emails sent), a fix that changes behavior callers rely on. On the page it's a `ul.know`; in chat, a `**⚠ You should know**` block first.

- **Two or three sensible fixes** → the fix page: read `references/fix-page.md`. The options differ in *where* or *how* they fix: at the symptom (a guard), at the origin, or structurally so the same kind of bug can't return. Each names the regression test it would add. Don't pad to three.
- **One sensible fix** → chat, no page:

  ```
  **Bug:** <expected vs actual>
  **Root cause:** <what goes wrong, in `file:line`> — <confirmed | likely>
  **Evidence:** <the reproduction, the trace, the commit that introduced it>
  **Fix:** <the change>, with a regression test that <what it checks>
  Apply it?
  ```

- **Cause not found** → chat: what was ruled out (each hypothesis with the evidence against it), the best remaining hypothesis, and what would confirm it — often the step the read-only rule kept you from taking.
- **Not a bug** (expected behavior, config, environment) → chat, with the evidence: the doc, the config line, the version.

## After the pick

Applying a fix, picked on the page or confirmed in chat, goes test-first:

1. **Write the regression test** the fix named and run it. Watch it fail for the reason the root cause predicts; a test that passes before the fix doesn't cover this bug.
2. **Apply the fix.**
3. **Run the test again and watch it pass**, then the project's checks (tests, typecheck, lint — whatever the repo uses).
4. **Report** what changed, the test that now guards it, and the checks that ran — with a `**⚠ You should know**` block first if the fix changed behavior callers rely on or left damaged data to repair.

## What to avoid

- **Changing anything before the pick.** No "quick" log line, no formatter run, no `git stash` to try an older version — bisect in a worktree.
- **Calling the symptom the cause.** Where it fails is where you start tracing.
- **Overclaiming confidence.** *Confirmed* means reproduced and explained.
- **Padding the fixes.** One sensible fix goes in chat.
- **Applying a fix without watching its test fail first.**
