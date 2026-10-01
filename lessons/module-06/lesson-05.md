---
id: "06.5"
module: 6
minutes: 22
practice_minutes: 40
prerequisites: ["06.4"]
objectives:
  - Choose a WPA2-Personal passphrase by entropy, explaining why length beats character-class complexity.
  - Enable PMF and understand the reality of PMKID suppression, and know when to migrate to WPA3-SAE.
  - Measure the difference between a vulnerable and a hardened configuration using the attacks from this module.
volatility: implementation
sources:
  - title: "NIST SP 800-63B — memorized secrets: length over composition rules"
    url: https://pages.nist.gov/800-63-3/sp800-63b.html
  - title: "hostapd configuration — ieee80211w (PMF) and WPA2/WPA3 key management"
    url: https://w1.fi/cgit/hostap/plain/hostapd/hostapd.conf
last_verified: "2026-10-01"
---

# 06.5 · Hardening WPA2-Personal and measuring the difference

Every attack in this module ends at the same control: a passphrase an attacker cannot guess, on a configuration that gives them no shortcuts. This defence lesson turns the earlier attacks into a measurement — you take the vulnerable lab AP, harden it (high-entropy passphrase, PMF, PMKID suppression where roaming allows), and re-run the capture and cracking steps to show the attack now fails — and it is the one lesson you can pass entirely by demonstrating that the protection works, without recovering any key.

## Why this matters

A finding without a measured control is just an alarm. The value you deliver to a client is not "I cracked your Wi-Fi" but "here is the exact configuration change, and here is the before/after proof that it closes the attack." This lesson gives you that proof: the same `hashcat` run that recovered the weak passphrase returns `Exhausted` against the hardened one; the same deauth that forced a reconnect is rejected with PMF; the same PMKID request returns nothing once suppressed. Measuring the difference is what makes the defence credible — and it is a legitimate way to complete this module even if you never crack a thing.

## Learning objectives

- Choose a WPA2-Personal passphrase by **entropy**, explaining why **length beats complexity**.
- Enable **PMF** and understand the reality of **PMKID suppression**, and know when to migrate to **WPA3-SAE**.
- **Measure** the difference between a vulnerable and a hardened configuration using this module's attacks.

## Prerequisites

- [06.4 · Offline cracking with hashcat](lesson-04.md) — the bounded/strong result you will now reproduce as a before/after measurement.

## Concept

### The control or process

Hardening WPA2-Personal is three concrete settings plus a migration pointer:

**1. Passphrase entropy — length beats complexity.** Every attack in this module reduces to guessing the passphrase, so the control is making it unguessable. **Entropy** — how many equally-likely possibilities a guesser must cover — is what matters, and for human-chosen secrets **length delivers far more entropy than character-class rules**. A short "complex" passphrase like `P@ssw0rd!` is in every wordlist; a long passphrase of several random words, or 20+ random characters, is in none and is infeasible to brute-force at WPA's slow PBKDF2 hashrate (lesson 06.4). NIST SP 800-63B makes the same point for memorised secrets: favour length, drop mandatory composition rules. Rough guide: aim well beyond the 8-character WPA2 minimum — a 20+ character random passphrase or a 5–6 random-word phrase.

**2. PMF (802.11w).** Enabling Protected Management Frames makes forged deauths rejected (lesson 06.2), removing the attacker's ability to *force* a reconnect and signalling a hardened network. PMF does **not** stop a handshake being captured from a natural join, and it does **not** make a weak passphrase safe — it closes the deauth shortcut, nothing more. In `hostapd`, `ieee80211w=1` is optional/capable, `ieee80211w=2` is required.

**3. PMKID suppression — with a caveat.** Where your APs do not rely on the roaming features that surface a PMKID, disabling PMKID/PMK-caching advertisement removes the clientless path (lesson 06.3). Be honest about the limit: **suppression is not universally available or effective**, it only removes one capture route (a handshake can still be captured), and on some firmware it is tied to roaming you may actually need. Treat it as defence-in-depth, not a substitute for entropy.

**4. Migrate to WPA3-SAE when you can.** SAE yields **no offline-crackable hash** from a passive capture (Module 7), so it removes the entire capture-and-crack class rather than just raising its cost. Transition mode (SAE + WPA2 both advertised) reintroduces the WPA2 surface, so prefer SAE-only where your clients support it. WPA3 is the strategic fix; passphrase entropy is the control that protects you until then (and still matters under transition mode).

