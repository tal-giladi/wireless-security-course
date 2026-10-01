---
id: "02.3"
module: 2
minutes: 25
practice_minutes: 25
prerequisites: ["02.1"]
objectives:
  - Apply a secure wireless baseline covering segmentation, AP hygiene, firmware, WPS, client policy, and monitoring.
  - Contrast a vulnerable configuration with a hardened one for each control and state what evidence proves the difference.
  - Produce a reusable baseline checklist that later modules measure their attacks against.
volatility: concept
sources:
  - title: "IEEE 802.11-2020 standard (RSN, PMF, management-frame protection)"
    url: https://standards.ieee.org/ieee/802.11/7028/
  - title: "Wi-Fi Alliance — security (WPA3, PMF, OWE, configuration guidance)"
    url: https://www.wi-fi.org/discover-wi-fi/security
  - title: "OWASP — wireless security testing methodology reference"
    url: https://owasp.org/
last_verified: "2026-10-01"
---

# 02.3 · The secure wireless baseline

Defence does not belong only at the end of a security course, so we set the secure wireless baseline here, in Module 2, and then measure every attack in the rest of the course against it. This lesson is a checklist you will keep coming back to: segmentation, access-point hygiene, firmware maintenance, WPS configuration, client policy, and monitoring — and, for each control, the contrast between a vulnerable configuration and a hardened one, with the evidence that proves the difference.

## Why this matters

The course's teaching rule is that every major lab compares a vulnerable configuration with a hardened one and *measures* the difference — deauth succeeds without PMF and is rejected with it; a PMKID is present on one AP and suppressed on another; a rogue RADIUS captures credentials from a careless client and is refused by a careful one. None of those measurements mean anything without a baseline to measure against. By defining the baseline before you learn a single attack, you give yourself the reference point that turns "I ran a tool" into "I demonstrated that this control works." Defenders get the same value in reverse: this is the configuration you are trying to reach, and the checklist you audit against.

## Learning objectives

- Apply a secure wireless baseline across six control areas: segmentation, AP administration hygiene, firmware maintenance, WPS configuration, client policy, and monitoring/rogue detection.
- For each control, contrast a vulnerable configuration with a hardened one and name the evidence that proves the difference.
- Produce a reusable baseline checklist that later modules will reference when they measure an attack against a hardened configuration.

## Prerequisites

- Lesson 02.1 — the protocol family. The baseline assumes you can tell WPA2 from WPA3-SAE, recognise transition mode, and know what PMF does.

## Concept

This is a defence lesson, so each control is presented as a process and then as a vulnerable-vs-hardened contrast you can measure. **LAB TARGET vs REAL NETWORK:** you apply this baseline to equipment you own; auditing someone else's network needs authorisation.

### The control or process

**1. Segmentation (guest vs internal).** Put untrusted and guest clients on a separate network/VLAN from internal resources, with firewall rules between them and client isolation on the guest SSID so guests cannot reach each other. A guest network should reach the Internet and nothing else.

**2. AP administration hygiene.** Change default admin credentials; disable remote/WAN management; disable unused services (UPnP, legacy management protocols); use HTTPS/SSH for management on a management VLAN; keep an inventory of your APs and their config. The management plane is a target in its own right.

**3. Firmware maintenance.** Track firmware versions, subscribe to the vendor's advisories, and patch on a schedule — this is how KRACK, FragAttacks, and Kr00k (Module 12) get fixed in practice. An AP you never update accumulates known, published vulnerabilities.

**4. WPS configuration.** WPS PIN onboarding has a long history of flaws (Pixie Dust and online PIN brute — Module 8). Baseline: **disable WPS**, or if a device genuinely needs push-button onboarding, limit it to push-button only, time-boxed, and never leave the external PIN method enabled.

**5. Client policy.** Clients leak and misbehave as much as APs do:
- **Server-certificate validation on Enterprise** — the client must validate the RADIUS server certificate and expected identity, or it will hand credentials to a rogue server (Modules 10–11).
- **MAC randomisation** — on by default on modern OSes; it reduces passive client tracking.
- **Auto-join / preferred network list hygiene** — disable auto-join for open and sensitive SSIDs and prune the PNL, because a remembered SSID is what KARMA/MANA and evil-twin attacks exploit (Module 9).

**6. Monitoring and rogue detection.** Know your legitimate BSSIDs and SSIDs, and watch for rogue APs, evil twins, and unexpected deauth floods. Even periodic manual scans beat nothing; a WIDS/WIPS does it continuously (Module 9.5 and Module 14).

**Protocol choice underpins all of it.** Prefer WPA3-SAE with PMF required; where transition mode is unavoidable for compatibility, treat the network as only as strong as its WPA2 side and plan to retire the fallback. Use a high-entropy passphrase on any PSK network (Module 6.5). Use OWE instead of a bare Open network for public Wi-Fi, remembering OWE encrypts but does not authenticate (Lesson 02.1).

### Vulnerable vs hardened — and how to measure

