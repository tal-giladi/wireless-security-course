---
id: "09.4"
module: 9
minutes: 22
practice_minutes: 40
prerequisites: ["09.2"]
objectives:
  - Explain KARMA, MANA, and known-beacon attacks as PNL-dependent techniques and how they differ.
  - State precisely what modern clients resist (reduced directed probing, MAC randomisation) and what still works.
  - Run hostapd-mana against a controlled client and record which technique drew it and which did not.
volatility: implementation
sources:
  - title: "SensePost — Improvements in Rogue AP attacks (MANA)"
    url: https://sensepost.com/blog/2015/improvements-in-rogue-ap-attacks-mana-1/2/
  - title: "SpecterOps — Modern Wireless Tradecraft Pt II: MANA and Known Beacon Attacks"
    url: https://specterops.io/blog/2019/11/04/modern-wireless-tradecraft-pt-ii-mana-and-known-beacon-attacks/
  - title: "SensePost hostapd-mana wiki — KARMA/MANA attack theory"
    url: https://github.com/sensepost/hostapd-mana/wiki/KARMA---MANA-Attack-Theory
last_verified: "2026-10-01"
---

# 09.4 · KARMA, MANA, and known-beacon attacks

KARMA, MANA, and the known-beacon attack are all ways to make a rogue AP answer for networks a client already trusts, and all of them depend on the client's preferred-network list (PNL) — which is exactly why modern clients that probe less and randomise their MAC have made the original versions far less reliable. This lesson explains how the three techniques differ, states precisely what current clients resist and what still works, and has you run `hostapd-mana` against a controlled client to see which technique draws it and which does not.

> [!WARNING]
> These techniques respond to or guess at the SSIDs a client trusts and transmit to attract it. Run them **only** against a **controlled client you own**, on your [allowlist](../module-00/lesson-03.md), with synthetic SSIDs where you set the client's PNL yourself. Never respond to or brute-force the PNLs of devices you do not own — that targets strangers' saved networks and is unlawful ([00.3](../module-00/lesson-03.md)). Prefer the virtual path; minimum TX on physical.

## Why this matters

KARMA is one of the most over-claimed attacks in wireless training: a decade of tutorials present it as "the AP that becomes any network your phone is looking for," and learners assume it still works universally. It largely does not. The client-side changes you met in lesson 09.2 — reduced directed probing, passive scanning, per-network MAC randomisation, broadcast-probe hygiene — were deployed specifically to break KARMA, and they succeeded against its original form. MANA and the known-beacon attack were the attackers' response, and they work in narrower, nameable conditions. Getting this right matters because the honest finding is not "KARMA works" but "a client that still does directed probing for an open SSID in its PNL is drawable; a current client that passive-scans is not" — a precise, defensible, conditional claim.

## Learning objectives

- Explain **KARMA**, **MANA**, and the **known-beacon** attack as **PNL-dependent** techniques, and how they differ.
- State precisely what **modern clients resist** (reduced directed probing, MAC randomisation, broadcast-probe hygiene) and what **still works**.
- Run **`hostapd-mana`** against a controlled client and record which technique drew it and which did not.

## Prerequisites

- [09.2 · Evil twin — conditional on client behaviour](lesson-02.md) — you need the PNL/auto-join/randomisation model, since every technique here is a variation on exploiting it.

## Concept

### How the protocol works

All three techniques exploit the fact that a client advertises or acts on its **PNL** (lesson 09.2). They differ in *how* they discover or guess the names:

- **KARMA (2004).** The rogue responds to a client's **directed probe request** ("is `HomeWiFi` here?") by saying "yes, I am `HomeWiFi`" — for *any* name asked. It needs the client to probe for specific SSIDs by name. This is what modern clients broke by probing less and using broadcast (wildcard) probes.
- **MANA (2014, SensePost).** The response to KARMA's decline. The rogue watches each device's probes and builds a per-device view of its PNL, then answers **broadcast** probes with directed responses for the networks it has learned that device wants — a smarter, per-client KARMA that copes with devices that still do *some* directed probing. SensePost's `hostapd-mana` is the reference implementation.
- **Known-beacon attack (2018).** When a client probes too little to reveal anything, the rogue **beacons a list of common/likely SSIDs** (from a dictionary of popular names) and waits: a device whose PNL contains one of those names may spontaneously associate when it hears the matching beacon. It brute-forces the *namespace* rather than reading the PNL.

