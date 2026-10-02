# Recorded-data capstone — assess a supplied engagement and report

This is the path-R capstone: a realistic wireless assessment you complete with **no wireless hardware**, working entirely from supplied, validated captures. You take a fictional but complete engagement from recon through interpretation and justified technique selection to a full written report with remediation and residual risk. It is credited as **analysis — recorded data** only; it does not prove live capture or injection, and it never will — that is the point of being honest about the path.

> [!NOTE]
> **Lab path:** R (recorded-data) only. You interpret supplied captures and run the cracking/analysis workflow. This capstone **cannot** be credited as physical capture or injection ([`../curriculum/assessment-rubrics.md`](../curriculum/assessment-rubrics.md)). If you want physical-RF credit, do the [physical-lab capstone](physical-lab-capstone.md).

## Why this matters

Most of the judgement in a real wireless engagement happens after the capture, not during it: deciding what a frame set actually proves, choosing the technique the evidence supports, knowing when *not* to crack, and writing it up so a client can act. This capstone exercises exactly that skill, which is the one a recorded-data learner can genuinely master. It is also the honest ceiling of the R path — you will reason about RF behaviour you did not produce, and your report must say so.

## The scenario

You have been authorised (on paper — see the authorisation step) to assess the wireless posture of a fictional small office, **"Meridian Clinic"**, an owned lab environment standing in for the client. The office runs three wireless networks, all on equipment the lab owns, all using synthetic credentials:

- **`Meridian-Staff`** — WPA2-Personal, used by staff laptops. You are told PMF is disabled.
- **`Meridian-Guest`** — WPA2-Personal, a separate guest SSID with its own passphrase, intended to be on a segmented VLAN.
- **`Meridian-Secure`** — a network the client *believes* is hardened and wants you to confirm or refute.

You are handed a set of captures taken by the lab team on the virtual path, plus the two wordlists the engagement agreed to use. Your job is to determine, from the captures alone, what is actually true about each network, which attacks the evidence supports, what the impact would be, and what the client must change.

> [!NOTE]
> **LAB TARGET vs REAL NETWORK:** every capture in this capstone was generated in our own lab on the virtual `mac80211_hwsim` path with synthetic credentials (`Lab-WiFi-Passw0rd!`, `LAB-FLAG-<uuid>`). You analyse only these supplied files. Analysing a capture of a network you do not own carries the same authorisation and interception constraints as capturing it did ([`../lessons/module-00/lesson-03.md`](../lessons/module-00/lesson-03.md)). "Meridian Clinic" is fictional; the owner of every target is the lab.

## Supplied captures

This capstone reuses the shared recorded-data set documented in [`../labs/common/CAPTURES.md`](../labs/common/CAPTURES.md), plus the module-6 wordlists. Map them onto the scenario as follows.

> [!IMPORTANT]
> The capture binaries are **PENDING** a verified generation run (`gen-captures.sh` on the virtual path; see [`../labs/common/CAPTURES.md`](../labs/common/CAPTURES.md)). **Never invent a checksum** — until a capture has been generated and its SHA-256 recorded from a real run, treat its expected result as documented, not reproduced, and write "checksum PENDING" wherever your report would cite one. The commands below are exact and will work unchanged once the files land.

| Network | Supplied capture(s) | What it should let you establish |
|---|---|---|
| `Meridian-Staff` | `wpa2-handshake-good.pcapng` / `.hc22000` | complete 4-way handshake; cracks with `bounded.txt` → `Lab-WiFi-Passw0rd!` (the weak-passphrase case) |
| `Meridian-Guest` | `wpa2-pmkid.pcapng` / `.hc22000` | RSN PMKID present in EAPOL M1; clientless crack with `bounded.txt` (and a segmentation question to reason about) |
| `Meridian-Secure` | `wpa2-strong.pcapng` / `.hc22000` | complete handshake, 24-char random passphrase; does **NOT** crack with the shipped lists — the correct outcome is to recommend the control |
| (quality control) | `wpa2-handshake-partial.pcapng` | **incomplete** handshake; tools report no crackable material — included so you can tell a bad capture from a strong passphrase |

Wordlists come from [`../labs/common/make-wordlists.sh`](../labs/common/CAPTURES.md): `bounded.txt` (contains `Lab-WiFi-Passw0rd!`) and `strong-absent.txt` (deliberately does not contain the strong passphrase).

