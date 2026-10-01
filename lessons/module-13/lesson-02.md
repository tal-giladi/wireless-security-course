---
id: "13.2"
module: 13
minutes: 25
practice_minutes: 35
prerequisites: ["13.1"]
objectives:
  - Run a repeatable wireless methodology that ties the course together — recon, capture, analysis, attempt, harden, retest.
  - Capture evidence with provenance — artifact naming, checksums, a chain-of-custody-lite record, and the lab notebook.
  - Record honestly which lab path (R, V, or P) proved each claim, so analysis is never credited as physical capture.
volatility: concept
sources:
  - title: "NIST SP 800-115 — Technical Guide to Information Security Testing and Assessment"
    url: https://csrc.nist.gov/publications/detail/sp/800-115/final
  - title: "Penetration Testing Execution Standard (PTES) — Reporting and evidence handling"
    url: http://www.pentest-standard.org/index.php/Reporting
last_verified: "2026-10-01"
---

# 13.2 · Methodology and evidence capture

A result you cannot reproduce and cannot prove is not a finding — it is an anecdote. This lesson gives you a single repeatable methodology that threads every phase of the course into one engagement loop, and the evidence discipline that makes each step defensible: what to record, how to name and checksum artifacts, a lightweight chain of custody, the lab notebook, and the honest recording of which lab path actually proved each claim. Scope (Lesson 13.1) said what you may do; this lesson says how you do it so the work stands up to a reviewer.

## Why this matters

Two testers can run the same tools against the same network and produce very different reports. The difference is method and evidence. A repeatable methodology means you do not forget the hardening-and-retest step that turns an attack into a recommendation, and it means a second tester can follow your notes and reach your conclusion. Evidence discipline means that when a client's engineer disputes a finding six weeks later, you can hand over a capture whose checksum still matches, a notebook entry that names the exact commands and versions, and an honest statement of which path produced the result. Without that, the report is "trust me," and in this field "trust me" does not survive a retest. This is also where the course's honesty rule becomes a professional habit: **a recorded-data analysis is never written up as if you performed a live capture.**

## Learning objectives

- Run a repeatable six-phase wireless methodology — recon, capture, analysis, attempt, harden, retest — and say which course module feeds each phase.
- Capture evidence with provenance: consistent artifact naming, SHA-256 checksums, a chain-of-custody-lite record, and a completed lab-notebook entry.
- Record which lab path (R recorded-data / V virtual / P physical) proved each claim, so interpretation is never credited as physical capture or injection.

## Prerequisites

- Lesson 13.1 — scoping and authorisation. You run this methodology only inside an agreed scope, with the allowlist and stop conditions already written.

## Concept

This is a process lesson. **LAB TARGET vs REAL NETWORK:** you practise the methodology against your own lab; the same loop and the same evidence rules apply to an authorised engagement, and to nothing else.

### The control or process — the engagement loop

The course is not a bag of attacks; it is one loop applied to each in-scope network. The six phases, and where each was taught:

