---
id: "06.2"
module: 6
minutes: 22
practice_minutes: 40
prerequisites: ["06.1"]
objectives:
  - Obtain a WPA2 4-way handshake by waiting for a join or, on non-PMF networks, forcing a reconnect, stating the cost of each.
  - Qualify deauthentication honestly as an over-the-air DoS that PMF rejects and that is never required when you can wait.
  - Distinguish a clean, crackable capture from a partial one and verify which you have before spending time cracking.
volatility: implementation
sources:
  - title: "IEEE 802.11-2020 — deauthentication/disassociation frames and Protected Management Frames (802.11w)"
    url: https://standards.ieee.org/ieee/802.11/7028/
  - title: "aircrack-ng documentation — airodump-ng capture and aireplay-ng deauthentication"
    url: https://www.aircrack-ng.org/doku.php?id=airodump-ng
last_verified: "2026-10-01"
---

# 06.2 · Capturing a handshake — deauth caveats, clean versus partial

Cracking a WPA2 passphrase (lesson 06.4) is only ever as good as the handshake you feed it, so this lesson is about getting a capture that actually contains the values lesson 06.1 identified — and recognising when it does not. It covers the two honest ways to obtain a handshake (wait for a client to join, or on a non-PMF network nudge one to reconnect), qualifies deauthentication as the over-the-air denial-of-service it is, and teaches the difference between a clean, crackable capture and a partial one that will waste your time.

> [!WARNING]
> Deauthentication frames are transmitted over the air and affect **any** device in range on that channel, not just your target. They are a denial-of-service. Use them only against a client **you own**, on your [allowlist](../module-00/lesson-03.md), at minimum TX power, on a set channel, with stop conditions — or avoid them entirely by waiting for a natural join. A private subnet does not contain radio.

## Why this matters

The single most common reason a WPA2 crack fails for a beginner is not a weak GPU or a bad wordlist — it is a **partial capture** that never contained a usable MIC in the first place. Learning to confirm a clean handshake before you start cracking saves hours. And the reflex many learners copy from old tutorials — "always fire a deauth" — is both unnecessary when a client will reconnect on its own and actively wrong on modern PMF-protected networks, where it is rejected. Getting the capture step right, and honest, is what makes everything downstream work.

## Learning objectives

- Obtain a handshake by **waiting for a join** or, on **non-PMF** networks, **forcing a reconnect** — and state the cost of each.
- Qualify **deauthentication** as an over-the-air **DoS** that **PMF rejects** and that is **not required** when you can wait.
- Distinguish a **clean, crackable** capture from a **partial** one, and verify which you have before cracking.

## Prerequisites

- [06.1 · The 4-way handshake in depth](lesson-01.md) — you must know which frames and fields a crackable capture must contain.

## Concept

### How the protocol works

A capturing station in monitor mode, parked on the AP's channel, records the EAPOL-Key frames exactly when a client associates and runs the 4-way handshake (lesson 06.1). You capture a handshake by **being present on the right channel at the moment a client joins**. There are two ways to make that moment happen:

- **Wait for a natural join.** Any client that connects while you are capturing — a phone waking, a laptop returning to range, a device rebooting — produces a full handshake. This transmits nothing from you and is always legitimate against your own lab.
- **Force a reconnect.** If a client is already associated and you do not want to wait, you can (on a non-PMF network) send it a **deauthentication** frame; it drops and almost always reconnects, replaying the handshake into your capture.

### Why the weakness exists

Deauthentication and disassociation are **unauthenticated management frames** in the original 802.11 design: the AP and client act on them without verifying the sender. That is what lets an attacker forge one and knock a client off — and it is the same design flaw behind deauth-based DoS generally (lesson 12.1). **Protected Management Frames (PMF / 802.11w)** close this: when PMF is active, forged deauths are rejected and the client stays connected.

> [!CAUTION]
> Deauth is an **over-the-air denial-of-service**, not a neutral "capture helper." Every deauth you send disrupts a real device. On your own lab client that is contained; aimed at anything you do not own it is both harmful and, in most jurisdictions, an **interference** offence ([00.3](../module-00/lesson-03.md)). It is never a prerequisite for capturing — it is an optional, costly shortcut over simply waiting.

### Prerequisites & affected configurations

To capture a handshake you need: a radio that can **monitor** on the target's channel (physical path) or a simulated setup (virtual path), the AP's **channel** and **BSSID**, and a **client that joins or rejoins** during your capture window. The deauth shortcut additionally needs the network to be **non-PMF** — on a PMF-required network (all WPA3, and WPA2 where the admin enabled it) your deauth is simply ignored, and you must wait for a natural join instead. Capturing itself works on any WPA2-Personal network; PMF changes only whether you can *force* the reconnect, not whether a handshake is crackable once captured.

### How a tester recognises it

