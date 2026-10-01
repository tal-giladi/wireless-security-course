# Lesson structure (planning — not imported)

Review point 9 **reconciled with the binding Academy instructions**. Instructions §4 are explicit:
"Pick **one fixed set of `##` sections** for the course's lessons and keep it in every lesson. Use
`###` inside sections." So we do **not** use three different top-level section sets. Instead:

> **One fixed `##` set course-wide, adapted per lesson with `###` subsections.**

This still satisfies the review's intent — foundation and reporting lessons are **not** forced to carry
an attack-only "why the weakness exists" heading, because that content is an **optional `###`** inside
`## Concept`, used only where there is a weakness. The guided walkthrough and the independent exercise
stay clearly separated.

## Front-matter (exactly the documented fields — no custom keys)
```yaml
id, module, minutes, practice_minutes, prerequisites, objectives, volatility, sources, last_verified
```
Do **not** invent extra front-matter keys (e.g. `template`, `lab_paths`) — keep front-matter to the set
the importer documents. Lab-path support and lesson kind are stated **in the body** (see below) and
tracked for planning in `course-outline.md` (the Tpl/Paths columns there are planning notes, not fields).

## The one fixed `##` section set (every lesson)
```
# NN.M · Title
<one plain intro paragraph — becomes the lesson summary>
## Why this matters
## Learning objectives
## Prerequisites
## Concept
## Hands-on
## Exercise
## References
## What you should now be able to do
```
No "Knowledge check"/"Quiz"/"Assessment" `##` section — the quiz lives only in `lesson-MM.quiz.yaml`
(instructions §4, §5).

## Adapting with `###` inside `## Concept` (use only what the lesson needs)
- **Foundation lesson** (RF, frames, protocols): `### How it works on the wire` (and more `###` as
  needed). No weakness/remediation subsections.
- **Attack lesson**: `### How the protocol works` → `### Why the weakness exists` →
  `### Prerequisites & affected configurations` → `### How a tester recognises it` →
  `### Manual method` → `### Tooling` → `### Impact` → `### Remediation & blue-team view`
  (vulnerable-vs-hardened) → `### Legacy & deprecated note` (only if relevant).
- **Defence / practice lesson**: `### The control or process` →
  `### Vulnerable vs hardened — and how to measure`.

## Adapting with `###` inside `## Hands-on`
- `### Guided walkthrough` — we show the steps.
- `### Lab` — state **which lab paths** (R recorded / V virtual `mac80211_hwsim` / P physical) and what
  each proves, plus starting state, estimated duration, expected artifacts, troubleshooting, cleanup.
  Use a GitHub alert, **not** a `<div>` (divs are stripped — instructions §4):
  ```
  > [!NOTE]
  > **Lab paths:** R (supplied capture) · V (`mac80211_hwsim`) · P (owned adapter + AP).
  > **Start state:** … **Duration:** … **Artifacts:** … **Cleanup:** …
  ```
- For attack lessons add `### Verification & expected evidence` and `### Why it may fail` here (or in
  Concept — pick one placement and keep it consistent course-wide).

## `## Exercise`
Independent, **distinct from the guided walkthrough** — learner reasons, no inline solution.
Progressive hints in `<details>`; reference solution only in a collapsed `<details>` or a named
`solution` file under `labs/module-NN/` (instructions §6).

## Allowed markup (instructions §4)
GFM (tables, task lists, footnotes, fenced code with language), `$…$`/`$$…$$` KaTeX, ```mermaid```,
images from `assets/`, GitHub alerts `> [!NOTE|TIP|IMPORTANT|WARNING|CAUTION]`. Raw HTML limited to
`<details>/<summary>/<kbd>/<sub>/<sup>/<br>`. **No** `<div class=…>`, `<script>`, `<style>`, inline
`<svg>`, buttons or forms. Badges F/C/E/D and "LAB TARGET vs REAL NETWORK" are written as **plain
text/bold**, never CSS classes. Risky actions open with `> [!WARNING]`/`> [!CAUTION]`.
```
