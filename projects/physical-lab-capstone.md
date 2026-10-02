# Physical-lab capstone — build, attack, harden, and retest your own Wi-Fi

This is the path-P capstone: a full build-attack-harden-retest engagement against **your own** access points, test clients, and adapters. You assess WPA2-Personal (handshake and PMKID), run a WPA3 assessment, and stand up an evil-twin against a lab client — then you harden each network and **retest to show the attack now fails**. It is the only capstone that can be credited as **practical — physical RF**, and only for the steps you actually perform on real radios; any step you run on virtual radios is credited as virtual, and your report must say which was which.

> [!WARNING]
> This capstone transmits. A private subnet does **not** isolate radio — deauth, beacons, and probes leave the wire and reach every device in range, including networks you do not own. You may run it **only** against equipment you own, with a filled-in authorisation record, synthetic credentials, minimum transmit power, and the stop conditions below. If you cannot meet those conditions, do the affected steps on the **virtual path (V)** instead and credit them as virtual. Read [`../lessons/module-00/lesson-03.md`](../lessons/module-00/lesson-03.md) and fill [`../templates/authorisation-template.md`](../templates/authorisation-template.md) before you transmit anything.

> [!NOTE]
> **Lab paths:** P (physical RF) preferred; **V** (virtual `mac80211_hwsim`) wherever you lack the hardware for a step (no second adapter, no WPA3-capable AP, no injection-capable chipset). Per-path honesty is mandatory: **R and V never grant physical-capture or injection credit** ([`../curriculum/assessment-rubrics.md`](../curriculum/assessment-rubrics.md)). Record, per claim, which path proved it.

## Why this matters

Recovering a key in a lab tells you almost nothing on its own; the professional skill is the full loop — establish the weakness with evidence, change the configuration, and **prove the change worked by re-running the same attack and watching it fail**. That vulnerable-vs-hardened measurement is the heart of every major lab in this course (plan §8), and the capstone is where you run the whole loop yourself against real radios and feel what the recorded-data path can only reason about: range, interference, PMF rejecting a deauth, a correctly-configured client refusing a forged beacon.

## Prerequisites and equipment

You need owned equipment and the ability to configure it. An ordinary phone hotspot does **not** provide WPA3, WPS, or every configuration you need ([`../curriculum/lab-matrix.md`](../curriculum/lab-matrix.md) has the full matrix); plan which steps you can do physically and which fall back to V.

- An **injection/monitor-capable adapter** (see [`../curriculum/lab-matrix.md`](../curriculum/lab-matrix.md); verify per hardware revision).
- A **target AP you own** that can be set to WPA2-Personal and, for the WPA3 step, WPA3-SAE and transition mode — or `hostapd`/`mac80211_hwsim` on the V path.
- A **controlled test client** you own (real device and/or a VM supplicant), including one you can configure correctly for the evil-twin comparison.
- The pinned toolchain in [`../TOOLS.md`](../TOOLS.md): `aircrack-ng`, `hcxdumptool`/`hcxtools`, `hashcat`, `hostapd`/`hostapd-mana`, `wpa_supplicant`, `iw`, `bettercap`/`eaphammer` as applicable.

## Safety and containment (read before every offensive step)

Every offensive step in this capstone restates the same rules; they are not optional.

- **LAB TARGET vs REAL NETWORK.** You target only the SSIDs/BSSIDs on your own allowlist. Anything not on the allowlist is out of scope and must not be probed, deauthenticated, or captured ([`../templates/authorisation-template.md`](../templates/authorisation-template.md)).
- **Authorisation.** The only legitimate owner of every target here is you; the authorisation record names the equipment and the time window.
- **Synthetic credentials only** — `Lab-WiFi-Passw0rd!` for the weak case, a 20+-character random passphrase for the strong case, `LAB-FLAG-<uuid>` for any flag. Never a real secret.
- **Minimum transmission.** Lowest TX power that works, a specific channel, directional/attenuated or RF-shielded where possible. Prefer the V path for transmit-heavy work.
- **Stop conditions.** Stop immediately if any device not on the allowlist associates, is deauthenticated, or is affected; if you see interference with a neighbouring network; or at the end of the window.
- **Cleanup.** Stop `hostapd`/the rogue AP, restore the client, delete captured synthetic credentials, return adapters to managed mode, reset the regulatory domain if you changed it.

## The engagement — four parts, each build -> attack -> harden -> retest

### Part A — WPA2-Personal: handshake and PMKID

