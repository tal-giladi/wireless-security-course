---
id: "08.2"
module: 8
minutes: 22
practice_minutes: 45
prerequisites: ["08.1"]
objectives:
  - Explain how Pixie Dust recovers the WPS PIN offline from a single M1-M3 exchange by exploiting weak or zero E-S1/E-S2 nonces.
  - State the prerequisites and the chipset/firmware conditions an AP must meet for the attack to work, qualifying it as not universal.
  - Run the reaver -K / bully tooling against an owned AP and correctly conclude that a patched or locked AP resists the attack.
volatility: implementation
sources:
  - title: "Bongard (2014) — Offline bruteforce attack on WiFi Protected Setup (the Pixie Dust E-S1/E-S2 weakness)"
    url: https://archive.hack.lu/2014/Hacklu2014_offline_bruteforce_attack_on_wps.pdf
  - title: "reaver-wps-fork-t6x README — -K Pixie Dust (pixiewps) integration and affected chipsets"
    url: https://sources.debian.org/src/reaver/1.6.6-2/README.md
last_verified: "2026-10-01"
---

# 08.2 · Pixie Dust — the offline WPS attack and why it may fail

Pixie Dust turns the slow online WPS PIN brute of 08.1 into an offline computation that can recover the PIN — and therefore the WPA2 passphrase — in seconds, but only against APs whose chipset generates weak or zero WPS nonces. This attack lesson explains the E-S1/E-S2 nonce weakness it exploits, the exact prerequisites and affected chipsets, how to run it with `reaver -K` or `bully`, and — just as important — why it fails against patched, well-seeded, or locked APs, which is the outcome you must be able to recognise and report honestly.

> [!WARNING]
> **LAB TARGET vs REAL NETWORK.** Pixie Dust actively engages a registrar over the air and, on success, recovers a real network credential. Run it **only** against an AP **you personally own**, on your [allowlist](../module-00/lesson-03.md), with the synthetic lab passphrase `Lab-WiFi-Passw0rd!`, at minimum TX power, on a set channel, with stop conditions. Engaging any WPS registrar you do not own is unauthorised access and, in most jurisdictions, an offence ([00.3](../module-00/lesson-03.md)). A private subnet does not contain radio — prefer an RF-quiet or isolated setup.

## Why this matters

Pixie Dust is the reason WPS earns an elective module at all: where the online brute of 08.1 takes hours and trips modern lockouts, Pixie Dust needs **one** WPS exchange and then runs entirely offline, often finishing in seconds. For a tester it is the fastest route from "this router has WPS on" to "here is your WPA2 passphrase" — when the AP is vulnerable. The professional skill, though, is not running the tool; it is knowing **which** APs are affected and being able to state, with evidence, when an AP **resists** it. A report that claims "WPS is exploitable" against a patched AP is simply wrong, and this lesson is where you learn to tell the difference.

## Learning objectives

- Explain how Pixie Dust recovers the PIN **offline** from a single exchange by exploiting weak/zero **E-S1/E-S2** nonces.
- State the **prerequisites** and the **chipset/firmware** conditions the AP must meet — qualifying the attack as **not universal**.
- Run `reaver -K` / `bully` against an **owned** AP and correctly conclude that a **patched or locked** AP resists it.

## Prerequisites

- [08.1 · How WPS works](lesson-01.md) — you must understand the registrar/enrollee exchange and the split PIN before the nonce weakness makes sense.

## Concept

### How the protocol works

In the external-registrar PIN exchange (M1–M8 from 08.1), the AP (enrollee side of the key exchange) proves it knows each PIN half by sending **hashes** of them — **E-Hash1** and **E-Hash2** — computed with a Diffie-Hellman-derived key and two secret nonces, **E-S1** and **E-S2**. In a correct implementation E-S1 and E-S2 are fresh, unpredictable 128-bit random numbers, so even though you receive E-Hash1/E-Hash2 you cannot invert them to learn the PIN.

### Why the weakness exists