You know you have what you need when your capture tool reports a **captured handshake** (airodump-ng shows `WPA handshake: <BSSID>` in its top-right corner) or when a validator confirms a complete EAPOL exchange. You recognise the network is a candidate for the deauth shortcut by its RSN capabilities: **MFPR/MFPC** bits clear (PMF not required/!capable) in the beacon mean deauth will likely work; MFPR set means it will not (lesson 06.5, and the glossary MFPC/MFPR entry).

### Manual method

On the physical path, the minimal honest sequence (own lab only):

```bash
sudo airmon-ng check kill                       # stop interfering services
sudo airmon-ng start wlan1                       # monitor interface, e.g. wlan1mon
sudo airodump-ng -c 1 --bssid AA:BB:CC:DD:EE:FF -w cap wlan1mon
# ^ park on the AP's channel+BSSID and write cap-01.cap; WAIT for a client to join.
#   Only if a client is already on and you own it, in a separate terminal:
sudo aireplay-ng --deauth 1 -a AA:BB:CC:DD:EE:FF -c <client-MAC> wlan1mon
# ^ ONE deauth, targeted at your own client. Watch airodump for "WPA handshake".
```

Note `--deauth 1` (a **single** frame), not a flood: you want to prompt one reconnect, not run a DoS. On a PMF network this line does nothing — remove it and wait.

### Tooling

