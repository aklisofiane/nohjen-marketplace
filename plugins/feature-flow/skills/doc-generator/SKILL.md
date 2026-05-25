---
name: doc-generator
description: Generate or update project documentation from the latest git commit or from a specific set of files passed as arguments. Use this skill whenever the user asks to document their code, refresh the docs, write an API doc, a data-model doc, a design/UI doc, or says things like "document what I just changed", "update the docs after my commit", "doc these files", or "add documentation for X". Also use when the user wants docs that both humans and AI agents can read — structured markdown, not inline code comments. Produces concise, high-signal markdown files that slot into an existing `docs/` folder, updates the doc index, and fits into the project's own doc conventions rather than imposing a generic template.
---

# Doc Generator

Generate or update project documentation from source code. Input is either:

- **The latest commit** (default when no files are given): use `git show --name-only HEAD` to find the files that changed, document those, and also think at a higher level about whether the change affects any existing docs elsewhere.
- **A specific list of files/paths** the user passes: document those.

The end deliverable is markdown files written into the project's `docs/` folder (creating it if absent), organized using the folder structure described below, with `docs/INDEX.md` kept in sync.

## Why this skill exists

Good docs make a codebase readable for both humans and AI agents. The goal is **just enough detail** — purpose, shape, responsibilities, key flows, non-obvious constraints. Not line-by-line narration, not exhaustive API dumps, not marketing fluff. A future reader (human or agent) should be able to open a doc and, within a few minutes, know what the thing is and where to look next.

## Workflow

Follow these steps in order. They're not rigid — use judgment — but most invocations will hit each one.

### 1. Figure out the scope

- No args / just "document the latest commit" → run `git show --name-only --pretty=format: HEAD` (or `git log -1 --name-only --pretty=format:`) to get the changed files. Also read the commit message for intent.
- Explicit paths → use those exactly. Resolve globs if any.
- Exclude lockfiles, generated files, pure config churn, and anything that isn't meaningfully documentable unless the user asked for it.

### 2. Read the project's existing docs *first*

Before writing anything, look at what's already in `docs/`. Skills must adapt to the project, not the other way around.

- Read `docs/INDEX.md` (or `docs/README.md`) if present — this is the map.
- Skim 2–3 existing doc files to pick up tone, heading depth, use of tables/diagrams, and naming conventions (e.g. `UPPERCASE.md` vs `kebab-case.md`, top-level vs. subfolders).
- Note any folder conventions (e.g. `docs/design-docs/` for subsystem deep-dives, `docs/adr/` for decisions).

Match what's there. Don't invent a new structure if one exists.

### 3. Decide what to create vs. update

For each in-scope file or cluster of related files, decide:

- **New doc needed?** The file introduces a new module, subsystem, data shape, API surface, or UI area that isn't documented yet.
- **Existing doc to update?** The file changes something already documented — the change may ripple into `ARCHITECTURE.md`, `data-model.md`, an API doc, or a design doc even if the changed file itself lives elsewhere.
- **No doc change needed?** Bugfix that doesn't alter public behavior, refactor that doesn't change shape, test-only changes.

Also zoom out: a commit that adds a new package almost always affects the top-level architecture doc, the structure map, and the index, not just its own folder. Think about the system, not just the diff.

**`ARCHITECTURE.md` vs `STRUCTURE.md`:** architecture is *why* (responsibilities, data flow, contracts); structure is *where* (directory map, one-line notes per folder). Keep them separate — architecture drifts slowly, structure drifts with every refactor. If a change touches the shape of the repo (new directory, moved responsibility, renamed module), update `STRUCTURE.md` even when `ARCHITECTURE.md` stays still.

### 4. Pick the right doc type

The folder structure below is a *default*. If the project already uses different names (e.g. `ARCHITECTURE.md` vs `architecture.md`), follow the project. Otherwise use these:

| Doc type | Filename | When to create |
|---|---|---|
| Overview / map | `docs/INDEX.md` | Always. Update whenever a doc is added/removed. |
| System architecture | `docs/ARCHITECTURE.md` | New app/package, cross-cutting flow change, new infra dependency |
| Repo structure map | `docs/STRUCTURE.md` | New app/package added, top-level directory reshuffled, or responsibilities of an existing directory materially shift. Shallow map — what lives where — not a line-by-line tour |
| Data model | `docs/data-model.md` | Schema/types touched that others depend on |
| API surface | `docs/API.md` | HTTP/RPC/WS endpoints or public package exports changed |
| Frontend / UI | `docs/FRONTEND.md` | Route, page, or major component added |
| Design / visual | `docs/DESIGN.md` | Palette, typography, spacing, component look-and-feel — pull tokens from Tailwind config / CSS variables / theme files when they exist; describe feel when they don't |
| Security | `docs/SECURITY.md` | Auth, secrets handling, sandboxing, permissions |
| Reliability | `docs/RELIABILITY.md` | Retries, idempotency, crash recovery, cancellation |
| Subsystem deep-dive | `docs/design-docs/<subsystem>.md` | A single subsystem (e.g. queue runner, auth flow) needs more than a section in ARCHITECTURE |
| Decision record | `docs/adr/NNNN-title.md` | Only if the project already uses ADRs |

**Where setup, scripts, and "how to run locally" belong:** the project's root `README.md`, not a new `docs/DEVELOPMENT.md`. Only create a `DEVELOPMENT.md` or `CONTRIBUTING.md` doc if the project *already has one* — then update it in place. README is the universally expected home for prerequisites, install commands, and everyday npm/make/cargo scripts; duplicating this into `docs/` makes it a second place to keep in sync and readers won't look there first.