Pixie Dust (Dominique Bongard, 2014) is the discovery that **many chipsets generate E-S1 and E-S2 badly** — with a broken or unseeded PRNG, so the nonces are predictable, or in the worst cases **all zero**. If you can predict E-S1 and E-S2, then E-Hash1 and E-Hash2 (which the AP sends you in message M3) become **offline oracles**: you brute-force the first PIN half against E-Hash1 and the second half against E-Hash2 on your own CPU, with no further contact with the AP. The 11,000-guess split of 08.1 becomes a sub-second offline computation. The flaw is entirely in the AP's **nonce generation**, not in the WPS message format — which is why it is chipset- and firmware-specific.

### Prerequisites & affected configurations

For Pixie Dust to succeed, **all** of these must hold:

- **WPS enabled** and the **PIN external-registrar** method active (not PBC-only).
- **WPS not locked** — the AP must complete at least the M1–M3 exchange so you obtain E-Hash1/E-Hash2, the DH public keys (PKE/PKR), the enrollee nonce, and the authkey.
- **A vulnerable chipset/firmware** whose E-S1/E-S2 are weak, predictable, or zero. Historically affected families include many **Ralink/MediaTek**, **Realtek**, and **Broadcom** devices from roughly 2010–2016; vulnerability varies **per chipset and firmware revision**, and later firmware on the same silicon is often fixed.

If the AP seeds its nonces properly, Pixie Dust fails no matter how many times you run it — the data is captured but the offline solve has no shortcut. **The attack is a property of the specific device, not of WPS in general.**

### How a tester recognises it

During recon (08.1, Module 4) you already flagged the AP as WPS-enabled with the **PIN** method and **AP Setup Locked: False**. The device/model string in the WPS IE, plus the BSSID OUI, hint at the chipset vendor — a rough predictor of whether Pixie Dust is worth trying. The definitive recognition, though, is operational: you run the capture step, get a complete M1–M3 with E-Hash1/E-Hash2, and `pixiewps` either returns a PIN in seconds (vulnerable) or reports it could not recover one (not vulnerable).

### Manual method

Conceptually the attack is two stages against your **own** AP:

1. **Collect one exchange.** Associate as an external registrar and drive the WPS PIN exchange far enough to receive M3, capturing **PKE**, **PKR**, **E-Hash1**, **E-Hash2**, the **enrollee nonce (E-Nonce)**, and the **AuthKey**.
2. **Solve offline.** Feed those values to `pixiewps`, which (assuming weak/zero E-S1/E-S2) recovers the two PIN halves, hence the full PIN. Re-submit that PIN once to the AP to have it hand back the WPA2 passphrase.

You never have to run the 11,000-guess online loop — you need a single clean exchange and the offline solve.

### Tooling

- **`reaver -i <mon> -b <BSSID> -K -vv`** — the `-K` flag runs the Pixie Dust path: reaver collects the needed values and invokes `pixiewps` automatically, trying Ralink/Broadcom/Realtek strategies.
- **`bully -b <BSSID> -d <mon>`** — an alternative WPS tool with its own Pixie Dust mode; useful when reaver struggles with a particular AP's timing.
- **`pixiewps`** — the standalone offline solver the above call into; can be run by hand on captured E-Hash1/E-Hash2/nonce values.

```bash
# Own AP only. Channel-locked monitor interface assumed (lesson 03.4).
sudo reaver -i wlan1mon -b AA:BB:CC:DD:EE:FF -c 1 -K -vv
# -K  => Pixie Dust (offline) via pixiewps; -c pins the channel; -vv shows the M1-M3 exchange.
# A vulnerable AP yields a PIN (and the WPA PSK) in seconds; a patched AP yields no PIN.
```

> [!NOTE]
> Reaver/bully/pixiewps flags and behaviour change across versions (`volatility: implementation`, see `TOOLS.md`). Treat an unexpected flag or a changed output line as a `--help` exercise, not a blog-copy exercise.

### Verification & expected evidence

A **successful** run prints the recovered **WPS PIN** and, because the PIN then unlocks the registrar, the **WPA2 passphrase (PSK)** — for the lab AP that must be the synthetic `Lab-WiFi-Passw0rd!`. A **resistant** AP produces one of two honest non-results: `pixiewps` completes but reports it **could not find the PIN** (nonces were well-seeded), or the AP **never completes M1–M3** (WPS locked / rate-limited), so there is nothing to solve. Both are valid, reportable outcomes — "AP tested, not vulnerable to Pixie Dust" is a finding, not a failure.

