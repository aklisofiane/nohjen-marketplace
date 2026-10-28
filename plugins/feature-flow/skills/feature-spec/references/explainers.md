# Explainers

An explainer is one picture for the person reading a page. On the spec page it sits beside the section it explains; the md keeps prose and ASCII sketches only, so an implementor gets the same shape without it. On the brainstorm page it sits inside an option and shows that option's shape (see "In a brainstorm option"). Both pages use the same markup and drawing kit.

## When to draw

- **Draw** when a flow, state or structure is hard to follow from text: data moving between stores, a lifecycle with a few states, a request crossing services, what happens over time, a before/after of a structure.
- **Don't draw** when the prose already carries it, to restate a list of changes, or to decorate a section. Most specs need none; a large one, one or two. At most one per section.

## The eli5 rule

One picture made for one hard idea, with few words.

- **One idea.** Say the idea in a sentence before drawing; that sentence becomes the `<p>` under the picture. If it takes two sentences, it is two pictures, or the idea isn't clear yet.
- **Big picture.** Boxes are the things the reader already knows by name: tables, services, files, screens. Leave out whatever doesn't move or change.
- **Few words.** Labels of one to four words, at most a short note under a box. Names from the code go in `.mono`.
- **Made for this feature.** Draw what this change does, not a stock diagram type: a timeline when time is the point, a before/after when the structure changes, a loop when something repeats.
- **One highlight.** Mark what this spec changes or adds with `.hi`; everything else stays neutral.

## Markup

```html
<figure class="explain" data-section="Approach">
  <figcaption>How it works</figcaption>
  <svg viewBox="0 0 520 296" role="img" aria-label="<the picture in one sentence>">…</svg>
  <p><the takeaway, one sentence></p>
</figure>
```

- `data-section` names the `##` heading the picture sits beside. One that matches no section leads the page.
- A `viewBox` about **520 wide**: the picture fills a column about half the page, and under ~820px it stacks above the text at full width. The height is whatever the picture needs, usually 180 to 300.
- `role="img"` and an `aria-label` that says what the picture shows.
- **Prefix every id** in the SVG (markers, gradients) with a short per-explainer prefix, such as `rr-` for run retention. All explainers share one document, so two `id="a"` would collide.
- No `<style>` and no colors: the drawing kit below follows the light and dark theme.
- SVG text doesn't wrap. Keep each line short and put lines 15 to 18 units apart; the base font is 12px sans.

## Drawing kit

| Class | On | Draws |
|---|---|---|
| `box` | `rect` | a thing: surface fill, thin outline |
| `box hi` | `rect` | the thing this spec adds or changes, in the accent |
| `ln` | `line`, `path` | a connection or a move, no fill |
| `ln hi` / `ln dash` | `line`, `path` | the changed path / a boundary or a maybe |
| `t` / `t2` / `t3` | `text` | a label / a secondary line / a small muted note |
| `hi` on `t`, `t2`, `t3` | `text` | text in the accent |
| `b` | `text` | bold |
| `mono` | `text`, `tspan` | a name from the code |
| `dot` / `dot old` | `circle` | items, such as rows / items that moved or aged |
| `head` / `head hi` | `path` in a `marker` | an arrowhead, neutral / accent |

Arrowheads are markers defined once per explainer, then used with `marker-end`:

```html
<defs>
  <marker id="rr-a" viewBox="0 0 8 8" refX="7" refY="4" markerWidth="8" markerHeight="8" orient="auto"><path class="head" d="M0,0 L8,4 L0,8 z"/></marker>
</defs>
<path class="ln" d="M296 138 C 300 176, 384 160, 414 194" marker-end="url(#rr-a)"/>
```

## In a brainstorm option

A picture inside an option, above `.how`, shows that option's shape; the brainstorm's *Visual sketches* section says when an option gets one. The rules above hold, with these differences:

- **No `data-section`.** The figure sits in the option's markup, where it shows.
- **A `viewBox` about 360 wide.** With two or three options a column is 300 to 480px; a 520-wide picture would shrink its 12px text below 8px. The height is whatever the picture needs, usually 100 to 180.
- **The figcaption and the `<p>` are optional.** `.how` already says what the option does; keep the line only when the picture's point isn't in it.
- **Draw every option the same way**: the same `viewBox`, the same box for the same thing, in the same place, so only the difference between options changes. The highlight goes to what this option adds or changes.
- **Prefix ids per option**, such as `a-` and `b-`: all options share one document.

