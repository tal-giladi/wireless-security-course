---
id: "12.4"
module: 12
minutes: 20
practice_minutes: 25
prerequisites: ["12.2"]
objectives:
  - Read a wireless CVE or vendor advisory and extract its affected conditions, versions, and preconditions.
  - Convert those conditions into a concrete version or behaviour check runnable on an owned device.
  - Record a defensible per-device verdict and connect it to the scope of a wireless engagement.
volatility: implementation
sources:
  - title: "NVD — CVE record format and CVSS/affected-configuration data"
    url: https://nvd.nist.gov/vuln
  - title: "MITRE CVE — program and record structure"
    url: https://www.cve.org/
  - title: "Vanhoef — FragAttacks (worked example of a wireless advisory with CVEs and conditions)"
    url: https://www.fragattacks.com/
last_verified: "2026-10-01"
---

# 12.4 · Reading a wireless CVE and turning it into a check

The three attacks in this module (KRACK, FragAttacks, Kr00k) are all handled the same way in practice: read the advisory, extract the conditions under which it applies, and turn those conditions into a concrete check you can run on an owned device — a version comparison or an observable behaviour. This lesson generalises that habit into a repeatable method so that when the next wireless CVE lands, you can scope its real relevance to a client's equipment instead of repeating a headline.

## Why this matters

New wireless CVEs appear constantly, most of them conditional and version-specific, and clients will ask "are we affected?" about advisories this course never mentioned. The valuable skill is not memorising attacks; it is reading an advisory for its **affected conditions** — protocol, role, chipset, version range, required attacker position — and converting them into a **check** whose answer is evidence, not opinion. This is exactly what you did for KRACK (12.2) and FragAttacks/Kr00k (12.3); here you make it a method. It feeds directly into a professional engagement: the wireless methodology work covered later in Module 13 (scoping, evidence capture, impact and limitations) depends on being able to say, per device, "affected / not affected / not determinable, and here is why."

## Learning objectives

- Read a wireless **CVE or vendor advisory** and extract its **affected conditions**, **versions**, and **preconditions** (attacker position, config, interaction).
- Convert those conditions into a **concrete check** — a version comparison or an observable behaviour — runnable on an **owned** device.
- Record a **defensible per-device verdict** and connect it to the **scope of a wireless engagement**.

## Prerequisites

- [12.2 · KRACK — key reinstallation and what to verify now](lesson-02.md) — the first worked instance of advisory → conditions → check, which this lesson generalises.

## Concept

### The anatomy of a wireless advisory

A useful wireless advisory (a CVE record on NVD/MITRE, a vendor security bulletin, or a research page like FragAttacks) almost always carries the same extractable parts, even when they are buried in prose:

- **Identifier(s)** — the CVE id(s); one research name (e.g. "FragAttacks") often maps to **several** CVEs, each a distinct flaw.
- **Affected component and versions** — the protocol, the **role** (client/supplicant, AP/authenticator, or both), the **chipset or product**, and the **version range** that is vulnerable, plus the **fixed version**.
- **Preconditions** — what the attacker needs: **position** (passive-in-range, active on-path MITM, or local code execution), **network config** (e.g. non-PMF, transition mode), and any **user interaction** or specific traffic.
- **Impact** — decrypt / inject / exfiltrate / DoS / credential exposure, and how much (a few buffered frames vs full session).
- **Mitigation** — the fixed build, and any config-level trigger-reducer (segmentation, PMF, disabling a feature).

### Extracting the affected conditions

Reading for conditions means turning the prose into a short checklist of **must-all-be-true** facts. For each, ask: does my target even meet this precondition? A single unmet precondition can make the whole CVE **not applicable** — which is a finding, not a gap. Watch especially for:

- **Role mismatch** — a client-only flaw against a device used only as an AP (or vice versa).
- **Chipset/product scoping** — a bug in one chip family (Kr00k) is irrelevant to devices on other chips.
- **Config gating** — a flaw that needs non-PMF, or WPA2 transition mode, does not apply to a correctly hardened config.
- **Attacker-position gating** — an active-MITM requirement means a purely passive or remote attacker cannot trigger it.
- **Version boundaries** — "≤ X vulnerable, ≥ Y fixed"; a build at or past Y closes it.

### Turning conditions into a concrete check

Each condition becomes one of two kinds of check:

- **Version/identity check** — read a field and compare it: `wpa_supplicant -v` / `hostapd -v`, an OS build number and date, a firmware string, a chipset identifier, and the vendor advisory's fixed-version or patched-status statement. This is the most common and the most defensible.
- **Behaviour check** — observe a property instead of a version, when a version is unavailable or you want corroboration: read the **RSN Capabilities** to confirm PMF-required ([12.1](lesson-01.md)), confirm a feature is disabled, or observe in a capture that the device negotiates the hardened option (e.g. H2E, [07.3](../module-07/lesson-03.md)). Behaviour checks prove the *condition*, not the attack — you are confirming a precondition is unmet, never re-exploiting.

Write each check so its output is a recordable artifact: the field read, the threshold, and a **pass / fail / not-applicable** verdict with the evidence.

### What to verify now — a worked mini-method

Put it together as a five-step pass you can run on any new wireless advisory, against **owned** equipment only:

1. **Identify** the CVE(s) and the research name; note that one name can be many CVEs.
2. **Extract** the affected conditions into a must-all-be-true checklist (component, role, chipset, versions, preconditions).
3. **Map** each condition to a version or behaviour check on the target.
4. **Run** the checks (read versions/builds/chipset; read capability bits from a capture of your own device) — never by exploiting a third party's network.
5. **Record** the verdict per device — affected / not affected / not determinable — with the evidence and the fixed-version recommendation.

### Blue-team view

The same method is the defender's triage for an advisory flood: an inventory of **versions, roles, and chipsets** lets you answer "are we affected?" quickly and prioritise patching by real exposure, not headline severity. "Not determinable" is a legitimate, honest state (no version readable, abandoned firmware) that itself drives a decision — replace or isolate. And because many wireless flaws are gated on non-PMF or transition-mode configs, a hardened baseline (PMF-required, SAE-only) shrinks the set of advisories that apply to you at all — the vulnerable-vs-hardened principle applied to the CVE stream itself.

## Hands-on

### Guided walkthrough — advisory to check, end to end (path R)

Reading/analysis exercise: you build a check from an advisory and run it against your own device. You exploit nothing and transmit nothing beyond ordinary local queries.

1. Take one wireless advisory — reuse **Kr00k** or **FragAttacks** from [12.3](lesson-03.md), or pick a current wireless CVE from NVD — and record its CVE id(s) and research name.
2. Extract the **affected-conditions checklist**: component, role (client/AP/both), chipset/product, vulnerable vs fixed versions, attacker preconditions, and impact. Keep it to must-all-be-true bullets.
3. For each condition, write the **check**: the exact field to read or behaviour to observe, and the threshold. Mark which are version/identity checks and which are behaviour checks.
4. Run the checks against **one owned device**: read its version/build/chipset, and where relevant read a capability bit (e.g. PMF-required) from a capture of your own network.
5. Record a one-paragraph **verdict**: affected / not affected / not determinable, the evidence for each unmet or met condition, and the fixed-version or config recommendation. Note which single condition, if any, settled it.