In every case the goal is the same as lesson 09.2 — get the client to associate with a rogue for a network it trusts — and the same conditional caveats apply (open PNL entries are easiest; PSK needs the key; WPA3/enterprise resist a credential-less rogue).

### Why the weakness exists

The root weakness is still unauthenticated SSIDs plus the client's willingness to **act on a familiar name** without verifying AP identity (lesson 09.2). KARMA additionally exploited chatty **directed probing**; MANA exploits whatever probing remains plus per-device PNL inference; the known-beacon attack exploits auto-join on open networks whose names are *guessable*. None of them is a cryptographic flaw — they are all "the client trusts a name," which is why hardened client policy, not a cipher change, is the fix.

### Prerequisites & affected configurations

- **KARMA works** against a client that still **directed-probes** for SSIDs by name and will accept a directed response — older OSes, some IoT, misconfigured devices. It **fails** against clients that passive-scan or only broadcast-probe.
- **MANA works** against clients that leak *some* PNL information through any probing; it degrades as a client probes less and randomises more.
- **The known-beacon attack works** against a client with a **guessable open SSID** in its PNL and **auto-join** on; it fails for networks whose names aren't in the attacker's dictionary, and (as always) for PSK/SAE/enterprise saved networks where the rogue lacks credentials.
- **Across the board, modern defaults resist:** current iOS/Android reduce directed probing, prefer passive scanning, randomise MAC per network, and increasingly prompt before joining — so the reliable modern target is an older or misconfigured client, or an open network with a common name. State the client's OS/version.

### How a tester recognises it

You profile the client first (Module 4): watching its probes tells you whether it directed-probes (KARMA/MANA surface) or stays quiet (push you toward known-beacon). You recognise a technique *worked* when `hostapd-mana` logs the client associating to one of the names it answered or beaconed, with `AP-STA-CONNECTED`. You recognise the modern-client resistance when a device probes only with wildcards, shows a randomised MAC, and does not bite any of KARMA's directed responses — at which point known-beacon against a guessable open name is your remaining avenue, if any.

### Manual method

On an owned lab, with a controlled client whose PNL **you** populated with synthetic names:

```bash
# hostapd-mana — same base config as 09.1, plus MANA options (names VERIFY per build):
#   enable_mana=1          # turn on MANA behaviour
#   mana_loud=1            # also answer broadcast probes with learned PNL entries (MANA "loud")
# Watch the log: it prints probes seen per client and any directed responses it sends.
sudo hostapd-mana /tmp/hostapd-mana-lab.conf
# For the known-beacon approach, feed a list of SYNTHETIC/common names to beacon and wait
# for your controlled client (with one of those names saved, open + auto-join) to associate.
```

You populate your own test client's PNL with synthetic SSIDs so nothing you respond to or beacon corresponds to a real network.

### Tooling

- **`hostapd-mana`** — the reference KARMA/MANA implementation; its log is your evidence of probes seen and responses sent. Option names are build-dependent — read the installed example config.
- **`eaphammer`** — wraps `hostapd-mana` and adds known-beacon/known-SSID list handling and enterprise steps (Module 11); technique-first, owned lab only.
- **`airodump-ng` / Kismet** — profile the client's probing so you pick the right technique (and to show it probes little on a modern OS).
- **A controlled client** whose PNL you set — the required target; a real owned device on P shows genuine modern probing/randomisation.

> [!NOTE]
> This whole area is **`volatility: implementation`**: what KARMA/MANA/known-beacon achieve depends on the client OS/version and on tool versions, both of which change frequently. A technique that drew a device last year may not this year. Re-verify against the actual client at test time and never generalise one device's result to "clients."

### Verification & expected evidence