> [!CAUTION]
> One of the four files is a trap. The partial handshake and the strong-passphrase handshake **both** fail to yield a key — but for completely different reasons, and they demand opposite conclusions in your report (re-capture needed vs the control is working). Distinguishing them is part of the grade. See [`../lessons/module-06/lesson-02.md`](../lessons/module-06/lesson-02.md) for how a partial handshake looks.

## Deliverables

Submit one engagement report plus your working notes:

1. **A completed authorisation record** — [`../templates/authorisation-template.md`](../templates/authorisation-template.md) filled for this engagement (owner = the lab; the four SSIDs as the allowlist; path R; no transmission, so transmission limits read "none — recorded-data analysis").
2. **A lab notebook** — one [notebook entry](../templates/lab-notebook-template.md) per network, recording the path (R), the commands run, the artifacts, and what each result proved and did not prove.
3. **A full engagement report** following [`../templates/report-template.md`](../templates/report-template.md): executive summary, scope & authorisation, methodology, one finding per network, limitations, prioritised remediation, retest plan, and residual risk. Model it on [the sample report](sample-report.md).

Your report must make at least these calls, each justified from the evidence:

- `Meridian-Staff`: a weak-passphrase WPA2-PSK finding (recovered key as **evidence**, with the asset-framed impact and the entropy as the real cause).
- `Meridian-Guest`: a PMKID finding — state precisely that collection was available **because** the AP included an RSN PMKID and that it is not fully passive ([`../lessons/module-06/lesson-03.md`](../lessons/module-06/lesson-03.md)); and reason about whether the capture alone lets you confirm or deny the intended segmentation (it does not — that is a limitation, not a finding).
- `Meridian-Secure`: a **strong-password** result — correctly conclude it will not crack in scope, estimate the effort, and recommend the control. *Failing to crack here is the correct outcome and a full-credit finding.*
- The partial capture: **not** a finding about the network — a note that the capture was unusable and a recommendation to re-capture. Do not report a strong passphrase where you actually have a bad capture, or vice versa.

## Step guidance

This is guidance on *what to establish*, not a click-path — choosing the exact commands and their order is part of what is assessed.

1. **Scope first.** Fill the authorisation record and the allowlist before you open a capture. Decide, in writing, what path-R analysis can and cannot conclude here.
2. **Recon from the captures.** For each file, identify the SSID, BSSID, band/channel where visible, the security configuration advertised (RSN parameters, PMF bit), and whether the frames you need (full 4-way handshake, or an M1 with an RSN PMKID) are actually present. This is your reconnaissance — you have no live scan, so the captures *are* the recon surface.
3. **Decide what each capture supports before cracking anything.** Which network has a complete handshake? Which has a PMKID? Which is partial? Write the technique selection down with its justification *before* you run a cracker, so the evidence drives the choice rather than the reverse.
4. **Run the bounded cases.** Convert/confirm the `hc22000` and run `hashcat -m 22000 … bounded.txt` for `Meridian-Staff` and `Meridian-Guest`. Record the recovered key as evidence, not as the conclusion.
5. **Run the strong case correctly.** Run `Meridian-Secure` against `strong-absent.txt`, confirm `Exhausted`, then estimate the brute-force effort (keyspace × your H/s) and write the recommendation. Do not keep running it.
6. **Diagnose the partial capture.** Show that it yields no crackable material and explain *why* (missing handshake messages), distinct from the strong case (valid hashline, passphrase out of reach).
7. **Interpret and assess.** For each network, state the affected configuration precisely, the impact framed to the clinic's assets, and the preconditions that must hold for the attack (and the ones that would make it fail).
8. **Write the report.** Executive summary last; limitations explicit (no RF/live-capture evidence; segmentation unverifiable from captures; captures PENDING a verified run); remediation verifiable; residual risk in one actionable line.

<details>
<summary>Representative commands (path R)</summary>

```bash
# Build the wordlists (once)
./labs/common/make-wordlists.sh         # -> wordlists/bounded.txt, wordlists/strong-absent.txt

# Recon: inspect a capture's security parameters and handshake completeness
#   (use your frame-analysis workflow from Module 5/6 — e.g. tshark/Wireshark display filters
#    for eapol, and check the RSN IE / PMF capability bit and for an RSN PMKID in M1).

# Meridian-Staff — weak WPA2-PSK, expected to recover:
hashcat -m 22000 wpa2-handshake-good.hc22000 wordlists/bounded.txt
hashcat -m 22000 wpa2-handshake-good.hc22000 wordlists/bounded.txt --show

# Meridian-Guest — PMKID, same mode, clientless:
hashcat -m 22000 wpa2-pmkid.hc22000 wordlists/bounded.txt

# Meridian-Secure — strong passphrase, expected Exhausted (correct outcome):
hashcat -m 22000 wpa2-strong.hc22000 wordlists/strong-absent.txt
hashcat -b -m 22000                    # your H/s, for the effort estimate

# Partial capture — expected: no valid hashline / no crackable material (re-capture, not a finding)
```

