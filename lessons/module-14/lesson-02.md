---
id: "14.2"
module: 14
minutes: 30
practice_minutes: 35
prerequisites: ["13.3"]
objectives:
  - Structure a wireless penetration-test report that serves both a non-technical decision-maker and an engineer who must reproduce and fix each finding.
  - Write a finding with affected configuration, evidence (artifact plus checksum), why-it-works/why-it-may-fail, and asset-framed impact.
  - State scope, limitations, remediation, retest, and residual risk honestly, treating obtaining a key as evidence rather than as the deliverable.
volatility: concept
sources:
  - title: "NIST SP 800-115 — Technical Guide to Information Security Testing and Assessment (reporting)"
    url: https://csrc.nist.gov/pubs/sp/800/115/final
  - title: "Penetration Testing Execution Standard (PTES) — Reporting"
    url: http://www.pentest-standard.org/index.php/Reporting
  - title: "OWASP Web Security Testing Guide — Reporting (structure and evidence)"
    url: https://owasp.org/www-project-web-security-testing-guide/
last_verified: "2026-10-01"
---

# 14.2 · Writing the wireless pentest report

The report is the deliverable — not the key you recovered. A good wireless report is read by two people who never read the same part: a decision-maker who reads the executive summary and nothing else, and an engineer who reproduces and fixes each finding. This lesson walks the report structure in `../../templates/report-template.md` and shows how to write each section so it serves both, with honest scope, evidence that stands on its own, and residual risk a manager can act on.

## Why this matters

Everything you learned to do in this course produces artifacts — a captured handshake, a cracked passphrase, a rogue-RADIUS credential capture, a client that refused a forged deauth. None of it helps the client until it is written down in a way they can act on. Testers routinely lose the value of good work by handing over a tool transcript and a recovered key: the decision-maker cannot tell whether to spend money, and the engineer cannot tell exactly what to change. Worse, "we got the key" overstates certainty — it says nothing about the conditions that made it possible, what you did not test, or what risk remains after the obvious fix. The report is where you convert technique into a decision and a verifiable change. It is also the professional artifact you are judged on; the capstones (`../../projects/`) are graded on the report, not on whether a key fell out.

## Learning objectives

- Structure a wireless penetration-test report that serves both a non-technical decision-maker and an engineer who must reproduce and fix each finding.
- Write a finding with affected configuration, evidence (artifact plus checksum), why-it-works/why-it-may-fail, and asset-framed impact.
- State scope, limitations, remediation, retest, and residual risk honestly, treating obtaining a key as evidence rather than as the deliverable.

## Prerequisites

- Lesson 13.3 — impact assessment and limitations. This lesson assumes you can already reason about the impact of a wireless finding and state what an engagement did not cover; here you write those judgements into a report.

## Concept

This is a practice lesson built around the report template. Each section below is a process: what it is for, who reads it, and how to write it so it is both honest and useful. **LAB TARGET vs REAL NETWORK:** every example uses synthetic lab credentials (`Lab-WiFi-Passw0rd!`, `LAB-FLAG-{uuid}`); a real report redacts real secrets and names only authorised, in-scope targets.

### The control or process

Open `../../templates/report-template.md` alongside this lesson. It has eight parts; write them in this order of *thinking*, even though the reader sees the executive summary first.

**Scope & authorisation.** The allowlist of BSSIDs/SSIDs in scope, who authorised the test and when, the agreed transmission constraints (channels, TX power, shielding) and stop conditions, and the lab paths used (R recorded-data / V virtual / P physical) with what each proves. This section bounds everything after it: a finding outside this scope should not exist, and a reader learns here what "tested" even means for this engagement.

**Methodology.** Tools and versions, the recon approach (passive/active), the capture method, and the analysis workflow — enough that a peer could repeat it. Pin versions (your `TOOLS.md` set): `hcxdumptool`, `hashcat`, `aircrack-ng`, `hostapd`/`hostapd-wpe`, and so on. Reproducibility is what separates a finding from an assertion.

**Findings** — the core, one subsection per finding. Each finding has five parts:

