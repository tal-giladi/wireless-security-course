# Module 12 labs — Modern protections & famous attacks as context

These labs are **path R throughout** — analysis and reading, not exploitation. By design, the famous
attacks in this module (KRACK, FragAttacks, Kr00k) are **not re-exploited** here: each needs conditions a
recorded or virtual setting cannot reproduce (an active man-in-the-middle during a live handshake for
KRACK; an on-path injector and specific traffic for FragAttacks; a vulnerable physical chip and the
capture of a few buffered frames for Kr00k). The learning outcome is the honest professional output —
reading an advisory for its affected conditions and producing a **per-device version/chipset/behaviour
check** and a defensible verdict. This is an elective/advanced module.

> [!WARNING]
> LAB TARGET vs REAL NETWORK — any version, build, or chipset reading here is done only against your
> **own** equipment ([00.3](../../lessons/module-00/lesson-03.md)). These labs transmit nothing beyond
> ordinary local queries and **never depend on a deauth or on frame injection** — WPA3 mandates PMF, so a
> forged deauth is rejected anyway ([12.1](../../lessons/module-12/lesson-01.md)). Never run any of these
> famous attacks against a network you do not own.

## Paths and what each proves

| Lesson | R (analysis / reading / version check) | What it does NOT prove |
|---|---|---|
| 12.1 PMF / 802.11w | classify a BSS as PMF required/capable/absent from RSN Capabilities; state cleartext residue | not a live capture; not that a deauth was sent or rejected on air |
| 12.2 KRACK | turn the advisory into a supplicant/firmware patch check and a per-device verdict | not a working key-reinstallation MITM |
| 12.3 FragAttacks and Kr00k | build a FragAttacks build/advisory check and a Kr00k chipset-then-firmware check | not a working injection or clear-key frame capture |
| 12.4 CVE → check | extract affected conditions from an advisory and produce a per-device verdict | not exploitation of any flagged flaw |

## Tools

Wireshark/`tshark` (read RSN Capabilities / PMF bits from a capture — [TOOLS.md](../../TOOLS.md)); local
version/identity commands on **owned** devices (`wpa_supplicant -v`, `hostapd -v`, OS build info, firmware
strings, Wi-Fi chipset identification); a browser to read primary advisories (NVD/MITRE, vendor bulletins,
the KRACK/FragAttacks/Kr00k research pages). Exact tool versions VERIFY at build.

## Starting state, artifacts, success, cleanup

- **Start:** the relevant advisory/reference open; a capture containing a beacon + association for 12.1
  (PENDING — see below); access to one owned device's version/build/chipset for 12.2–12.4.
- **Artifacts:** a PMF classification with RSN-Capabilities evidence (12.1); a written KRACK patch check +
  verdict (12.2); a FragAttacks build/advisory check and a Kr00k chipset-then-firmware check (12.3); an
  affected-conditions checklist, mapped checks, and a per-device verdict (12.4).
- **Success:** a correct, evidence-backed classification or verdict — affected / not affected / not
  determinable / not applicable. Proving a device is **not** exposed (patched build, unaffected chipset,
  PMF-required config) is a full pass, exactly as it is elsewhere in the course.
- **Cleanup:** none — nothing is transmitted or captured; local version queries on owned devices need no
  reset. Stop any capture tool you opened.

## Shipped captures

The 12.1 walkthrough references a beacon/association capture used to read **RSN Capabilities** (PMF bits).
This capture is **PENDING** a real generation run on owned equipment — see
[`../common/CAPTURES.md`](../common/CAPTURES.md) for provenance, licence, and the SHA-256 checksum that
must accompany it before shipping. Until it lands, use any WPA2/WPA3 capture that contains a beacon, an
association, and a deauth/disassoc frame. No capture in this module contains, or needs, a KRACK,
FragAttacks, or Kr00k exploitation trace — those attacks are analysed from advisories, not reproduced.
