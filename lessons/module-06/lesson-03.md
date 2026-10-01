---
id: "06.3"
module: 6
minutes: 20
practice_minutes: 35
prerequisites: ["06.1"]
objectives:
  - Explain how the RSN PMKID in EAPOL message 1 enables a capture that needs no second client, and derive what it is.
  - Qualify PMKID availability precisely — present only when the AP includes it, not universal, and not fully passive.
  - Capture a PMKID with hcxdumptool and convert it to a hc22000 hashline, recognising the detection signals you emit.
volatility: implementation
sources:
  - title: "Jens 'atom' Steube — new WPA/WPA2 attack using the RSN PMKID (hashcat forum, 2018)"
    url: https://hashcat.net/forum/thread-7717.html
  - title: "hcxdumptool / hcxtools documentation (Kali) — PMKID capture and hc22000 conversion"
    url: https://www.kali.org/tools/hcxtools/
last_verified: "2026-10-01"
---

# 06.3 · PMKID clientless capture — when it is available

The PMKID attack lets you obtain crackable WPA2 material from an access point without waiting for the 4-way handshake and without a second client present — but only when the AP chooses to include a PMKID, and never silently. This lesson derives what the PMKID is, states exactly when it is and is not available, corrects the popular myth that "clientless" means "passive and everywhere," and walks the hcxdumptool capture through to a `hc22000` hashline for lesson 06.4.

> [!WARNING]
> PMKID capture is **not passive** — you associate with or probe the target AP, which transmits and is logged. Do this only against an AP **you own**, on your [allowlist](../module-00/lesson-03.md), with the containment controls from Module 0. Associating with a network you do not own can itself be unauthorised access.

## Why this matters

PMKID capture is genuinely useful: against a vulnerable AP it collapses the capture step from "wait for a client to join" to "ask the AP once," and it needs no other station. But it is also the single most over-claimed technique in Wi-Fi tutorials, routinely presented as a passive, universal win. A professional who repeats that claim loses credibility the first time an AP returns no PMKID. Knowing precisely *when* it works — and that you are transmitting and detectable while you try — is what separates a real finding from a copied command.

## Learning objectives

- Explain how the **RSN PMKID** in **EAPOL message 1** enables a capture needing **no second client**, and derive what it is.
- Qualify availability precisely: **present only when the AP includes it**, **not universal**, and **not fully passive**.
- Capture a PMKID with **hcxdumptool**, convert it to **hc22000**, and recognise the **detection signals** you emit.

## Prerequisites

- [06.1 · The 4-way handshake in depth](lesson-01.md) — the PMK and EAPOL message 1 this attack reuses.

## Concept

### How the protocol works

To support fast roaming, some APs place a **PMKID** in the RSN element of **EAPOL message 1** — the first frame the AP sends after you associate. The PMKID is derived from the very PMK you are trying to attack:

$$\text{PMKID} = \text{HMAC-SHA1-128}(\text{PMK},\ \text{"PMK Name"} \,\|\, \text{AA} \,\|\, \text{SPA})$$

where **AA** is the AP's MAC and **SPA** your station's MAC — both of which you know. Because the PMKID is a keyed function of the PMK over known inputs, it is a **self-contained offline oracle**, exactly like the handshake MIC (lesson 06.1): guess a passphrase → compute the candidate PMK → compute the candidate PMKID → compare. A single captured PMKID is enough to attempt cracking, with **no client and no full handshake**.

### Why the weakness exists

Nothing here is a protocol break — the PMKID is a legitimate roaming optimisation. The weakness is that it hands an attacker the same crackable PMK-derived value the handshake would, but **earlier and from the AP alone**, removing the need to catch a client mid-join. As always, the PMKID exposes the PMK only to *guessing*, never directly: against a strong passphrase it is as useless to the attacker as a captured handshake (lesson 06.5).

### Prerequisites & affected configurations

PMKID capture works **only when all of these hold**:

- **The AP includes a PMKID in message 1.** This is a per-AP, per-firmware behaviour — many APs do not, some disable it, and whether it appears can depend on roaming/802.11r configuration. **It is not universal.**
- **You can associate with or probe the AP** enough to receive message 1. This means **you transmit** — PMKID capture is *not* fully passive.
- **The network is WPA2-Personal (PSK).** PMKID-from-PSK cracking targets the passphrase-derived PMK; enterprise PMKs are not passphrase-derived, and SAE (WPA3) yields no crackable PMKID of this kind.

"**Clientless**" means **no other client is needed** — you talk to the AP directly. It does **not** mean silent, passive, or universal. If the AP returns no PMKID, the technique simply does not apply and you fall back to capturing a handshake (lesson 06.2).

