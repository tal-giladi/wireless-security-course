---
id: "07.2"
module: 7
minutes: 24
practice_minutes: 40
prerequisites: ["07.1"]
objectives:
  - Distinguish SAE-only from transition mode by reading the AKM list and PMF bits in a beacon.
  - Explain why transition mode, not SAE, is the real WPA3-Personal downgrade surface and how the Module 6 path reapplies.
  - Demonstrate recognising transition mode in a capture and reason about which clients remain exposed.
volatility: concept
sources:
  - title: "Wi-Fi Alliance — WPA3 Specification: WPA3-Personal transition mode"
    url: https://www.wi-fi.org/discover-wi-fi/security
  - title: "IEEE 802.11-2020 — RSN element, AKM suite selectors, RSN Capabilities (MFPC/MFPR)"
    url: https://standards.ieee.org/ieee/802.11/7028/
  - title: "hostapd configuration — SAE, WPA-PSK, sae_require_mfp, transition (wpa_key_mgmt)"
    url: https://w1.fi/cgit/hostap/plain/hostapd/hostapd.conf
last_verified: "2026-10-01"
---

# 07.2 · SAE-only versus transition mode — the real downgrade surface

SAE itself gives an attacker no offline hash (07.1) — but most WPA3-Personal networks are not deployed SAE-only. To keep older devices working they run **transition mode**: the same BSS advertises **both** WPA3-SAE and WPA2-PSK. That single compatibility choice reopens the entire Module 6 attack surface, because a client that chooses (or can be steered to) WPA2-PSK completes a WPA2 4-way handshake whose MIC is exactly the offline oracle SAE removed. This lesson separates the two deployment modes precisely, shows how to recognise transition mode in a beacon, and explains why the downgrade lives in the *configuration*, not in SAE.

## Why this matters

"We're on WPA3" is one of the most common things a client will tell you, and it is usually only half true. If the network runs transition mode, your WPA3 assessment is not finished when you confirm SAE is present — because a WPA2-PSK handshake from any legacy client on that same BSS is still capturable and still crackable with a weak passphrase, exactly as in Module 6. Missing this is how a report wrongly concludes "WPA3, no WPA2 attack applies." Getting it right lets you tell the client the true state: the strong mode is available, but as long as WPA2-PSK is advertised alongside it, the passphrase is the control that matters and the WPA2 capture path is live for any device that uses it.

## Learning objectives

- Distinguish **SAE-only** from **transition mode** by reading the AKM list and PMF bits in a beacon.
- Explain why **transition mode**, not SAE, is the real WPA3-Personal downgrade surface, and how the **Module 6** capture-and-crack path reapplies.
- Demonstrate **recognising transition mode** in a capture and reason about which clients remain exposed.

## Prerequisites

- [07.1 · SAE (Dragonfly) — why there is no offline-crackable hash](lesson-01.md) — you need to know that SAE yields no offline hash, so that you can see exactly what transition mode reintroduces.

## Concept

### How the two modes work

WPA3-Personal can be deployed two ways, and the difference is entirely in what the AP advertises in its **RSN element** and how it answers an association request:

- **SAE-only.** The AKM list contains **only SAE** (00-0F-AC:8). **PMF is Required** (MFPR set). A client must authenticate with SAE; there is no WPA2-PSK path to fall back to. This is the mode that actually delivers WPA3-Personal's security properties.
- **Transition mode.** The AKM list contains **both SAE and WPA2-PSK** (00-0F-AC:2) in the same BSS, so one network name accepts both. **PMF is Capable but not Required** (MFPC set, MFPR clear) — it must be optional, because a WPA2-PSK-only legacy client cannot do PMF-Required. A WPA3-capable client prefers SAE; a WPA2-only client associates with WPA2-PSK.

Transition mode exists for a real reason: you cannot flip an estate to SAE-only until every client supports it. But the security of a BSS is the security of its *weakest accepted* authentication, and transition mode accepts WPA2-PSK.

### Why the weakness exists

The downgrade is not a flaw in SAE and not a cryptographic break — it is a direct consequence of advertising WPA2-PSK. When any client completes WPA2-PSK on the transition-mode BSS, that association produces an ordinary WPA2 4-way handshake, whose **MIC is a function of the PBKDF2 PMK** — the exact offline oracle from [06.1](../module-06/lesson-01.md). Everything in Module 6 then applies unchanged to *that* handshake:

