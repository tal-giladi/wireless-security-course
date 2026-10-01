---
id: "13.3"
module: 13
minutes: 25
practice_minutes: 30
prerequisites: ["13.2"]
objectives:
  - Turn a technical finding into impact tied to the client's actual assets rather than a generic CVSS recital.
  - Document limitations honestly — what was not tested and why (out of scope, no hardware for a path, PMF blocked a technique, time box).
  - Preview residual risk as the bridge from this engagement to the defence program and reporting in Module 14.
volatility: concept
sources:
  - title: "NIST SP 800-115 — Technical Guide to Information Security Testing and Assessment"
    url: https://csrc.nist.gov/publications/detail/sp/800-115/final
  - title: "FIRST — Common Vulnerability Scoring System (CVSS) specification"
    url: https://www.first.org/cvss/
last_verified: "2026-10-01"
---

# 13.3 · Impact assessment and limitations

A finding that ends at "WPA2-PSK is crackable, CVSS 7.5" tells the client nothing they can act on. The job of this lesson is the two sections that make a wireless report useful and honest: turning each finding into **impact tied to the client's own assets**, and documenting **limitations** — what you did not test and why — so that the absence of a finding is never mistaken for a guarantee of safety. It closes the methodology loop and hands off to the defence program and reporting in Module 14.

## Why this matters

Clients do not fix "CVSS 7.5"; they fix things that threaten what they care about. The same crackable passphrase is a minor issue on an isolated guest SSID and a serious one if that SSID bridges to the network holding the finance system — the technical fact is identical, the impact is not, and only the asset context tells them apart. At the same time, a wireless engagement *always* leaves gaps: a path you had no hardware for, a technique PMF legitimately blocked, a device that was out of scope, a time box that ran out. If those gaps are not written down, the report quietly implies the whole estate is clean, and the first undetected problem in an untested corner destroys the client's trust in everything else you reported. Honest impact and honest limitations are what make the report true, not just correct.

## Learning objectives

- Translate a technical wireless finding into business impact expressed against the client's specific assets, using severity scoring as support rather than as the conclusion.
- Document limitations explicitly — out-of-scope targets, missing hardware for a path, techniques blocked by a control such as PMF, and time-box cutoffs — and state why each gap exists.
- Describe residual risk and how this engagement feeds the defence program, remediation roadmap, and reporting covered in Module 14.

## Prerequisites

- Lesson 13.2 — methodology and evidence capture. Impact and limitations are written from the notebook, the evidence set, and the per-path record produced there.

## Concept

This is a process lesson. **LAB TARGET vs REAL NETWORK:** you practise impact and limitations against your own lab's results; the reasoning transfers directly to an authorised engagement and nowhere else.

### The control or process — from finding to impact

A finding is a technical fact; impact is what that fact means for the client. Build impact in four moves:

1. **State the affected configuration precisely.** Not "weak Wi-Fi" but "WPA2-PSK, PMF disabled, 8-character lowercase passphrase on SSID `Corp-Internal`." Precision is what makes the impact and the fix checkable (it mirrors the report template's per-finding structure).
2. **Trace it to an asset.** What does the attacker reach once the finding is exploited? A recovered PSK on a *flat* network reaches every internal host; the same PSK on a *segmented* guest VLAN reaches the Internet and nothing else. Impact follows the network's topology to the data or systems the client actually values.
3. **State what the attacker gains, and the preconditions.** Be concrete and bounded: "an attacker in RF range who captures a handshake can recover this passphrase offline and join the internal network." Name the preconditions that must hold (RF range, PMKID present, a client that does not validate the server cert) so the client can judge likelihood, not just severity.
4. **Use severity scoring as support, not as the message.** A CVSS vector can communicate severity to a security team, but reciting a number is not an impact statement. Lead with the asset consequence; attach the score if it helps the reader prioritise. A base score that ignores the client's segmentation and data sensitivity can be actively misleading — temporal/environmental context is what makes it meaningful.

The same loop applies to a **defence that held**: "a correctly-configured enterprise client rejected the rogue RADIUS, so credential capture against it is not feasible in this configuration" is a finding with positive impact — it tells the client a control is working and worth keeping. Proving a protection works is a reportable result, not a blank.

### Documenting limitations honestly

Every engagement is bounded; the report must say how. Limitations are not an admission of weakness — they are what keep the report from overclaiming. Record each gap and *why* it exists:

- **Out of scope.** Targets the allowlist (Lesson 13.1) excluded. State that they were not tested and are not covered by any finding here.
- **No hardware for a path.** If you ran the recorded-data or virtual path, you did not prove live capture, injection, range, or RF behaviour — say so explicitly, using the per-path language from Lesson 13.2. A V-path "evil twin worked" does not establish it works over real RF at range.
- **A control blocked a technique.** Sometimes you *cannot* run a technique because a control legitimately stops it — most commonly **PMF rejecting a forged deauth**, so a deauth-assisted capture was not possible on that network. That is both a limitation (the technique wasn't exercised) *and* evidence the control works; record it as both, and never present the blocked technique as a failure of the engagement.
- **Time box.** What you would have tested with more time. A bounded crack that was still running at the window's end is "not recovered in the time allotted," not "uncrackable."

The governing sentence, straight from the report template: **a finding absent from this report is not a guarantee of safety.** Put it in the limitations section every time.

### Residual risk — the bridge to Module 14

Even after remediation and retest, some risk remains, and the client needs it in one actionable sentence: "passphrase strengthened and verified, but WPS is still enabled on two APs"; "SAE-only configured, at the cost of dropping three legacy clients"; "the recorded-data path could not confirm behaviour at real RF range." Residual risk is the honest remainder after the fixes, and it is the hand-off point: **Module 14** takes these findings, impacts, limitations, and residual-risk notes and turns them into the defence program, the written report (executive summary plus technical evidence), and the remediation roadmap with client communication.

## Hands-on

### Guided walkthrough — write impact and limitations for a finding

A paper exercise built on your Lesson 13.2 notebook; no attack. Take one finding you recorded there (e.g. the bounded crack of a supplied handshake).

1. Write the **affected configuration** in one precise line (protocol, PMF state, passphrase characteristics, SSID).
2. Invent a plausible **asset context** for your lab scenario (e.g. "this SSID bridges to the host holding `LAB-FLAG-{uuid}`") and **trace the impact** to that asset in two or three sentences, leading with the consequence, not a score.
3. Add an optional **severity line** (a CVSS-style vector or a High/Medium/Low with a one-line rationale) *after* the asset impact, and note how segmentation or data sensitivity would change it.
4. Write the **limitations** for this finding: which path you used and what it therefore did not prove, anything PMF or scope blocked, and the time-box note. Include the "absence is not safety" sentence.
5. Write the **residual-risk** sentence you would carry into Module 14 after the recommended fix.

### Lab

> [!NOTE]
> **Lab paths:** R — produce an impact-and-limitations write-up for an owned-lab finding (no hardware, nothing transmitted). It proves you can turn a finding into asset-tied impact and document gaps honestly; it does **not** prove any live capture, injection, or RF-range behaviour — and your limitations section must say so where you used path R or V.
> **Start state:** your Lesson 13.2 lab-notebook entry and evidence log; the [report template](../../templates/report-template.md).
> **Duration:** ~30 min.
> **Artifacts:** a one-finding write-up with a precise affected-configuration line, asset-tied impact, an optional supporting severity line, an explicit limitations list (path, blocked techniques, scope, time box, "absence is not safety"), and a one-sentence residual-risk note.
> **Success criteria:** impact leads with the asset consequence (not a bare score); limitations state the path's proof boundary and any control that blocked a technique; the residual-risk sentence is specific and actionable.
> **Cleanup:** none (paper). Carry this write-up into Module 14, which builds the full report and remediation roadmap from it.

## Exercise

Two offices have the identical technical finding: WPA2-PSK with an 8-character lowercase passphrase, PMF disabled, recovered by a bounded crack on the recorded-data path. Office A runs one flat network with the finance server on the same SSID. Office B puts this SSID on a segmented guest VLAN that reaches only the Internet, with the finance server on a separate WPA3-SAE network. Write the impact for each, explain why the identical finding has different impact, and list the limitations you must state given the path you used.

<details>
<summary>Hint</summary>

The crack is the same; the question is what the recovered PSK *reaches*. Follow each network's topology to the asset. For limitations, remember what recorded-data (path R) does and does not prove, and whether PMF being disabled changed what you could exercise.
</details>

<details>
<summary>Reference answer</summary>

**Office A (flat network):** recovering the PSK puts an attacker in RF range onto the same network as the finance server, so the impact is direct access to sensitive internal systems — high, because the finding leads straight to the client's most valuable asset. Lead with that, then optionally attach a severity score; the flat topology and sensitive data are exactly what push it up.

**Office B (segmented):** the same recovered PSK reaches only a guest VLAN limited to the Internet; the finance system is on a separate WPA3-SAE network with no offline-crackable hash. Impact is limited to guest-network access (bandwidth abuse, lateral reach to other guests if client isolation is off) — meaningfully lower, because segmentation stops the finding short of the valued asset.

**Why they differ:** impact is not a property of the vulnerability; it is a property of what the vulnerability reaches in *this* environment. Reciting one CVSS base score for both would misrepresent Office B. Segmentation and data sensitivity — the environmental context — are the difference.

**Limitations to state (both):** the crack was on the **recorded-data path (R)** against a supplied handshake, so it proves the cracking workflow and that this passphrase is weak, not that you performed a live over-the-air capture at range. Note that no live capture, injection, or RF-range behaviour was exercised. State the time box if the run was bounded by it, list any out-of-scope APs, and include "a finding absent from this report is not a guarantee of safety." Residual risk after strengthening the passphrase: for Office A, the exposure is closed for this vector but the flat topology remains a risk until segmented; for Office B, little changes because segmentation already contained it.
</details>

## References

- NIST SP 800-115 — analysis, reporting, and post-testing (`../../references/README.md`).
- FIRST — CVSS specification, used here as support for severity, not as the impact statement (`../../references/README.md`).
- [Report template](../../templates/report-template.md) — the Findings, Limitations, and Retest & residual-risk sections.
- Built on: [13.2](lesson-02.md) methodology and evidence; scope from [13.1](lesson-01.md); safety and law [00.3](../module-00/lesson-03.md).
- Next: Module 14 turns these into the defence program, the full report, and the remediation roadmap.
- Glossary: impact (asset-tied), limitations statement, residual risk (`../../glossary.md`).

## What you should now be able to do

- Turn a technical wireless finding into impact tied to the client's assets, using severity scoring as support rather than the conclusion.
- Document limitations honestly — out-of-scope targets, missing-hardware paths, control-blocked techniques, and time-box cutoffs — and state why each gap exists.
- Write a specific residual-risk sentence and hand your findings off to the defence program and reporting in Module 14.
