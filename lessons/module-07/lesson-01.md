---
id: "07.1"
module: 7
minutes: 24
practice_minutes: 25
prerequisites: ["06.1"]
objectives:
  - Trace the SAE commit-confirm exchange and explain how both sides agree a PMK without sending a passphrase-derived value.
  - Explain why a passively captured SAE exchange yields no offline-crackable hash, contrasting it with the WPA2 EAPOL MIC.
  - Describe hunting-and-pecking versus hash-to-element and state that PMF is mandatory in WPA3.
volatility: concept
sources:
  - title: "IEEE 802.11-2020 — SAE (Dragonfly) authentication, commit/confirm, PWE derivation, RSN/PMF"
    url: https://standards.ieee.org/ieee/802.11/7028/
  - title: "Wi-Fi Alliance — WPA3 Specification (SAE, H2E, mandatory PMF)"
    url: https://www.wi-fi.org/discover-wi-fi/security
  - title: "Dragonblood — Vanhoef & Ronen (2019): SAE handshake, hunting-and-pecking vs hash-to-element"
    url: https://wpa3.mathyvanhoef.com/
last_verified: "2026-10-01"
---

# 07.1 · SAE (Dragonfly) — why there is no offline-crackable hash

WPA3-Personal keeps the one thing WPA2-Personal had — a single shared passphrase — but changes the exchange so that capturing it off the air hands an attacker nothing to crack offline. This lesson derives why: SAE is a password-authenticated key exchange whose commit and confirm messages depend on a live, per-session Diffie-Hellman exchange, so there is no PBKDF2-of-passphrase value and no EAPOL MIC sitting in the capture to recompute-and-compare against. You will trace the exchange, see precisely where WPA2's offline oracle used to be and why it is absent here, and read a real SAE capture to confirm there is nothing to feed a wordlist.

## Why this matters

Module 6 turned on one fact: a captured WPA2 handshake is a self-checking offline oracle for the passphrase. Everything you do against WPA3-Personal depends on understanding why that oracle is gone. If you cannot explain *why* SAE has no offline-crackable hash, you will either overclaim ("I'll just capture the WPA3 handshake and crack it like WPA2") or underclaim ("WPA3 is unbreakable"). The truth is precise and defensible: passive capture-and-crack is structurally impossible against SAE, the remaining passphrase attack is online and rate-limited, and the real WPA3-Personal weaknesses live in transition mode (07.2) and in old implementations (07.3) — not in SAE's design. Getting this right is what lets you give a client an honest WPA3 assessment instead of a slogan.

## Learning objectives

- Trace the SAE **commit-confirm** exchange and explain how both sides agree a **PMK** without sending a passphrase-derived value.
- Explain why a passively captured SAE exchange yields **no offline-crackable hash**, contrasting it with the WPA2 EAPOL **MIC**.
- Describe **hunting-and-pecking** versus **hash-to-element (H2E)** and state that **PMF is mandatory** in WPA3.

## Prerequisites

- [06.1 · The 4-way handshake in depth — PSK, PMK, and PTK](../module-06/lesson-01.md) — you must understand how WPA2's PMK comes from PBKDF2 and why the captured MIC is an offline oracle, because SAE is defined here by what it removes.

## Concept

### How SAE works on the wire

SAE (Simultaneous Authentication of Equals, nicknamed **Dragonfly**) replaces the "AP already knows the PMK from PBKDF2, now prove it in the 4-way handshake" model of WPA2-PSK with a mutual, password-authenticated key exchange that runs **before** the familiar 4-way handshake. In WPA3-Personal there are two phases:

1. **SAE authentication** — a commit-confirm exchange (carried in 802.11 Authentication frames) in which both sides prove they know the passphrase and jointly derive a fresh **PMK**.
2. **The 4-way handshake** — the same EAPOL exchange as WPA2, but now keyed from the SAE-derived PMK, deriving the PTK and GTK.

The whole security difference is in phase 1. Both the client and the AP first turn the passphrase into a shared secret element on an elliptic curve — historically the **Password Element (PWE)**, called the **PT** (password token / password element) in the modern derivation. Then:

