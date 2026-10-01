---
id: "04.2"
module: 4
minutes: 24
practice_minutes: 30
prerequisites: ["04.1"]
objectives:
  - Read an airodump-ng display — BSSID, PWR, CH, ENC/CIPHER/AUTH, ESSID, and the stations list.
  - Decide when to channel-hop and when to lock a channel, and recognise a hidden SSID.
  - Use Kismet for passive discovery and read its AP and client/PNL view.
volatility: implementation
sources:
  - title: "aircrack-ng — airodump-ng documentation (fields, channel hopping, --channel)"
    url: https://www.aircrack-ng.org/doku.php?id=airodump-ng
  - title: "Kismet documentation — operation and device views"
    url: https://www.kismetwireless.net/docs/
last_verified: "2026-10-01"
---

# 04.2 · airodump-ng and Kismet — the AP and client view

Two tools turn a monitor-mode interface into a readable picture of the air: airodump-ng gives you a fast live table of access points and the clients talking to them, and Kismet gives you a passive, long-running sensor view with a richer per-client and preferred-network picture. This lesson reads the airodump-ng display field by field, covers the channel-hop versus channel-lock decision and how a hidden SSID shows up, then uses Kismet for the same discovery from a passive angle.

> [!NOTE]
> Tool output formats, column labels, and flags change between tool versions (`volatility: implementation`). The fields and behaviour below match the documented airodump-ng and Kismet output at the verification date; confirm against the versions you pinned in `TOOLS.md`. The *reasoning* — what each field tells you — is stable even when a label moves.

## Why this matters

Capture and cracking in Modules 5 and 6 start from a single line you pick out of this display: the BSSID, its channel, and whether a client is associated. Misread the ENC/CIPHER/AUTH triplet and you waste an afternoon attacking the wrong security mode; miss that the target is on a 5 GHz channel and your channel-hopping capture never catches its handshake. airodump-ng and Kismet are the tools OSWP (and this course) expect you to be fluent in, and fluency means reading the table correctly, not memorising flags.

## Learning objectives

- Read the **airodump-ng** AP table (BSSID, PWR, CH, ENC/CIPHER/AUTH, ESSID) and the **stations** list.
- Decide between **channel hopping** and **locking a channel**, and recognise a **hidden SSID**.
- Run **Kismet** for passive discovery and read its **AP and client/PNL** view.

## Prerequisites

- [04.1 · Passive versus active discovery](lesson-01.md) — you must know which parts of a scan transmit, so you can run these tools within the minimum-transmission discipline.

## Concept

### How it works on the wire — reading the airodump-ng display

With an interface in monitor mode, `airodump-ng wlan0mon` prints two tables that refresh live. The **upper table is access points**, one row per BSSID:

| Field | What it tells you |
|---|---|
| **BSSID** | the AP's MAC — the per-cell identifier you will target and filter on |
| **PWR** | signal level your adapter reports for that AP (closer to 0 is stronger); driver-dependent, and `-1` means the driver did not supply it |
| **Beacons** | count of beacon frames heard — rises steadily for an AP you are hearing well |
| **#Data / #/s** | data frames seen and their rate — activity, and a hint that clients are present |
| **CH** | the channel the AP announces it is on |
| **ENC** | encryption family: `OPN` (open), `WEP`, `WPA`, `WPA2`, `WPA3` |
| **CIPHER** | the pairwise cipher: `CCMP` (AES), `TKIP`, or `GCMP` for the newest modes |
| **AUTH** | key-management: `PSK` (Personal), `SAE` (WPA3-Personal), `MGT` (802.1X/Enterprise), `OWE` |
| **ESSID** | the network name, or blank/`<length: N>` for a hidden SSID |

The **lower table is stations (clients)**, one row per client MAC:

