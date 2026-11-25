# The spec page

`.specs/<slug>.spec.html` is a view of the draft for the person reviewing it: the high-level view to decide from, with the full text one click away. It is built from three parts: an HTML layer you write, the markdown draft, and the shared page runtime. The runtime renders the markdown one block per `##` section with a note each, and puts the layer's parts in place. Shared rules (build, show, markup, *You should know*, reading the response) are in `../../../shared/answerable-page.md`. Read it first.

## The layer

```html
<!doctype html>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><2-4 word name></title>

<ul class="know">   <!-- optional: what the spec commits to that clears the bar -->
  <li><b>Breaking:</b> <…></li>
</ul>

<ul class="key" data-section="Approach">
  <li class="decision"><a decision the user should see before approving></li>
  <li class="rule"><a rule the implementation must keep></li>
  <!-- also class="change" and class="risk"; untagged is fine for a plain summary -->
</ul>

<figure class="explain" data-section="Approach">   <!-- optional; see shared/explainers.md -->
  <figcaption><what it shows, 2-4 words></figcaption>
  <svg viewBox="0 0 520 260" role="img" aria-label="<the picture in one sentence>">…</svg>
  <p><the takeaway, one sentence></p>
</figure>

<fieldset class="ask">
  <legend><the [?] marker's text, verbatim></legend>
  <label><input type="radio" name="<unique-name>" value="x" checked> <answer> <small><consequence></small></label>
  <label><input type="radio" name="<unique-name>" value="y"> <answer></label>
</fieldset>

<fieldset class="next">
  <legend>Next step</legend>
  <p><the confidence line: how sure, what drives it, phased or one pass></p>
  <label><input type="radio" name="next" value="revise"> Show me the revised spec <small>I apply your answers and notes, then show this page again</small></label>
  <label><input type="radio" name="next" value="save" checked> Apply my answers and save <small>to <code>.specs/<slug>.md</code>, then implement in a new session</small></label>
  <label><input type="radio" name="next" value="implement"> Apply my answers and implement <small><how: inline, or through <code>feature-implement</code> phase by phase></small></label>
</fieldset>
```

- **You should know** holds what the spec commits the user to: a breaking change, an irreversible migration, a manual rollout step. Each item restates something the md says (usually in *Changes* or *Migration / rollout*), so the implementor has it too.
- **Key points** are the high-level view: 1 to 5 per section, one short line each, covering every decision and rule the user should see before approving. A point that needs two lines is detail and stays in the md. With key points, the section's text folds under *Details*, and its mockups and question cards stay in view; a section without them (a short Goal, Out of scope) shows its text as is. `data-section` names the `##` heading.
- **Explainers** are optional pictures beside the section named in `data-section` (stacked above it on a narrow screen). Draw one only when a flow, state or structure is hard to follow from text; read `../../../shared/explainers.md` the first time one comes up.
- **Question cards** pair with markers by text: a card answers the `[?: …]` its `<legend>` repeats, so copy the marker's text exactly. Write a card when the question has discrete answers, with `checked` on your suggestion. An open-ended marker needs no card: the page gives it a text box.
- **Next step:** the confidence line, then the three choices with *save* `checked`; `checked` moves to *implement* only for a very small, unphased change.

## Build and rebuild

```bash
"<this skill's directory>/../../shared/build-page.sh" .specs/<slug>.spec.html --md .specs/_<slug>.draft.md <<'SPEC_PAGE'
<the layer>
SPEC_PAGE
```

After an edit — answers applied, key points updated, answered cards dropped — Edit the layer inside the page (everything above `<script type="text/markdown" id="spec">`), then rebuild from it and the current md:

```bash
"<this skill's directory>/../../shared/build-page.sh" .specs/<slug>.spec.html --rebuild --md .specs/_<slug>.draft.md
```

After the save, the md is `<slug>.md` instead of the draft. In an umbrella, all of these paths sit in `.specs/<umbrella>/`.

## Chat summary

```
⚠ <label>: <item>                     (one per You-should-know item, if any)
<Goal, in one line>
<N> open questions · ~<confidence>% sure, <phased in P | one pass> · suggested: <next step>
Page: .specs/<slug>.spec.html — answer there and press Respond, or reply here.
```

## The response

The block starts `# Re: <title> (spec)` and has *Questions* (each with its section), *Notes* by section, and the *Next step* (see the shared file). Each answer resolves its marker: the `[?]` in the draft becomes a clear sentence and its card leaves the layer.