> [!NOTE]
> **Lab paths:** R only (read an advisory, build a check, and run version/behaviour queries against an owned device — no exploitation of any attack). This is deliberately a methodology lab, not an attack: the point is a defensible per-device verdict from advisory conditions, and the famous attacks of this module are not re-run.
> **Start state:** one chosen advisory open (Kr00k, FragAttacks, or a current NVD wireless CVE); access to one owned device's version/build/chipset and, optionally, a capture of your own network ([TOOLS.md](../../TOOLS.md)).
> **Duration:** ~25 min.
> **Artifacts:** the affected-conditions checklist, the mapped checks (version and behaviour) with thresholds, and a one-paragraph per-device verdict with evidence.
> **Success criteria:** a complete, defensible verdict (affected / not affected / not determinable) traceable to specific conditions and readings — *not* any demonstration of an attack.
> **Cleanup:** none — nothing transmitted beyond local queries on your own device; no check here depends on a deauth or on frame injection ([00.3](../module-00/lesson-03.md)).

## Exercise

A client forwards you a brand-new wireless CVE you have never seen, with the message "a scanner flagged this — are we affected?" The advisory says the flaw is in a specific AP firmware's handling of a management frame, requires the attacker to be associated to the network first, and is fixed in a firmware build newer than what three of the client's APs run. Lay out the exact conditions you would extract, the checks you would build from them, and the possible verdicts — without claiming to have run the attack.

<details>
<summary>Hint</summary>

Turn the advisory into a must-all-be-true list: which product/role, which versions, and what the attacker must already have (here, an existing association). Each becomes a check — mostly a firmware-version comparison plus a role/config confirmation. What single reading per AP settles "affected or not"?
</details>

<details>
<summary>Reference answer</summary>

**Conditions to extract:** (1) component/role — a specific **AP firmware**, so only devices acting as that AP model are in scope (client-only devices are not applicable); (2) **version boundary** — vulnerable below the fixed build, not-affected at or above it; (3) **precondition** — the attacker must **already be associated** (an authenticated-insider position), which bounds impact and means an outsider with no access cannot trigger it; (4) **impact** — whatever the management-frame mishandling causes (e.g. DoS or injection), to state severity honestly.

**Checks to build:** for each of the client's APs, a **version/identity check** — read the firmware build and compare it to the advisory's fixed build (the single reading that settles each AP); a **role/applicability check** — confirm the device is that AP model (if not, **not applicable**); and a **precondition note** — record that exploitation needs an associated attacker, which affects impact and the remediation urgency. Optionally a behaviour/config check for any hardening that further gates it.

**Possible verdicts, per AP:** the three APs on the older firmware → **affected** (evidence: build below the fixed version, correct model, insider precondition noted) → recommend the firmware update and, interim, tighten who can associate/segment the network; any AP already on the fixed build → **not affected** (evidence: build at or above fixed); any device that is not that AP model → **not applicable**. If a firmware build cannot be read, the honest verdict is **not determinable** → treat as potentially affected and update or isolate. At no point do you run the attack — the verdict rests on readings against the client's owned equipment and the advisory's conditions, which is exactly what a Module 13 engagement needs to record.
</details>

## References

- [NVD — vulnerability database](https://nvd.nist.gov/vuln) — CVE records with affected-configuration and CVSS data to read conditions from.
- [MITRE CVE](https://www.cve.org/) — the CVE record structure and how one research name maps to multiple CVE ids.
- [FragAttacks — fragattacks.com](https://www.fragattacks.com/) — a worked example of an advisory carrying several CVEs, conditions, and fixed versions.
- [12.2 · KRACK](lesson-02.md) and [12.3 · FragAttacks and Kr00k](lesson-03.md) — the worked instances this method generalises.
- [12.1 · PMF and 802.11w](lesson-01.md) — behaviour checks (RSN Capabilities / PMF-required) and config gating of many advisories.

## What you should now be able to do

- Read a wireless CVE or advisory and extract its affected conditions, versions, and attacker preconditions as a must-all-be-true checklist.
- Convert each condition into a version or behaviour check runnable on owned equipment, distinguishing confirming a precondition from exploiting the flaw.
- Record a defensible per-device verdict (affected / not affected / not determinable) with evidence, ready to feed a wireless engagement.
