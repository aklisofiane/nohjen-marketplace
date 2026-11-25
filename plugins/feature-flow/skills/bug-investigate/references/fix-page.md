# The fix page

Two or three fixes go on one page the user reads and answers in place. Shared rules (build, show, markup, *You should know*, reading the response) are in `../../../shared/answerable-page.md`. Read it first. Build with:

```bash
"<this skill's directory>/../../shared/build-page.sh" .specs/<slug>.bug.html <<'BUG_PAGE'
<the content>
BUG_PAGE
```

`<slug>` is a short kebab-case name for the bug. This page is the one file the skill writes before the pick.

## The content

```html
<!doctype html>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><2-4 word name of the bug></title>

<h1><the bug, in a few words></h1>
<p class="goal">Expected <…>; actual <…>.</p>

<ul class="know">   <!-- optional: e.g. the bug already corrupted data; any fix leaves those rows to repair -->
  <li><b>Heads-up:</b> <…></li>
</ul>

<ul class="context">
  <li>Root cause: <what goes wrong>, in <code>file:line</code></li>
  <li><Confirmed | Likely>: <how it was reached — reproduced with <code>…</code>, traced through …, bisected to …></li>
  <li>Introduced in <commit or change> <!-- only if known --></li>
</ul>

<figure class="explain">   <!-- optional: the root-cause picture -->
  <figcaption>Where it goes wrong</figcaption>
  <svg viewBox="0 0 640 120" role="img" aria-label="<the path from cause to symptom, in one sentence>">…</svg>
</figure>

<section class="option" id="A">
  <h2><fix name></h2>
  <figure class="explain">…</figure>   <!-- optional: a sketch of the fix -->
  <p class="how"><where it fixes and how, 1-2 lines></p>
  <p class="how">Test: <the regression test it adds></p>
  <ul class="pros"><li><project-specific pro></li></ul>
  <ul class="cons"><li><project-specific con></li></ul>
  <ul class="know"><li><b>Breaking:</b> <only if this fix is picked — e.g. callers relying on the buggy behavior change></li></ul>   <!-- optional -->
  <p class="effort">Small: <one clause on what drives it></p>
</section>
<!-- Fix B, and C only if it's genuinely distinct -->

<p class="recommendation" data-option="A"><one sentence why, grounded in the root cause></p>

<fieldset class="next">
  <p><one line on why: how contained the fix is, whether it changes a design></p>
  <label><input type="radio" name="next" value="apply" checked> Apply the fix <small>test first, then the fix, then the project's checks</small></label>
  <label><input type="radio" name="next" value="spec"> Write a spec <small>with <code>feature-spec</code>, for a fix that changes a design</small></label>
  <label><input type="radio" name="next" value="again"> Look again <small>I dig where your notes say and show this page again</small></label>
</fieldset>
```

- Preselect *Apply the fix* for a contained fix and *Write a spec* for one that changes a design.
- **You should know** for a bug: damage already done (bad rows written, emails sent), a fix that changes behavior callers rely on, a cause that is only *likely*, or a fix that hides the symptom while the cause stays. By the shared bar, at most three.
- **The root-cause picture** shows the path from where it goes wrong to where it fails: a few boxes for the steps, the cause marked `.hi`, the symptom labeled where it surfaces. Draw it when the two are apart (another file, layer or step); skip it when they sit on the same line. It spans the page, so its `viewBox` is about 640 wide; prefix its ids with `r-`.
- **A sketch in a fix option** follows the brainstorm's pictures: an SVG when the fixes act at different points of one flow (the same flow in every option, highlighting where each fixes), an HTML mockup in `<div class="sketch">` for a layout bug, ASCII in `<pre class="sketch">` for code or terminal output. Read `../../../shared/explainers.md` the first time a picture comes up; its "In a brainstorm option" section covers option sketches.

## Chat summary

```
⚠ <label>: <item>                     (one per You-should-know item, if any)
<the bug, in one line>
Cause: <one line> · <confirmed | likely> · <file:line>
A  <fix name> · <effort>  ★ recommended
B  <fix name> · <effort>
Suggested next: <Apply the fix | Write a spec>
Page: .specs/<slug>.bug.html — pick there and press Respond, or reply with a letter.
```

## The response

A plain letter reply is the pick with the suggested next step kept.

- *Apply the fix* — follow "After the pick" in the skill with the picked option.
- *Write a spec* — hand the root cause, its evidence and the picked fix to `feature-spec`.
- *Look again* — dig where the notes say, then update the page and show it again. The read-only rule still holds.