- **Commit (each side → the other):** each party picks random secrets, computes a public **scalar** and **element** from them and the PWE, and sends them. This is a Diffie-Hellman-style commitment mixed with the password.
- **Confirm (each side → the other):** each party sends a hash (a **confirm** value) computed over the exchanged commit values and the shared key they independently derived. A matching confirm proves the other side derived the *same* key — which is only possible if it used the *same passphrase*.

If both confirms verify, both sides hold an identical PMK and the 4-way handshake proceeds. If the passphrase was wrong, the derived keys differ, the confirms do not match, and authentication fails.

### Why there is no offline-crackable hash

Put the WPA2 oracle and the SAE exchange side by side. In WPA2-PSK, the PMK is $\text{PBKDF2}(\text{passphrase}, \text{SSID})$ — a function of the passphrase **alone** (plus the public SSID). The captured EAPOL MIC is computed from that PMK, so an attacker can, entirely offline:

$$\text{guess} \rightarrow \text{PBKDF2} \rightarrow \text{PMK} \rightarrow \text{PTK} \rightarrow \text{MIC}' \stackrel{?}{=} \text{captured MIC}$$

Every arrow is computable from the capture plus a guess. That is the offline oracle.

In SAE there is no step in that chain you can reproduce from a passive capture. The commit values are `scalar` and `element`, each of which is **blinded by a fresh per-session random secret** that never leaves the device. The confirm is a hash over those commit values **and the jointly-derived shared key** — and that shared key depends on *both* sides' random secrets, not on the passphrase alone. So for a guessed passphrase an attacker can compute a candidate PWE, but cannot reconstruct either side's random secret, cannot reconstruct the shared key, and therefore cannot compute a confirm value to compare against the captured one.

> [!IMPORTANT]
> The reason is structural, not a matter of key length or iteration count. WPA2 leaks a value that is a function of the passphrase and public data only; SAE never puts such a value on the air. There is nothing in a passive SAE capture to recompute-and-compare, so offline guess-and-check has no oracle — "throw a bigger GPU at it" changes nothing.

The only way to test a passphrase guess against SAE is to **run the exchange** against the AP (or a client) for that one guess and see whether confirm succeeds. That is an **online, rate-limited, logged, and PMF-covered** attack — one network interaction per guess — which is categorically weaker than offline cracking and is defeated by anti-clogging and lockout mechanisms plus any reasonable passphrase. This is why WPA3-Personal removes the entire capture-and-crack class from Module 6 rather than merely raising its cost.

### Hunting-and-pecking versus hash-to-element

How each side derives the password element matters for 07.3, so name the two methods now:

- **Hunting-and-pecking (H&P)** — the original SAE method: iterate a loop, hashing the password with an incrementing counter until the result maps to a valid curve point. The *number of iterations* needed depends on the password, and early implementations did this in **non-constant time** — the leak Dragonblood exploited (07.3).
- **Hash-to-element (H2E)** — introduced in WPA3 release 2: a **constant-time** derivation of the password element that does not loop a password-dependent number of times. H2E removes the timing/cache side-channel at its source. An AP advertises H2E support in the **RSNXE** element; modern WPA3 deployments use it.

Both produce a valid password element; the difference is whether the derivation leaks timing. Neither changes the core fact above — passive capture yields no offline hash in either case. H2E closes an *implementation* side-channel, not an offline-hash hole (there was never one).

### PMF is mandatory in WPA3

WPA3 **requires** Protected Management Frames (PMF / 802.11w) — it is not optional as it was under WPA2. SAE-only networks set PMF **Required** (the MFPR bit); transition mode sets PMF **Capable** (07.2). Two consequences you will rely on throughout this module:

- Forged **deauthentication** against a WPA3 (SAE-only) client is **rejected**, so no WPA3 lab here may depend on a successful deauth to force a reconnect. You capture from natural joins, or you work on the recorded/virtual paths.
- The presence of PMF-Required alongside the SAE AKM in the RSN/RSNXE elements is one of the signals that tells you a network is genuinely WPA3-SAE rather than transition mode (07.2).

