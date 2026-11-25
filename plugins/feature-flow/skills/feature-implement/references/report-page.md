# The report page

Whenever a run ends, finished or stopped, build `.specs/<slug>.report.html`: one page that proves what shipped, built from the verdicts, never from the implementers' reports. Shared rules (build, show, markup, *You should know*, reading the response) are in `../../../shared/answerable-page.md`. Read it first.

## Build

```bash
"<this skill's directory>/../../shared/build-page.sh" .specs/<slug>.report.html --proof .specs/_<slug>.proof <<'REPORT_PAGE'
<the content>
REPORT_PAGE
```

`--proof` inlines each `src="proof:<file>"` as a `data:` URI, so the page stays one file. If the script stops on a screenshot name, fix that `src` and rerun; the old page stays as it was meanwhile. With no screenshots, leave `--proof` out.

## The content

```html
<!doctype html>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><2-4 word name of the spec></title>

<h1><the spec's name></h1>
<p class="status" data-verdict="pass">Every phase passed.</p>   <!-- or data-verdict="stopped": Stopped at phase <N>: <why, in a few words>. -->
<ul class="counts">
  <li><b>2</b> phases</li>
  <li><b>9</b> files changed</li>
  <li><b>1</b> fix round</li>
  <li><b>4</b> checks</li>
</ul>

<ul class="know">   <!-- optional: what the user must know before committing or deploying this -->
  <li><b>Manual step:</b> run the <code>runs_archive</code> migration before deploying; the job fails without it.</li>
</ul>

<section class="phase" data-verdict="pass">   <!-- pass | stopped | not-run -->
  <h2>Phase 1 · <name></h2>
  <p class="rounds">1 fix round</p>   <!-- only when it took any -->
  <ul class="items">
    <li><Changes item, in the spec's words> <code>file:line</code></li>
    <li class="partial"><item> <code>file:line</code></li>
    <li class="missing"><item> <code>missing</code></li>
  </ul>
  <p class="why"><why it stopped, or why a proof is missing></p>   <!-- only when there's something to say -->
  <figure class="shot"><img src="proof:p1-archived.png" alt="<the state>"><figcaption><the state it shows, and where></figcaption></figure>
  <pre class="out">npm test · exit 0 · 214 passed, 0 failed</pre>
</section>
<!-- one section per phase, in order; a phase after the one that stopped is data-verdict="not-run", with its items (no file:line) and nothing else -->

<ul class="review">
  <li><b>Blocking</b> <the finding> <code>file:line</code></li>
  <li class="fixed">3 findings fixed before this report</li>
</ul>

<ul class="noted">
  <li>Phase 2 · <a non-blocking finding> <code>file:line</code></li>
</ul>

<ul class="manual">
  <li><what to check by hand, and why the verifier couldn't></li>
</ul>

<fieldset class="next">
  <p><the run's outcome, in one line></p>
  <label><input type="radio" name="next" value="document" checked> Document now <small>with <code>doc-generator</code>, on the files this run touched</small></label>
  <label><input type="radio" name="next" value="fix"> Fix something <small>say what in a note; its owner fixes it and the verifier checks that phase again</small></label>
  <label><input type="radio" name="next" value="later"> Later <small>the spec stays open until <code>doc-generator</code> runs</small></label>
</fieldset>
```

- **Counts:** phases, files changed (`git diff --name-only <base>` plus untracked files), fix rounds across the run, checks the verifiers ran.
- **You should know** gathers the verdicts' *You should know* lines, the spec's *Migration / rollout* and *Dependencies* steps the user still has to take, and any open review finding that clears the bar — without repeats, at most three, by the shared bar. A stopped run is already in the status line; don't repeat it here.
- **A phase card** takes its items, checks and proof from that phase's last verdict, plus any screenshots the whole-diff verdict took for it; in session mode, all from the whole-diff verdict's group for it. One `figure.shot` per screenshot, one `pre.out` per check or test run. The runtime adds the verdict tag, *Checked by spec-verifier* and *Add note*.
- **Code review** lists only open findings that are high-impact or blocking, plus one `li.fixed` with the count fixed before the report. No open findings: just the `li.fixed` line. No `/code-review` in the session: one line saying so.
- **Noted** gathers the verdicts' *Noted* lines, each with its phase, without repeats; leave it out when empty.
- **Test by hand** comes from the verdicts' "check by hand" lines; leave it out when empty.
- Preselect *Document now* when every phase passed and *Fix something* when one didn't.

## Chat summary

```
⚠ <label>: <item>                     (one per You-should-know item, if any)
<spec name> · <every phase passed | stopped at phase N>
Phase 1 · <name> — passed · <its proof, in a few words>
Phase 2 · <name> — stopped after 2 fix rounds · <why>
Code review: <n open | none open> · <m fixed>
Suggested next: <Document now | Fix something>
Page: .specs/<slug>.report.html — answer there and press Respond.
```

## The proof folder

It stays while a rebuild may still need its screenshots. Once the page is final (the response is anything but *Fix something*), delete `.specs/_<slug>.proof/`: the page holds every screenshot inline.

## The response

The block starts `# Re: <h1> (report)`, with notes under each phase's name or *General*, and the next step.

- *Document now* — run `doc-generator` scoped to the files this run touched.
- *Fix something* — the notes say what. Each fix goes to its owner (team mode: the implementer that changed the file, by `SendMessage`; session mode: this session), then the verifier checks that phase again (the whole spec, in session mode). Rebuild the page and show it again.
- *Later* — remind the user that `doc-generator` also flips umbrella checkboxes; the spec stays open until it runs.
