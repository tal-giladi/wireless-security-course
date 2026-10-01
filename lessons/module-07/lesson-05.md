---
id: "07.5"
module: 7
minutes: 16
practice_minutes: 30
prerequisites: ["07.2", "07.3"]
objectives:
  - Configure WPA3-SAE securely — SAE-only where clients allow, PMF required, H2E.
  - Verify the configuration with a client and a capture, proving the downgrade surface is gone.
  - Measure the difference between a transition-mode and an SAE-only deployment.
volatility: implementation
sources:
  - title: "Wi-Fi Alliance — WPA3 specification"
    url: https://www.wi-fi.org/discover-wi-fi/security
  - title: "hostapd configuration (sae, ieee80211w, sae_pwe)"
    url: https://w1.fi/cgit/hostap/tree/hostapd/hostapd.conf
last_verified: "2026-10-01"
---

# 07.5 · Configuring and verifying WPA3 securely

Knowing how WPA3 can be attacked is only half the module; the other half is deploying it so those attacks have nothing to work with. This defence lesson configures WPA3-SAE the hardened way — SAE-only where your clients allow it, PMF required, hash-to-element — and then verifies, with a client and a capture, that the downgrade surface from 07.2 is actually gone.

## Why this matters

Most real WPA3 weaknesses in the field are not exotic cryptography; they are configuration: a network left in transition mode "for compatibility" that still accepts WPA2, or an old implementation without H2E. The assessor who can *configure and verify* a hardened WPA3 network — and show the before/after — delivers far more value than one who can only name attacks. This lesson is also where a learner can pass by **demonstrating the protection works**, not by breaking anything.

## Learning objectives

- Configure WPA3-SAE securely: **SAE-only** where clients allow, **PMF required**, **H2E**.
- **Verify** with a client and a capture that the WPA2 downgrade surface is gone.
- **Measure** the difference between a transition-mode and an SAE-only deployment.

## Prerequisites

- [07.2 · SAE-only versus transition mode](lesson-02.md) — the downgrade surface you are closing.
- [07.3 · Dragonblood](lesson-03.md) — why H2E matters in the configuration.

## Concept

### The control or process

A hardened WPA3-Personal configuration rests on three settings, with one trade-off to decide:

- **SAE-only (no transition) where you can.** A transition-mode BSS advertises WPA2-PSK alongside SAE, so a client (or an attacker coercing one) can still complete the crackable WPA2 handshake (07.2, Module 6). SAE-only removes that path entirely. The trade-off is compatibility: devices too old for WPA3 cannot join. Decide deliberately — SAE-only for networks whose clients all support it; transition only as a temporary, documented migration step.
- **PMF required.** WPA3 mandates Protected Management Frames; ensure the AP sets *required*, not merely *capable* (`ieee80211w=2`). This blocks forged deauth/disassoc against the network (Module 12) and is part of what makes WPA3 labs not depend on a working deauth.
- **Hash-to-Element (H2E).** Ensure the implementation uses the constant-time H2E mapping (`sae_pwe` set to H2E, or both), closing the Dragonblood side-channels (07.3). Keep firmware current.
- **A strong passphrase still matters.** SAE resists offline cracking, but a trivially guessable passphrase can still fall to online attempts and is bad practice; carry the entropy habit from Module 6.

### Vulnerable vs hardened — and how to measure

The measurement is whether the WPA2 downgrade path exists, shown in a beacon and a join:

- **Vulnerable (transition mode):** the beacon's RSN information advertises **both** SAE and WPA2-PSK AKMs; a WPA2-only client associates and produces a crackable 4-way handshake — the Module 6 attack applies despite "WPA3" being enabled.
- **Hardened (SAE-only, PMF required, H2E):** the beacon advertises **only** the SAE AKM with **MFPR** set; a WPA2-only client **cannot** associate (you can show it being refused), and no crackable WPA2 handshake is possible. A capture confirms SAE commit/confirm and PMF, with no WPA2 AKM present.

That before/after — "WPA2 downgrade reachable" vs "SAE-only, downgrade gone" — is the evidence. Passing this lab by producing the hardened capture and the refused WPA2 client is a full, valid outcome.

## Hands-on

### Guided walkthrough — harden and verify (paths V / P)

