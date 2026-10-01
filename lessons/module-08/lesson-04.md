---
id: "08.4"
module: 8
minutes: 14
practice_minutes: 20
prerequisites: ["08.1", "08.2"]
objectives:
  - Check whether an owned AP has WPS enabled and in what mode, and judge its exposure.
  - Apply the clean remediation (disable WPS, or push-button only on patched firmware with lockout).
  - Measure the difference between a WPS-vulnerable and a hardened configuration.
volatility: implementation
sources:
  - title: "US-CERT/CISA VU#723755 — WiFi Protected Setup PIN brute force vulnerability"
    url: https://www.kb.cert.org/vuls/id/723755
  - title: "Wi-Fi Alliance — Wi-Fi Protected Setup"
    url: https://www.wi-fi.org/discover-wi-fi/wi-fi-protected-setup
last_verified: "2026-10-01"
---

# 08.4 · Prevalence and remediation — disabling and limiting WPS

WPS is one of the few features where the defensive advice is blunt: in most environments the right move is to turn it off. This lesson shows how to check what an owned AP actually exposes, what remediation to recommend, and how to measure that the fix closed both the offline (Pixie Dust) and online PIN paths — tying WPS back into the secure baseline from Module 2.

## Why this matters

WPS was designed for convenience, and it remains enabled by default on a large share of consumer and small-office routers — often with the owner unaware it is on. Because a recovered PIN hands over the WPA2 passphrase regardless of how strong that passphrase is, WPS can completely bypass the one control (passphrase entropy) that Module 6 spent so long establishing. A tester who can say "your 20-character passphrase is excellent, but WPS on this router makes it irrelevant" is delivering the single most valuable WPS finding there is.

## Learning objectives

- Check whether an owned AP has **WPS enabled**, in which mode (PIN vs push-button), and whether it locks out.
- Apply the clean remediation: **disable WPS**, or — where it must stay — **push-button only** on **patched firmware** with **lockout**.
- **Measure** the difference between a WPS-vulnerable configuration and a hardened one.

## Prerequisites

- [08.1 · How WPS works](lesson-01.md) and [08.2 · Pixie Dust](lesson-02.md) — you need the PIN mechanism and the offline attack to explain what the remediation removes.

## Concept

### The control or process

The remediation ladder, strongest first:

1. **Disable WPS entirely.** This removes the external registrar PIN method, which eliminates both Pixie Dust and the online PIN brute in one step. On most APs this is a single setting; verify it actually took effect (below), because some firmware leaves a vestigial registrar running.
2. **If WPS must stay, use push-button (PBC) only, and disable the PIN method.** PBC requires physical access to the button for a short window, so it is not remotely brute-forceable the way the PIN is. This is a real reduction, not a cryptographic guarantee — it narrows the window rather than removing the feature.
3. **Patched firmware + lockout as defence-in-depth.** Keep firmware current so known Pixie Dust nonce weaknesses (08.2) are fixed, and confirm the AP enforces a meaningful lockout/rate-limit after failed PINs (08.3). Treat these as backstops, not the primary control.

WPS belongs in the **secure baseline** ([02.3](../module-02/lesson-03.md)) alongside firmware maintenance and admin hygiene: check it on every AP, and default to off.

### Vulnerable vs hardened — and how to measure

The measurement is the same attack from 08.2 run before and after the change, plus a configuration check:

- **Vulnerable:** WPS PIN enabled (and, on a legacy chipset, unpatched). `reaver -K` against your **owned** AP either recovers the PIN/PSK (Pixie Dust) or at least completes WPS registration exchanges; a scan shows the WPS information element present and unlocked.
- **Hardened:** WPS disabled. The same `reaver`/`wash` scan now shows **no WPS IE** (or the registrar refuses to engage), Pixie Dust has nothing to attack, and the online brute has no registrar to query. The passphrase you set in Module 6 is once again the only way in.

The difference is binary and easy to evidence: WPS present and attackable → WPS absent and the attack surface gone. That before/after is exactly what belongs in the report.

## Hands-on

### Guided walkthrough — check, remediate, and re-verify (paths V limited · P)