Evidence is the `hostapd-mana` log showing (a) the probes it observed from your controlled client, (b) the directed responses or beacons it sent, and (c) an `AP-STA-CONNECTED` if the client associated — tied to the specific technique (KARMA directed-probe response, MANA learned-PNL response, or known-beacon name). Equally valuable evidence is a **negative**: a current-OS client that broadcast-probes, shows a randomised MAC, and does **not** associate to any KARMA/MANA response — demonstrating the modern-client resistance precisely.

### Why it may fail

- **Client passive-scans / barely probes** — KARMA and MANA have little to work with; only known-beacon against a guessable open name remains.
- **MAC randomisation + no directed probes** — the attacker cannot profile or target the device; modern defaults in action.
- **Saved networks are PSK/SAE/enterprise** — the rogue lacks credentials, so even a drawn client doesn't fully/ usefully associate (ties to lessons 09.2/09.3).
- **Name not in the known-beacon dictionary** — the attack beacons names the client doesn't have saved.
- **OS prompts before joining** — current defaults may require user action, defeating the silent-join premise.

### Impact

A client drawn by any of these techniques is in the same position as any evil-twin victim (lesson 09.2): impact is whatever the rogue can do with the association — portal (lesson 09.3), relay/inspection, or enterprise credential capture (Module 11) — and is **bounded by the client condition** that allowed the draw. The honest impact statement names the technique and the client condition: "an older device directed-probing for a saved open SSID associated via MANA," not "KARMA compromised the clients."

### Remediation & blue-team view

The defences are the client policies from lesson 09.2, sharpened: **keep OS current** (for reduced directed probing, passive scanning, and better randomisation — the measures that broke KARMA); **disable auto-join for open networks** and **prune the PNL** (defeats known-beacon by removing guessable open entries); **keep MAC randomisation on** (frustrates per-device MANA profiling); and prefer **network-authenticating** security (WPA3-SAE/enterprise) so a familiar name alone is never enough. The blue-team demonstration (lesson 09.5) is a hardened client that broadcast-probes, randomises, and does **not** associate to any KARMA/MANA/known-beacon lure.

## Hands-on

### Guided walkthrough — which technique draws which client (paths V / P)

1. **Profile.** With `airodump-ng`/Kismet, observe your controlled client's probes: directed (names visible) or broadcast only? Randomised MAC? Record OS/version.
2. **Populate a vulnerable PNL.** On one controlled client, save a **synthetic open** SSID with auto-join on (simulating an older/chatty device).
3. **KARMA/MANA.** Start `hostapd-mana` with MANA on; watch whether the vulnerable client's directed/broadcast probes get answered and whether it associates (`AP-STA-CONNECTED`).
4. **Known-beacon.** Beacon a short list of synthetic/common names including the one your client saved; see if it spontaneously associates.
5. **Hardened contrast.** Repeat against a current-OS client that passive-scans, randomises MAC, and has no stale open entries; record that none of the techniques draw it.
6. Write the result: per technique, which client was drawn, under which condition, with the log evidence — and the negative result for the hardened client.

### Lab

> [!NOTE]
> **Lab paths:**
> V (`mac80211_hwsim` + `hostapd-mana` + controlled `wpa_supplicant` clients — proves the KARMA/MANA/known-beacon *logic* and that a populated-PNL client is drawn while a clean one is not; a controlled client is **required**. Does **not** reproduce a real OS's probing/randomisation defaults, which are the whole point of the resistance — so treat V's "vulnerable" client as a simulation of an older device).
> P (owned AP-mode adapter + owned controlled clients, ideally real devices on different OS versions — the only path that shows genuine modern probing/randomisation resisting the techniques).
> **Start state:** V — hwsim radios up ([03.3](../module-03/lesson-03.md)); `hostapd-mana` installed. P — AP-mode adapter + owned clients; reg domain set. Synthetic SSIDs you save into the test client's PNL; a synthetic/common-name list for the known-beacon step.
> **Duration:** ~30 min (V) / ~40 min (P).
> **Artifacts:** a per-technique table (technique, client, OS/version, probing behaviour, PNL entry, outcome); `hostapd-mana` logs of probes seen and responses sent; `AP-STA-CONNECTED` for any drawn client; the negative result for the hardened client.
> **Success criteria:** you show **at least one technique drawing a vulnerable-configured client** (named condition) **and** a **hardened client that none of the techniques draw**, each with evidence. Demonstrating the modern-client resistance (the negative result) is a full pass — a successful draw is **not** required.
> **Troubleshooting:** no probes seen (client passive-scanning — expected on modern OS; move to known-beacon); MANA options rejected (build-specific names — read the installed example config); client never associates (SSID saved as PSK not open; auto-join off; name not in beacon list); nothing on air (channel/TX on P).
> **Cleanup:** stop `hostapd-mana`; forget synthetic SSIDs on test clients; `../../labs/common/reset-lab.sh`; on V, `../../labs/common/hwsim-down.sh`.

