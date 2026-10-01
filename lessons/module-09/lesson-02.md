---
id: "09.2"
module: 9
minutes: 24
practice_minutes: 45
prerequisites: ["09.1"]
objectives:
  - State evil-twin success as a conditional claim tied to a specific client behaviour, never as universal.
  - Enumerate the client factors that decide the outcome — PNL, auto-join, saved-network security, MAC randomisation, OS version.
  - Demonstrate one controlled client that is vulnerable and one hardened client that is not, and record the evidence.
volatility: implementation
sources:
  - title: "IEEE 802.11-2020 — association, RSN, and Protected Management Frames (802.11w)"
    url: https://standards.ieee.org/ieee/802.11/7028/
  - title: "SpecterOps — Modern Wireless Tradecraft Pt II (client association behaviour, known-beacon)"
    url: https://specterops.io/blog/2019/11/04/modern-wireless-tradecraft-pt-ii-mana-and-known-beacon-attacks/
  - title: "Apple Support — Wi-Fi private (randomised) address behaviour"
    url: https://support.apple.com/en-us/102509
last_verified: "2026-10-01"
---

# 09.2 · Evil twin — conditional on client behaviour

An evil twin only ever succeeds against a client that chooses to join it, so every claim in this lesson is framed the only honest way: "a client that does X is vulnerable to Y," never "evil twins work." This lesson enumerates the client-side factors that decide the outcome — what is in the preferred-network list, whether auto-join is on, the security of the saved network being impersonated, MAC randomisation, and OS version — and has you demonstrate one controlled client that associates with the twin and one hardened client that refuses, with the evidence for each.

> [!WARNING]
> An evil twin impersonates an SSID and transmits over the air to attract clients. In this course you impersonate **only a synthetic SSID of a network you own** and attract **only a controlled client you own**. Never clone a real/third-party ESSID or attempt to draw devices you do not own — that is unlawful impersonation and interference ([00.3](../module-00/lesson-03.md)). Prefer the virtual path; keep TX power minimal on the physical path.

## Why this matters

The single most common error in rogue-AP reporting is the universal claim — "the network is vulnerable to evil-twin attacks" — stated with no reference to which client, in which configuration, running which OS. It is both imprecise and usually wrong: a modern, hardened client frequently will not join a twin at all, while a laptop with a saved open network and auto-join enabled joins instantly. Because the vulnerability lives in the **client**, not the network's air, a tester who cannot name the client condition is not describing a real finding. This lesson trains the conditional framing that makes an evil-twin result credible and the measurement that distinguishes a vulnerable client from a hardened one.

## Learning objectives

- State evil-twin success as a **conditional** claim tied to a named client behaviour — never universal.
- Enumerate the client factors: **PNL contents**, **auto-join**, **saved-network security**, **MAC randomisation**, **OS version**, and **PMF**.
- Demonstrate **one vulnerable** controlled client and **one hardened** client, and record which condition decided each.

## Prerequisites

- [09.1 · Rogue-AP mechanics and lures](lesson-01.md) — you must be able to stand up a controlled rogue AP before you can test which clients join it.

## Concept

### How the protocol works

A client maintains a **Preferred Network List (PNL)**: SSIDs it has joined and, depending on the OS and per-network setting, will **auto-join** when it sees them again. When a client sees a beacon or gets a probe response for an SSID in its PNL, it may associate automatically — and 802.11 gives it no way to confirm the AP's *identity*, only that the SSID string and advertised security match. An evil twin wins when it presents an SSID the target's PNL contains, with a security configuration the client's saved profile accepts, and the client's policy permits auto-join. If the real AP is also present, the client generally prefers the stronger signal, so an evil twin often pairs with getting closer, raising power (within scope), or — on non-PMF networks only — nudging the client off the real AP; on PMF-protected networks that nudge is rejected (below), so the twin must simply be more attractive or wait.

### Why the weakness exists