1. **Recon** (Modules 4–5). Passive-then-active discovery: enumerate in-scope BSSIDs, their security (RSN/AKM — WPA2, WPA3-SAE, transition, OWE, Enterprise), channels, and associated clients. Output: a target profile per allowlisted BSSID.
2. **Capture** (Modules 5–6). Obtain the evidence the chosen technique needs — a clean 4-way handshake, a PMKID (when the AP offers one), an EAP exchange — on the path you are using. Output: named, checksummed capture files.
3. **Analysis** (Modules 5–6, 10–12). Interpret what you captured: is the handshake complete, is PMF required, does the RSN element advertise transition mode, is the enterprise client validating the server cert? Output: a reasoned statement of what is and is not attackable, and why.
4. **Attempt** (Modules 6–11). Run the justified technique — bounded crack, PMKID crack, evil-twin against a controlled client, enterprise credential capture — recording the outcome, including an *expected failure* (a strong passphrase that does not crack, a deauth rejected by PMF). A correct "it did not work, here is why" is a result.
5. **Harden** (every attack module's defence half). Apply the specific control — passphrase entropy, PMF required, WPS disabled, server-cert validation, SAE-only — to the owned target.
6. **Retest** (Modules 6.5, 11.5, and throughout). Repeat the attempt against the hardened configuration and **measure the difference**: deauth now rejected, PMKID suppressed, rogue RADIUS refused with the client's log line explaining why. Output: the vulnerable-vs-hardened evidence pair that makes the recommendation provable.

The loop is deliberately circular: hardening without retest is an assertion; retest is what earns the recommendation its place in the report.

### Evidence capture — provenance, naming, checksums

Evidence is only as good as its provenance. For every artifact you keep, record enough that a stranger (or future you) can trust it:

- **Consistent artifact names.** Encode the target, phase, and path, e.g. `bssid-aa-bb-cc_m6_handshake_P.pcapng`, `bssid-aa-bb-cc_m6_pmkid_R.hc22000`, `ent-client01_m11_rogue-radius_V.log`. A name should tell you what it is without opening it.
- **Provenance record** for every shipped or kept capture: how it was generated (your lab, owned equipment, synthetic credentials such as `Lab-WiFi-Passw0rd!`), the tool and version, the redistribution/licence status, and **what it should produce** (e.g. "cracks to `Lab-WiFi-Passw0rd!` with the supplied wordlist"). This mirrors the capture rules in `curriculum/assessment-rubrics.md`.
- **SHA-256 checksum** of each artifact, recorded at capture time. A checksum proves the bytes have not changed since; it says nothing about where the file came from, which is why provenance and checksum are *both* required.

```bash
# record a checksum when you capture evidence (Linux)
sha256sum bssid-aa-bb-cc_m6_handshake_P.pcapng >> SHA256SUMS
# verify later, before you rely on it in a report
sha256sum -c SHA256SUMS
```

### Chain-of-custody-lite and the lab notebook

You do not need courtroom chain of custody for a lab, but you need its lightweight form: for each artifact, **who captured it, when, on which device/interface, and where it has been stored** since. One line per artifact is enough, kept with the checksums. The point is that nobody can quietly swap or edit evidence between capture and report without it being obvious.

The [lab-notebook template](../../templates/lab-notebook-template.md) is where this lives — one entry per lab, recording starting state, tools and versions, commands run (with *why*), artifacts produced (with checksum and expected result), observations (including why an attack failed if it did), the vulnerable-vs-hardened measurement, and cleanup. A disciplined notebook makes writing the report (Module 14) a transcription job rather than an act of memory.

### Recording the lab path honestly

Every claim in the notebook and the report carries the path that produced it — **R** recorded-data, **V** virtual (`mac80211_hwsim`), or **P** physical RF — because the paths prove different things (`curriculum/assessment-rubrics.md`):

- **R** proves interpretation and the cracking/analysis workflow on a *supplied* capture — not that you captured it live.
- **V** proves protocol flow and attack mechanics end-to-end in simulated radios — not real RF, drivers, range, or injection.
- **P** is the only path that proves real monitor, capture, injection, and AP-mode behaviour.

So "I cracked the handshake" is incomplete; "I cracked a *supplied* handshake (path R)" or "I captured and cracked the handshake on owned hardware (path P)" is honest. **R and V never earn physical-capture or injection credit**, and a report that blurs this is overclaiming — the exact error the course's scoping rules exist to prevent.

## Hands-on

### Guided walkthrough — build a methodology checklist and evidence log

A paper/recorded exercise; no live attack. Reuse the scope sheet from Lesson 13.1.

1. Write a **one-page methodology checklist** with the six phases above as headings. Under each, note the course module(s) that feed it and the artifact that phase should produce.
2. Take any supplied capture from an earlier module (a Module 5 or Module 6 recorded capture) and give it a **consistent name** encoding target, phase, and path `R`.
3. Compute its **SHA-256** and record it in a `SHA256SUMS` file, then add a one-line **provenance + custody** entry: how it was generated, tool/version, what it should produce, who holds it and since when.
4. Open the [lab-notebook template](../../templates/lab-notebook-template.md) and fill one entry for an analysis you actually did (even "parsed this capture in Wireshark and confirmed a complete handshake"). **Mark the path as R** and the credited-as line accordingly.
5. Write the single sentence you would put in a report for that analysis — and check it does not claim live capture.

### Lab

> [!NOTE]
> **Lab paths:** R — produce a methodology checklist and an evidence log against a supplied capture (no hardware, nothing transmitted). It proves you can run the engagement loop on paper and keep defensible evidence; it does **not** prove live capture or injection — those are credited only on V/P in the attack modules.
> **Start state:** the [lab-notebook template](../../templates/lab-notebook-template.md); your Lesson 13.1 scope sheet; one supplied capture from Module 5 or 6.
> **Duration:** ~35 min.
> **Artifacts:** a one-page six-phase methodology checklist; a renamed capture with a `SHA256SUMS` line; a one-line provenance + chain-of-custody-lite entry; one completed lab-notebook entry marked path R.
> **Success criteria:** the checksum verifies with `sha256sum -c`; the notebook entry names tools/versions and the path; the report sentence states the capture was supplied (path R) and does not claim live capture.
> **Cleanup:** none (paper/analysis). If you later run V/P work, record its path separately — do not relabel R/V work as P.

## Exercise

You are handed a colleague's draft notebook entry: *"Target `Lab-Net-7`. Captured the 4-way handshake and cracked it to `Lab-WiFi-Passw0rd!`. Hardened the AP. Done."* Independently of any tool, list what is missing or wrong for this to be defensible evidence, and rewrite it into a sound entry. Assume the work was actually done on the recorded-data path against a supplied capture.

<details>
<summary>Hint</summary>

Walk the evidence checklist: provenance, naming, checksum, custody, tools/versions, and — critically — the path. Then check the two phases the entry skips entirely. Finally, is the word "captured" honest for recorded-data work?
</details>

<details>
<summary>Reference answer</summary>

What is missing or wrong:

- **Path not stated, and the verb overclaims.** The work was recorded-data (R), so "captured the 4-way handshake" is false — the capture was supplied. It should read "cracked a *supplied* handshake (path R)," which credits interpretation and the cracking workflow, not live capture.
- **No provenance or checksum.** There is no record of how the capture was generated, the tool/version, its expected result, or a SHA-256 — so nobody can verify the evidence later.
- **No chain-of-custody-lite.** Who holds the file, captured when, on which source, stored where.
- **No retest / measurement.** "Hardened the AP" is an assertion; the entry skips the retest that proves the control works (e.g. with a strong passphrase the same crack now exhausts without recovery). Hardening without a measured retest is not a finding.
- **No commands or observations.** Nothing a second tester could follow.

A sound rewrite: *Lab: 6.4 — offline cracking. Date / Path: R (recorded-data), credited as "analysis — recorded data." Starting state: supplied capture `labnet7_m6_handshake_R.pcapng` (provenance: our lab, owned AP, synthetic creds; hashcat 6.x; expected: cracks to `Lab-WiFi-Passw0rd!` with the supplied wordlist; SHA-256 recorded in `SHA256SUMS`; held by me since capture). Commands: `hcxpcapngtool` → `hc22000`, then `hashcat -m 22000 -a 0` with the supplied wordlist (to recover the PSK). Observations: recovered `Lab-WiFi-Passw0rd!`; the capture contained a complete M1–M2 pair. Vulnerable vs hardened: against a supplied strong-password capture the same run exhausts the wordlist without recovery — the recommended control (high-entropy passphrase / WPA3-SAE) is what makes the difference. Cleanup: none (analysis).*
</details>

## References

- NIST SP 800-115 — testing phases and evidence handling (`../../references/README.md`).
- PTES — reporting and evidence (`../../references/README.md`).
- [Lab-notebook template](../../templates/lab-notebook-template.md) and [report template](../../templates/report-template.md).
- Capture provenance, checksums, and per-path credit: `curriculum/assessment-rubrics.md` (planning) and the glossary entries below.
- Scope first: [13.1](lesson-01.md). Safety and law: [00.3](../module-00/lesson-03.md).
- Glossary: engagement loop, chain of custody (lite), provenance, SHA-256 checksum, lab paths (R/V/P) (`../../glossary.md`).

## What you should now be able to do

- Run the six-phase engagement loop — recon, capture, analysis, attempt, harden, retest — and name the module that feeds each phase.
- Keep defensible evidence: consistent artifact names, SHA-256 checksums, a chain-of-custody-lite line, and a complete lab-notebook entry.
- Record the lab path for every claim and write findings that never credit recorded-data or virtual work as physical capture or injection.