- capture the WPA2 handshake from a natural join ([06.2](../module-06/lesson-02.md));
- or collect a WPA2 **PMKID** if the AP offers one on the WPA2-PSK AKM ([06.3](../module-06/lesson-03.md));
- convert and crack with `hashcat -m 22000` ([06.4](../module-06/lesson-04.md)).

The passphrase is typically **shared** between the SAE and WPA2-PSK credentials on a transition-mode AP, so cracking the WPA2 handshake usually recovers the passphrase that also unlocks SAE. The SAE exchange itself was never attacked — the attacker simply used the WPA2 door the configuration left open.

> [!IMPORTANT]
> Transition mode is a **downgrade surface**, not a downgrade *attack* on SAE. An attacker does not break SAE down to WPA2; they use the WPA2-PSK path the AP already advertises, exercised by a client that speaks it. The fix is configuration (go SAE-only, or raise passphrase entropy), not a patch to SAE.

### Prerequisites & affected configurations

The WPA2 path on a transition-mode BSS is reachable only when **a client actually uses WPA2-PSK**. That means the exposure depends on the client population:

- **A WPA2-only legacy device** (old phone, IoT gadget, printer) will associate with WPA2-PSK and hand you a crackable handshake on its natural join.
- **A modern WPA3-capable client** prefers SAE on the same BSS, so its join yields an SAE exchange with no offline hash — transition mode does not downgrade a client that chooses SAE.
- An attacker cannot, on a PMF-Required SAE association, forge a deauth to force anything (07.1). Where downgrade steering is attempted at all it targets client/band selection behaviour, is conditional on client configuration, and is out of scope here — this lesson is about the *standing* WPA2 surface the AP advertises, which needs no deauth to exploit: you simply wait for a WPA2-speaking client to join.

So the honest claim is: **transition mode is exploitable to the extent that WPA2-PSK clients exist on it**, and the control is the same passphrase entropy that protects WPA2 — plus moving to SAE-only when the client base allows.

### How a tester recognises transition mode

In Wireshark, open a beacon or probe response and expand the **RSN Information** element:

- **Auth Key Management (AKM) List** — count the suites. Both **SAE (00-0F-AC:8)** *and* **PSK (00-0F-AC:2)** present = transition mode. Only SAE = SAE-only. Only PSK = plain WPA2.
- **RSN Capabilities** — check the **Management Frame Protection** bits: transition mode shows **MFP Capable** set and **MFP Required** clear; SAE-only shows **MFP Required** set.
- Confirm on the wire: on a transition BSS you will see some clients doing SAE **Authentication** (commit/confirm) and others doing **Open-System** auth then a WPA2 4-way handshake — both on the same BSSID.

`airodump-ng` is coarser here: its `AUTH` column may show `SAE` and `PSK` together (e.g. `SAE PSK` / `PSK SAE`) for a transition BSS, but the RSN element in Wireshark/tshark is the authoritative read. A quick `tshark` check:

```bash
tshark -r beacon.pcapng -Y "wlan.rsn.akms.type" \
  -T fields -e wlan.ssid -e wlan.rsn.akms.type -e wlan.rsn.capabilities.mfpr
# two AKM types (8 and 2) with mfpr=0 -> transition mode
```

### Verification & expected evidence

You have correctly identified transition mode when you can show, from the capture: (1) an RSN AKM list containing **both** SAE and PSK on one BSSID; (2) **MFP Required clear** (Capable set); and (3) at least one client completing a **WPA2 4-way handshake** on that BSSID whose `hc22000` conversion produces a hashline. SAE-only is verified by the opposite: a single SAE AKM, MFP Required set, and **no** convertible WPA2 handshake anywhere on the BSSID.

### Why it may fail (as an attacker) / holds (as a defender)

The WPA2 surface yields nothing when **no WPA2-PSK client ever associates** (every device supports and chooses SAE) — common on a modern, managed fleet even while the AP still advertises transition mode for safety. It also yields nothing useful when the **passphrase is strong** (07.1, 06.5): the WPA2 handshake is capturable but `Exhausted`. And on **SAE-only**, there is simply no WPA2 AKM to accept a handshake. These are exactly the three ways a defender removes the exposure.

### Impact

On a transition-mode network with a weak passphrase and any legacy client, the impact is identical to a WPA2-Personal compromise: offline recovery of the passphrase and therefore full access — the SAE upgrade bought nothing for that network until it goes SAE-only or the passphrase is made unguessable. On SAE-only, this entire path is closed.

