---
id: "14.3"
module: 14
minutes: 25
practice_minutes: 35
prerequisites: ["14.2"]
objectives:
  - Build a prioritised, verifiable remediation roadmap in which each item carries a vulnerable-vs-hardened retest as its proof of fix.
  - State residual risk so a decision-maker can act on it, distinguishing what was fixed, what remains, and why.
  - Communicate findings by justifying severity against the client's assets rather than reciting a generic score, and deliver bad news constructively.
volatility: concept
sources:
  - title: "NIST SP 800-30 Rev. 1 — Guide for Conducting Risk Assessments"
    url: https://csrc.nist.gov/pubs/sp/800/30/r1/final
  - title: "FIRST — Common Vulnerability Scoring System (CVSS) specification and user guide"
    url: https://www.first.org/cvss/
  - title: "NIST SP 800-115 — Technical Guide to Information Security Testing and Assessment"
    url: https://csrc.nist.gov/pubs/sp/800/115/final
last_verified: "2026-10-01"
---

# 14.3 · Remediation roadmap, residual risk, and client communication

A report that lists findings but leaves the client unsure what to do first, what risk is left, or why a finding matters to *them* has not finished the job. This lesson turns the report's remediation and residual-risk sections into a prioritised, verifiable roadmap, shows how to state residual risk so a decision-maker can act, and covers the human side: justifying severity against the client's assets rather than reciting a generic score, and delivering bad news so it leads to action rather than defensiveness.

## Why this matters

The value of an engagement is realised when the client changes something and the change is proven to work. That requires three things the raw findings do not provide on their own: an order (what to fix first, given limited time and budget), a proof (how each fix is verified, not just asserted), and a clear-eyed statement of what is still exposed afterward. It also requires that the client believes the findings — which depends less on a score and more on whether the severity is argued in terms of their own assets, and on how the news is delivered. A technically perfect finding that lands as an accusation, or a "Critical" rating the client cannot connect to anything they care about, gets ignored. Getting this right is the difference between a report that is filed and a report that is acted on.

## Learning objectives

- Build a prioritised, verifiable remediation roadmap in which each item carries a vulnerable-vs-hardened retest as its proof of fix.
- State residual risk so a decision-maker can act on it, distinguishing what was fixed, what remains, and why.
- Communicate findings by justifying severity against the client's assets rather than reciting a generic score, and deliver bad news constructively.

## Prerequisites

- Lesson 14.2 — writing the report. This lesson builds on the findings, remediation, and residual-risk sections you learned to write there, and turns them into a prioritised, communicated roadmap.

## Concept

This is a practice lesson. Each part is a process: prioritising remediation, proving each fix, stating residual risk, and communicating it. **LAB TARGET vs REAL NETWORK:** examples use the synthetic lab networks and credentials from earlier modules; real remediation is agreed with the asset owner and retested only within the authorised scope.

### The control or process

**Prioritise by risk reduction, not by finding count or raw score.** Order remediation by how much risk each change removes for the effort it takes, framed to the client's assets. A weak WPA2 passphrase on the network that carries the finance share outranks a cosmetic issue on an isolated guest SSID, even if a generic table would score them similarly. Group quick high-impact wins first, then structural changes (segmentation, Enterprise migration), then longer-term items (legacy-client replacement). The defence program (Lesson 14.1) is the destination; the roadmap is the ordered path to it.

**Make every remediation item verifiable with a retest.** Each item names the control *and* the vulnerable-vs-hardened measurement that proves it took effect — the same measurements used throughout the course:

- Weak passphrase → strong passphrase / WPA3-SAE: *a bounded crack recovered the old key; after the change the crack is exhausted* (Module 6.4).
- PMF disabled → PMF required: *a forged deauth disconnected the client; after the change it is rejected* (Modules 6.5, 7, 12.1).
- PMKID present → suppressed / SAE: *a PMKID was collected; after the change there is none, or no offline-crackable material at all* (Modules 6.3, 7.1).
- Non-validating Enterprise client → validates CA + server identity: *a rogue RADIUS captured credentials; after the change the client refuses and logs why* (Module 11.5).