- `airodump-ng` — survey and channel-locked capture; reports when a handshake is seen.
- `aireplay-ng --deauth` — sends deauthentication frames (own client only; prefer `1`, not a flood).
- `hcxdumptool` — an alternative capture tool (central to lesson 06.3's PMKID path).
- `tshark`/Wireshark and **`hcxpcapngtool`** — validate a capture actually contains a complete handshake before cracking.

> [!NOTE]
> Tool flags change across versions (`hcxdumptool` especially — see `TOOLS.md`). Treat a changed flag as a troubleshooting exercise: read the tool's own `--help`, not an old blog.

### Verification & expected evidence

A **clean** capture contains a complete, consistent EAPOL exchange — at minimum a well-formed message-2 (or 2+3) pair with a MIC over the right nonces — and `hcxpcapngtool` extracts a `hc22000` hashline from it. A **partial** capture (client cut off mid-exchange, only message 1, or mismatched nonces) yields **no** hashline, or a tool warning that the handshake is incomplete. Verifying is a 10-second check that precedes any cracking:

```bash
hcxpcapngtool -o out.hc22000 cap-01.cap    # a hashline written => crackable; none/empty => partial
```

The module ships both so you can tell them apart by hand: `wpa2-handshake-good.pcapng` (clean, produces a hashline) and `wpa2-handshake-partial.pcapng` (incomplete, produces none) — both **PENDING** a verified generation run (see the lab README).

### Why it may fail

- **No client joins or rejoins** in your window — nothing to capture. Wait longer, or (non-PMF, own client) prompt one reconnect.
- **PMF is on** — your deauth is rejected; the client never drops. Switch to waiting for a natural join.
- **Wrong channel / channel-hopping** — if your radio is surveying instead of locked to the AP's channel, it is rarely present for the handshake. Lock the channel (`-c`).
- **Partial capture** — you caught some but not all of the exchange; `hcxpcapngtool` extracts nothing. Re-capture.
- **Monitor/injection not actually working** (physical) — verify with `aireplay-ng -9` first (lesson 03.4).

### Impact

A single captured clean handshake is enough to attempt offline passphrase recovery (lesson 06.4) with **no further contact** with the network — the AP can be switched off and the crack continues. The impact is therefore bounded entirely by passphrase strength, which is why the control lives on the client/AP configuration side, not the capture side.

### Remediation & blue-team view

Capturing a handshake cannot be prevented — any client join is enough and waiting is passive. Defences target the **shortcut** and the **payoff**: enable **PMF** so forged deauths are rejected (removing the attacker's ability to force a reconnect and signalling a hardened network), and — the real control — use a **high-entropy passphrase** so the captured handshake is uncrackable (lesson 06.5). A blue team also watches for **deauth floods** as an IDS signal: a burst of deauths is a visible, noisy event even though a single one is subtle.

## Hands-on

### Guided walkthrough — capture, then verify clean vs partial (paths R / V / P)

1. **R (no hardware):** open `captures/wpa2-handshake-good.pcapng`, filter `eapol`, confirm all four messages; then open `captures/wpa2-handshake-partial.pcapng` and confirm messages are **missing**. Run `hcxpcapngtool -o /tmp/good.hc22000 wpa2-handshake-good.pcapng` and `hcxpcapngtool -o /tmp/partial.hc22000 wpa2-handshake-partial.pcapng` — note which produces a hashline.
2. **V (`mac80211_hwsim`):** bring up a WPA2 AP and a client, capture on a monitor interface, and watch a **natural** join produce a handshake — no deauth needed (`labs/common/gen-captures.sh` automates exactly this).
3. **P (owned gear):** park airodump-ng on your own AP's channel/BSSID and wait for your own client to join. Only if it is already connected and you own it, send a **single** targeted deauth; if your AP has PMF on, observe that it does **not** drop — and capture a natural join instead.

### Lab

> [!NOTE]
> **Lab paths:**
> R (supplied `wpa2-handshake-good.pcapng` + `wpa2-handshake-partial.pcapng` — no hardware; proves you can tell a crackable capture from a partial one and validate it, **not** that you captured live).
> V (`mac80211_hwsim` + `hostapd` + `wpa_supplicant` + a monitor interface — proves you can reproduce a handshake capture end to end from a natural join; does **not** reproduce real RF, drivers, range, interference, or monitor/injection behaviour).
> P (owned adapter in monitor mode + owned AP + owned client — the only path that proves real capture, channel locking, and that a single deauth prompts a reconnect on a non-PMF network).
> **Start state:** R — recorded toolchain + module zip. V — `hwsim` radios up ([03.3](../module-03/lesson-03.md)). P — monitor/injection verified ([03.4](../module-03/lesson-04.md)); your own AP (SSID `Lab-Target-01`, passphrase `Lab-WiFi-Passw0rd!`) and one owned client; regulatory domain set.
> **Duration:** ~10 min (R) / ~30 min (V) / ~40 min (P).
> **Artifacts:** a capture file containing a complete 4-way handshake; a `hc22000` hashline extracted from the clean capture and **none** from the partial one; a note of whether you waited or (non-PMF) prompted one reconnect.
> **Success criteria:** you obtain a clean handshake (by waiting, or by a single own-client deauth on a non-PMF lab AP) **and** you correctly identify the partial capture as non-crackable. On a PMF-enabled lab AP, correctly observing that the deauth is **rejected** and capturing a natural join instead is a full pass — **a successful deauth is not required**.
> **Troubleshooting:** no handshake seen (not channel-locked — set `-c`; no client joined — wait or reboot your own client); deauth has no effect (PMF on — expected; wait for a natural join); `hcxpcapngtool` extracts nothing (partial capture — re-capture); interface won't monitor (`airmon-ng check kill`, verify with `aireplay-ng -9`).
> **Cleanup:** stop `airodump-ng`/`hostapd`/`wpa_supplicant`; `../../labs/common/reset-lab.sh` returns interfaces to managed mode and stops services; on V, `../../labs/common/hwsim-down.sh`. Delete scratch captures you do not need.

> [!WARNING]
> **LAB TARGET vs REAL NETWORK:** the only AP and client you may capture, deauth, or reconnect are ones **you personally own**, with the synthetic credentials above. Never deauth, capture, or probe a network you do not own — that is interference and/or interception ([00.3](../module-00/lesson-03.md)). Prefer waiting over deauthing; prefer the virtual path for transmit-heavy practice.

## Exercise

A learner reports: "I deauthed the target three hundred times at full power to be sure, captured for an hour, and hashcat still says no hash — the network must use some unbreakable WPA2 variant." Identify at least three things wrong with this approach (safety, technique, and diagnosis), and describe the correct minimal procedure to obtain and confirm a crackable handshake.

<details>
<summary>Hint</summary>

Separate three questions: was the deauth necessary and safe? Would a flood even help, and what does it cost? And before blaming "unbreakable WPA2," what one command tells you whether the capture is clean or partial? Consider also whether the network might have PMF, which would explain no reconnect at all.
</details>

<details>
<summary>Reference answer</summary>

Three faults: **(1) Safety/legality** — a 300-frame full-power deauth flood is a denial-of-service that disrupts every device in range, not a "capture helper"; one targeted frame against your own client is all a reconnect needs, and a flood against anything you do not own is an interference offence. **(2) Technique** — flooding does not improve capture odds over a single deauth or simply waiting; if the client never reconnected, the network may have **PMF** (deauth rejected), in which case the answer is to wait for a natural join, not deauth harder. **(3) Diagnosis** — "no hash" almost always means a **partial capture**, not unbreakable crypto; `hcxpcapngtool -o out.hc22000 cap.cap` producing no hashline confirms the capture is incomplete. Correct minimal procedure: lock monitor to the AP's channel/BSSID, wait for a natural join (or send **one** targeted deauth to your own client on a non-PMF lab AP), then validate with `hcxpcapngtool` before cracking. A clean handshake is crackable or not based on passphrase entropy — never on a secret WPA2 variant.
</details>

## References

- IEEE 802.11-2020 — deauthentication/disassociation frames and Protected Management Frames (`../../references/README.md`).
- [aircrack-ng — airodump-ng capture & aireplay-ng deauthentication](https://www.aircrack-ng.org/doku.php?id=airodump-ng).
- [06.1 · The 4-way handshake in depth](lesson-01.md) and [`../common/CAPTURES.md`](../../labs/common/CAPTURES.md) — what a crackable capture must contain and the shipped clean/partial examples.

## What you should now be able to do

- Obtain a WPA2 handshake by waiting for a join, or on a non-PMF network by prompting a single reconnect, and state the cost of each.
- Explain why deauthentication is an over-the-air DoS, why PMF rejects it, and why it is never required to capture.
- Tell a clean, crackable capture from a partial one and validate which you have before spending time cracking.