The "DESIGN" doc is dual-purpose: for UI-heavy changes, it covers both visual tokens (colors from the Tailwind config, fonts, spacing scale) **and** the feel/intent (what the UI is trying to communicate). Read the actual theme files when they exist; otherwise describe what's observable from the components.

### 5. Write the docs

Content principles (these are the whole point — take them seriously):

- **Lead with purpose.** First sentence answers "what is this and why does it exist?" — not "this file contains...".
- **Describe shape, not lines.** Name the exports, the public API, the key data flows. Don't paraphrase every function.
- **Stay high-level to avoid drift.** Docs should help a reader understand *what something is about* and *how it fits together* — not mirror the code. Avoid referencing specific function names, variable names, or implementation details that change with every refactor. If renaming a function would break the doc, the doc is too specific. Write at the level of concepts, responsibilities, and flows — the code is the source of truth for specifics.
- **Call out non-obvious constraints.** Ordering requirements, side effects, who owns what, what must not be called from where. This is where docs earn their keep.
- **Prefer tables for enumerable things** (endpoints, exports, env vars, types).
- **ASCII diagrams for flows** when they help. One small diagram beats three paragraphs.
- **Link, don't duplicate.** If something's explained elsewhere, link to it. Cross-link related docs.
- **Use file paths as references** like `apps/api/src/webhooks/github.controller.ts` so a reader (or agent) can jump straight to the code.
- **Be terse.** If a section has one bullet, it probably belongs inline in another section. If a doc is under ~20 lines, consider folding it into a neighbor.

Length target: most docs land between 40 and 200 lines. A subsystem deep-dive can go longer if genuinely needed.

Do **not**:

- Rewrite the source code in prose.
- Add changelog entries or "Recent changes" sections (that's what git log is for).
- Include TODOs or author tags.
- Start every file with a giant ToC — it's clutter for short files.

### 6. Update `INDEX.md`

`INDEX.md` is the front door. Every time a doc file is created, renamed, or removed, update it. Keep entries short: one line per doc with a hook sentence. If the project already has a specific INDEX format (numbered read order, grouped sections), match that format.

If there's no `INDEX.md` yet, create one the first time you add a doc. Base the structure on whatever docs exist.

### 7. Report what changed

At the end, give the user a short summary: which docs were created, which were updated, which existing docs you *didn't* touch but flagged as possibly affected (so they can double-check). One short paragraph or a bulleted list.

### 8. Close the spec loop

`.specs/` (at the repo root) holds working specs that this skill's siblings — `feature-brainstorm` and `feature-spec` — write while a feature is in flight. A spec is only truly "complete" when the change has shipped *and* been documented. This skill is the place where that loop closes.

After step 7, do a quick check:

- **Glob `.specs/*/SPEC_PLAN.md`.** For each one, read the unchecked items (`- [ ]`). If any unchecked item plausibly matches what was just documented (the sub-feature name appears in the changed files, the doc updates, or the commit message), ask the user to confirm completion (*Mark complete* / *Not yet*). If yes, flip the checkbox from `- [ ]` to `- [x]` and append a one-line note (e.g., `— shipped in commit abc1234`).
- **Also check standalone specs** (`.specs/*.md` outside subdirectories). If a feature name matches what was just documented, ask whether to *Delete the spec file*, *Keep it*, or *Leave it for me to handle*. Default to keeping; never delete without explicit confirmation.

When asking either of these, prefer `AskUserQuestion` if available. If `.specs/` doesn't exist or there's no plausible match, skip silently — the loop closes only when there's something to close.

## Handling ambiguity

- **No `docs/` folder exists yet** → create it, seed with `INDEX.md` and whichever doc types fit the changes in scope. Don't over-scaffold — only create the docs the current changes need.
- **User's project uses a different convention** (e.g. docs live in `documentation/` or inside each package as `README.md`) → follow the project's convention. This skill's table is a default, not a requirement.
- **Monorepo with per-package docs** → if packages already have their own READMEs, update those in place; use root `docs/` for cross-cutting concerns.
- **Private/generated files in the diff** (lockfiles, `.d.ts` outputs, snapshots) → skip silently.
- **Commit touches many files across unrelated areas** → group by domain and document each group, rather than one giant file-by-file list.

## Examples

**Example 1 — default (latest commit):**
User: "doc what I just committed"
→ Run `git show --name-only HEAD`. See that `apps/api/src/webhooks/github.controller.ts` and `packages/shared/src/trigger-event.ts` changed. Update `docs/API.md` with the new endpoint, update `docs/data-model.md` if `TriggerEvent` shape shifted, update `INDEX.md` only if a new doc was added.

**Example 2 — explicit files:**
User: "document packages/agent/src/providers/claude.ts and packages/agent/src/workspace.ts"
→ These are subsystem-level. Check if `docs/design-docs/agent-execution.md` already covers them. If yes, update. If no, either extend an existing doc or create a new subsystem deep-dive; update `INDEX.md` only if a new file is added.

**Example 2b — new top-level directory:**
User commits a new `apps/scheduler/` service.
→ Update `STRUCTURE.md` with the new directory and one-line notes per subdir, update `ARCHITECTURE.md` with the responsibility + how it fits the data flow, update `INDEX.md` only if new docs were added.

**Example 3 — UI change:**
User: "doc the new canvas styling"
→ Read the Tailwind config (`tailwind.config.*` or CSS `@theme`) and the changed component files. Update `docs/FRONTEND.md` for structure and `docs/DESIGN.md` for tokens (palette, typography, radii) — both, since visual changes are dual-natured.