> [!CAUTION]
> Capturing a 4-way handshake usually involves deauthenticating a client to force a reconnection. Deauth transmits and affects a real device — do it **only** to your own test client on your own AP, at minimum power. On the V path, drive the association from `wpa_supplicant` instead of deauthenticating.

1. **Build (vulnerable):** configure your AP as WPA2-PSK with the weak passphrase `Lab-WiFi-Passw0rd!`, PMF disabled.
2. **Attack:** capture a complete 4-way handshake from your own client (P: monitor + optional targeted deauth; V: trigger association), and separately collect an **RSN PMKID** if the AP includes one in M1. Convert to `hc22000` and recover the passphrase with the bounded wordlist.
3. **Harden:** change to a 20+-character random passphrase and enable PMF (802.11w); where supported, suppress the PMKID.
4. **Retest:** re-capture and re-run the crack — it now runs to `Exhausted`; the forged deauth is now rejected (PMF); the PMKID is absent or no longer recovers. **Record the measurement**, not just "fixed."

### Part B — WPA3-SAE assessment

> [!CAUTION]
> Do not design this step around a successful deauth. On a PMF-enabled WPA3 network deauth is rejected by design — that rejection is a result to record, not an obstacle to defeat ([`../lessons/module-07/lesson-01.md`](../lessons/module-07/lesson-01.md)).

1. **Build:** configure WPA3-SAE-only on an AP that supports it (or V path).
2. **Assess:** show that SAE yields **no offline-crackable hash** — capturing the SAE exchange gives you nothing to feed to hashcat, and explain *why* (the Dragonfly handshake, [`../lessons/module-07/lesson-01.md`](../lessons/module-07/lesson-01.md)). If you have a transition-mode-capable AP, assess the **transition-mode downgrade surface** (SAE + WPA2-PSK advertised together) as the real weakness, distinct from SAE itself ([`../lessons/module-07/lesson-02.md`](../lessons/module-07/lesson-02.md)).
3. **Harden:** move from transition mode to **SAE-only**; note which legacy clients that drops.
4. **Retest:** confirm the WPA2 downgrade path is gone and that SAE-only still offers no crackable material. The "attack now fails" here is **demonstrating the protection works**, which is a full-credit result — no key required.

### Part C — Evil twin vs a lab client

> [!WARNING]
> An evil twin beacons a forged SSID and may deauth a client to lure it across. This is the most intrusive step — it transmits a rogue AP. Run it only against your own client on your own SSID, at minimum power, ideally shielded or on the V path. Success is **conditional on the client's configuration**; frame every claim as "a client that does X is vulnerable to Y" ([`../lessons/module-09/lesson-02.md`](../lessons/module-09/lesson-02.md)).

1. **Build (vulnerable client):** a test client configured to auto-join the SSID with no protection against a rogue AP.
2. **Attack:** stand up an evil twin of your own SSID and show the vulnerable client associating / being lured. If you include a captive portal, state plainly that capturing a passphrase there is **social engineering, not a crypto break** ([`../lessons/module-09/lesson-03.md`](../lessons/module-09/lesson-03.md)).
3. **Harden (client-side):** reconfigure the client (remove auto-join, require the correct network / server validation as applicable); for an enterprise variant, a correctly-configured client that **validates the RADIUS server certificate and rejects the rogue server** ([`../lessons/module-11/lesson-01.md`](../lessons/module-11/lesson-01.md)).
4. **Retest:** show the **hardened client refuses** the rogue AP, with the log/packet evidence explaining *why* it refused. That refusal is the result.

### Part D (optional, V-first) — Enterprise rejecting client

If you have an enterprise setup (CA + FreeRADIUS + supplicant, [`../lessons/module-10/lesson-01.md`](../lessons/module-10/lesson-01.md)), demonstrate credential capture against a client that does **not** validate the server cert, then harden to a client that does and show it rejects the rogue RADIUS with the evidence. This is first-class on the V path.

## Deliverables

1. **A completed authorisation record** ([`../templates/authorisation-template.md`](../templates/authorisation-template.md)) — your equipment as the allowlist, transmission limits and stop conditions filled in, before any transmission.
2. **A lab notebook** ([`../templates/lab-notebook-template.md`](../templates/lab-notebook-template.md)) — one entry per part, each recording **the path used (P or V)**, the commands, the artifacts with their SHA-256, and the **vulnerable-vs-hardened measurement**.
3. **A full engagement report** ([`../templates/report-template.md`](../templates/report-template.md), modelled on [the sample report](sample-report.md)) with an executive summary, scope & authorisation (including **which path proved each claim**), methodology, one finding per part, limitations, prioritised remediation, the retest results, and residual risk.

