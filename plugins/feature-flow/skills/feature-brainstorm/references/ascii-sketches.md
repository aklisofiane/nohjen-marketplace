# ASCII Sketches for Feature Brainstorming

Quick inline wireframes that make spatial differences between options legible at a glance. Read this file when an option's shape — not its concept — is what distinguishes it.

## When to sketch

Sketch when the *layout* or *spatial relationship* is the tradeoff:

- Two UI options arrange the same content differently (split pane vs. stacked, sidebar vs. tabs, modal vs. inline editor)
- A flow's *order* or *branching* is the point (wizard vs. single form, sync vs. async path)
- A structural relationship is hard to convey in one bullet (parent/child, before/after a refactor)

A 6-8 line sketch above the `How:` line tells the user "these options are shaped differently" faster than three bullets ever will.

## When *not* to sketch

Skip the sketch when:

- The difference is conceptual, not spatial — different libraries, different validation strategies, different data models with the same UI
- The difference fits cleanly in one bullet ("Option A uses a modal, Option B uses an inline drawer" — no sketch needed)
- The sketch is mostly chrome that's identical across options (header, sidebar, footer that all options share). Zoom in on the part that differs instead.
- Both options would produce visually identical sketches (then the difference is below the surface and a sketch hides it)

Over-sketching is worse than under-sketching. The skill's value is concise, scannable options; a wall of ASCII art defeats that.

## Constraints

- **Size by what the sketch needs, not a fixed line count.** Typical ranges: flow diagrams 4-6 lines, row/component sketches 6-10, full layout mockups 10-18. Bigger is fine when it earns it.
- **Zoom in on what differs between options.** If two options share the same surrounding chrome (header, sidebar, page layout), don't redraw it — sketch only the part that's actually different. Most oversized sketches come from drawing shared structure that adds no information.
- **Give the UI room to breathe.** Pad horizontally so labels don't crowd box edges; add a blank line above and below the sketch so it doesn't fuse with prose. A cramped sketch is harder to read than a slightly larger one.
- **Place above the `How:` line** so the reader sees the shape before the prose.
- **Use box-drawing characters**: `┌ ─ ┐ │ └ ┘ ├ ┤ ┬ ┴ ┼` (lighter than `+--+|`). Arrows: `→ ← ↑ ↓`.
- **Label sparingly** — short words inside boxes, not full sentences. The prose explains; the sketch shows.
- **Fixed width** — assume monospace; align columns by hand.
- **Annotations go on their own line below the row they describe**, prefixed with `└─` or `↑`, indented to point at the element. Don't trail them on the same line — it crushes the sketch.

## Patterns

### Split pane (sidebar + main)

```
┌────────────────┬────────────────────────────────────┐
│  Sidebar       │   Main view                        │
│                │                                    │
│   • Inbox      │     [ content area ]               │
│   • Sent       │                                    │
│   • Drafts     │                                    │
│                │                                    │
└────────────────┴────────────────────────────────────┘
```

Good for: navigation-heavy UIs, list+detail layouts, anywhere persistent context matters.

### Stacked / single column

```
┌────────────────────────────────────┐
│   Header                           │
├────────────────────────────────────┤
│                                    │
│     [ content ]                    │
│                                    │
├────────────────────────────────────┤
│   Footer / actions                 │
└────────────────────────────────────┘
```

Good for: focused single-task views, mobile-first, forms.

### Table row with inline action (hover-revealed)

```
┌──────────────────────────────────────────────────────────────────┐
│  ●  workflow-name      webhook · push   2h ago · 14s   [on]  🗑  │
└──────────────────────────────────────────────────────────────────┘
                                                                ↑
                                                  fades in on row hover
```

Good for: showing where an action lives in a dense row, calling out hover/visibility behavior with an arrow annotation.

### Row with kebab menu (popover)

```
┌────────────────────────────────────────────────────────────────┐
│  ●  workflow-name    webhook · push   2h ago · 14s   [on]  ⋯  │
└────────────────────────────────────────────────────────────────┘
                                                            └──┐
                                                    ┌──────────▼─┐
                                                    │  Delete    │
                                                    │  Rename    │
                                                    │  Duplicate │
                                                    └────────────┘
```

Good for: extensible action lists, distinguishing "one action visible" vs "menu of actions" tradeoffs.

### Modal over base view

```
┌────────────────────────────────────────────┐
│   Base view (dimmed)                       │
│                                            │
│        ┌──────────────────────────┐        │
│        │   Modal title            │        │
│        │                          │        │
│        │   [ form fields ]        │        │
│        │                          │        │
│        │           [Cancel] [OK]  │        │
│        └──────────────────────────┘        │
│                                            │
└────────────────────────────────────────────┘
```

Good for: distinguishing modal vs. inline-edit options, confirming "interrupting flow" tradeoffs.

### List → detail (master-detail)

```
┌──────────────┐       ┌──────────────────────────────┐
│  Item 1  ●   │  ──►  │   Item 1 detail              │
│  Item 2      │       │                              │
│  Item 3      │       │     [ fields ]               │
│  Item 4      │       │                              │
└──────────────┘       └──────────────────────────────┘
```

Good for: clarifying selection-driven views, "click row → side panel" patterns.

### Flow / sequence

```
[Form] → [Validate] → [Save] → [Confirmation]
                  ↓ (error)
              [Inline message]
```

Good for: comparing wizard vs. single-page flows, sync vs. async paths, branching logic. Arrows beat boxes when *order* is the point.

### Before / after (for refactor options)

```
Before:                          After:

┌────────────────────┐           ┌────────────┐   ┌────────────┐
│   BigComponent     │    ──►    │   List     │   │   Item     │
│     + List         │           └────────────┘   └────────────┘
│     + Item         │
└────────────────────┘
```

Good for: extraction/decomposition options, showing structural change.

## Final note

If you're unsure whether a sketch helps, write the option's bullets first. If after reading them a reader could draw the layout themselves in their head, skip the sketch. If they couldn't, add one.