The weakness is that for **open** and **WPA2-PSK** saved networks the client authenticates the *network secret*, not the *AP identity*. An open saved network has no secret at all, so any same-SSID AP is acceptable — the worst case. A WPA2-PSK saved network is better: to complete the 4-way handshake the twin must know the PSK, so a twin without the passphrase fails the key exchange and the client does not fully associate (this is why PSK evil twins are usually paired with a captive-portal lure that asks the user for the passphrase — lesson 09.3 — rather than a silent join). WPA3-SAE and enterprise EAP add mutual/network authentication that a credential-less twin cannot satisfy. So the saved network's security mode is decisive: open is trivially twinned, PSK is twinned only with the key (or social engineering), SAE/enterprise resist a credential-less twin.

### Prerequisites & affected configurations

Frame each as a client condition:

- **A client with an open network in its PNL and auto-join on** is vulnerable to a silent same-SSID join — the classic case.
- **A client with a WPA2-PSK network saved** is vulnerable to a *full* join only if the twin knows the PSK; otherwise the handshake fails (partial association), which is still enough to present a captive portal on some stacks but is not a confidentiality break.
- **A client with directed probing and no/weak MAC randomisation** leaks its PNL, telling the attacker which SSIDs to twin (ties into KARMA/MANA, lesson 09.4).
- **A client with MAC randomisation and passive-only scanning** leaks little and is harder to profile — randomisation is a *privacy/profiling* defence, not an anti-join control by itself.
- **A WPA3/PMF client** cannot be forced off its real AP by deauth; the twin must out-compete or wait.
- **OS version matters:** current iOS/iPadOS and Android default to per-network MAC randomisation and reduced directed probing, and prompt before joining many networks; older OSes probe more and auto-join more freely. State the OS and version in any finding.

### How a tester recognises it

You recognise a *vulnerable* client when, with the twin on the air, the client associates without user action — `hostapd` logs `AP-STA-CONNECTED <client-MAC>` and (open) traffic begins, or (PSK with known key) the handshake completes. You recognise a *hardened* client when, under the same conditions, it stays on its real AP, prompts the user, or declines — no `AP-STA-CONNECTED`, or an association that fails at the key exchange. The recognisable signal is always at the client, which is why the finding names the client.

### Manual method

On an owned lab, with the controlled rogue AP from 09.1 on a **synthetic** SSID that your test client has saved:

```bash
# 1. Twin a synthetic OPEN SSID your controlled client has saved as open + auto-join:
#    hostapd config: ssid=Lab-Open-01  (no wpa* lines)
sudo hostapd /tmp/hostapd-lab.conf
#    Watch for:  AP-STA-CONNECTED <your-client-MAC>   <- vulnerable client joined on its own

# 2. Twin a synthetic WPA2-PSK SSID WITHOUT the key:
#    hostapd config: ssid=Lab-PSK-01  wpa=2 ... wpa_passphrase=WRONG-KEY
#    Your client attempts association; the 4-way handshake FAILS -> no full join.
#    (With the correct synthetic key it completes — you own both sides.)
```

You never send a deauth at a PMF/WPA3 client expecting it to drop — on those it is rejected (lesson 06.2), and the lab must not depend on it.

### Tooling

- **`hostapd` / `hostapd-mana`** — present the twin; `hostapd` logs `AP-STA-CONNECTED`/key-exchange results that are your evidence.
- **`wpa_supplicant`** — your controlled client; its config file is where you set a network as open vs PSK, auto-join on/off, and (where supported) MAC randomisation, so you can build both the vulnerable and hardened clients.
- **`airodump-ng` / Kismet** — observe the client's probe behaviour (does it leak its PNL?) to reason about profiling.
- **A real controlled device** (owned phone/laptop) on the physical path — to see genuine OS auto-join prompts and randomisation defaults.

> [!NOTE]
> Client behaviour is **`volatility: implementation`**: OS auto-join, probing, and randomisation defaults change release to release (current iOS/Android randomise per network and probe less than older versions). Re-verify against the client's actual OS version at test time; do not generalise from one device to "all clients."

### Verification & expected evidence