- **Title & severity, with the rationale.** The severity is justified against *this client's* exposure, not read off a generic table (Lesson 14.3 goes deeper on severity rationale).
- **Affected configuration** — the precise conditions that must hold. "WPA2-PSK, PMF disabled, 8-character lowercase passphrase," not "weak Wi-Fi." "An enterprise client that does not validate the RADIUS server certificate," not "insecure client." The precision is what tells the engineer exactly what to change and tells the reader exactly how narrow or broad the problem is.
- **Evidence** — the capture, log line, or command output that proves it, named by **artifact filename and SHA-256 checksum**, with real secrets redacted (the lab uses synthetic ones). The checksum lets the client verify you are both looking at the same bytes (glossary: SHA-256 checksum, provenance). Evidence is shown, not claimed.
- **Why it works / why it may fail** — the mechanism and the preconditions. A PMKID finding states that the AP included an RSN PMKID and that collection was not fully passive (Module 6.3); an evil-twin finding states which client behaviour made it work and which hardened behaviour would defeat it (Module 9). This is where you prevent the reader from over-generalising a conditional result.
- **Impact** — what the attacker gains, framed to the client's assets. "Recovery of the office Wi-Fi passphrase grants an attacker in the car park access to the flat internal network, including the finance file share," not "attacker gains network access (High)."

**Limitations.** What you did **not** test and why — out of scope, no hardware for a path, time-boxed, a technique PMF prevented (do not treat a rejected deauth as a failed test; it is a finding that the control works). State plainly that a finding's absence is not a guarantee of safety. Honest limitations are what make the rest of the report trustworthy.

**Remediation.** Prioritised, concrete, and verifiable: for each finding, the control and how to confirm it took effect — the vulnerable-vs-hardened measurement ("deauth now rejected with PMF," "PMKID suppressed," "the hardened client refuses the rogue RADIUS and logs why"). This ties straight back to the defence program in Lesson 14.1. Lesson 14.3 turns these into a prioritised roadmap.

**Retest & residual risk.** What you re-ran after the fix and the result, plus the risk that remains in one actionable sentence ("passphrase strengthened, but WPS is still enabled"; "SAE-only configured, but three legacy clients were dropped and need replacement"). Residual risk is the honest tail the decision-maker must own.

**Executive summary — written last, read first.** Three to six sentences, no jargon: what was tested, the overall risk, the two or three things that most need fixing, whether exploitation was demonstrated or only inferred, and residual risk in one line. The decision-maker may read only this; it must be true and complete on its own.

### Serving both audiences — and why a key is not the deliverable

The two audiences fail in opposite ways, and the structure defends against both:

| Reader | Reads | Fails when the report… | The section that serves them |
|---|---|---|---|
| Decision-maker | Executive summary, residual risk | is a tool transcript with no business meaning | Executive summary, impact (asset-framed), residual risk |
| Engineer | Findings, remediation | states a conclusion without reproducible evidence | Methodology, affected config, evidence + checksum, remediation |

"We recovered the passphrase `Lab-WiFi-Passw0rd!`" is **evidence inside a finding**, not the deliverable. On its own it tells the decision-maker nothing to decide and the engineer nothing to change. The deliverable is the justified finding (what configuration, proven how), the asset-framed impact (what it means for them), the verifiable remediation (what to change and how to confirm), and the honest residual risk (what is left). A strong-password case where you *failed* to recover the key (Module 6.4) produces an equally valuable finding: the control works, here is the evidence, here is the effort estimate, keep the control. Obtaining a key is never the point; the decision and the verified change are.

## Hands-on

### Guided walkthrough — write one finding and the executive summary from a supplied result set

A paper/analysis exercise, R path, no radio. Using the supplied result set and the report template:

1. Open `../../templates/report-template.md` and the supplied `finding-inputs.md` in `../../labs/module-14/` — it gives you a lab result: a WPA2-PSK network, PMF disabled, an 8-character lowercase passphrase recovered from a captured handshake, with the artifact filename and its SHA-256 recorded.
2. Write the **finding**: title and a justified severity, the exact affected configuration, the evidence (name the artifact and its checksum; the passphrase is synthetic, so quote it as evidence but note it would be redacted for a real secret), the why-it-works/why-it-may-fail (handshake capture needed a connecting client; a strong passphrase would not have fallen), and the asset-framed impact for the described office.
3. Write the matching **remediation** line with its verification measurement (strengthen the passphrase and/or move to WPA3-SAE, enable PMF; confirm that a bounded crack now fails and that forged deauth is rejected).
4. Write a one-line **residual risk** sentence and then the **executive summary** (3–6 sentences, no jargon) last. Check the summary is true and complete on its own — hand it to someone who has not read the finding and see if they can decide.
5. Save your finding, remediation, residual-risk line, and executive summary as one document.