> [!IMPORTANT]
> There is exactly one control that defeats **all** of this module's attacks on a WPA2 network: a passphrase with enough entropy that it is not in any wordlist and is infeasible to brute-force. PMF and PMKID suppression remove *shortcuts*; they do not rescue a weak passphrase. Rank your recommendations accordingly.

### Vulnerable vs hardened — and how to measure

The measurement is the lesson. Take the lab AP in two configurations and run the identical attack against each:

| What you measure | Vulnerable config | Hardened config |
|---|---|---|
| **Cracking** (lesson 06.4) | weak passphrase `Lab-WiFi-Passw0rd!` → `hashcat -m 22000` **recovers** it with `bounded.txt` | 20+ char random passphrase → same run is **`Exhausted`**; brute-force estimate shows infeasible |
| **Deauth shortcut** (lesson 06.2) | PMF off → a single targeted deauth drops your own client; it reconnects | PMF required (`ieee80211w=2`) → forged deauth **rejected**; client stays connected |
| **PMKID path** (lesson 06.3) | PMKID advertised → `hcxdumptool` extracts a type-01 hashline | PMKID suppressed → **no** PMKID returned (handshake still possible) |

Each row is a before/after with concrete, checkable evidence. The decisive row is **cracking**: even with PMF off and a PMKID offered, a strong passphrase makes every captured value `Exhausted`. That is why a learner can **pass this module by demonstrating the protection works** — configure the hardened AP, run the attacks, and show the `Exhausted` result, the rejected deauth, and the absent PMKID — without ever recovering a key.

The `hostapd` difference is small and worth seeing:

```ini
# Vulnerable lab AP
ssid=Lab-Target-01
wpa=2
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP
wpa_passphrase=Lab-WiFi-Passw0rd!
# ieee80211w not set (PMF off); PMKID advertised by default

# Hardened lab AP
ssid=Lab-Target-01
wpa=2
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP
wpa_passphrase=<20+ char random passphrase, NOT in any shipped wordlist>
ieee80211w=2          # PMF required -> forged deauth rejected
# disable PMKID advertisement where your roaming does not need it (firmware-dependent)
```

> [!NOTE]
> Config keys and PMKID-suppression knobs vary by `hostapd`/firmware version (`TOOLS.md`, `volatility: implementation`). The measurement — attack both configs, compare evidence — is stable even when a specific flag name is not; read your version's docs.

## Hands-on

### Guided walkthrough — harden, then measure the difference (paths R / V / P)

1. **R (no hardware):** compare the shipped captures as a stand-in for the two configs — `wpa2-handshake-good.hc22000` cracks with `bounded.txt`; `wpa2-strong.hc22000` goes `Exhausted` with `strong-absent.txt`. Write the before/after: same tool, same mode, entropy is the only difference (captures **PENDING** a verified run — `CAPTURES.md`).
2. **V (`mac80211_hwsim`):** bring up the vulnerable AP, run the 06.2–06.4 attacks and record the evidence; reconfigure to the hardened AP (strong passphrase, `ieee80211w=2`, PMKID off), re-run, and record that the crack is `Exhausted`, the deauth is rejected, and no PMKID is returned.
3. **P (owned gear):** do the same on your own AP if it exposes these settings — note which it does (not all consumer firmware lets you suppress PMKID or require PMF), and mark anything your hardware cannot do as `VERIFY`/not-supported.

### Lab