### How a tester recognises SAE in a capture

In a beacon or probe response, the **RSN element** lists the AKM suites. **SAE** is AKM suite type 8 (shown by Wireshark as `SAE (SHA256)` / AKM 00-0F-AC:8); WPA2-PSK is type 2. A pure WPA3-SAE BSS advertises **only** SAE in the AKM list, with **MFPR (PMF Required)** set in the RSN Capabilities, and often an **RSNXE** element signalling H2E. During a join you will see 802.11 **Authentication** frames carrying **commit** then **confirm** (not the WPA2 Open-System two-frame auth), followed by the 4-way handshake. If you *also* see WPA2-PSK in the AKM list, you are looking at transition mode — the subject of 07.2.

Compare SAE's commit/confirm with the WPA2 handshake side by side (educational model):

[Simulation: 4-way handshake and SAE visualiser](../../simulations/handshake/index.html)

## Hands-on

This lesson supports the recorded (R) and virtual (V) paths. You read a supplied SAE capture and confirm there is no offline-crackable quantity; optionally you bring up a virtual SAE AP and watch a real commit-confirm. Nothing here requires transmission against a real network, and nothing depends on a deauth.

### Guided walkthrough — find the absence of an offline hash (paths R / V)

1. From the module zip (`labs/module-07/`), open `captures/wpa3-sae.pcapng` in Wireshark (this capture is **PENDING** a verified generation run — see the lab README; the steps are exact once it lands).
2. Filter to `wlan.fc.type_subtype == 0x0b` (Authentication frames). Confirm you see **commit** and **confirm** SAE frames — not the two-frame Open-System auth of a WPA2 join.
3. In a nearby beacon (`wlan.fc.type_subtype == 0x08`), expand the **RSN Information** element. Confirm the AKM list contains **SAE (00-0F-AC:8)** and **only** SAE (no PSK), and that **Management Frame Protection Required** is set. Note whether an **RSNXE** element is present (H2E signalling).
4. Filter to `eapol` and confirm the 4-way handshake still occurs — but note it is keyed from the SAE PMK, so its MIC is **not** a function of the passphrase alone (unlike WPA2, where the PMK is PBKDF2 of the passphrase).
5. Write one sentence naming exactly what an offline cracker would recompute-and-compare here, and conclude: **nothing** — the commit/confirm values are blinded by per-session randomness the capture does not contain.
6. **(V, optional)** Bring up a virtual SAE AP and client (`../../labs/common/hwsim-up.sh`, a `hostapd` SAE-only config, a `wpa_supplicant` SAE profile) and capture your own commit-confirm on the simulated radios to see the same frames live. Note that the virtual path reproduces the *protocol*, not real RF or timing.

### Lab

> [!NOTE]
> **Lab paths:**
> R (read the supplied `wpa3-sae.pcapng` — no hardware; proves you can locate the SAE commit/confirm frames and reason about why there is no offline hash, **not** that you captured SAE live).
> V (`mac80211_hwsim` + `hostapd` SAE-only + `wpa_supplicant` — proves you can stand up a WPA3-SAE association and observe a real commit-confirm end to end; does **not** reproduce real RF, drivers, or the timing behaviour behind 07.3).
> **Start state:** R — the recorded toolchain from [03.2](../module-03/lesson-02.md) (Wireshark/tshark) and the supplied capture. V — `hwsim` radios up ([03.3](../module-03/lesson-03.md)); a `hostapd` SAE-only config and a `wpa_supplicant` SAE profile with the synthetic passphrase `Lab-WiFi-Passw0rd!`.
> **Duration:** ~25 min.
> **Artifacts:** an annotated note identifying the commit and confirm frames, the SAE AKM and PMF-Required bit in the RSN element, and a one-sentence statement of why a passive capture offers an offline cracker nothing; (V) your own `wpa3-sae-selfcap.pcapng`.
> **Success criteria:** you can point to commit and confirm in the capture, show SAE + PMF-Required in the beacon, and explain in your own words why the confirm value cannot be recomputed offline from a guessed passphrase.
> **Troubleshooting:** no Authentication frames with commit/confirm (you opened a WPA2 capture, or a filter is hiding them — confirm the file and clear filters); AKM shows PSK as well as SAE (that is transition mode — the capture for 07.2, not this one); (V) `wpa_supplicant` fails to associate with `key_mgmt=SAE` (your build lacks SAE/CONFIG_SAE or `ieee80211w` is unset — SAE requires PMF; set `ieee80211w=2`).
> **Cleanup:** R transmits nothing — none. V — stop `hostapd`/`wpa_supplicant`, then `../../labs/common/hwsim-down.sh` and `../../labs/common/reset-lab.sh`.