> [!IMPORTANT]
> Record, per claim, the path that proved it. If you ran Part B or C on virtual radios because you lacked a WPA3 AP or a second adapter, those claims are credited as **virtual**, not physical RF, and your scope section says so. Captures you generate get a real SHA-256 from your run; anything not yet generated is **PENDING** — never invent a checksum ([`../labs/common/CAPTURES.md`](../labs/common/CAPTURES.md)).

## Rubric (scored out of 100; pass mark 70)

Reproduced from [`../curriculum/assessment-rubrics.md`](../curriculum/assessment-rubrics.md). Obtaining a key alone is **not** a pass; the retest and the honest report carry as much weight as the attack.

| Dimension | Weight | What full credit looks like here |
|---|---|---|
| Recon & scoping | 15 | authorisation, owned-equipment allowlist, transmission limits, and stop conditions complete before transmitting; path (P/V) planned per step |
| Interpretation / analysis | 20 | each result correctly characterised — handshake vs PMKID preconditions, SAE yields no crackable hash, evil-twin success tied to specific client behaviour, PMF rejection read correctly |
| Justified technique selection | 15 | technique chosen to fit the configuration and the path; deauth not made a prerequisite on PMF/WPA3; V used honestly where P is unavailable |
| Evidence quality | 15 | real artifacts with real SHA-256 for what you generated (PENDING only where truly not generated); the "protection works" evidence (PMF reject, client refusal) captured, not asserted |
| Remediation | 15 | concrete hardening per part, each tied to a measurement that confirms it |
| Retesting / verifying the fix | 10 | the same attack re-run after hardening and shown to **fail**, with the before/after measurement recorded |
| Report incl. exec summary, limitations, residual risk | 10 | summary decision-ready; limitations state untested paths and which claims are virtual vs physical; residual risk actionable (e.g. "SAE-only set but legacy clients dropped") |

> [!IMPORTANT]
> Parts B and C can be **passed by demonstrating the protection works** — SAE offers no crackable material; the hardened client rejects the rogue AP — with no key recovered. A capstone that recovers the Part A key but never hardens or retests, or that claims virtual work as physical RF, fails. A recovered key is evidence inside a finding ([`../lessons/module-14/lesson-02.md`](../lessons/module-14/lesson-02.md)).

<details>
<summary>Marking guide (for a reviewer / instructor)</summary>

**Must appear for a pass (70+):**

- Authorisation record and owned-equipment allowlist, transmission limits, and stop conditions filled **before** any transmission; every offensive part restates LAB TARGET vs REAL NETWORK.
- Each part shows the full **build -> attack -> harden -> retest** loop with a recorded vulnerable-vs-hardened measurement (e.g. crack recovers then `Exhausted`; deauth succeeds then rejected by PMF; rogue AP lures the vulnerable client then is refused by the hardened one).
- Per-claim path honesty: the report states which claims were proved on physical RF and which on virtual radios; nothing virtual or recorded is credited as physical capture/injection.
- SAE assessed correctly: no offline-crackable hash; transition mode (if tested) identified as the real downgrade surface; deauth **not** used as a prerequisite on PMF/WPA3.
- Evil-twin framed as conditional on client behaviour; any captive portal called social engineering, not a crypto break.
- Evidence: real SHA-256 for generated artifacts; PENDING used only for genuinely ungenerated captures; "protection works" evidence captured.
- Limitations and residual risk honest and actionable; executive summary decision-ready.

**Red flags (cap the score):**

- Any claim of physical RF/injection for a step actually run on the V path.
- A key recovered with no hardening or no retest.
- Deauth treated as a required step on a PMF/WPA3 network (or a rejected deauth reported as a failed test rather than a working protection).
- Any invented checksum, or "captured" evidence that is asserted rather than shown.
- Transmission without a filled authorisation record / allowlist, or against anything not owned.
</details>

## What you should be able to show

- You can run the full build-attack-harden-retest loop against your own Wi-Fi and measure the difference the hardening made.
- You can assess WPA2 (handshake + PMKID), WPA3-SAE (no crackable hash; transition-mode downgrade), and an evil twin conditional on client behaviour — and prove each protection works after hardening.
- You can record honestly which path proved each claim, and never credit virtual or recorded work as physical RF.
