---
name: doc-generator
description: Generate or update project documentation from the latest git commit or from files passed as arguments. Use when the user asks to document their code, refresh or update the docs, write an API, data-model or design/UI doc, or says "document what I just changed", "doc these files", "add documentation for X". Writes terse markdown for humans and agents into the project's `docs/`, following its existing conventions, and keeps the index in sync.
---

# Doc Generator

Write or update markdown docs in the project's `docs/` folder from the latest commit (default) or from files the user names. A reader — human or agent — should learn within minutes what a thing is, how it fits, and where to look next. Nothing more.

## Workflow

### 1. Scope

- **Default** → files changed in HEAD: `git show --name-only --pretty=format: HEAD`, plus the commit message for intent. Merge commit → `git diff HEAD^1 HEAD --name-only`.
- **"Refresh / update the docs"** → everything since docs were last touched: `git diff $(git log -1 --format=%H -- docs/)..HEAD --name-only`. "Last N commits" → `git diff HEAD~N..HEAD --name-only`.
- **Dirty working tree** → the user may mean uncommitted work (`git diff HEAD --name-only`). Ask if unclear.
- **Explicit paths** → use exactly; resolve globs.
- Skip lockfiles, generated output (`.d.ts`, snapshots), and config churn unless asked.

The diff says *where to look*; the current code says *what to write*. Read the files, not just the diff — docs describe what the system **is**, not what changed.

### 2. Read existing docs first

Read `docs/INDEX.md` (or `docs/README.md`) and skim 2–3 docs for tone, heading depth, file naming, and folder layout (`design-docs/`, `adr/`, per-package READMEs, a `documentation/` folder). Follow the project's conventions everywhere; the defaults below apply only where it has none. In a monorepo, update existing package READMEs in place and keep root `docs/` for cross-cutting concerns.

### 3. Decide: create, update, remove, or nothing

- **Create** — a new module, subsystem, data shape, API surface, or UI area.
- **Update** — changes something already documented, including ripple into `ARCHITECTURE.md`, `data-model.md`, API or design docs.
- **Remove** — deleted code that's documented. Prune the section, or the whole doc if empty. A stale doc misleads.
- **Nothing** — bugfixes with no behavior change, shape-preserving refactors, test-only changes.

Think about the system, not the diff: a new package usually touches architecture and structure docs too. Group a wide commit by domain, not file by file.

`ARCHITECTURE.md` is *why* (responsibilities, data flow, contracts); `STRUCTURE.md` is *where* (directory map, one line per folder). A new directory, moved responsibility, or renamed module updates `STRUCTURE.md` even when architecture is unchanged.

### 4. Doc types (defaults)

| File | Covers |
|---|---|
| `docs/INDEX.md` | One line per doc. Always present. |
| `docs/ARCHITECTURE.md` | Apps/packages, cross-cutting flows, infra dependencies |
| `docs/STRUCTURE.md` | Shallow directory map |
| `docs/data-model.md` | Schemas/types others depend on |
| `docs/API.md` | HTTP/RPC/WS endpoints, public package exports |
| `docs/FRONTEND.md` | Routes, pages, major components |
| `docs/DESIGN.md` | Visual tokens from Tailwind config / CSS variables / theme files (palette, type, spacing, radii), plus the intended feel; describe what's observable when there are no theme files |
| `docs/SECURITY.md` | Auth, secrets, sandboxing, permissions |
| `docs/RELIABILITY.md` | Retries, idempotency, crash recovery, cancellation |
| `docs/design-docs/<subsystem>.md` | A subsystem too big for a section in ARCHITECTURE |
| `docs/adr/NNNN-title.md` | Only if the project already uses ADRs |

Setup, scripts, and "run locally" go in the root `README.md`. Update `DEVELOPMENT.md` / `CONTRIBUTING.md` only if one already exists; never create one.

No `docs/` yet → create it with `INDEX.md` and only the docs the current change needs.

### 5. Write

- **Lead with purpose.** First sentence: what it is and why it exists.
- **Shape, not lines.** Concepts, responsibilities, flows, public surface. No function or variable names that a rename would break — the code is the source of truth for specifics. Never restate code in prose.
- **No pasted code.** Point at it by path (`packages/queue/src/runner.ts`). Only illustrative fragments that mirror no real source (e.g. an example payload).
- **Spend words on surprises only:** ordering, side effects, ownership, what must not call what, the why. A simple flow gets one sentence.
- **Tables for enumerable things** (endpoints, exports, env vars, types); fragments are fine in cells and bullets. A small ASCII diagram beats paragraphs for a flow.
- **One home per fact.** Link instead of repeating — including what `INDEX.md`, README, or a parent doc already says.
- **Updates replace, not append.** Rewrite the affected section and delete what the change made stale; an update shouldn't grow a doc by default.
- **No filler:** no "Overview" restating the title, no "This document describes…", no summary or conclusion, no ToC on short files, no changelog / "Recent changes", no TODOs or author tags.
- **Size:** keep docs under ~200 lines (a deep-dive may exceed it when it must). A one-bullet section belongs inline elsewhere; a doc under ~20 lines folds into a neighbor.

Then do a **cut pass**: for each sentence, ask what a reader would do differently because of it. Cut the ones with no answer. The result should feel slightly too short.

### 6. Update `INDEX.md`

On every create, rename, or remove: one line per doc with a hook, in the project's existing format (grouping, read order).

### 7. Verify and report

Check every file in `docs/` has an `INDEX.md` entry, every entry resolves, and new cross-links resolve. Then report in a short list: created, updated, and possibly affected docs left untouched.

### 8. Close the spec loop

`.specs/` holds in-flight specs from `feature-brainstorm` / `feature-spec`; shipping and documenting a change completes them. Skip silently if there's no `.specs/` or no plausible match. Ignore files starting with `_` (drafts). Ask with `AskUserQuestion` when available.

- **`.specs/*/SPEC_PLAN.md`** — for an unchecked `- [ ]` item matching what was documented (by name in the changed files, docs, or commit message), ask *Mark complete* / *Not yet*. On yes, check it and append `— shipped in commit <sha>`.
- **Standalone `.specs/*.md`** — on a match, ask *Delete the spec file* / *Keep it* / *Leave it for me to handle*. Default to keeping; delete only on explicit confirmation, along with its `.specs/<slug>.spec.html`.