> [!NOTE]
> **Lab paths:**
> R (shipped weak vs strong captures — no hardware; proves you can show entropy decides crackability, **not** that you reconfigured a live AP).
> V (`mac80211_hwsim` + `hostapd` in both configs — proves you can reproduce the vulnerable-vs-hardened measurement end to end: crack vs `Exhausted`, deauth rejected, PMKID absent; does **not** reproduce real RF, drivers, or a real AP's firmware limits).
> P (your own AP + client — proves which hardening controls your real firmware actually supports and that they change the attack's outcome over the air).
> **Start state:** R — recorded toolchain + module zip + wordlists. V — `hwsim` radios up; both `hostapd` configs ready. P — your own AP/client; monitor verified; regulatory domain set.
> **Duration:** ~40 min (most of it reconfiguring and re-running, not waiting).
> **Artifacts:** a before/after table with evidence — the vulnerable crack result vs the hardened **`Exhausted`**; (V/P) a rejected-deauth observation with PMF required; (V/P) a "no PMKID returned" result after suppression; the two `hostapd` configs.
> **Success criteria:** you demonstrate the hardened configuration defeats the attacks — **recovering the weak key is optional; showing the strong passphrase is `Exhausted`, the deauth is rejected, and the PMKID is absent is a full pass.** On WPA2/PMF, **a successful deauth is not required** — the hardened pass is precisely that it is *rejected*.
> **Troubleshooting:** hardened crack still recovers a key (your "strong" passphrase was guessable or in a list — pick a genuinely random 20+ char one); `ieee80211w=2` breaks an old client (that client lacks PMF — expected; use `=1` to test capability or a PMF-capable client); PMKID still appears after "suppression" (firmware does not honour the knob — document it as a limit, recommend WPA3-SAE); no difference measured (you changed the passphrase but reused the same wordlist that excludes it — confirm the list and the config actually differ).
> **Cleanup:** stop `hostapd`/`wpa_supplicant`/capture tools; `../../labs/common/reset-lab.sh`; on V, `../../labs/common/hwsim-down.sh`. Restore any client you set to PMF-required.

> [!NOTE]
> **LAB TARGET vs REAL NETWORK:** reconfigure and attack only your **own** AP and client, with synthetic credentials. The point of this lesson is to *measure a defence on gear you own*, then recommend it — never to test the control on a network you do not own ([00.3](../module-00/lesson-03.md)).

## Exercise

A client's Wi-Fi policy reads: "Passphrases must be at least 8 characters with an uppercase letter, a number, and a symbol, rotated every 90 days. PMF is disabled for compatibility." Using what you measured in this module, critique this policy: say which rule gives the most and least real protection against the attacks in Module 6, and rewrite it into three prioritised recommendations with the reasoning a client would accept.

<details>
<summary>Hint</summary>

Run each rule through the attacks: does an 8-character "complex" passphrase survive a wordlist? Does 90-day rotation help against an offline crack that finishes in minutes? What does disabling PMF cost, and is it the main control or a shortcut-closer? Rank by what actually changes an `Exhausted` vs a recovered key.
</details>

<details>
<summary>Reference answer</summary>

Critique: the **8-char + complexity** rule gives the *least* real protection — `P@ssw0rd!`-style passphrases are exactly what wordlists and masks target, and 8 characters is the crackable floor; composition rules add little entropy while pushing users to predictable patterns. **90-day rotation** is near-useless against this module's threat: an offline crack of a weak passphrase finishes long before 90 days, and rotation mainly annoys users (NIST now advises against routine rotation). **Disabling PMF** removes a useful shortcut-closer (forged-deauth rejection) for marginal compatibility gain, though it is not the main control. Rewrite, prioritised: **(1)** Require a **high-entropy passphrase** — a 20+ character random string or 5–6 random words — because entropy is the one control that turns every captured handshake/PMKID into `Exhausted`; drop the composition rules and routine rotation (rotate only on suspected compromise). **(2)** **Enable PMF** (`ieee80211w` required where clients support it) to reject forged deauths and signal a hardened network, accepting that very old clients may need a capable-not-required setting. **(3)** **Plan migration to WPA3-SAE** (SAE-only where supported), which removes the offline-crackable material entirely; suppress PMKID advertisement where roaming does not need it as defence-in-depth. Lead the client with the before/after evidence: the weak passphrase recovered in minutes, the strong one `Exhausted`.
</details>

## References

- [NIST SP 800-63B — memorized secrets](https://pages.nist.gov/800-63-3/sp800-63b.html) — length over composition; no routine rotation.
- [hostapd.conf — `ieee80211w` (PMF) and key management](https://w1.fi/cgit/hostap/plain/hostapd/hostapd.conf) — the hardened settings.
- [06.4 · Offline cracking with hashcat](lesson-04.md) — the bounded/strong result reused here as the before/after measurement.

## What you should now be able to do

- Choose a WPA2-Personal passphrase by entropy and explain why length beats character-class complexity.
- Enable PMF, apply PMKID suppression with its real caveats, and know when to migrate to WPA3-SAE.
- Measure vulnerable vs hardened with this module's attacks, and pass by demonstrating the protection works — not only by cracking.