### How a tester recognises it

`hcxdumptool` reports when it has received a PMKID from a target, and `hcxpcapngtool` prints the PMKID hashlines it extracts. In a capture, a PMKID appears as the **PMKID field inside the RSN element of EAPOL message 1**. A quick way to know an AP is a candidate: attempt a PMKID request and see whether message 1 carries the field — absence is itself the finding ("PMKID not offered; fall back to handshake"). The `wpa2-pmkid.pcapng` sample ships so you can see a present-PMKID M1 in Wireshark (**PENDING** a verified generation run — see the lab README).

### Manual method

Conceptually: associate (or send an association/EAPOL-start) to the target AP, receive message 1, and read the PMKID from its RSN element. In practice you let `hcxdumptool` do the association and extraction rather than hand-crafting frames.

### Tooling

```bash
# Capture PMKIDs/handshakes (own AP only). Flags vary by hcxdumptool major version — check --help.
sudo hcxdumptool -i wlan1mon -w pmkid.pcapng --rds=1
# Convert to a hashcat hc22000 hashline (type 01 = PMKID, type 02 = EAPOL):
hcxpcapngtool -o pmkid.hc22000 pmkid.pcapng
# Then crack in lesson 06.4:  hashcat -m 22000 pmkid.hc22000 wordlist.txt
```

> [!CAUTION]
> `hcxdumptool` **actively engages** targets and its options change significantly between major versions (filtering to your own BSSID, enabling/disabling specific request types). Always scope it to **your own BSSID** so you do not touch neighbouring APs, and read the installed version's `--help` rather than an old tutorial (`TOOLS.md`, `volatility: implementation`).

### Verification & expected evidence

Success is a `hc22000` hashline of **type 01 (PMKID)** extracted by `hcxpcapngtool`, bound to your target's BSSID and SSID. In the module set, `wpa2-pmkid.pcapng` → `wpa2-pmkid.hc22000` is the expected clientless artifact, cracking to the bounded passphrase with `bounded.txt` (lesson 06.4). If no hashline of type 01 appears, the AP did not offer a PMKID — that is a valid, documentable outcome, not a tooling failure.

### Why it may fail

- **The AP does not include a PMKID.** The most common outcome on modern/consumer gear — fall back to handshake capture (lesson 06.2).
- **You never successfully associate/probe** the AP (range, driver, or the AP rejecting you) — no message 1, no PMKID.
- **It is WPA3-SAE or enterprise** — no passphrase-derived PMKID to crack this way.
- **Version flag drift** — `hcxdumptool` options differ; the command "does nothing" because a renamed flag silently no-ops. Check `--help`.
- **Strong passphrase** — you captured a perfectly valid PMKID and it still will not crack; that is lesson 06.5's point, not a capture failure.

### Impact

When available, PMKID capture removes the client dependency and shortens the engagement: one association to a vulnerable AP yields offline-crackable material. The downstream impact is identical to a captured handshake — bounded entirely by passphrase entropy — so the finding to report is "PMKID offered by the AP (clientless capture possible)" plus the passphrase-strength assessment, not "network broken."

### Remediation & blue-team view

Where roaming does not require it, **disable PMKID / PMK caching advertisement** (or the 802.11r features that surface it) so message 1 carries no PMKID — this removes the clientless path, though a handshake can still be captured. The decisive control, again, is a **high-entropy passphrase** that makes any captured PMKID or handshake uncrackable (lesson 06.5). Blue teams can also detect the attack's footprint: PMKID requests are **active associations/EAPOL-starts**, so a monitoring sensor or AP log sees an unfamiliar station associating and immediately leaving — a recognisable signal precisely because the technique is not passive.

## Hands-on

### Guided walkthrough — see a PMKID, then extract it (paths R / V / P)

1. **R (no hardware):** open `captures/wpa2-pmkid.pcapng`, find **EAPOL message 1**, and locate the **PMKID** field inside its RSN element. Run `hcxpcapngtool -o /tmp/pmkid.hc22000 wpa2-pmkid.pcapng` and confirm a **type-01** hashline. For contrast, run the same tool on `wpa2-handshake-good.pcapng` and note you get a type-02 (EAPOL) line instead — same mode 22000, different type.
2. **V (`mac80211_hwsim`):** stand up a WPA2 AP configured to advertise a PMKID and capture it clientless with `hcxdumptool` scoped to your BSSID; convert and confirm the type-01 hashline.
3. **P (owned gear):** point `hcxdumptool` at **your own** AP's BSSID. If it returns a PMKID, extract it; if it does **not**, record "PMKID not offered" as the finding and fall back to lesson 06.2.