### Remediation & blue-team view

Prioritised: **(1)** migrate to **SAE-only** wherever the client base supports it — this removes the WPA2 AKM and the whole surface; **(2)** until then, treat the passphrase as the control and make it high-entropy (07.1, [06.5](../module-06/lesson-05.md)), since it protects both the SAE and the transition WPA2 credential; **(3)** inventory and retire WPA2-only clients so SAE-only becomes possible; **(4)** verify the deployed mode from the air (not just the admin UI) — confirm the AKM list and MFPR bit match what you intended. 07.5 is the full configure-and-verify defence lab.

## Hands-on

This lesson supports the virtual (V) and physical (P) paths. You stand up (or inspect) a transition-mode BSS and a SAE-only BSS, recognise each from its beacon, and — on transition mode — capture a WPA2 handshake from a WPA2-speaking client's natural join and confirm it is crackable. No step requires a deauth.

### Guided walkthrough — recognise and exploit the transition surface (paths V / P)

> [!WARNING]
> The capture step is **over the air** on the physical path. Run it only against **your own** AP and **your own** test client on your [allowlist](../module-00/lesson-03.md), at minimum TX power, on a set channel, with synthetic credentials (`Lab-WiFi-Passw0rd!`). LAB TARGET, never a real network. Prefer the virtual path for transmit-free practice. No deauth is used or needed — you wait for a natural join.

1. **Bring up transition mode (V or P).** Configure `hostapd` for WPA3-Personal transition on SSID `Lab-Target-01`: `wpa=2`, `wpa_key_mgmt=SAE WPA-PSK`, `ieee80211w=1` (PMF capable, not required), `rsn_pairwise=CCMP`, `sae_password=Lab-WiFi-Passw0rd!` / `wpa_passphrase=Lab-WiFi-Passw0rd!`.
2. **Read the beacon.** Capture a beacon and, in Wireshark, confirm the RSN AKM list shows **both SAE and PSK** and that **MFP Required is clear** (Capable set). This is the recognition skill.
3. **Join with a WPA2-only client.** Point a `wpa_supplicant` profile with `key_mgmt=WPA-PSK` (no SAE) at the BSS — standing in for a legacy device. It associates over WPA2-PSK.
4. **Capture its WPA2 handshake** from that natural join (channel-locked capture, [06.2](../module-06/lesson-02.md)). Then join instead with a `key_mgmt=SAE` profile and observe that *that* client does commit-confirm with no crackable handshake.
5. **Confirm crackability.** Convert the WPA2 handshake with `hcxpcapngtool -o /tmp/trans.hc22000 cap.pcapng`; with `bounded.txt` it recovers `Lab-WiFi-Passw0rd!` ([06.4](../module-06/lesson-04.md)). This is the downgrade surface made concrete.
6. **Now switch to SAE-only** (`wpa_key_mgmt=SAE`, `ieee80211w=2`), repeat the WPA2-only client's join attempt, and record that it **cannot associate** — there is no WPA2 AKM to accept it, and no crackable handshake exists.

### Lab