| Field | What it tells you |
|---|---|
| **BSSID** | the AP the client is associated to, or `(not associated)` if it is only probing |
| **STATION** | the client's MAC (often randomised on modern devices — see [04.3](lesson-03.md)) |
| **PWR** | the client's signal level at your adapter |
| **Frames** | frames seen from the client |
| **Probe** | SSIDs the client has probed for — a window onto its preferred-network list ([04.3](lesson-03.md)) |

Reading ENC/CIPHER/AUTH together is what names the real target: `WPA2 CCMP PSK` is WPA2-Personal (Module 6), `WPA3 ... SAE` is WPA3-Personal (Module 7), `WPA2 CCMP MGT` is Enterprise (Modules 10–11), `OPN` with an `OWE` AKM is Enhanced Open ([02.1](../module-02/lesson-01.md)).

### Channel hopping versus locking a channel

A radio hears only the channel it is tuned to ([01.2 · Bands and channels](../module-01/lesson-02.md)). By default airodump-ng **hops** across channels to survey everything, which is right for the initial sweep but means you are on your target's channel only a fraction of the time — no good for catching a specific handshake. Once you have chosen a target, **lock** the channel:

```bash
airodump-ng --channel 6 --bssid AA:BB:CC:DD:EE:FF -w capture wlan0mon
```

Locking parks the radio on channel 6, filters to one BSSID, and writes to `capture*.pcapng`. Hopping surveys; locking captures. Choosing the wrong one is the most common reason a capture comes up empty despite the target being "right there" in the survey.

### Recognising a hidden SSID

A hidden network beacons with the SSID field blanked, so airodump-ng shows the ESSID as empty or `<length: 7>` (the name's length leaks even when the name does not). The name is **omitted, not encrypted** — it is not security, only obscurity. You resolve it passively by waiting for a client to associate (the association request and the client's directed probes carry the name) or actively with a directed probe once you have learned it ([04.1](lesson-01.md)).

### Kismet — the passive sensor view

Kismet is a passive detector and sensor: you point it at one or more monitor-mode sources and it builds a long-running database of every AP and client it hears, viewable in its web UI. Where airodump-ng is a fast live table you watch, Kismet excels at **passive accumulation over time** and a **richer client view** — per-device history, the SSIDs each client has probed (its PNL, [04.3](lesson-03.md)), and signal over time — without you transmitting. It is the tool for "sit and listen thoroughly" recon, and the client/PNL view it builds is what feeds evil-twin viability reasoning later (Module 9). Kismet logs to its own formats and can export captures; it channel-hops by default across its sources just as airodump-ng does.

## Hands-on

This lesson supports all three paths. **R** proves you can read a supplied airodump-ng capture / recorded output; **V** proves you can drive the tools against simulated radios; **P** is the only path that proves real monitor-mode survey and capture over the air against your own equipment.

### Guided walkthrough — survey, then lock, then listen with Kismet

1. **(R)** Open the recorded survey `captures/airodump-survey.txt` (a saved airodump-ng screen) and `captures/survey.pcapng` from `labs/module-04/`. For each AP row, name the real security from ENC/CIPHER/AUTH, and in the stations table find a client that is `(not associated)` and read its probed SSIDs.
2. **(R)** Find the hidden-SSID row (blank ESSID / `<length: N>`) and, in `survey.pcapng`, locate the association request that reveals its name.
3. **(V/P)** Run a hopping survey: `airodump-ng wlan0mon`. Identify your own `LAB-RECON` AP, its channel, and its security triplet.
4. **(V/P)** Lock on it: `airodump-ng --channel <ch> --bssid <your-bssid> -w lab wlan0mon`. Confirm the capture file grows and your lab client appears in the stations table.
5. **(V/P)** Start Kismet on the same monitor source, open its web UI, and compare: the same AP, plus the per-client/PNL view. Note that you transmitted nothing to build it.

### Lab

