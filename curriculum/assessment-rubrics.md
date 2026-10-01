# Assessment rubrics & completion criteria (planning — not imported)

Covers review points 4, 10, 11. Graded quizzes are multiple-choice in `.quiz.yaml` (instructions §5);
the rubrics here govern **labs, exercises, and capstones**, and define **per-path completion** so a
recorded-data learner is never credited with physical capture/injection.

## Per-path completion criteria

| Path | A module lab is "complete" when the learner… | Credited as |
|---|---|---|
| **R** Recorded-data | correctly interprets supplied captures, runs the cracking/analysis workflow, and explains prerequisites + why an attack would succeed/fail | "analysis — recorded data" |
| **V** Virtual (`mac80211_hwsim`) | reproduces the protocol flow / attack mechanic end-to-end in the VM and shows the expected artifacts | "protocol lab — virtual radios" |
| **P** Physical | performs real monitor/capture/injection/AP against owned equipment and shows the real artifacts + RF notes | "practical — physical RF" |

Completion records which path was used. **R and V do not grant P credit.** Where a lab offers multiple
paths, the learner records what they actually did.

## Every lab must document (author checklist)
- [ ] **Known starting state** (what's configured, which path, prerequisites met)
- [ ] **Estimated duration**
- [ ] **Expected artifacts** (named files/outputs: e.g. `handshake.pcapng`, `*.hc22000`, RADIUS log line)
- [ ] **Success criteria** (objective, checkable — incl. "protection works" successes)
- [ ] **Troubleshooting** (top 3–5 failure modes + fixes)
- [ ] **Cleanup / reset** (stop services, remove rogue AP, restore client, delete synthetic creds)
- [ ] **Progressive hints** in `<details>`; independent exercise separate from the guided walkthrough

## Shipped capture provenance (every `.pcap`/`.pcapng`/`.hc22000`)
Record in the lab README: **how generated** (our lab / owned equipment / synthetic creds), **tool +
version**, **redistribution permission/licence**, **SHA-256 checksum**, and **what it should
produce**. Ship **both** a successful example (e.g. clean 4-way handshake) **and** an unsuccessful one
(partial handshake / no PMKID) so learners learn to tell them apart.

## Cracking exercises (bounded + strong-password)
- **Bounded**: supplied wordlist contains the passphrase → known achievable result, exercise
  terminates. Success = recovered key + correct explanation of method.
- **Strong-password**: passphrase not in any supplied list / high entropy → **recovery not expected**.
  Success = correctly concluding it won't crack in scope, estimating effort, and **recommending the
  control** (passphrase entropy, WPA3-SAE). *Failing to crack is the correct outcome here.*

## "Prove the protection works" assessments
A learner can pass by **demonstrating a defence**, not only an attack — e.g.:
- show **PMF rejects** the deauth (vulnerable vs hardened comparison),
- show **PMKID suppressed** on a hardened AP,
- show the **correctly-configured enterprise client rejects the rogue RADIUS** with the log/packet
  evidence and the reason.

## Capstone rubric (both capstones)
Score each dimension (weight): **Recon & scoping** (15) · **Interpretation/analysis** (20) ·
**Justified technique selection** (15) · **Evidence quality** (15) · **Remediation** (15) ·
**Retesting / verifying the fix** (10) · **Report incl. exec summary, limitations, residual risk** (10).
Obtaining a key alone is **not** a pass — justification, evidence, remediation, and retest matter.

- **Recorded-data capstone**: recon + interpret supplied captures + justify + assess + report.
- **Physical-lab capstone**: owned APs — WPA2 (handshake+PMKID), WPA3 assessment, evil-twin vs lab
  client — then **harden and retest**, showing the attack now fails.

Ship a **sample report** + the rubric in `projects/`. Report template covers: scope & authorisation,
methodology, findings, impact, **limitations**, remediation priorities, **residual risk**, and a
concise **executive summary** alongside technical evidence.