> [!NOTE]
> **LAB TARGET vs REAL NETWORK:** the supplied capture and any virtual AP use our own simulated radios with the synthetic passphrase `Lab-WiFi-Passw0rd!` and SSID `Lab-Target-01`. Observe SAE only on networks you own; the authorisation rules ([00.3](../module-00/lesson-03.md)) apply to every capture, even passive ones.

## Exercise

A colleague who has just finished Module 6 says: "WPA3 still has a 4-way handshake, and I can capture it. So I'll grab the WPA3 handshake, convert it with `hcxpcapngtool`, and crack it with `hashcat -m 22000` exactly like WPA2 — it'll just be a different mode number." Explain precisely why this plan fails against WPA3-Personal, name what *does* cross the air in an SAE join and why none of it is an offline oracle, and state the only kind of passphrase attack that remains against SAE and why it is far weaker.

<details>
<summary>Hint</summary>

Where did WPA2's crackable value come from — is the PMK a function of the passphrase alone? Now ask the same of SAE: the confirm value is a hash over the commit values *and* a shared key that depends on both sides' secret randomness. Can you reconstruct that randomness from the capture? If not, what must you do to test a single guess?
</details>

<details>
<summary>Reference answer</summary>

The plan fails because WPA3-Personal's 4-way handshake is keyed from the **SAE-derived PMK**, not from PBKDF2 of the passphrase. In WPA2 the PMK is a deterministic function of the passphrase and SSID, so the captured MIC can be recomputed offline for each guess — that is the oracle `-m 22000` exploits. In SAE the PMK comes out of the commit-confirm exchange: what crosses the air is each side's **scalar** and **element** (blinded by fresh per-session random secrets) and a **confirm** hash over those values and the jointly-derived shared key. None of it is a function of the passphrase alone — the shared key depends on both parties' secret randomness, which is never transmitted — so there is nothing in a passive capture to recompute-and-compare, and converting it to `hc22000` yields no crackable hashline. The only remaining passphrase attack is **online**: run the SAE exchange against the AP (or a client) once per guess and see whether confirm succeeds. That is rate-limited, logged, slowed by anti-clogging/lockout, and defeated by any reasonable passphrase — categorically weaker than offline cracking, which is why WPA3-SAE removes the whole capture-and-crack class.
</details>

## References

- IEEE 802.11-2020 — SAE authentication, commit/confirm, password-element derivation, RSN/PMF (`../../references/README.md`).
- Wi-Fi Alliance — WPA3 Specification: SAE, hash-to-element, mandatory PMF (`../../references/README.md`).
- [Dragonblood (Vanhoef & Ronen, 2019)](https://wpa3.mathyvanhoef.com/) — the SAE handshake and the H&P vs H2E distinction (detail in [07.3](lesson-03.md)).
- [02.2 · Key hierarchies at a glance](../module-02/lesson-02.md) — the overview this lesson derives; [06.1](../module-06/lesson-01.md) — the WPA2 oracle it contrasts with.
- Glossary: SAE (Dragonfly), PMK, PMF / 802.11w, RSNE, AKM (`../../glossary.md`).

## What you should now be able to do

- Trace the SAE commit-confirm exchange and explain how both sides agree a PMK without sending a passphrase-only value.
- Explain, structurally, why a passively captured SAE exchange yields no offline-crackable hash while a WPA2 handshake does.
- Recognise SAE in a capture (commit/confirm frames, SAE AKM, PMF-Required), distinguish H&P from H2E, and state that PMF is mandatory in WPA3.