> [!NOTE]
> **Lab paths:**
> R (read `airodump-survey.txt` + `survey.pcapng` — no hardware; proves you can interpret the AP/station tables and spot a hidden SSID, not that you captured them).
> V (`mac80211_hwsim` + `hostapd` + `airodump-ng`/Kismet — proves you can drive the tools and read their output; does **not** reproduce real RF, PWR values, range, interference, or hardware monitor quirks — PWR in particular is meaningful only on P).
> P (owned adapter in monitor mode + your own AP and client — the only path that proves real survey, channel-lock capture, and live PWR readings).
> **Start state:** path built and verified ([03.x](../module-03/lesson-01.md)); for V/P your own AP beaconing `LAB-RECON` (include one hidden-SSID BSS) on a known channel, one lab client; allowlist written.
> **Duration:** ~30 min (V/P) / ~15 min (R).
> **Artifacts:** an annotated AP table naming each network's real security; a channel-locked capture file (`lab-01.pcapng`) of your own BSSID; a Kismet export or screenshot showing the same AP and its client/PNL view.
> **Troubleshooting:** empty capture while target is in the survey (you are hopping, not locked — add `--channel`); AP missing (wrong band/channel — [04.1](lesson-01.md)); PWR shows `-1` (driver does not report signal — expected on some adapters and on V); Kismet UI not loading (confirm the source interface and that monitor mode is up, [03.4](../module-03/lesson-04.md)).
> **Cleanup:** stop `airodump-ng`/Kismet; on V run `labs/common/hwsim-down.sh`; delete capture files you do not intend to keep, or record their provenance if you do ([04 lab README](../../labs/module-04/)).

> [!WARNING]
> A channel-hopping survey is passive reception, but any locked capture still records the channel. Capture **only** your allowlisted targets and keep nothing from networks you do not own ([00.3](../module-00/lesson-03.md)). LAB TARGET vs REAL NETWORK: `LAB-RECON` is yours; other networks in the survey are out of scope — do not lock-capture or save them.

## Exercise

A learner surveys with `airodump-ng wlan0mon`, sees their target AP listed on channel 11 with a client associated, and immediately starts the same command writing to a file to capture the handshake — but after ten minutes the capture contains beacons from dozens of networks and not one frame they can use from the target. Without naming a new tool, explain what the learner got wrong about how the radio was behaving and the single change that fixes it.

<details>
<summary>Hint</summary>

The survey saw the target because the radio visited channel 11 — along with every other channel. Ask what fraction of those ten minutes the radio actually spent on channel 11, and what that does to the chance of catching frames that only happen on 11.
</details>

<details>
<summary>Reference answer</summary>

Plain `airodump-ng wlan0mon` channel-hops: the radio cycles through channels and is on the target's channel 11 only a small fraction of the time, which is fine for *surveying* (that is how it saw the AP at all) but hopeless for *capturing* frames from one BSSID, since the radio is elsewhere whenever the target transmits. The capture fills with scattered beacons because hopping catches a beacon here and there from everything. The fix is to lock the channel and filter the BSSID: `airodump-ng --channel 11 --bssid <target> -w capture wlan0mon`, which parks the radio on 11 so it is present for the target's frames. Hopping surveys; locking captures.
</details>

## References

- [aircrack-ng — airodump-ng](https://www.aircrack-ng.org/doku.php?id=airodump-ng) — field meanings, channel hopping, and `--channel`/`--bssid`.
- [Kismet documentation](https://www.kismetwireless.net/docs/) — passive operation and the device/client views.
- [04.1 · Passive versus active discovery](lesson-01.md) — which parts of a survey transmit.
- [02.1 · The protocol family](../module-02/lesson-01.md) — reading ENC/CIPHER/AUTH as a security mode.

## What you should now be able to do

- Read the airodump-ng AP and stations tables and name a network's real security from ENC/CIPHER/AUTH.
- Choose channel hopping for a survey and a channel lock for a capture, and recognise a hidden SSID.
- Run Kismet for passive discovery and read its AP and client/PNL view.
