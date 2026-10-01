# Module 14 labs — Defence program & reporting

Module 14 is professional-practice material, so its "labs" are **paper/analysis exercises on the R
(recorded-data) path**: you assemble the course's defence controls into a program, write a report
finding, and build a prioritised remediation roadmap. There is no radio here. The R path proves you can
turn results and controls into the professional artifacts a client acts on — a defence program, a
report, a roadmap. It does **not** prove you performed any live capture, injection, or remediation; the
retests you specify are documented, not executed. That hands-on work lives on the V/P paths in the
earlier modules and in the physical capstone (`../../projects/`).

## In this module's zip

Shipped in `labs/module-14/` (this folder):

- `README.md` — this file.
- `defence-program-skeleton.md` — the program document skeleton used in Lesson 14.1: the seven control
  areas with empty **owner**, **cadence**, and **verification** columns, plus a drift-log section to fill in.
- `finding-inputs.md` — the supplied lab result used in Lesson 14.2 (a WPA2-PSK, PMF-disabled network
  with a recovered synthetic passphrase, named artifact, and SHA-256) from which you write one complete
  report finding, its remediation, residual risk, and an executive summary.
- `remediation-roadmap-worksheet.md` — the four-finding owned-lab result set used in Lesson 14.3, with a
  worksheet for prioritisation, per-item retests, residual risk, and a decision-maker note.

Included automatically from `labs/common/` (added to every module zip): the shared tooling and the
course captures. Module 14 does not run any of it — it is referenced only as the source of the evidence
and measurements your written artifacts describe.

## Templates used (not in the zip — linked from the lessons)

- `../../templates/report-template.md` — the report structure Lesson 14.2 walks section by section.

## Success criteria

- **Lesson 14.1:** a completed defence-program document — seven controls, each with an owner, a cadence,
  and a verification method tied to a vulnerable-vs-hardened measurement — plus a short drift log.
- **Lesson 14.2:** one complete report finding (title/severity, affected configuration, evidence with
  artifact + checksum, why-it-works/why-it-may-fail, asset-framed impact), its remediation with a
  verification measurement, a one-line residual-risk statement, and a **decision-maker-usable executive
  summary** (3–6 sentences, no jargon, true and complete on its own).
- **Lesson 14.3:** a prioritised remediation roadmap in which **each item carries a verifiable
  vulnerable-vs-hardened retest**, asset-framed severity rationale per finding, a specific residual-risk
  statement (fixed / remains / why), and a short constructive note to a non-technical owner.

## Provenance of supplied inputs

`finding-inputs.md` and `remediation-roadmap-worksheet.md` describe results generated on the course's
own virtual (`mac80211_hwsim`) path with synthetic credentials (`Lab-WiFi-Passw0rd!`,
`LAB-FLAG-{uuid}`). They are teaching inputs, not real engagement data; any artifact filenames and
SHA-256 values they quote refer to the course's committed captures recorded in `labs/common/CAPTURES.md`.
Treat the synthetic passphrase as you would a real secret when deciding what to quote versus redact.

## Cleanup

None — every Module 14 exercise is read-only, paper analysis. Nothing is transmitted or captured live.