> [!CAUTION]
> Respond to and beacon **only synthetic** names you have saved on **your own** client. Never answer or brute-force the real PNLs of devices you do not own — that targets strangers' saved networks and is unlawful ([00.3](../module-00/lesson-03.md)).

## Exercise

A tester runs `hostapd-mana` in a busy office for an hour and reports: "KARMA attack successful — the AP impersonated dozens of networks and several devices connected, proving all staff devices are vulnerable." Given what modern clients do, identify what is questionable about this claim and rewrite it as a precise, conditional finding, noting what evidence you would need and what the likely real condition of the connecting devices was.

<details>
<summary>Hint</summary>

"Impersonated dozens of networks" and "several devices connected" are different claims — which did the log actually show? What do current iOS/Android do that makes classic KARMA unreliable, so what kind of device is a "connecting device" most likely to be? What condition (saved security, auto-join, OS age) would each connection require?
</details>

<details>
<summary>Reference answer</summary>

**Questionable points:** (1) Running `hostapd-mana` in a public office answers/beacons for networks belonging to uninvolved people — a scoping/legal problem unless every drawn device is owned and authorised. (2) "Impersonated dozens of networks" likely just means MANA *responded* to many probed names — not that dozens of devices associated. (3) "Several devices connected ... all staff devices are vulnerable" over-generalises: modern iOS/Android passive-scan, randomise MAC, and probe little, so classic KARMA is unreliable against them; the devices that actually associated were most likely **older or IoT devices still directed-probing, with an open SSID saved and auto-join on**, or devices whose **guessable open SSID** matched a beaconed name. (4) No per-device condition or OS/version is recorded, so the claim isn't defensible. **Rewrite:** "Against authorised, owned test devices, MANA drew N devices that still perform directed probing and had an open SSID saved with auto-join enabled (OS versions recorded); known-beacon drew M devices with a guessable open SSID saved. Current-OS devices that passive-scanned and randomised their MAC were **not** drawn. The exposure is specific to older/misconfigured clients and guessable open auto-join entries — not a universal staff-device vulnerability." **Evidence needed:** the `hostapd-mana` log tying each `AP-STA-CONNECTED` to a technique and SSID, and each device's OS/version and saved-network settings.
</details>

## References

- [SensePost — Improvements in Rogue AP attacks (MANA)](https://sensepost.com/blog/2015/improvements-in-rogue-ap-attacks-mana-1/2/) — why KARMA declined and how MANA responds.
- [SpecterOps — Modern Wireless Tradecraft Pt II](https://specterops.io/blog/2019/11/04/modern-wireless-tradecraft-pt-ii-mana-and-known-beacon-attacks/) — MANA and the known-beacon attack against modern clients.
- [SensePost hostapd-mana wiki — KARMA/MANA theory](https://github.com/sensepost/hostapd-mana/wiki/KARMA---MANA-Attack-Theory) — the tool run in this lab.
- [09.2 · Evil twin — conditional on client behaviour](lesson-02.md) — the PNL/auto-join/randomisation model these techniques exploit.

## What you should now be able to do

- Explain how KARMA, MANA, and known-beacon differ and that all three are PNL-dependent, not cryptographic.
- State what modern clients resist (reduced directed probing, passive scanning, MAC randomisation) and the narrow conditions under which each technique still works.
- Run `hostapd-mana` against a controlled client, record which technique drew it under which condition, and present the hardened-client negative result as a valid outcome.
