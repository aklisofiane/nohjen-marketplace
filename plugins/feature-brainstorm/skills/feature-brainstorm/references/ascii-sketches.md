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
- Drawing would take more lines than the prose pros/cons it sits next to
- Both options would produce visually identical sketches (then the difference is below the surface and a sketch hides it)

Over-sketching is worse than under-sketching. The skill's value is concise, scannable options; a wall of ASCII art defeats that.

## Constraints

- **≤10 lines** per sketch. If it doesn't fit, the sketch is doing too much.
- **Place above the `How:` line** so the reader sees the shape before the prose.
- **Use box-drawing characters**: `┌ ─ ┐ │ └ ┘ ├ ┤ ┬ ┴ ┼` (lighter than `+--+|`). Arrows: `→ ← ↑ ↓`.
- **Label sparingly** — short words inside boxes, not full sentences. The prose explains; the sketch shows.
- **Fixed width** — assume monospace; align columns by hand.

## Patterns

### Split pane (sidebar + main)

```
┌──────────┬─────────────────┐
│ Sidebar  │  Main view      │
│ • Inbox  │                 │
│ • Sent   │   [content]     │
│ • Drafts │                 │
└──────────┴─────────────────┘
```

Good for: navigation-heavy UIs, list+detail layouts, anywhere persistent context matters.

### Stacked / single column

```
┌─────────────────────────────┐
│  Header                     │
├─────────────────────────────┤
│  [content]                  │
├─────────────────────────────┤
│  Footer / actions           │
└─────────────────────────────┘
```

Good for: focused single-task views, mobile-first, forms.

### Modal over base view

```
┌─────────────────────────────┐
│  Base view (dimmed)         │
│      ┌───────────────┐      │
│      │  Modal        │      │
│      │  [form]       │      │
│      │     [Cancel] [OK]│   │
│      └───────────────┘      │
└─────────────────────────────┘
```

Good for: distinguishing modal vs. inline-edit options, confirming "interrupting flow" tradeoffs.

### List → detail (master-detail)

```
┌──────────┐    ┌─────────────────┐
│ Item 1 ● │ →  │  Item 1 detail  │
│ Item 2   │    │                 │
│ Item 3   │    │  [fields]       │
└──────────┘    └─────────────────┘
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
Before:                  After:
┌─────────────┐          ┌──────┐  ┌──────┐
│ BigComponent│    →     │ List │  │ Item │
│  + List     │          └──────┘  └──────┘
│  + Item     │
└─────────────┘
```

Good for: extraction/decomposition options, showing structural change.

## Final note

If you're unsure whether a sketch helps, write the option's bullets first. If after reading them a reader could draw the layout themselves in their head, skip the sketch. If they couldn't, add one.