The vulnerable result is a `hostapd` `AP-STA-CONNECTED` for your client on the twinned SSID with no user action (open), or a completed handshake (PSK, known key). The hardened result is the **absence** of that line under identical conditions, plus a client-side log/screenshot showing it stayed on the real AP, prompted, or failed the key exchange. Capture both: the finding is the *difference* between the two clients, and the evidence must name each client's OS/version and relevant settings (auto-join, saved security, randomisation).

### Why it may fail

- **Saved network is PSK and you lack the key** — the full join fails at the handshake; a silent evil twin does not work (this is a *feature* of PSK and a reason to pivot to lesson 09.3's consented portal on owned gear, not a crypto break).
- **Client is WPA3/enterprise** — mutual/network authentication the twin cannot satisfy; it declines.
- **PMF prevents the nudge** — you cannot deauth the client off its real AP; wait or out-compete, never rely on deauth.
- **Modern OS defaults** — reduced directed probing and join prompts mean no silent join; the correct conclusion may be "this client is not vulnerable," which is a full result.
- **Real AP simply stronger** — the client prefers the better signal; within scope you may reposition, but never escalate power unlawfully.

### Impact

When a vulnerable client does join, the impact is whatever the twin can then do with that association — observe/relay cleartext, redirect to a captive portal (lesson 09.3), or, for enterprise, attempt credential capture (Module 11). The impact is **bounded by the client condition that allowed the join**: a one-off open-network auto-join on a guest device is lower impact than a managed laptop silently joining a twinned corporate open SSID. Always state impact as "client X, in configuration Y, joined and therefore Z" — never as a property of the network alone.

### Remediation & blue-team view

Because the vulnerability is client-side, the controls are **client policy** (lesson 09.5): disable auto-join for open and for sensitive networks, delete stale PNL entries, prefer networks with network authentication (WPA3-SAE, enterprise with server-cert validation), keep OS versions current (for reduced probing and better randomisation), and keep MAC randomisation on to resist profiling. Network-side, moving guests off open to OWE improves confidentiality but — as Module 7 stressed — does **not** stop an active same-SSID rogue; only network authentication does. The hardened-client measurement (it does not auto-join the twin) is exactly what the blue team should be able to demonstrate.

## Hands-on

### Guided walkthrough — vulnerable client vs hardened client (paths V / P)

1. **Build the vulnerable client.** Configure a `wpa_supplicant` (V) or an owned device (P) with a **synthetic open** SSID saved and auto-join enabled. Record OS/version and settings.
2. **Build the hardened client.** A second `wpa_supplicant`/device with auto-join **off** for open networks, no stale open entries, MAC randomisation on, current OS. Record settings.
3. **Present the twin.** Start the 09.1 rogue AP on the synthetic open SSID. Observe `hostapd`: the vulnerable client logs `AP-STA-CONNECTED` on its own; the hardened client does **not**.
4. **PSK contrast.** Repeat with a synthetic WPA2-PSK SSID and a *wrong* key: watch the handshake fail for both clients — a silent PSK twin needs the key. (With the correct synthetic key, owned both sides, it completes.)
5. **PMF note.** If testing the nudge, confirm that against a PMF client your deauth is rejected and the lab does not depend on it — you wait or out-compete instead.
6. Write the two-row result: client, OS/version, saved-network security, auto-join, randomisation, and outcome (joined / declined) with the evidence line.

### Lab

> [!NOTE]
> **Lab paths:**
> V (`mac80211_hwsim` + `hostapd` + two `wpa_supplicant` clients — proves the association *logic*: a vulnerable config joins, a hardened config declines; a controlled client is **required**. Does **not** reproduce real OS auto-join UX, real randomisation defaults, RF, or range).
> P (owned AP-mode adapter + two owned controlled clients, ideally real devices — the only path that shows genuine OS auto-join prompts, randomisation defaults, and RF/signal competition with a real AP).
> **Start state:** V — hwsim radios up ([03.3](../module-03/lesson-03.md)); 09.1 rogue AP working. P — AP-mode adapter + two owned clients; reg domain set. Synthetic SSIDs `Lab-Open-01` / `Lab-PSK-01`, passphrase `Lab-WiFi-Passw0rd!`.
> **Duration:** ~30 min (V) / ~45 min (P).
> **Artifacts:** a two-client comparison table (client, OS/version, saved security, auto-join, randomisation, outcome); `hostapd` logs showing `AP-STA-CONNECTED` for the vulnerable client and its **absence** for the hardened one; a note of the PSK handshake failing without the key.
> **Success criteria:** you show **one client that associates** with the twin because of a named condition (open + auto-join) **and one hardened client that does not auto-join** the twin under identical conditions, each with evidence and the client condition that decided it. Concluding "the hardened client is not vulnerable" is a full pass — a successful silent join is **not** required.
> **Troubleshooting:** vulnerable client won't join (SSID/security mismatch with its saved profile; auto-join actually off; real AP stronger); PSK twin never fully joins (expected without the key); nothing logs (wrong channel/band; TX too low on P); deauth has no effect (PMF — expected, do not depend on it).
> **Cleanup:** stop `hostapd`/helpers; forget the synthetic SSIDs on your test devices; `../../labs/common/reset-lab.sh`; on V, `../../labs/common/hwsim-down.sh`.

> [!CAUTION]
> Use **synthetic** SSIDs and **owned** clients only. The twin must never carry a real network's name, and you must never attempt to attract a device you do not own. Impersonating a real ESSID over the air to third-party devices is unlawful ([00.3](../module-00/lesson-03.md)).

## Exercise

A report states: "Evil-twin attack succeeded; the corporate Wi-Fi is vulnerable." During the test the only device that joined the twin was a personal phone running a three-year-old OS that had the open guest SSID saved with auto-join on; two current-OS managed laptops never joined. Rewrite the finding so it is a precise, conditional claim, and list the client controls you would recommend and how you would retest each.

<details>
<summary>Hint</summary>

The vulnerability is not "the corporate Wi-Fi." Name the exact client condition that allowed the join (which SSID, which security, which setting, which OS) and say explicitly what the current-OS laptops demonstrated. Then map each control to the condition it removes, and make the retest the same vulnerable-vs-hardened comparison.
</details>

<details>
<summary>Reference answer</summary>

**Conditional finding:** "A personal device (OS version N, three releases behind) with the **open** guest SSID saved and **auto-join enabled** associated automatically with a same-SSID rogue AP. Two managed laptops on current OS with auto-join disabled for open networks did **not** join under identical conditions. The exposure is therefore specific to clients that (a) have an open network saved and (b) permit auto-join — not a property of the corporate wireless itself." **Controls:** disable auto-join for open/guest SSIDs on managed devices; remove stale open-network PNL entries; migrate guest from open to a network-authenticating option where feasible (noting OWE alone does not stop an active twin — only network authentication does); keep OS current for reduced directed probing and better MAC randomisation; where sensitive, move to WPA3-SAE/enterprise with server-cert validation. **Retest:** re-run the twin against (1) the original vulnerable device and (2) a hardened profile; success is the hardened device declining to auto-join (no `AP-STA-CONNECTED`), evidenced by the AP log and the client's state, with OS/version recorded for each.
</details>

## References

- IEEE 802.11-2020 — association, RSN, and PMF (`../../references/README.md`).
- [SpecterOps — Modern Wireless Tradecraft Pt II](https://specterops.io/blog/2019/11/04/modern-wireless-tradecraft-pt-ii-mana-and-known-beacon-attacks/) — how modern client probing/association behaviour constrains rogue-AP success.
- [Apple Support — Wi-Fi private address](https://support.apple.com/en-us/102509) — per-network MAC randomisation default, an example of OS-version-dependent behaviour.
- [06.2 · Capturing a handshake — deauth caveats](../module-06/lesson-02.md) — why you never depend on a successful deauth against PMF clients.

## What you should now be able to do

- Frame every evil-twin claim as a conditional tied to a specific client behaviour, never as a universal network vulnerability.
- Name the client factors — PNL, auto-join, saved-network security, MAC randomisation, OS version, PMF — that decide the outcome.
- Demonstrate and evidence one vulnerable client and one hardened client, and recommend the client controls that move a device from the first to the second.
