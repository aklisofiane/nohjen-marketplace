# UI mockups

A mockup is a small piece of HTML in the spec's md that shows a UI the spec adds or changes. The spec page renders it live, in the page's light or dark theme, so the reviewer sees the UI before approving; `feature-implement` reads the same block and builds it with the project's own components. What the user approves is what gets built.

## When to draw

- **Draw** for any new or changed component, screen or layout: a panel, row, form, dialog, banner, menu, or a rearrangement of existing ones.
- **Don't draw** for a copy, color or behaviour-only change, or for a layout that stays as it is.
- **Not a mockup:** a flow's order, a before/after structure, code or terminal output. Those stay ASCII sketches (`ascii-sketches.md`); a flow worth a picture on the page is an explainer (`../../../shared/explainers.md`).

## The fence

````md
**UI**
- Run detail page renders a read-only state when `archived: true`: …

```mockup Archived run
<div class="run">…</div>
```
````

- The info string starts with `mockup`; the rest is the caption the page shows above the box ("Mockup · Archived run"). With no caption it reads "Mockup".
- The fence starts at the beginning of a line, after the text it illustrates, never indented under a list item: the page only renders a fence that starts a line.
- On the page, a mockup shows where it sits in the md. In a section with key points, where the text folds under *Details*, the mockups move out and show under the key points, above the question cards.
- GitHub and other md readers show the block as code, so keep the HTML tidy: indented, one element per line where it helps.

## A wireframe, not a design

A mockup shows arrangement, wording and which controls exist, in the page's theme. It doesn't claim to show the app's real look, and it isn't code to copy: the implementation uses the project's own components and styles.

- **Theme variables for every color**, so it follows light and dark:
  - `--bg`, `--surface`, `--surface-2`: backgrounds, from the page's to a raised panel
  - `--ink`, `--ink-2`, `--ink-3`: text, from primary to muted
  - `--line`: borders and dividers
  - `--accent`, `--accent-soft`, `--on-accent`: the thing that's new or highlighted, its soft fill, text on a solid accent
  - `--pro`, `--con`, `--warn`: success, error, warning
  - `--sans`, `--mono`: the page's fonts
- **It inherits the page's font and text color** (15px sans, `--ink`). Native `<button>`, `<input>` and `<select>` don't take the font unless given `font: inherit`; a bordered `<span>` drawn as a button is often simpler.
- **A `<style>` at the top of the block is fine.** Each mockup gets its own shadow root, so its classes don't reach the page or other mockups, and the page's styles don't reach it. Short class names keep the HTML readable; inline styles work too.
- **Plain flex or grid, fluid widths.** A mockup may render in a column 340px wide or one 740px wide: let rows wrap (`flex-wrap`, `minmax`), and no fixed width over ~300px.
- **Zoom in on what changes.** Draw the part that's new or moved, plus just enough around it to place it (the header row it sits under, the neighbouring control). The app's chrome stays out, as with sketches.
- **Room to breathe.** Padding inside boxes and gaps between controls; a cramped mockup is harder to read than a slightly larger one.
- **Short, real labels.** The words the UI will show — button labels, banner text, empty-state copy — since the mockup is where the wording gets approved. No lorem ipsum.
- **Icons as text or Unicode**: `⋯ ✕ ↻ ▸ ● ⚠`. A disabled control is drawn faded (`opacity: .45`).
- **A dialog or popover** is a box drawn over a dimmed box inside the mockup (`position: relative` on the outer box, `absolute` on the dialog), never `position: fixed`.

## What never goes in

- Scripts or event handlers. They don't run; a mockup is static.
- Project CSS: the app's class names, Tailwind classes, design tokens, fonts.
- Hex, `rgb()` or named colors: only theme variables.
- Images, icon files or any other linked file. The page is a standalone copy, so links don't load.

## States

Draw the default state of what's new, plus each state the spec names, in *UI states* or *Changes*: one `mockup` block per state, captioned with the state's name (`mockup Empty`, `mockup Saving`). Don't invent states to look complete — a state the spec doesn't name isn't part of it. When the change is itself a state of a screen that otherwise stays as it is, that state is the only mockup, as below.

Draw the states of one UI alike — the same markup, changing only what the state changes — so the difference shows.

## Worked example: archived run

The spec in `example-spec.md` gives the run detail page a read-only state for archived runs. The page's layout doesn't change, so the mockup zooms in on the header, where the banner goes:

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

Why it works:

- **Only what changes, plus a hook.** The header row places the banner; the rest of the page is one muted line because it stays as today.
- **The wording is the real wording.** The banner text is what users will read, so the reviewer approves it here, not in a later PR.
- **The controls that exist.** *Re-run* is drawn faded because the spec disables it; no control the spec doesn't name.
- **One state.** Live runs look as they do today, so the archived state is the only mockup.
- **Theme only.** Every color is a variable, so it reads right in light and dark, and nothing in it is the app's CSS.
