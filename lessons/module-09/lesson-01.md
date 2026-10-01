---
id: "09.1"
module: 9
minutes: 18
practice_minutes: 40
prerequisites: ["06.1"]
objectives:
  - Define a rogue AP and distinguish an evil twin from an unmanaged or mis-shadowed AP.
  - Stand up a controlled rogue AP with hostapd/hostapd-mana and craft a beacon or SSID lure on an owned lab.
  - Explain honestly why standing up the AP is easy and getting a client to associate is the real challenge.
volatility: implementation
sources:
  - title: "IEEE 802.11-2020 — beacon and probe management frames, BSS establishment"
    url: https://standards.ieee.org/ieee/802.11/7028/
  - title: "hostapd documentation (hostapd.conf) — AP configuration"
    url: https://w1.fi/cgit/hostap/plain/hostapd/hostapd.conf
  - title: "SensePost hostapd-mana — rogue-AP mechanics and MANA theory"
    url: https://github.com/sensepost/hostapd-mana/wiki/KARMA---MANA-Attack-Theory
last_verified: "2026-10-01"
---

# 09.1 · Rogue-AP mechanics and lures

A rogue AP is nothing more than an access point the network owner never sanctioned, and standing one up is the easy part of every attack in this module — a laptop with a supported adapter and a few lines of `hostapd` config is a working AP in seconds. This lesson covers what a rogue AP actually is, how `hostapd` and `hostapd-mana` build one on your own lab, the beacon and SSID lures that advertise it, and the honest central point that attracting a real client to associate is the whole challenge, not the broadcasting.

> [!WARNING]
> Standing up an AP transmits beacons over the air and is visible to **every** device in range, not just your lab client. Run a rogue AP only against a **controlled client you own**, on your [allowlist](../module-00/lesson-03.md), at minimum TX power, on a set channel, with stop conditions. **Never advertise an SSID that belongs to a network you do not own** — impersonating a real ESSID to attract strangers' devices is both harmful and, in most jurisdictions, unlawful. Prefer the virtual (`mac80211_hwsim`) path for practice.

## Why this matters

Every attack in Module 9 — evil twin, captive portal, KARMA/MANA — begins with a rogue AP, so the mechanics here are the foundation for the rest of the module. Just as important is the expectation-setting: beginners watch a rogue AP appear in a scan and assume the attack is done, then are surprised when no client joins. The truth is the reverse. Broadcasting a beacon is trivial and proves nothing; persuading a specific client — with its own saved networks, auto-join rules, and signal preferences — to leave a legitimate AP and associate with yours is the hard, conditional work that the next lessons are entirely about. Understanding that split early stops you from over-claiming impact.

## Learning objectives

- Define a **rogue AP** and distinguish an **evil twin** from an unmanaged or accidentally-shadowing AP.
- Stand up a controlled rogue AP with **`hostapd`** (and introduce **`hostapd-mana`**) and craft a **beacon/SSID lure** on an owned lab.
- Explain why standing up the AP is **easy** and getting a client to **associate** is the real challenge.

## Prerequisites

- [06.1 · The 4-way handshake in depth](../module-06/lesson-01.md) — you need the join and key-exchange flow to reason about what a client does when it associates with your AP.

## Concept

### How the protocol works

