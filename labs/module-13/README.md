# Module 13 labs — Wireless engagements & methodology

These labs are **path R throughout** — scoping, methodology, and reporting are paper and analysis work, not
exploitation. Nothing in this module transmits, captures live, or injects: the deliverables are the
professional artifacts a real engagement produces — a scope & authorisation sheet, a methodology checklist
with an evidence log, and an impact-and-limitations write-up. They reuse the course templates and the
supplied captures from earlier modules; they add no new captures of their own.

> [!WARNING]
> LAB TARGET vs REAL NETWORK — the scoping and methodology habits here are written so they transfer unchanged
> to an authorised engagement, but in this course the only legitimate target is equipment **you** own
> ([00.3](../../lessons/module-00/lesson-03.md)). Filling in a scope sheet is practice, not authorisation:
> it authorises nothing against a network you do not own. A private subnet does not isolate radio, so even
> owned-lab transmit work (done in the attack modules, not here) stays inside the allowlist and transmission
> limits you write in these labs.

## Paths and what each proves

| Lesson | R (paper / analysis deliverable) | What it does NOT prove |
|---|---|---|
| 13.1 Scoping & authorisation | a completed scope & authorisation sheet (BSSID allowlist, limits, window, stop conditions, collateral statement) | no live capture, injection, or AP-mode work; filling the sheet is not authorisation |
| 13.2 Methodology & evidence | a six-phase methodology checklist + an evidence log (named + checksummed capture, provenance, custody, notebook entry, path recorded) | not a live capture — the capture is supplied; path R never earns physical credit |
| 13.3 Impact & limitations | a one-finding impact write-up tied to an asset, with an explicit limitations list and a residual-risk line | not RF-range or injection behaviour; the write-up states the path's proof boundary |

## Templates and inputs

- [Scope & authorisation template](../../templates/authorisation-template.md) — filled in 13.1.
- [Lab-notebook template](../../templates/lab-notebook-template.md) — filled in 13.2.
- [Report template](../../templates/report-template.md) — the Findings / Limitations / Residual-risk shape used in 13.3.
- Any supplied capture from Module 5 or Module 6 (e.g. a clean 4-way handshake) is reused as the evidence
  artifact in 13.2–13.3. No capture is generated in this module.

## Tools

No attack tooling. A text editor for the three artifacts, and `sha256sum` (Linux/WSL/Git Bash) to record and
verify a capture's checksum in 13.2. Exact tool versions: see [TOOLS.md](../../TOOLS.md).

## Starting state, artifacts, success, cleanup

- **Start:** the three templates above open; a note of the equipment you own (or an owned-lab scenario you
  invent); one supplied capture from an earlier module for the 13.2–13.3 evidence work.
- **Artifacts:** a scope & authorisation sheet (13.1); a methodology checklist, a `SHA256SUMS` line, a
  provenance + chain-of-custody-lite entry, and a completed lab-notebook entry marked **path R** (13.2); an
  impact-and-limitations write-up with a residual-risk sentence (13.3).
- **Success:** every allowlist entry carries a BSSID and the collateral is scoped explicitly (13.1); the
  checksum verifies with `sha256sum -c` and every claim records its path honestly (13.2); impact leads with
  the asset consequence and limitations state what each path did not prove, including any control-blocked
  technique (13.3). Proving a protection works, and stating a gap honestly, are full passes here.
- **Cleanup:** none — nothing is transmitted or captured. These artifacts are carried forward into both
  capstones and into Module 14 (defence program and reporting).

## Shipped captures

This module ships **no captures of its own** and needs none — it reuses the provenance-and-checksum metadata
of captures shipped with Modules 5 and 6 (see [`../common/CAPTURES.md`](../common/CAPTURES.md) for provenance,
licence, and SHA-256 checksums). The 13.2 evidence exercise is about *recording* that metadata correctly, not
about generating new recordings.