| Control | Vulnerable configuration | Hardened configuration | How you measure the difference |
|---|---|---|---|
| Segmentation | Guests and internal hosts share one subnet | Separate guest VLAN, client isolation, firewall rules | From a guest client, attempt to reach an internal host: succeeds vs blocked |
| PSK strength | Short/dictionary passphrase | Long high-entropy passphrase (or WPA3-SAE) | Bounded crack succeeds vs strong-password crack does not (Module 6) |
| PMF | PMF off (WPA2 default) | PMF required | Forged deauth disconnects the client vs is rejected (Modules 6, 7, 12) |
| WPS | WPS PIN enabled | WPS disabled | Pixie Dust / PIN attack has a target vs no WPS to attack (Module 8) |
| Enterprise client | Does not validate server cert | Validates CA and server identity | Rogue RADIUS captures credentials vs client refuses and logs why (Module 11.5) |
| Firmware | Unpatched, known-CVE firmware | Current, advisory-tracked firmware | Known attack applies vs patched/not-applicable (Module 12) |
| Protocol/PMKID | WPA2-PSK, PMKID present | WPA3-SAE (no offline hash) | PMKID/handshake crackable vs nothing to crack offline (Modules 6, 7) |

Each row is a future lab. The point of the baseline is that every attack later in the course has a hardened counterpart in this table, and "the control works" is a passing result just as much as "the attack worked."

## Hands-on

### Guided walkthrough — audit a supplied AP configuration against the baseline

A reading/analysis exercise; no radio, no attack. Using the sample AP configuration and checklist in `../../labs/module-02/`:

1. Open `baseline-checklist.md` from the module zip — it enumerates the six control areas above as checkable items.
2. Open the two supplied sample configurations, `ap-config-vulnerable.txt` and `ap-config-hardened.txt` (annotated `hostapd`-style configs). For each control area, mark the checklist "vulnerable" or "hardened" and note the specific line that decides it (for example, `ieee80211w=0` vs `ieee80211w=2` for PMF, or a `wps_state` line).
3. For each item you marked vulnerable, write the one-line hardening change and the evidence you would collect later to prove the fix (pull the "how you measure" column above).
4. Save your completed checklist — you will reuse it as the reference baseline when you reach Modules 6, 7, 9, and 11.

> [!NOTE]
> **Lab paths:** R — supplied sample configurations and a checklist, no hardware (proves you can *audit* a configuration against the baseline and state the measurable difference). It does **not** prove you have hardened a live AP or measured a real attack; those happen on the V/P paths in the attack modules.
> **Start state:** `baseline-checklist.md`, `ap-config-vulnerable.txt`, `ap-config-hardened.txt` from the module zip.
> **Duration:** ~25 min.
> **Artifacts:** a completed baseline checklist marking each control vulnerable/hardened with the deciding config line and the measurement that would prove each fix.
> **Cleanup:** none (read-only analysis). If you later apply changes to an AP you own, record before/after config.

## Exercise

A small office runs one flat network: a consumer AP with WPA2-PSK (passphrase `office2021`), WPS PIN enabled for "easy printer setup," default admin password, firmware two years old, guests on the same SSID as the finance laptops, and staff phones set to auto-join the open SSID `Airport_Free_WiFi` from a business trip. Without running any attack, rank the top three changes by risk reduction and, for each, state the vulnerable-vs-hardened measurement a later lab would use to prove the fix worked.

<details>
<summary>Hint</summary>

Think about which weaknesses give an attacker the most, and which are measurable. A weak passphrase plus WPS gives offline/online key recovery; a flat network means one compromised guest reaches finance; a remembered open SSID is exactly what an evil twin needs. Each maps to a row in the vulnerable-vs-hardened table.
</details>

<details>
<summary>Reference answer</summary>

A defensible top three (order can be argued, but the reasoning and the measurements matter):

1. **Replace the weak passphrase and disable WPS** (ideally move to WPA3-SAE with PMF). `office2021` is trivially crackable and WPS PIN offers a second recovery path. *Measurement:* a bounded crack recovers `office2021` but fails against a long high-entropy passphrase; with WPS disabled, Pixie Dust/PIN attacks have no target.
2. **Segment guests from internal.** A flat network means a single compromised guest device reaches the finance laptops. *Measurement:* from a guest client, an attempt to reach an internal host succeeds on the flat network and is blocked once a guest VLAN with client isolation and firewall rules is in place.
3. **Fix client auto-join / PNL hygiene on staff phones.** A phone that auto-joins `Airport_Free_WiFi` will associate to any AP advertising that SSID. *Measurement:* an evil twin broadcasting that SSID attracts the phone before the change and is ignored after auto-join is disabled and the SSID is removed from the PNL.

Honourable mentions: change the default admin password (management-plane exposure) and update firmware (closes published CVEs). The habit to take away: every fix is paired with a concrete, measurable before/after — that is what makes a hardened configuration provable, not merely asserted.
</details>

## References

- IEEE 802.11-2020 — RSN and PMF (what the hardened protocol settings mean) (`../../references/README.md`).
- Wi-Fi Alliance — security guidance: WPA3, PMF, OWE (`../../references/README.md`).
- OWASP — wireless testing methodology, used here as a defence-audit reference (`../../references/README.md`).
- Safety and scope: `../module-00/lesson-03.md` (audit only equipment you own).
- Glossary: PMF, WPS, OWE, SAE, transition mode, rogue AP, PNL (`../../glossary.md`).

## What you should now be able to do

- Apply the secure wireless baseline across segmentation, AP hygiene, firmware, WPS, client policy, and monitoring.
- State, for each control, the vulnerable and hardened configurations and the evidence that proves the difference.
- Produce and keep a baseline checklist that the attack modules later measure their results against.