### Why it may fail

- **Good RNG / patched firmware** — E-S1/E-S2 are properly random, so the offline solve has no shortcut. The most common reason modern APs resist.
- **WPS locked or rate-limited** — the AP will not complete the exchange (08.3's lockout mechanism), so you never get E-Hash1/E-Hash2.
- **WPS disabled or PBC-only** — no PIN registrar to engage (08.1).
- **Virtual-path limits** — `mac80211_hwsim` + `hostapd` give you the WPS *protocol* flow, but `hostapd`'s WPS implementation uses proper nonces, so it does **not** reproduce a *vulnerable* AP. The virtual path proves you can drive the exchange and read the evidence; it cannot demonstrate a real chipset's nonce flaw — that needs a physical vulnerable AP.
- **Flaky timing / weak signal** (physical) — the exchange drops before M3; re-run channel-locked at close range on your own AP.

### Impact

Against a vulnerable AP, Pixie Dust yields the **full WPA2-Personal passphrase** from a single over-the-air exchange, bypassing passphrase entropy entirely — the strong-passphrase control from Module 6 does **not** help, because WPS hands out the key directly. That is why, for an affected device, disabling WPS is more important than any passphrase change. Against a non-vulnerable AP the impact is nil, which is exactly why per-device assessment matters.

### Remediation & blue-team view

The clean fix is to **disable WPS** (lesson 08.4): no registrar, no attack. Where WPS must stay on, use **PBC only** (no PIN registrar), ensure **patched firmware** with properly-seeded nonces, and rely on **WPS lockout** to blunt any residual online attempts. A blue team detects Pixie Dust attempts the same way as any WPS attack — a burst of external-registrar M1/M2 exchanges from an unknown MAC — and should treat repeated WPS registration attempts as an alertable event. The decisive control, though, is configuration: an AP with WPS off cannot be Pixie-Dusted at all.

## Hands-on

### Guided walkthrough — attempt Pixie Dust, then prove resistance (paths V / P)

1. **V (`mac80211_hwsim`):** bring up a `hostapd` AP with WPS enabled and drive `reaver -K` against it. Observe the M1–M3 exchange in `-vv` and that `pixiewps` **does not** recover a PIN — because `hostapd` seeds its nonces correctly. This proves the *workflow* and lets you read a resistant-AP result; it does **not** demonstrate a vulnerable chipset.
2. **P (owned vulnerable AP, if you have one):** run the same command against an owned legacy router known to be affected; observe `pixiewps` return the PIN and PSK in seconds, matching `Lab-WiFi-Passw0rd!`.
3. **P (owned patched AP):** repeat against an owned current router; observe either no PIN (good RNG) or no completed exchange (WPS locked), and record that as "tested, resistant." Turning WPS **off** on the same AP and re-running — and seeing the exchange refused entirely — is the bridge to 08.4.

### Lab

> [!NOTE]
> **Lab paths:**
> V (`mac80211_hwsim` + `hostapd` with WPS on — proves you can drive the external-registrar exchange and correctly read a **resistant** result; because `hostapd` uses proper nonces it does **not** reproduce a vulnerable chipset, so it **cannot** show a successful Pixie Dust. Real WPS/Pixie behaviour needs a real AP — the virtual path is limited to the protocol flow.)
> P (owned adapter in monitor mode + an owned AP — the only path that can show a **real** chipset's nonce weakness; use a known-vulnerable legacy router to see success and a current router to see resistance).
> **Start state:** V — `hwsim` radios up ([03.3](../module-03/lesson-03.md)); a `hostapd` WPS config. P — monitor verified ([03.4](../module-03/lesson-04.md)); your own AP (SSID `Lab-Target-01`, passphrase `Lab-WiFi-Passw0rd!`) with WPS/PIN enabled and unlocked; regulatory domain set.
> **Duration:** ~30 min (V) / ~45 min (P, including a patched-AP comparison).
> **Artifacts:** the `reaver -K -vv` transcript showing the M1–M3 exchange; the `pixiewps` result (a recovered PIN + PSK on a vulnerable AP, or an explicit "could not recover" / "WPS locked" on a resistant one); a one-line verdict per AP.
> **Success criteria:** you drive the WPS exchange and either (a) recover the PIN and the synthetic PSK on an owned vulnerable AP, **or** (b) **correctly conclude a patched AP resists Pixie Dust** — showing the no-PIN or locked evidence and recording it as a legitimate "not vulnerable" finding. Outcome (b) is a full pass; a successful crack is **not** required.
> **Troubleshooting:** exchange never reaches M3 (WPS locked/rate-limited — wait for auto-unlock or accept it as a resistant result; see 08.3); `pixiewps` returns no PIN (well-seeded nonces — the AP is not vulnerable, record it); reaver times out (weak signal/timing — move closer to your own AP, pin the channel with `-c`, or try `bully`); nothing happens on V and you expected a crack (expected — `hostapd` is not a vulnerable chipset).
> **Cleanup:** stop `reaver`/`bully`/`hostapd`; `../../labs/common/reset-lab.sh` returns interfaces to managed mode and stops services; on V, `../../labs/common/hwsim-down.sh`. Re-enable WPS lockout or disable WPS on your test AP afterwards, and never commit a recovered real passphrase.

> [!CAUTION]
> Do not point `reaver`/`bully` at any BSSID you do not own, even "just to test" — engaging a registrar is active, unauthorised access. The only correct targets are the owned APs on your allowlist with synthetic credentials.

## Exercise

A junior tester reports: "I ran `reaver -K` against the client's guest router for ten minutes, pixiewps came back empty, so I escalated to the online PIN brute and left it running overnight. WPS is clearly vulnerable, I just need more time." Assuming this was an **authorised** engagement, identify what is wrong with both the technical reasoning and the conclusion, and describe the correct, honest way to report a Pixie Dust attempt that returns no PIN.

<details>
<summary>Hint</summary>

Separate two questions: what does an empty `pixiewps` result actually tell you about the AP's nonces, and does "more time" change an offline computation that has no shortcut? Then ask whether falling back to the online brute is justified, and what the honest finding is when an AP resists Pixie Dust.
</details>

<details>
<summary>Reference answer</summary>

The reasoning is wrong on both counts. **Technically:** an empty `pixiewps` result means the AP's E-S1/E-S2 nonces were **well-seeded**, so the offline solve has no shortcut — "more time" cannot help, because Pixie Dust is a single offline computation, not a search that converges with runtime. The conclusion "WPS is clearly vulnerable, I just need more time" is backwards: the evidence points to the AP being **resistant** to Pixie Dust. **Escalating to the online brute** is a separate, far noisier attack that modern APs mostly mitigate with lockout (08.3), and running it overnight is likely to trip the lockout and produce nothing while generating a lot of traffic. The correct, honest report is: "AP tested for Pixie Dust; the exchange completed but no PIN was recovered, indicating properly-seeded nonces — **not vulnerable to Pixie Dust**." If WPS PIN is still enabled, the tester can *note the residual online-brute exposure as a lower-severity item* and recommend disabling WPS (08.4), but must not represent a resistant AP as exploitable. A clean "tested, not vulnerable" is a valid professional finding.
</details>

## References

- [Bongard (2014) — Offline bruteforce attack on WiFi Protected Setup](https://archive.hack.lu/2014/Hacklu2014_offline_bruteforce_attack_on_wps.pdf) — the original Pixie Dust (E-S1/E-S2) disclosure.
- [reaver-wps-fork-t6x README](https://sources.debian.org/src/reaver/1.6.6-2/README.md) — the `-K` Pixie Dust integration and the Ralink/Broadcom/Realtek chipset strategies.
- [08.1 · How WPS works](lesson-01.md) and [08.4 · Prevalence and remediation](lesson-04.md) — the exchange this exploits and the control that closes it.

## What you should now be able to do

- Explain how Pixie Dust recovers the WPS PIN offline from one exchange by exploiting weak or zero E-S1/E-S2 nonces.
- State the prerequisites and chipset/firmware conditions for success, and qualify the attack as device-specific, not universal.
- Run `reaver -K`/`bully` against an owned AP and correctly conclude — with evidence — when a patched or locked AP resists it.