"Fixed" without a retest is an assertion; "fixed, and here is the before/after measurement" is proof. This is why the course paired every attack with a hardened counterpart.

**State residual risk in terms a decision-maker can act on.** Residual risk is what remains after the agreed remediation — and it always exists, because fixes have limits, scope has edges, and some changes are deferred. Write it as what was fixed, what remains, and why, in sentences a manager can own:

- "Passphrase strengthened and PMF enabled; **residual:** WPS remains enabled on two APs pending a firmware update — Pixie Dust exposure persists until then."
- "SAE-only configured on the main SSID; **residual:** three legacy handheld scanners cannot do WPA3 and were moved to a segmented WPA2 SSID — that segment remains WPA2-crackable and should be retired when the scanners are replaced."

Residual risk is not an admission of failure; it is the honest tail the client must decide to accept, mitigate, or budget to close. Vagueness here ("some risk remains") is useless; specificity makes it actionable.

### Communicating findings — severity rationale and delivering bad news

**Justify severity against the client's assets, not a generic CVSS recital.** A score can summarise, but it does not persuade and it is often miscalibrated for a specific environment. The same technical finding — a crackable WPA2 passphrase — is a different severity on a guest-only hotspot than on the flat network that also carries patient records. Argue severity from exposure: *what an attacker reaches, from where, and what it costs the client.* Where the client uses CVSS, provide the vector for comparability but lead with the asset-framed rationale; a bare "7.5 High" that the client cannot connect to their business gets discounted. (FIRST's CVSS guidance itself notes base scores describe a vulnerability's intrinsic properties, not your environmental risk — that is what the environmental metrics and your narrative are for.)

**Deliver bad news constructively.** The goal is action, not blame. A few habits:

- Lead with impact and the fix, not with how clever the attack was. The client needs to know what to do, not to feel outmatched.
- Separate the finding from the people — "this configuration allows X," not "you misconfigured X."
- Pair every serious finding with a concrete, proportionate remediation and its retest, so the message is "here is a problem and here is the proven way out," never a dead end.
- Acknowledge constraints (budget, legacy devices, uptime) and reflect them in the roadmap's ordering and the residual-risk statement, so the client sees you understood their reality.
- Be accurate about certainty: say whether exploitation was demonstrated or inferred, and never inflate severity to force attention — it costs you the credibility the next finding needs.

The through-line of the whole course lands here: you are not delivering "we broke in," you are delivering a prioritised, proven, asset-framed path to a defensible network, with the remaining risk stated honestly enough to act on.

## Hands-on

### Guided walkthrough — build a prioritised, verifiable roadmap with residual risk

A paper/analysis exercise, R path, no radio. Using the supplied multi-finding result set and the roadmap worksheet:

1. Open `remediation-roadmap-worksheet.md` in `../../labs/module-14/`. It lists four findings against a small owned-lab network: a weak WPA2 passphrase on the main SSID (carries the file share), PMF disabled, WPS PIN enabled on one AP, and one legacy client that cannot do WPA3.
2. **Prioritise:** order the four by risk reduction for the effort, framed to the described assets. Write one sentence of severity rationale per finding tied to what an attacker reaches — not a bare score.
3. **Make each verifiable:** for every item, write the control and the vulnerable-vs-hardened retest that proves it (pull the measurement from the matching attack module).
4. **State residual risk:** after your proposed remediation, write two or three residual-risk sentences in the "what was fixed / what remains / why" form — including the legacy client that forces a segmented WPA2 island.
5. **Communicate:** write a two-to-three sentence note to the (non-technical) owner that leads with impact and the fix, acknowledges the legacy-device constraint, and states the residual risk plainly.
6. Save the roadmap, the retests, the residual-risk statements, and the owner note as one document.

