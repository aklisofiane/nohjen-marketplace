# feature-flow

A feature workflow for Claude Code that takes a feature from an open question to shipped, documented code. Each stage writes to `.specs/` in your repo, and the next stage picks it up, in the same session or a later one.

Decisions happen on **answerable pages**: HTML pages that open beside the chat. You pick an option, answer questions, add notes, and press **Respond** to send one answer back.

## The flow

```
            "I want to add X"                           "why is X happening?"
                   │                                              │
                   ▼                                              ▼
          feature-brainstorm ── too big? ──► SPEC_PLAN.md   bug-investigate
          2-3 options on a page               (umbrella)    read-only, root cause,
                   │                              │         1-3 fixes on a page
                   ▼                              │                │
             feature-spec  ◄── one sub-feature ───┘                ▼
          draft → review page → .specs/<slug>.md         regression test first,
                   │                                     then the fix
                   │      feature-spec-audit
                   │      (umbrella only: contradictions
                   │       between sub-specs)
                   ▼
          feature-implement ──► spec-verifier gates each phase
          session or team of agents        + whole diff + /code-review
                   │
                   ▼
            report page (what shipped, with proof)
                   │
                   ▼
             doc-generator ──► docs/, closes the spec in .specs/
```

Every stage ends by suggesting the next one, preselected on its page. You can also start at any stage: `feature-spec` on a decision you already made, `feature-implement` on a spec you wrote by hand, `doc-generator` on any commit.

## Skills

Skills trigger from what you say. You can also call one directly, e.g. `/feature-flow:feature-brainstorm`.

| Skill | Use it when | What you get |
|---|---|---|
| **feature-brainstorm** | You want to add or change something and the approach isn't decided. *"How should we add notifications?"* | It reads the codebase and checks your stack's libraries, then puts 2-3 grounded options with a recommendation on a page. A feature too big for one choice becomes an umbrella plan (`.specs/<feature>/SPEC_PLAN.md`) of sub-features, each brainstormed in turn. |
| **feature-spec** | The direction is chosen and you want it written down before coding. *"Spec this out."* | A markdown spec (goal, approach, changes, open questions, out of scope), with UI mockups and phases when needed. You review it on a page where every unclear point is a question. Then you save it, revise it, or go straight to implementing. |
| **feature-spec-audit** | You have an umbrella with several sub-specs. *"Do my specs contradict each other?"* | A read-only report in chat: contradictions, gaps, plan drift and open questions, with file paths and quotes. Saved to `_audit.md` only if you ask. |
| **feature-implement** | A spec should become code. *"Implement `.specs/archive-runs.md`."* | It plans the phases and lets you pick: run in this session, or a team of agents that this session coordinates. The `spec-verifier` gates every phase, then the whole diff gets a final check and `/code-review`. It ends with a report page: each phase, its proof and screenshots, what to check by hand. |
| **doc-generator** | Code shipped and the docs should match. *"Document what I just changed."* | Short markdown in `docs/` (architecture, API, data model, frontend…) that follows your project's conventions and keeps `docs/INDEX.md` in sync. It then offers to tick the umbrella checkbox or remove the finished spec. |
| **bug-investigate** | You want a bug's cause found before anything changes. *"Find the root cause, don't fix it yet."* | It traces the bug read-only (reading code, running the failing test, git history, a bisect in a temporary worktree). It names the cause with a confidence (*confirmed*, *likely* or *not found*) and offers 1-3 fixes. Once you pick one, it writes a regression test that fails first, then applies the fix. |

### Agent

**spec-verifier**: checks code against a spec and returns a pass or fail verdict with proof. It can't edit the project. It reads the diff against a base commit, marks each *Changes* item as done, partial or missing with `file:line`, runs the project's checks, and takes screenshots of the UI states the spec names. `feature-implement` uses it after every phase and on the whole diff. You can also run it yourself: *"check this spec against the code"*.

## Answerable pages

| Page | From | You decide |
|---|---|---|
| `.specs/<slug>.brainstorm.html` | feature-brainstorm | which option, follow-up questions, next step |
| `.specs/<slug>.spec.html` | feature-spec | each `[?]` in the draft, save / revise / implement |
| `.specs/<slug>.bug.html` | bug-investigate | which fix |
| `.specs/<slug>.report.html` | feature-implement | document now, fix something, or later |

- **Respond** copies one markdown block (your pick, your answers, your notes) for you to paste back into the chat. A plain chat reply works too: "B", "save it", "1: per workspace". Anything you don't mention keeps the suggested answer.
- **You should know** is a short red list under the heading. It flags what you must not miss before committing: a **Breaking** change, something **Irreversible**, a **Manual step**, a **Security**, **Cost** or **License** consequence, or a **Heads-up**. It shows up only when something clears that bar, and it's echoed as `⚠` lines in chat. Skills that answer only in chat use the same labels.
- Each page is one self-contained file. It opens beside the chat in the desktop app, or in any browser.

## What lives in `.specs/`

```
.specs/
├── archive-runs.md                 a saved spec (standalone)
├── archive-runs.spec.html          its review page
├── archive-runs.brainstorm.html    the options it came from
├── archive-runs.report.html        what shipped
├── _archive-runs.proof/            verifier screenshots
├── _search-filters.draft.md        a draft not yet approved
└── auth/                           an umbrella
    ├── SPEC_PLAN.md                sub-features as checkboxes
    ├── session-strategy.md
    ├── ui-flows.md
    └── _audit.md                   saved audit report
```

- **A leading `_` means "not a spec"**: drafts, notes, audit reports, proof. The other skills skip these files.
- **`SPEC_PLAN.md` checkboxes** are flipped only by `doc-generator`, once a sub-feature is documented.
- **Specs are temporary.** `docs/` is the durable record. When a spec has shipped and been documented, `doc-generator` offers to delete it (only after you confirm).
- Interrupted implementation leaves the spec unchanged. The next `feature-implement` run sees which phases are already in the code and continues from there.

## Tips

- **Implement in a fresh session.** Writing a spec uses a lot of context, so *save* is the default next step. Start `feature-implement` in a new session on the saved spec. Very small specs can go straight from spec to code.
- **Audit an umbrella before implementing all of it.** Drift between sub-specs is cheaper to fix in prose than in code.
- **Team mode** keeps this session's context free for the whole run: it coordinates and writes no code, while implementers work in parallel on disjoint files. Session mode suits a small, tightly coupled spec (one phase, about 8 files or fewer).
- **Not for everything.** A rename, a typo or an obvious one-path change doesn't need a brainstorm or a spec. The skills say so and offer to just do it.

## Layout

```
feature-flow/
├── .claude-plugin/plugin.json
├── agents/spec-verifier.md
├── skills/
│   ├── feature-brainstorm/     SKILL.md + references/decomposition.md
│   ├── feature-spec/           SKILL.md + references/ (page, example spec, mockups, sketches)
│   ├── feature-spec-audit/
│   ├── feature-implement/      SKILL.md + references/report-page.md
│   ├── doc-generator/
│   └── bug-investigate/        SKILL.md + references/fix-page.md
└── shared/                     the page kit every skill uses
    ├── answerable-page.md      build, markup, "You should know", reading a response
    ├── build-page.sh           content + runtime → one self-contained page
    ├── page-runtime.html       layout, theme, picks, notes, Respond
    └── explainers.md           SVG pictures on pages
```