```html
<section class="option" id="A">
  <h2>…</h2>
  <figure class="explain">
    <svg viewBox="0 0 360 150" role="img" aria-label="<the picture in one sentence>">
      <defs><marker id="a-a" …><path class="head" d="M0,0 L8,4 L0,8 z"/></marker></defs>
      …
    </svg>
  </figure>
  <p class="how">…</p>
```

## Worked example: run retention

The spec in `example-spec.md` archives old runs. The hard idea in its *Approach* is: old runs move out of the busy table, but their links keep working. One picture, about 25 words:

```html
<figure class="explain" data-section="Approach">
  <figcaption>How it works</figcaption>
  <svg viewBox="0 0 520 296" role="img" aria-label="Runs older than 90 days move daily from runs to runs_archive; an old link still opens from the archive">
    <defs>
      <marker id="rr-a" viewBox="0 0 8 8" refX="7" refY="4" markerWidth="8" markerHeight="8" orient="auto"><path class="head" d="M0,0 L8,4 L0,8 z"/></marker>
      <marker id="rr-ah" viewBox="0 0 8 8" refX="7" refY="4" markerWidth="8" markerHeight="8" orient="auto"><path class="head hi" d="M0,0 L8,4 L0,8 z"/></marker>
    </defs>

    <text class="t3" x="20" y="16">today</text>
    <text class="t3 hi b" x="330" y="16" text-anchor="middle">90 days</text>
    <text class="t3" x="500" y="16" text-anchor="end">older →</text>
    <line class="ln" x1="20" y1="26" x2="500" y2="26"/>
    <line class="ln hi dash" x1="330" y1="26" x2="330" y2="290"/>

    <rect class="box" x="20" y="42" width="290" height="96" rx="10"/>
    <text class="t b mono" x="36" y="66">runs</text>
    <text class="t3" x="36" y="84">what lists, search and dashboards read</text>
    <circle class="dot" cx="44" cy="114" r="7"/><circle class="dot" cx="68" cy="114" r="7"/><circle class="dot" cx="92" cy="114" r="7"/>
    <circle class="dot" cx="116" cy="114" r="7"/><circle class="dot" cx="140" cy="114" r="7"/><circle class="dot" cx="164" cy="114" r="7"/>
    <circle class="dot" cx="188" cy="114" r="7"/><circle class="dot" cx="212" cy="114" r="7"/><circle class="dot" cx="236" cy="114" r="7"/>
    <circle class="dot" cx="260" cy="114" r="7"/><circle class="dot" cx="284" cy="114" r="7"/>

    <text class="t b" x="346" y="60">daily job</text>
    <text class="t3" x="346" y="78">moves runs past 90 days,</text>
    <text class="t3" x="346" y="93">5k rows at a time</text>
    <path class="ln" d="M296 138 C 300 176, 384 160, 414 194" marker-end="url(#rr-a)"/>

    <rect class="box" x="346" y="198" width="154" height="84" rx="10"/>
    <text class="t b mono" x="360" y="222">runs_archive</text>
    <text class="t3" x="360" y="240">kept, never deleted</text>
    <circle class="dot old" cx="366" cy="262" r="6"/><circle class="dot old" cx="386" cy="262" r="6"/><circle class="dot old" cx="406" cy="262" r="6"/>
    <circle class="dot old" cx="426" cy="262" r="6"/><circle class="dot old" cx="446" cy="262" r="6"/><circle class="dot old" cx="466" cy="262" r="6"/>
    <circle class="dot old" cx="486" cy="262" r="6"/>

    <rect class="box hi" x="20" y="198" width="250" height="84" rx="10"/>
    <text class="t b" x="36" y="222">old link <tspan class="mono">/runs/123</tspan></text>
    <text class="t2" x="36" y="242">still opens, read-only,</text>
    <text class="t2" x="36" y="260">with an “archived” banner</text>
    <path class="ln hi" d="M270 240 L 342 240" marker-end="url(#rr-ah)"/>
    <text class="t3 hi" x="300" y="232" text-anchor="middle">reads</text>
  </svg>
  <p>Recent runs stay where they are. Old runs move out of the busy table, but their links keep working.</p>
</figure>
```

Why it works:

- **One idea, drawn as time.** The 90-day line is the axis the whole feature turns on, so it runs through the picture; everything left of it stays, everything right of it moves.
- **Only what moves.** `runs`, the job, `runs_archive` and an old link. No workspace settings, no feature flag: they are in the text, and they don't change the shape.
- **The promise is highlighted.** The highlight goes to the old link that still opens, the part a reviewer most needs to trust, not to the job.
- **The caption is the takeaway**, so a reader who skips the picture still gets the idea.
