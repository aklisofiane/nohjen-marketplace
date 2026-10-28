# Example spec — calibration anchor

This is what a finished medium-weight spec looks like, at roughly the target level of detail. It's for a fictional feature ("run retention" in a workflow app), so don't copy its content — copy its *weight*: specific about shapes and names, silent on function bodies, sub-sections only where they earn their place, and short enough to review in two minutes.

---

# Run retention

## Goal

Automatically archive workflow runs older than a configurable retention window. The `runs` table is the largest in production (40M rows) and dashboard queries against it are the top slow-query offender; users only ever look at recent runs.

## Approach

A daily background job moves expired runs to an archive table instead of deleting them — support occasionally needs old runs for billing disputes, so destruction is out. Follows the existing `BackgroundJob` pattern in `apps/worker/src/jobs/` (same registration, retry, and metrics conventions as `pruneWebhookLogs`). Retention window is a per-workspace setting with a global default, resolved through the existing `WorkspaceSettings` service rather than a new config path.

Archived runs disappear from all list views and search. A run permalink to an archived run resolves to a slim read-only page served from the archive table — permalinks are in external incident reports and must not 404.

## Changes

**Data model**
- New table `runs_archive`: same columns as `runs` plus `archived_at: timestamptz`. No foreign keys back into live tables — archived rows must survive workspace deletion.
- New setting `workspace_settings.run_retention_days: int | null` (null = global default, initially 90).

**New modules**
- `apps/worker/src/jobs/archiveExpiredRuns.ts` — the job. Batched (5k rows per transaction) so it never holds a long lock.

**API**
- `GET /runs/:id` gains a fallback lookup into `runs_archive`; response gets an `archived: boolean` field. No other endpoints change — list endpoints already filter by recency.

**UI**
- Run detail page renders a read-only state when `archived: true`: a banner under the header, and *Re-run* disabled. No changes to list views.

```mockup Archived run
<style>
  .run { border: 1px solid var(--line); border-radius: 10px; overflow: hidden; background: var(--bg); }
  .head { display: flex; flex-wrap: wrap; align-items: center; gap: 6px 12px; padding: 10px 14px; border-bottom: 1px solid var(--line); }
  .muted { color: var(--ink-3); font-size: 13px; }
  .btn { margin-left: auto; padding: 3px 10px; border: 1px solid var(--line); border-radius: 6px; font-size: 13px; opacity: .45; }
  .banner { display: flex; flex-wrap: wrap; gap: 2px 10px; padding: 9px 14px; background: var(--accent-soft); color: var(--accent); font-size: 14px; }
  .rest { padding: 10px 14px; color: var(--ink-3); font-size: 13px; }
</style>
<div class="run">
  <div class="head">
    <b>Run #4821</b>
    <span class="muted">nightly-sync · 92 days ago</span>
    <span class="btn">↻ Re-run</span>
  </div>
  <div class="banner"><b>Archived</b> <span>Read-only. Runs older than 90 days move to the archive.</span></div>
  <div class="rest">Steps, logs and outputs, as today</div>
</div>
```

## Phases

1. **Data model** — migration for `runs_archive` and the setting; ships with the job disabled.
2. **Job** — `archiveExpiredRuns` behind the existing `jobs.` feature-flag convention; verify row counts on staging.
3. **Read path + UI** — permalink fallback and the archived banner.

## Open questions

_None — resolved during review: retention is workspace-level, not per-workflow._

## Out of scope

- Restoring archived runs to the live table (support reads them in place).
- Deleting archived rows (a future cold-storage decision, not this feature).
- Retention for tables other than `runs`.

---

**Why this is the target weight:**

- Every concrete claim is checkable at implementation time: table names, column types, file paths, batch size as a constraint (not code).
- *Approach* explains two non-obvious decisions (archive-not-delete, permalink fallback) with their reasons — that's the thinking an implementor can't reconstruct alone.
- *Changes* has only the sub-sections this feature needs; "UI" is one line and one mockup because that's all the UI change there is, and the mockup zooms in on the run header where the banner goes, not the whole page.
- No function bodies, no SQL, no component code — shape only. The mockup is a wireframe in the page's theme, not markup to copy (see `ui-mockups.md`).
- *Out of scope* is doing real work: all three bullets are things a well-meaning implementor might otherwise add.