> [!NOTE]
> **Lab paths:**
> V (`mac80211_hwsim` + `hostapd` transition vs SAE-only + two `wpa_supplicant` profiles — proves you can recognise each mode from the RSN element and show the WPA2 handshake is capturable/crackable on transition but absent on SAE-only; does **not** reproduce real RF, drivers, or a real AP's firmware mode handling).
> P (your own WPA3-capable AP + a WPA2-only and a WPA3 client — proves which modes your real firmware actually exposes and that a legacy client's natural join over the air yields a crackable WPA2 handshake while SAE-only refuses it).
> **Start state:** V — `hwsim` radios up; `hostapd` transition and SAE-only configs ready; `bounded.txt` built ([labs/common](../../labs/module-07/README.md)). P — your own AP set to transition then SAE-only; a controlled WPA2-only client and a WPA3 client; monitor verified ([03.4](../module-03/lesson-04.md)); regulatory domain set.
> **Duration:** ~40 min.
> **Artifacts:** an annotated beacon showing both AKMs + MFPR clear (transition) vs single SAE AKM + MFPR set (SAE-only); a WPA2 `hc22000` captured on the transition BSS and the `hashcat` recovery; a recorded "association refused — no WPA2 AKM" result on SAE-only.
> **Success criteria:** you recognise transition vs SAE-only from the RSN element; you capture and crack a WPA2 handshake from a WPA2-speaking client on the transition BSS; and you demonstrate that **the SAE-only configuration resists the downgrade** — the WPA2-only client cannot associate and no crackable handshake exists. (A successful deauth is **not** required or used.)
> **Troubleshooting:** AKM shows only SAE on your "transition" AP (you set `wpa_key_mgmt=SAE` only — add `WPA-PSK`); the WPA2-only client associates even on SAE-only (it negotiated SAE after all, or you left `WPA-PSK` in the config — check the client's `key_mgmt` and the AP's AKM list); no WPA2 handshake appears (the WPA3 client chose SAE — force the legacy profile with `key_mgmt=WPA-PSK` and `ieee80211w=0`); `hostapd` refuses `ieee80211w=1` with SAE (some builds require `=2` for SAE — set SAE-only to `=2`, transition to `=1`).
> **Cleanup:** stop `hostapd`/`wpa_supplicant`/capture tools; `../../labs/common/reset-lab.sh`; on V, `../../labs/common/hwsim-down.sh`; delete scratch `hc22000`/potfiles; restore any client profile you changed.

## Exercise

A client's IT lead tells you: "We finished our WPA3 rollout last quarter — every AP shows WPA3 in the dashboard, so the WPA2 attacks from your last engagement no longer apply and you can drop them from scope." You capture beacons and find the RSN AKM list on every AP contains both SAE and PSK, with MFP Required clear. Explain what the client actually deployed, why the WPA2 attacks are *not* out of scope, which of their devices are and are not exposed, and the two remediation steps you would put first.

<details>
<summary>Hint</summary>

Two AKMs (SAE + PSK) with PMF only capable is a specific deployment mode — which one? If a legacy client joins that BSS, which authentication does it use, and does that produce a crackable handshake? Is the SAE credential's passphrase shared with the WPA2-PSK one? What single configuration change removes the WPA2 AKM entirely?
</details>

<details>
<summary>Reference answer</summary>

They deployed **transition mode**, not SAE-only: both SAE and WPA2-PSK are advertised on the same BSS (MFP Capable, not Required). The WPA2 attacks are **in scope** because any WPA2-only client on that BSS completes an ordinary WPA2 4-way handshake whose MIC is the offline oracle from Module 6 — capturable from a natural join (no deauth needed, and PMF would reject one anyway) and crackable with `hashcat -m 22000` if the passphrase is weak. Since the SAE and WPA2-PSK credentials normally share the same passphrase, cracking the WPA2 handshake usually recovers the key that also unlocks SAE. Exposure splits by device: **WPA2-only legacy clients** (old phones, IoT, printers) use WPA2-PSK and are exposed; **modern WPA3 clients** prefer SAE on the same BSS and yield no offline hash, so they are not downgraded. First two remediations: **(1)** go **SAE-only** wherever the client base allows — this deletes the WPA2 AKM and closes the surface entirely; and until then **(2)** make the **passphrase high-entropy**, since it protects both credentials and renders any captured WPA2 handshake `Exhausted`. Also inventory and retire the WPA2-only devices so SAE-only becomes feasible, and verify the mode from the air rather than the dashboard.
</details>

## References

- Wi-Fi Alliance — WPA3 Specification: WPA3-Personal transition mode (`../../references/README.md`).
- IEEE 802.11-2020 — RSN element, AKM suite selectors, RSN Capabilities MFPC/MFPR (`../../references/README.md`).
- [hostapd.conf — `wpa_key_mgmt`, `sae_password`, `ieee80211w`](https://w1.fi/cgit/hostap/plain/hostapd/hostapd.conf) — the transition vs SAE-only settings.
- [06.1](../module-06/lesson-01.md)–[06.4](../module-06/lesson-04.md) — the WPA2 capture-and-crack path that reapplies to the transition WPA2 handshake.
- Glossary: Transition mode, SAE (Dragonfly), AKM, RSNE, MFPC / MFPR, PMF / 802.11w (`../../glossary.md`).

## What you should now be able to do

- Distinguish SAE-only from transition mode by reading the AKM list and the MFP Required bit in a beacon.
- Explain why transition mode is the real WPA3-Personal downgrade surface and how the Module 6 capture-and-crack path reapplies to a WPA2 client's handshake on it.
- Demonstrate recognising transition mode in a capture, show the WPA2 handshake is crackable there, and show that SAE-only resists it.