### Lab

> [!NOTE]
> **Lab paths:**
> R (supplied `wpa2-pmkid.pcapng` → `wpa2-pmkid.hc22000` — no hardware; proves you can recognise and extract a PMKID and reason about its availability, **not** that you captured it live).
> V (`mac80211_hwsim` + `hostapd` advertising a PMKID + `hcxdumptool` — proves you can reproduce clientless capture end to end; does **not** reproduce real RF, drivers, range, or a real AP's firmware decision to offer a PMKID).
> P (owned adapter in monitor mode + your own AP — the only path that proves whether a real AP offers a PMKID and that you can capture it over the air).
> **Start state:** R — recorded toolchain + module zip. V — `hwsim` radios up, AP configured to include a PMKID. P — monitor verified ([03.4](../module-03/lesson-04.md)); your own AP (`Lab-Target-01` / `Lab-WiFi-Passw0rd!`); regulatory domain set.
> **Duration:** ~10 min (R) / ~25 min (V) / ~35 min (P).
> **Artifacts:** a `hc22000` type-01 PMKID hashline (or, validly, a documented "no PMKID offered" result on the physical path); a note of the detection signal you emitted (an association to the AP).
> **Success criteria:** you extract a PMKID hashline from the supplied/own-AP capture **or** correctly conclude and document that the AP offers no PMKID. Recognising that you transmitted (not passive) and scoping to your own BSSID are part of the pass.
> **Troubleshooting:** no PMKID (AP does not offer one — expected; fall back to handshake); `hcxdumptool` appears to do nothing (version flag drift — check `--help`); it touches other APs (you did not filter to your BSSID — stop and scope it); no type-01 line but a type-02 appears (you captured a handshake, not a PMKID — still crackable, different path).
> **Cleanup:** stop `hcxdumptool`/`hostapd`; `../../labs/common/reset-lab.sh`; on V, `../../labs/common/hwsim-down.sh`. Delete scratch captures.

> [!WARNING]
> **LAB TARGET vs REAL NETWORK:** only your **own** AP, scoped by BSSID, with the synthetic credentials above. `hcxdumptool` actively engages whatever is in scope — never aim it at a network you do not own. Associating with others' APs is unauthorised access, not reconnaissance ([00.3](../module-00/lesson-03.md)).

## Exercise

A junior tester writes in a report: "WPA2 is passively broken — I silently grabbed the PMKID out of the air from every nearby network without touching them, so all WPA2 is clientless-crackable." Correct this statement on three independent points, and state what an honest PMKID finding looks like for a single audited AP.

<details>
<summary>Hint</summary>

Three separate claims are bundled together: that it was *passive/silent*, that it worked on *every* network, and that WPA2 is *broken*. Which of those survive contact with how a PMKID is actually obtained and when an AP includes one? And once you have a valid PMKID, what still decides whether it yields the passphrase?
</details>

<details>
<summary>Reference answer</summary>

Three corrections: **(1) Not passive** — obtaining a PMKID requires associating with or probing the AP; you transmit and are logged, so "silently, without touching them" is false. **(2) Not universal** — a PMKID is present only when that AP's firmware/config includes it in EAPOL message 1; many APs offer none, and "every nearby network" is wrong. **(3) Not broken** — a captured PMKID is only an offline *oracle*; it yields the passphrase only if the passphrase is guessable, so WPA2 with a high-entropy passphrase is unaffected. Also, "every nearby network" means touching APs you have no authorisation for — out of bounds. An honest finding for one audited AP: "The AP includes an RSN PMKID in message 1, so clientless capture is possible (active association, detectable); the captured PMKID was/was not recoverable with the agreed wordlist, and the passphrase strength is assessed as …," with the control (entropy, disabling PMKID advertisement) recommended.
</details>

## References

- [Jens "atom" Steube — RSN PMKID attack disclosure (2018)](https://hashcat.net/forum/thread-7717.html) — the origin and the "clientless, not passive/universal" framing.
- [hcxtools / hcxdumptool (Kali)](https://www.kali.org/tools/hcxtools/) — PMKID capture and `hc22000` conversion (flags are version-volatile).
- [06.1 · The 4-way handshake in depth](lesson-01.md) — the PMK and message 1 the PMKID reuses.

## What you should now be able to do

- Explain how the RSN PMKID in EAPOL message 1 enables capture with no second client, and derive what the PMKID is.
- Qualify PMKID availability honestly: present only when the AP offers it, not universal, and not fully passive.
- Capture a PMKID with hcxdumptool, convert it to a hc22000 hashline, and name the detection signals you emit.