An AP announces a BSS by transmitting **beacons** (lesson 1.4): periodic management frames carrying an SSID, a BSSID (the AP's MAC), supported rates, a channel, and an RSN element describing security. A client builds its view of the world from these beacons and from **probe responses** to its probe requests. Nothing in the original 802.11 design authenticates *which* AP sent a beacon — the SSID is just a string, and any radio can claim any SSID and any BSSID. A **rogue AP** exploits exactly that: it is an AP the network owner never sanctioned.

Rogue APs come in flavours worth separating:

- **Evil twin** — a rogue that deliberately **impersonates a legitimate SSID** (and often its BSSID, channel, and security advertisement) to attract that network's clients. This is the targeted, offensive case lesson 09.2 dissects.
- **Unmanaged / shadow AP** — an AP someone plugged in without authorisation (a staffer's travel router), not impersonating anything but still outside the owner's control and policy. The blue-team lesson 09.5 treats detecting these.
- **Lure AP** — a rogue advertising an attractive *generic* name (a common open SSID) to tempt auto-join, rather than cloning one specific target.

### Why the weakness exists

The weakness is that **beacons and SSIDs are unauthenticated**. A legacy open or WPA2-PSK network gives a client no way to verify an AP's identity before association — the client sees a familiar SSID and a plausible security advertisement and proceeds. (This is precisely the gap that OWE does *not* close and that enterprise server-certificate validation and WPA3-SAE's mutual authentication partially do — later lessons and Module 11.) The rogue-AP family exists because, for the common home/SOHO security modes, there simply is no network-identity check a client can fail.

### Prerequisites & affected configurations

To stand up a rogue AP you need a radio capable of **AP mode** (`hostapd` under the virtual `mac80211_hwsim` path, or a real AP-mode-capable adapter on the physical path — see the glossary "AP mode" entry and `TOOLS.md`), a channel, and a config file. That is all the *broadcasting* requires. Whether any *client* is affected is an entirely separate question answered by the next lessons — it depends on the client's saved networks, auto-join settings, and the security mode of the network being impersonated. A rogue AP against WPA2-PSK or open is easy to stand up; whether it draws a client is conditional.

### How a tester recognises it

From the attacker's side you confirm the AP is live when your own survey tool (`airodump-ng`, Kismet — Module 4) lists your BSSID/SSID on the expected channel, and when your controlled client *sees* it in its network list. From the defender's side (lesson 09.5) a rogue is recognised as a BSSID/SSID that should not be present, a duplicate SSID on an unexpected BSSID or channel, or a signal-strength anomaly. Seeing the AP in a scan is not the same as a client having joined it — keep those two observations distinct.

### Manual method

On the virtual path, a minimal WPA2 rogue AP for your **own** lab client (synthetic SSID, never a real one):

```bash
# /tmp/hostapd-lab.conf  — an OWNED-lab rogue AP on a synthetic SSID
interface=wlan0           # an AP-mode interface (hwsim radio on V, owned adapter on P)
driver=nl80211
ssid=Lab-Rogue-01         # synthetic lure name — NEVER a real network's SSID
hw_mode=g
channel=6
wpa=2
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP
wpa_passphrase=Lab-WiFi-Passw0rd!
```

```bash
sudo hostapd /tmp/hostapd-lab.conf      # beacons start; your client should now SEE "Lab-Rogue-01"
```

An **open** lure drops the `wpa*`/`rsn_*` lines. To go beyond static beacons — responding to a client's probes for networks in its PNL — you swap `hostapd` for **`hostapd-mana`**, which is a drop-in fork that adds the KARMA/MANA behaviours lesson 09.4 covers; the base config above is the same.

### Tooling

- **`hostapd`** — the standard user-space AP daemon; one config file makes an open, WPA2, or WPA3 BSS. The honest baseline rogue AP.
- **`hostapd-mana`** — SensePost's fork adding KARMA/MANA probe-response and PNL logic (lesson 09.4); behaves as `hostapd` until you enable its options.
- **`airodump-ng` / Kismet** — confirm your beacon is on the air and on the right channel (your side), and later the blue-team view (lesson 09.5).
- **`dnsmasq`** (or `hostapd`'s DHCP helpers) — hands the associated client an address once it joins, needed before a captive portal (lesson 09.3) can show anything.

> [!NOTE]
> `hostapd-mana` is built from source or a distro package; option names evolve. Treat a renamed option as a troubleshooting exercise — read the installed binary's example config, not an old blog. Versions are `VERIFY` in `TOOLS.md`.

### Verification & expected evidence

You have a working rogue AP when: `hostapd` reports the interface entering `AP-ENABLED`, a survey shows your BSSID/SSID on your channel, and your **controlled** client lists the network. You have an *associated* client — a much stronger claim — only when `hostapd` logs an `AP-STA-CONNECTED <client-MAC>` line and (for a PSK lure) the 4-way handshake completes. The two pieces of evidence are different, and lesson 09.2's success criteria turn entirely on the second one.

### Why it may fail

- **No AP-mode support** — the adapter/driver can monitor or inject but not run `hostapd`; AP mode is a separate capability (glossary). Use a hwsim radio or an AP-mode-capable adapter.
- **Client never sees it** — wrong channel, too low TX power, or the client is band-locked to 5/6 GHz while you beacon on 2.4 GHz.
- **Client sees but will not join** — the entire subject of lessons 09.2 and 09.4; the client's saved-network and auto-join behaviour decides this, not your beacon.
- **Regulatory block** — `hostapd` refuses a channel disallowed by your regulatory domain; set it correctly (`iw reg`).

### Impact

On its own, a rogue AP that no client joins has **no impact** — it is a beacon in the air. Impact arises only once a client associates, and then it is bounded by what the rogue can do with that association: serve a captive portal (social engineering, lesson 09.3), relay or inspect traffic, or harvest an enterprise credential (Module 11). Stating "I stood up an evil twin" is not a finding; "client X auto-joined my rogue and I captured Y" is. This lesson gives you the first half honestly so the next lessons can qualify the second.

### Remediation & blue-team view

Because the SSID is unauthenticated, you cannot stop someone from *broadcasting* a rogue — the defence is detection plus client policy (lesson 09.5): a **wireless IDS** that flags unexpected BSSIDs/SSIDs and signal anomalies, **client policies** that disable blind auto-join and prefer validated networks, and, where the medium allows it, network-side identity (enterprise server-cert validation, WPA3-SAE). The measurable control for the rest of the module is whether a **hardened client declines to associate** with the rogue at all.

## Hands-on

### Guided walkthrough — stand up a controlled rogue AP and prove the easy/hard split (paths V / P)

1. **V (`mac80211_hwsim`):** bring up two hwsim radios ([03.3](../module-03/lesson-03.md)); run `labs/common/hwsim-up.sh`. Start `hostapd` with the synthetic WPA2 config above on one radio. Confirm `AP-ENABLED` and that a `wpa_supplicant` client on the second radio *lists* `Lab-Rogue-01`.
2. **Observe the easy half:** from a third monitor interface (or `iw`/`airodump-ng`) confirm your beacon and BSSID are on channel 6. The AP exists — this took one config file.
3. **Attempt the hard half:** point your controlled client at `Lab-Rogue-01` with the matching passphrase and watch `hostapd` log `AP-STA-CONNECTED`. Note that *you configured the client to join* — nothing made it join on its own. That gap is lessons 09.2/09.4.
4. **P (owned gear):** repeat on an AP-mode-capable adapter against your own client, at minimum TX power, on a quiet channel. Record the RF note: real range and interference now matter, unlike on V.

### Lab

> [!NOTE]
> **Lab paths:**
> V (`mac80211_hwsim` + `hostapd`/`hostapd-mana` + a `wpa_supplicant` controlled client — proves you can stand up a rogue AP and observe association logic end to end; a controlled client is **required**. Does **not** reproduce real RF, range, driver, or interference behaviour).
> P (owned AP-mode adapter + an owned controlled client — the only path that proves a rogue AP transmitting over real RF, with real range/TX-power behaviour).
> **Start state:** V — hwsim radios up ([03.3](../module-03/lesson-03.md)); `hostapd`/`hostapd-mana` installed. P — AP-mode-capable adapter verified, regulatory domain set, one owned controlled client. Synthetic SSID `Lab-Rogue-01`, passphrase `Lab-WiFi-Passw0rd!`.
> **Duration:** ~25 min (V) / ~40 min (P).
> **Artifacts:** a `hostapd` config file (synthetic SSID); the `AP-ENABLED` log line; a survey entry showing your BSSID/SSID/channel; a `hostapd` `AP-STA-CONNECTED` line for your own client; a one-line note separating "AP is on air" from "client associated".
> **Success criteria:** you stand up the rogue AP and demonstrate your controlled client *can* associate **and** you can articulate why association was something you configured, not something the beacon compelled — the easy/hard split. (A hardened client that you then set to not auto-join and which does **not** associate is an equally valid, fuller result.)
> **Troubleshooting:** `hostapd` won't start (AP mode unsupported — use a hwsim radio or AP-mode adapter; or channel blocked by reg domain — `iw reg set`); client doesn't list the SSID (wrong channel/band, TX power too low); no `AP-STA-CONNECTED` (passphrase mismatch, or client band-locked).
> **Cleanup:** stop `hostapd`/`hostapd-mana` and any DHCP helper; `../../labs/common/reset-lab.sh` returns interfaces to managed mode and removes `/tmp/hostapd-lab.conf`; on V, `../../labs/common/hwsim-down.sh`.

> [!WARNING]
> **LAB TARGET vs REAL NETWORK:** the only SSID you may advertise is a **synthetic** one (`Lab-Rogue-01`), and the only client you may attract is one **you own**. Never clone a real network's SSID/BSSID or try to attract devices you do not own — that is the evil-twin case restricted to owned equipment ([00.3](../module-00/lesson-03.md)), and against strangers it is unlawful interference/impersonation. Prefer the virtual path for transmit-heavy practice.

## Exercise

A junior tester writes in a draft report: "I set up an evil twin of the client's corporate SSID in the car park and the network appeared on my phone's Wi-Fi list, confirming the corporate wireless is vulnerable to evil-twin attacks." Identify what is wrong with this as both a safety/scoping matter and a technical claim, and rewrite the sentence so it states only what was actually demonstrated.

<details>
<summary>Hint</summary>

Two separate problems. First: was advertising the *real* corporate SSID in a public car park within scope, and what devices could it have affected? Second: what does "appeared on my phone's Wi-Fi list" actually prove — that the AP broadcasts, or that any corporate client associated? Which of the module's two halves did the tester demonstrate?
</details>

<details>
<summary>Reference answer</summary>

**Safety/scoping fault:** advertising the client's *real* corporate SSID over the air in a public car park transmits beacons that any device in range can see and potentially associate with — it is not contained to the engagement and can affect uninvolved people's devices; impersonating a real ESSID this way needs explicit authorisation and, done against non-owned devices, is unlawful interference/impersonation. A proper test uses a controlled, owned client and keeps TX power and scope tight. **Technical fault:** "appeared on my phone's Wi-Fi list" proves only that the rogue AP is broadcasting — the easy half. It demonstrates nothing about whether any *corporate* client would auto-join it, which depends on client PNL/auto-join/validation behaviour (lessons 09.2/09.4) and is the half that constitutes impact. **Rewrite:** "On authorised, owned test equipment I stood up an AP advertising a test SSID; a survey confirmed it was on the air. I did not demonstrate that any client associated, so no evil-twin impact against the corporate network is established — client-association testing against a controlled corporate-profile device is the required next step."
</details>

## References

- IEEE 802.11-2020 — beacon/probe management frames and BSS establishment (`../../references/README.md`).
- [hostapd.conf reference](https://w1.fi/cgit/hostap/plain/hostapd/hostapd.conf) — AP configuration options used above.
- [SensePost hostapd-mana — KARMA/MANA theory](https://github.com/sensepost/hostapd-mana/wiki/KARMA---MANA-Attack-Theory) — the fork introduced here and used in lesson 09.4.
- [06.1 · The 4-way handshake in depth](../module-06/lesson-01.md) — what a client does once it associates with your AP.

## What you should now be able to do

- Define a rogue AP and tell an evil twin apart from an unmanaged or lure AP.
- Stand up a controlled `hostapd` rogue AP on a synthetic SSID and know where `hostapd-mana` extends it.
- Explain why broadcasting the AP is trivial and why client association — the part that creates impact — is conditional and is the subject of the rest of the module.