1. **Inventory.** Scan for WPS on your **own** AP: `sudo wash -i <mon-iface>` lists nearby APs with their WPS state (present, version, locked). Record whether your AP shows WPS and whether it is locked.
2. **Baseline attack.** With WPS enabled, run the 08.2 Pixie Dust attempt against your AP and record the outcome (recovered / resisted). This is your "vulnerable" measurement.
3. **Remediate.** In your AP's admin page, disable WPS (or switch to PBC-only and disable the PIN). Save and let it apply.
4. **Re-verify.** Re-run `wash` and the Pixie Dust attempt. Success = the WPS IE is gone (or the registrar refuses) and the attack can no longer start. Record the "hardened" measurement.

> [!WARNING]
> LAB TARGET vs REAL NETWORK — scanning and attacking WPS is only acceptable against an AP **you own**, on your allowlist, with synthetic credentials ([00.3](../module-00/lesson-03.md)). `wash` is passive, but the Pixie Dust step transmits; keep TX power minimal.

> [!NOTE]
> **Lab paths:** V (limited — `hostapd` can advertise/anneal WPS to show the IE and the disable/enable toggle, but cannot reproduce a vulnerable chipset, so the "vulnerable" step is conceptual on V) · P (owned AP — the only path that proves a real Pixie Dust outcome before and after).
> **Start state:** an owned AP with WPS enabled; a monitor-capable adapter (P).
> **Duration:** ~20 min. **Artifacts:** `wash` output before/after, the 08.2 attack result before/after, a baseline note for your report.
> **Success criteria:** you can show WPS present-and-attackable vs absent, OR correctly conclude a patched AP already resists Pixie Dust and recommend disabling WPS anyway.
> **Troubleshooting:** `wash` shows nothing → wrong channel or monitor mode not set ([03.4](../module-03/lesson-04.md)); AP still shows WPS after "disable" → firmware vestige, update firmware and recheck.
> **Cleanup:** stop `wash`/`reaver`, restore the interface, re-enable only what you intended to keep — see `../../labs/common/reset-lab.sh`.

## Exercise

You assess a small office with ten identical routers. The passphrase policy is excellent (long, random, per-site), but `wash` shows WPS enabled and unlocked on all ten, and Pixie Dust recovers the PSK on a sample of three. Write the finding and remediation as you would for the report: state the impact honestly (what WPS defeats), the remediation, and how you would retest.

<details>
<summary>Hint</summary>

The impact is not "weak passphrase" — it is that WPS bypasses a strong one. The remediation is one line applied fleet-wide, and the retest is the before/after `wash` + Pixie Dust measurement on the same sample.
</details>

<details>
<summary>Reference answer</summary>

**Finding:** All ten routers expose WPS (PIN method, unlocked); Pixie Dust recovered the WPA2 passphrase on 3 of 3 sampled devices in seconds. **Impact:** WPS lets an attacker in radio range recover the PSK regardless of its strength, so the otherwise-excellent passphrase policy provides no protection against this path. **Remediation:** disable WPS on all ten routers (or, if a business process truly needs it, PBC-only on current firmware with lockout verified); this removes both the Pixie Dust and online-PIN paths at once. **Retest:** re-run `wash` to confirm the WPS IE is gone on all devices and repeat the Pixie Dust attempt on the same three — expected outcome is that the attack can no longer start. **Residual risk after fix:** none from WPS; the network's security reverts to the (strong) passphrase and whatever else the baseline covers.
</details>

## References

- [US-CERT/CISA VU#723755](https://www.kb.cert.org/vuls/id/723755) — the PIN brute-force vulnerability that motivates disabling WPS.
- [Wi-Fi Alliance — Wi-Fi Protected Setup](https://www.wi-fi.org/discover-wi-fi/wi-fi-protected-setup) — PBC vs PIN methods and current guidance.
- [02.3 · The secure wireless baseline](../module-02/lesson-03.md) — where WPS configuration lives in the standing baseline.

## What you should now be able to do

- Check whether an owned AP exposes WPS, in which mode, and whether it locks out.
- Recommend the clean remediation (disable WPS, or PBC-only on patched firmware) with the reasoning.
- Measure and evidence the vulnerable-vs-hardened difference for a report.
