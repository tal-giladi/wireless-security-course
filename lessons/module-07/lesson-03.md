---
id: "07.3"
module: 7
minutes: 18
practice_minutes: 15
prerequisites: ["07.1"]
objectives:
  - Explain the Dragonblood class as implementation side-channels against SAE, not a break of its design.
  - Identify the affected implementations and the hash-to-element mitigation that removes the leak.
  - Judge the current status of Dragonblood honestly and translate it into a check you can run.
volatility: implementation
sources:
  - title: "Vanhoef & Ronen — Dragonblood: Analyzing the Dragonfly Handshake of WPA3 and EAP-pwd (2019)"
    url: https://wpa3.mathyvanhoef.com/
  - title: "Dragonblood paper (PDF)"
    url: https://papers.mathyvanhoef.com/dragonblood.pdf
  - title: "Wi-Fi Alliance — WPA3 specification (Hash-to-Element / H2E)"
    url: https://www.wi-fi.org/discover-wi-fi/security
last_verified: "2026-10-01"
---

# 07.3 · Dragonblood — timing and cache side-channels, versions, and mitigations

Dragonblood is the 2019 research that showed early WPA3-SAE implementations could leak enough about the password, through timing and cache side-channels, to enable an offline dictionary attack — despite SAE being designed to prevent exactly that. This lesson is careful about what Dragonblood is and is not: a set of *implementation* flaws with specific affected versions and a clean mitigation, not a standing break of SAE's design.

## Why this matters

Dragonblood is the most-cited reason people claim "WPA3 is broken," and that claim is usually wrong by now. If you repeat it uncritically you will misadvise a client; if you dismiss it entirely you will miss a genuinely unpatched device. The skill is to hold the precise version: SAE's design is sound, *some 2019-era implementations* leaked via side-channels, the **hash-to-element** method fixes the leak, and your job on an engagement is to determine which version a given device actually runs — not to assert a verdict from the headline.

## Learning objectives

- Explain the **Dragonblood class** as **implementation side-channels** against SAE, not a design break.
- Identify the **affected implementations** and the **hash-to-element (H2E)** mitigation that removes the leak.
- Judge Dragonblood's **current status** honestly and turn it into a **check** you can run.

## Prerequisites

- [07.1 · SAE (Dragonfly) — why there is no offline-crackable hash](lesson-01.md) — you need the commit/confirm exchange and hunting-and-pecking to see where the leak was.

## Concept

### How the vulnerable step worked

SAE's original password-to-group mapping used **hunting-and-pecking**: the device iterates, testing candidate points until it finds a valid one on the curve. Vanhoef and Ronen (2019) showed this loop is not constant-time:

- **Timing side-channel (CVE-2019-9494).** The number of iterations — and thus the time — depends on the password and the peer MAC. An attacker who can measure the victim's SAE response timing across many exchanges learns which passwords are consistent with the observed timing, partitioning the dictionary.
- **Cache side-channel (CVE-2019-9494's micro-architectural sibling).** On a device where the attacker can run unprivileged code, cache-access patterns of the hash-to-curve step leak similar information, even against some implementations that had added timing defences.

Both are **password-partitioning** attacks: each measurement rules out a fraction of candidate passwords, after which an **offline dictionary attack** finishes the job. Crucially, the leak is in *how an implementation computed the mapping*, not in SAE's commit/confirm design — SAE still sends no directly crackable hash (07.1).

### Why it is an implementation class, with versions

The attacks hit specific, datable targets: 2019-era **hostapd/wpa_supplicant** and several vendor SAE and **EAP-pwd** implementations that used hunting-and-pecking without constant-time protection. Different devices leaked by different amounts; some had partial defences that the cache attack still defeated. This is why "is WPA3 vulnerable?" has no single answer — it depends on the implementation and its patch level.

### The mitigation: hash-to-element (H2E)

The durable fix, standardised into WPA3 and shipped by vendors, is **Hash-to-Element (H2E)**: a constant-time password-to-group mapping that replaces hunting-and-pecking, removing the data-dependent timing and cache behaviour the attacks relied on. Alongside H2E, implementations added timing blinding and patched the specific CVEs. A device negotiating H2E is not exposed to the original Dragonblood side-channels.

### Current status — stated honestly

By now, current hostapd/wpa_supplicant and mainstream vendor firmware implement H2E and the Dragonblood CVEs are long patched, so an up-to-date WPA3-SAE network is **not** exposed to the 2019 side-channels. That is not a blanket "safe": unpatched or embedded devices may still run the old mapping, transition-mode networks still carry the WPA2 downgrade surface (07.2), and new implementation bugs can always appear. Report Dragonblood as **historically significant, mitigated by H2E, and a per-device patch-level question today** — never as a current universal break.

## Hands-on

### Guided walkthrough — determine exposure without attacking (path R / V)

You will not run a working timing attack here — reliably measuring the side-channel needs conditions a virtual radio cannot reproduce, and the point of the lesson is judgement, not exploitation. Instead, determine a device's exposure the way an assessor would:

1. On your **own** AP/stack, identify the SAE implementation and version (e.g. `hostapd -v`, firmware build) and whether it negotiates **H2E** (look for the H2E/`sae_pwe` configuration and the capability in the association, observable in a capture from [05.2](../module-05/lesson-02.md)).
2. Cross-check that version/CVE status against the vendor advisory and the Dragonblood references. Record "H2E negotiated / patched" or "hunting-and-pecking / unpatched — exposed to the 2019 class."
3. Write the one-line verdict you would put in a report, with the evidence (version + H2E capability), not a headline.

> [!NOTE]
> **Lab paths:** R (read a capture / version output and reason about exposure — the honest path for Dragonblood) · V (`mac80211_hwsim` + hostapd can show H2E vs hunting-and-pecking *configuration* and the negotiated capability, but **cannot** reproduce the real timing/cache side-channel). Neither path proves a working key recovery, and that is stated by design.
> **Start state:** an owned WPA3-SAE stack you can query for version and `sae_pwe`.
> **Duration:** ~15 min. **Artifacts:** a version/H2E determination and a one-line exposure verdict.
> **Success criteria:** you correctly classify the stack as mitigated (H2E/patched) or exposed, with evidence — *not* a key recovery.
> **Cleanup:** none beyond stopping any capture — `../../labs/common/reset-lab.sh`.

## Exercise

A vendor's marketing says "WPA3 — immune to Dragonblood." A security forum says "WPA3 is broken, Dragonblood proved it." Both are given to you about the same current router. Write the accurate position, and state exactly what evidence you would collect from the device to settle it.

<details>
<summary>Hint</summary>

Neither slogan is right. Dragonblood was an implementation side-channel class, mitigated by H2E. "Settling it" is a patch-level/capability question about this specific device, not an argument about the protocol.
</details>

<details>
<summary>Reference answer</summary>

Both statements are overstatements. Dragonblood (2019) was a class of **timing and cache side-channels in specific SAE/EAP-pwd implementations**, not a break of SAE's design, and it is mitigated by the constant-time **hash-to-element (H2E)** mapping plus the patched CVEs. So the router is "immune" only if it runs a current implementation that negotiates H2E, and "broken" only if it still runs unpatched hunting-and-pecking. **Evidence to settle it:** the device's firmware/hostapd version and CVE status from the vendor advisory, and a capture showing whether it negotiates H2E (`sae_pwe`). Verdict format: "SAE with H2E, patched → not exposed to the 2019 Dragonblood class," or "unpatched hunting-and-pecking → exposed; recommend firmware update." Note separately whether transition mode (07.2) adds a WPA2 downgrade surface regardless.
</details>

## References

- [Dragonblood project](https://wpa3.mathyvanhoef.com/) and the [paper (PDF)](https://papers.mathyvanhoef.com/dragonblood.pdf) — Vanhoef & Ronen, 2019.
- [Wi-Fi Alliance — WPA3 security](https://www.wi-fi.org/discover-wi-fi/security) — H2E and the current WPA3 requirements.
- [07.1 SAE](lesson-01.md) and [07.2 transition mode](lesson-02.md) — the design Dragonblood did *not* break, and the downgrade surface that persists.

## What you should now be able to do

- Describe Dragonblood as an implementation side-channel class against SAE, not a design break.
- Name the affected implementations and the H2E mitigation, and state the current status accurately.
- Turn "is this device vulnerable?" into a version/H2E check with evidence, rather than a headline verdict.