> [!NOTE]
> **Lab paths:** R — write a report section from a supplied result set using the template; no hardware. It proves you can turn a lab result into a finding, remediation, residual-risk statement, and a decision-maker-usable executive summary. It does **not** prove you performed the capture that produced the result — that credit belongs to the V/P path that generated it.
> **Start state:** `../../templates/report-template.md` and `finding-inputs.md` from the module zip.
> **Duration:** ~35 min.
> **Artifacts:** one complete finding (title/severity, affected config, evidence with artifact+checksum, why-it-works/why-it-may-fail, asset-framed impact), its remediation with a verification measurement, a one-line residual-risk statement, and a 3–6 sentence executive summary.
> **Cleanup:** none (paper exercise). Treat the synthetic passphrase as you would a real secret when deciding what to quote vs redact.

## Exercise

You are handed a junior tester's draft "report." In full, it reads: *"Cracked the Wi-Fi. Password is `Lab-WiFi-Passw0rd!`. Network is insecure, rating High. Recommend fixing."* The client is a dental practice whose Wi-Fi also carries the appointment-booking and imaging systems. Without rewriting the whole report, list the specific things this draft is missing for each of its two audiences, and explain why "cracked the Wi-Fi, here is the password" is evidence rather than a deliverable.

<details>
<summary>Hint</summary>

Go section by section against the template. The decision-maker cannot act because there is no asset-framed impact, no residual risk, and no plain-language summary. The engineer cannot act because there is no affected configuration, no evidence artifact or checksum, no methodology, no why-it-works/why-it-may-fail, and no verifiable remediation. The recovered password is the proof inside a finding, not the finding.
</details>

<details>
<summary>Reference answer</summary>

**For the decision-maker, the draft is missing:** an asset-framed impact (what does recovering this passphrase mean for the booking and imaging systems and patient data?), a plain-language executive summary, and a residual-risk statement. "High" with no rationale tied to the practice's assets is not something a manager can weigh or fund.

**For the engineer, the draft is missing:** the affected configuration (WPA2-PSK? PMF on/off? passphrase length/composition?), the evidence artifact and its checksum, the methodology and tool versions, the why-it-works/why-it-may-fail (did it need a connecting client; would a strong passphrase have resisted?), and a verifiable remediation (strengthen passphrase / WPA3-SAE / PMF, confirmed by the bounded crack now failing and deauth being rejected). Without these the engineer cannot reproduce it, cannot be sure what to change, and cannot prove the change worked.

**Why the password is evidence, not a deliverable:** the recovered passphrase proves the finding, but on its own it drives no decision and no verifiable fix. The deliverable is the justified finding, the asset-framed impact, the verifiable remediation, and the honest residual risk. A test that had *failed* to crack a strong passphrase would still produce a complete, valuable report — the control works, here is the evidence, keep it. The key is never the point.
</details>

## References

- `../../templates/report-template.md` — the structure this lesson walks section by section.
- NIST SP 800-115 — reporting guidance for security testing (`../../references/README.md`).
- PTES — Reporting (executive summary vs technical report, evidence) (`../../references/README.md`).
- OWASP Web Security Testing Guide — reporting structure and evidence quality, applied to wireless (`../../references/README.md`).
- Impact and limitations feeding the report: `../module-13/lesson-03.md`.
- Evidence integrity: glossary entries for SHA-256 checksum and provenance (`../../glossary.md`).

## What you should now be able to do

- Structure a wireless report that serves both a non-technical decision-maker and an engineer reproducing each finding.
- Write a finding with affected configuration, evidence (artifact plus checksum), why-it-works/why-it-may-fail, and asset-framed impact.
- State scope, limitations, remediation, retest, and residual risk honestly, and treat a recovered key as evidence inside a finding rather than as the deliverable.