> [!NOTE]
> **Lab paths:** R — build a remediation roadmap and residual-risk statement from a supplied multi-finding result set; no hardware. It proves you can prioritise, make each fix verifiable, state residual risk actionably, and communicate to a decision-maker. It does **not** prove you performed or retested the fixes on live equipment — the retests are specified, not executed here.
> **Start state:** `remediation-roadmap-worksheet.md` from the module zip (four findings against an owned-lab network).
> **Duration:** ~35 min.
> **Artifacts:** a prioritised roadmap with per-finding asset-framed severity rationale, a verifiable vulnerable-vs-hardened retest for each item, a two-to-three sentence residual-risk statement in the fixed/remains/why form, and a short decision-maker note that delivers the news constructively.
> **Cleanup:** none (paper exercise).

## Exercise

A client pushes back on your report: "Your biggest finding is rated High, but the CVSS calculator I ran gives it 5.3 Medium, so we are deprioritising it." The finding is a crackable WPA2 passphrase on the single flat network that carries both guest Wi-Fi and the point-of-sale system. Without simply insisting on your number, explain how you would justify the severity and re-open the conversation, and what residual-risk framing would help the client decide.

<details>
<summary>Hint</summary>

The disagreement is about environment, not arithmetic. A base CVSS score describes the vulnerability's intrinsic properties, not what it reaches in *this* network. Argue from the asset: a cracked passphrase on a flat network reaches the point-of-sale system from the car park. Offer the vector for comparability, but lead with exposure, and give a verifiable fix plus the residual risk so the client has a concrete decision rather than a number to argue about.
</details>

<details>
<summary>Reference answer</summary>

**Reframe from score to exposure.** A base CVSS score reflects the vulnerability's intrinsic properties, not your environment — that is exactly what the environmental metrics (and your narrative) are for. On this network the passphrase is the only thing separating anyone in radio range from the *same flat segment that carries the point-of-sale system*. So the real question is not "5.3 or High?" but "what does an attacker in the car park reach once the passphrase falls, and what does that cost the business?" — cardholder data exposure, PCI consequences, downtime. Argued that way, Medium understates it.

**Keep it collaborative, not a number fight.** Provide the CVSS vector so they can see where your rating diverges (likely environmental/scope and the asset context the base score omits), but lead with the asset-framed rationale. Acknowledge their constraint rather than overruling it.

**Give them a decision, not just a severity.** Pair it with the verifiable fix (strong passphrase and/or WPA3-SAE with PMF; proven by a bounded crack now being exhausted and forged deauth rejected) and, crucially, segmenting the point-of-sale system off the flat network so a future passphrase compromise no longer reaches it. Then state residual risk: "after the passphrase and segmentation changes, guest Wi-Fi compromise no longer reaches POS; residual exposure is limited to the guest segment." That turns an argument about a number into an actionable choice the client can own.
</details>

## References

- NIST SP 800-30 Rev. 1 — risk assessment concepts behind prioritisation and residual risk (`../../references/README.md`).
- FIRST — CVSS specification and user guide: base vs environmental scoring, why context matters (`../../references/README.md`).
- NIST SP 800-115 — testing and assessment reporting (`../../references/README.md`).
- Where each retest measurement comes from: `../module-06/lesson-04.md` (bounded crack), `../module-07/lesson-01.md` (SAE no offline hash), `../module-11/lesson-05.md` (client rejects rogue RADIUS).
- The program these fixes build toward: `../module-14/lesson-01.md`; the report they live in: `../module-14/lesson-02.md`.
- Glossary: residual risk framing via keyspace, strong-password (no-crack) case, PMKID suppression (`../../glossary.md`).

## What you should now be able to do

- Build a prioritised, verifiable remediation roadmap in which each item carries a vulnerable-vs-hardened retest as proof of fix.
- State residual risk so a decision-maker can act on it — what was fixed, what remains, and why.
- Communicate findings by justifying severity against the client's assets rather than reciting a generic score, and deliver bad news constructively.