1. **Baseline (transition).** Configure `hostapd` for transition mode (SAE + WPA2-PSK) on your **own** radio; capture the beacon and confirm both AKMs are advertised. Join with a WPA2-only client and capture the crackable handshake (this is the 07.2 / Module 6 surface).
2. **Harden.** Reconfigure for **SAE-only**: `wpa_key_mgmt=SAE`, `ieee80211w=2` (PMF required), `sae_pwe` using H2E. Restart hostapd.
3. **Verify.** Re-capture the beacon — confirm **only** the SAE AKM and **MFPR** set. Attempt to join with the WPA2-only client and record that it is **refused**. Join with a WPA3 client and confirm SAE commit/confirm in the capture.
4. **Record** the before/after as your vulnerable-vs-hardened measurement.

> [!WARNING]
> LAB TARGET vs REAL NETWORK — configure and test only your **own** AP with synthetic credentials
> ([00.3](../module-00/lesson-03.md)). PMF is required here, so do **not** build any step around a
> successful deauth.

> [!NOTE]
> **Lab paths:** V (`mac80211_hwsim` + hostapd + wpa_supplicant — fully reproduces the AKM/PMF
> configuration, the refused WPA2 client, and the SAE exchange in a capture) · P (owned WPA3 AP + clients
> — same over real RF). Both prove the configuration and the downgrade-gone result; neither needs a deauth.
> **Start state:** an owned AP/stack supporting SAE, PMF, and H2E; a WPA2-only and a WPA3 client (real or `wpa_supplicant`).
> **Duration:** ~30 min. **Artifacts:** beacon captures before/after (both-AKMs vs SAE-only+MFPR), a refused-WPA2-client log, an SAE join capture.
> **Success criteria:** demonstrate SAE-only + PMF-required + H2E, show the WPA2 client refused and no crackable handshake — the protection working is the pass.
> **Troubleshooting:** WPA3 client won't join SAE-only → check `ieee80211w=2` and client SAE/H2E support; WPA2 client still joins → you are still in transition mode (both AKMs present).
> **Cleanup:** stop hostapd/supplicant, restore interfaces — `../../labs/common/reset-lab.sh`.

## Exercise

You are hardening a WPA3 network for an office. Half the devices are new; a handful are old IoT units that only speak WPA2-PSK. Write the configuration decision you would make and justify it, including how you would verify the result and what residual risk remains under each option.

<details>
<summary>Hint</summary>

SAE-only removes the downgrade but drops the WPA2-only IoT devices. Transition keeps them but preserves the crackable WPA2 path. The right answer names the trade-off, picks deliberately, and says how to verify and what risk is left.
</details>

<details>
<summary>Reference answer</summary>

The core trade-off is **SAE-only (downgrade gone, but WPA2-only IoT cannot join)** vs **transition mode (IoT works, but the crackable WPA2 handshake remains)**. The strongest option is to put the modern devices on an **SAE-only** SSID (PMF required, H2E) and move the legacy IoT to a **separate, segmented SSID/VLAN** with its own strong WPA2-PSK and tight firewall rules — so the downgrade surface never touches the main network, and the IoT segment's risk is contained (ties to the Module 2 baseline). If a single SSID is mandated, document transition mode as a **temporary** migration with a date to retire it, and compensate with a strong passphrase, PMF, and rogue monitoring. **Verify** either way by capturing the main SSID's beacon (SAE-only, MFPR set, no WPA2 AKM) and confirming a WPA2 client is refused. **Residual risk:** SAE-only main network → essentially no WPA2 downgrade; the IoT segment carries normal WPA2-PSK risk, bounded by segmentation. Transition single-SSID → the WPA2 crack path persists until retired.
</details>

## References

- [Wi-Fi Alliance — WPA3 security](https://www.wi-fi.org/discover-wi-fi/security) — SAE-only, PMF, H2E requirements.
- [hostapd.conf reference](https://w1.fi/cgit/hostap/tree/hostapd/hostapd.conf) — `sae`, `ieee80211w`, `sae_pwe`.
- [07.2 transition mode](lesson-02.md), [02.3 secure baseline](../module-02/lesson-03.md) — the surface closed and where this sits in the standing baseline.

## What you should now be able to do

- Configure WPA3-SAE securely: SAE-only where clients allow, PMF required, H2E, strong passphrase.
- Verify the hardened configuration with a beacon capture, a refused WPA2 client, and an SAE join.
- Measure and justify the transition-vs-SAE-only decision and state the residual risk of each.