Flags drift across versions ([`../TOOLS.md`](../TOOLS.md)); check `--help` for the installed version rather than assuming a capture is bad.
</details>

## Rubric (scored out of 100; pass mark 70)

Reproduced from [`../curriculum/assessment-rubrics.md`](../curriculum/assessment-rubrics.md). Obtaining a key alone is **not** a pass — justification, evidence, remediation, and retest are what carry the score.

| Dimension | Weight | What full credit looks like here |
|---|---|---|
| Recon & scoping | 15 | authorisation + allowlist complete; each capture's SSID/BSSID/security config correctly read; path-R limits stated up front |
| Interpretation / analysis | 20 | every network correctly characterised; partial vs strong distinguished and explained; PMKID preconditions stated; segmentation correctly flagged as unverifiable from captures |
| Justified technique selection | 15 | the technique for each network chosen from the evidence and justified *before* running it; no technique applied that the capture cannot support |
| Evidence quality | 15 | findings cite the artifact filename and its checksum (**PENDING** where not yet generated — never invented); synthetic secrets quoted as evidence with a note they would be redacted for a real secret |
| Remediation | 15 | concrete, prioritised, verifiable controls per finding, each with the vulnerable-vs-hardened measurement that confirms it |
| Retesting / verifying the fix | 10 | a stated retest plan — what you would re-run and the result that would prove the fix (e.g. bounded crack now `Exhausted`; PMKID suppressed) — since path R cannot perform the retest itself, say so |
| Report incl. exec summary, limitations, residual risk | 10 | summary true and complete on its own; limitations honest (no live/RF evidence; captures PENDING; segmentation unverified); residual risk in one actionable sentence |

> [!IMPORTANT]
> You can **pass this capstone without recovering `Meridian-Secure`'s key** — correctly concluding it won't crack in scope and recommending the control is full credit for that network. Conversely, recovering `Meridian-Staff` and `Meridian-Guest` with no justification, no evidence integrity, no remediation, and no residual risk is a fail. The key is evidence inside a finding, never the deliverable ([`../lessons/module-14/lesson-02.md`](../lessons/module-14/lesson-02.md)).

<details>
<summary>Marking guide (for a reviewer / instructor)</summary>

**Must appear for a pass (70+):**

- Authorisation record and allowlist filled before analysis; path-R limitation stated explicitly somewhere in scope or limitations.
- `Meridian-Staff` reported as a weak-passphrase WPA2-PSK finding — recovered key shown as evidence, entropy named as the cause, asset-framed impact, verifiable remediation (lengthen passphrase / WPA3-SAE / enable PMF).
- `Meridian-Guest` reported as a PMKID finding with the RSN-PMKID precondition and the "not fully passive" qualification; the intended segmentation flagged as **unverifiable from the captures** (a limitation, not a confirmed finding).
- `Meridian-Secure` reported as a strong-password result: `Exhausted`, an effort estimate, and the control recommendation — explicitly framed as the correct outcome, not a failed test.
- The partial capture correctly diagnosed as unusable (re-capture), **not** confused with the strong case.
- Limitations section states: no live-capture/RF/injection evidence (path R); captures PENDING a verified run so checksums are not yet reproduced; segmentation and PMF status taken partly from the brief, not proven from frames.
- Residual risk in one actionable sentence; executive summary readable by a non-technical decision-maker.

**Red flags (cap the score):**

- A recovered key presented as the conclusion with no finding structure around it.
- Any invented SHA-256 checksum, or a claim that a capture was reproduced when it is PENDING.
- The strong case reported as "secure, done" with no effort estimate, or as a failure/"couldn't crack it."
- The partial capture reported as a network finding (or the strong case reported as a bad capture).
- Any claim of physical capture/injection or live RF observation — this is a path-R analysis and must not be credited otherwise.
</details>

## What you should be able to show

- You can turn a set of supplied captures into a scoped, justified, evidence-backed engagement report.
- You can tell a bad capture from a strong passphrase, and report each with the opposite correct conclusion.
- You can state honestly what recorded-data analysis proves and what it cannot, and never claim physical or RF credit from it.
