---
id: "05.1"
module: 5
minutes: 20
practice_minutes: 20
prerequisites: ["04.2"]
objectives:
  - Separate the radiotap pseudo-header your adapter adds from the 802.11 frame that was transmitted.
  - Choose between pcap and pcapng and explain what pcapng records that classic pcap cannot.
  - Explain what an hc22000 hashline is and is not, and convert a capture to it with hcxpcapngtool.
volatility: implementation
sources:
  - title: "The radiotap header specification and defined fields"
    url: https://www.radiotap.org/
  - title: "pcapng capture file format (IETF OPSAWG draft)"
    url: https://www.ietf.org/archive/id/draft-ietf-opsawg-pcapng-05.html
  - title: "hcxtools / hcxpcapngtool — conversion to hashcat formats"
    url: https://www.kali.org/tools/hcxtools/
  - title: "hashcat -m 22000 (WPA-PBKDF2-PMKID+EAPOL) hash format"
    url: https://hashcat.net/forum/thread-10253.html
last_verified: "2026-10-01"
---

# 05.1 · Radiotap and capture formats — pcap, pcapng, and hc22000

A capture file is not one thing: it is an 802.11 frame, a radiotap pseudo-header your receiver bolted on top of it, and a container format wrapping both — and the hashline you feed to a cracker is a fourth thing again, derived from the capture rather than a copy of it. This lesson pulls those layers apart so you know exactly what sits in a `.pcapng` you open, how it differs from an older `.pcap`, and why an `.hc22000` file is a cracking input, not a packet capture you can dissect.

> [!NOTE]
> Tool names, flags, and output lines below (`hcxpcapngtool`, `tshark`) change across versions (`volatility: implementation`). They match the documented behaviour at the verification date; confirm against the versions you pinned in [TOOLS.md](../../TOOLS.md). The file-format reasoning — what each layer holds — is stable even when a flag moves.

## Why this matters

Everything you analyse in this module and crack in Module 6 arrives as a file, and the single most common beginner error is confusing the layers: reporting a radiotap signal value as something the target transmitted, assuming a `.hc22000` can be opened in Wireshark, or handing a tool a classic `.pcap` and losing the per-packet annotations a `.pcapng` would have carried. Knowing which layer holds which fact is what lets you read a capture honestly, pick the right file to give each tool, and verify that a supplied capture is the one its checksum says it is before you build an afternoon of analysis on it.

## Learning objectives

- Separate the **radiotap pseudo-header** from the **802.11 frame** and say which fields live where.
- Choose between **pcap** and **pcapng**, and explain what pcapng records that classic pcap cannot.
- Explain what an **hc22000** hashline is and is not, and convert a capture to it with **hcxpcapngtool**.

## Prerequisites

- [04.2 · airodump-ng and Kismet](../module-04/lesson-02.md) — you produced channel-locked captures there; here you learn what is actually inside the files those tools wrote.

## Concept

### The layers in a monitor-mode capture

When you capture in monitor mode, each record in the file is built from the bottom up:

1. The **802.11 frame** — the bytes that were actually transmitted over the air: the MAC header (addresses, type/subtype, sequence), any payload, and the FCS. This is the frame ([01.3](../module-01/lesson-03.md)).
2. The **radiotap header** — a **pseudo-header your adapter prepends**; it is *not* transmitted over the air. It carries RF metadata about how *your receiver* heard the frame: channel frequency, data rate, antenna signal (dBm) and noise, MCS/VHT/HE info, and flags such as whether the FCS was present or bad. Its first bytes are a version, a length, and an `it_present` bitmap naming which fields follow; all little-endian.
3. The **container format** — pcap or pcapng — the file structure that stores a sequence of these records plus metadata about the capture itself.

The practical rule from [01.3](../module-01/lesson-03.md) holds throughout this module: **radiotap is how you heard the frame; the 802.11 header is the frame.** A capture's *link-layer header type* (DLT) tells you which layers are present — `IEEE802_11_RADIO` means radiotap-plus-802.11, while a plain `IEEE802_11` capture has the frames but no radio pseudo-header, so there is simply no signal or channel field to read.

### pcap versus pcapng

Both are containers for captured packets; they differ in what else they can record.

| | **pcap** (classic libpcap) | **pcapng** (next generation) |
|---|---|---|
| Structure | a global header, then one record per packet | a sequence of typed **blocks** |
| Interfaces | one link-layer type for the whole file | multiple interfaces, each described by its own block |
| Per-packet metadata | timestamp + lengths only | per-packet comments, flags, drop counts |
| Annotations | none | section/interface/packet comments embedded in the file |
| Tool support | read by essentially everything | Wireshark's default; libpcap reads a subset |

A pcapng file is organised as **blocks** appended one after another: a mandatory **Section Header Block**, an **Interface Description Block** per capture interface, and an **Enhanced Packet Block** per captured frame (the modern replacement for the old Packet Block). The payoff for an analyst is the extras: you can attach a comment to the exact frame where you spotted something, and a file can hold frames from several interfaces at once, each with its own link-layer type. Classic `.pcap` carries none of that — just packets and timestamps — which is why Wireshark writes `.pcapng` by default and you only drop back to `.pcap` for a tool that cannot read the newer format. Converting pcapng → pcap is lossy (comments and multi-interface structure are discarded); pcap → pcapng simply wraps the same frames.

### What hc22000 is — and is not

`hc22000` is **not a packet capture.** It is a **text hashline format** that hashcat's mode `-m 22000` (WPA-PBKDF2-PMKID+EAPOL) consumes. Each line is the small set of values a cracker needs, extracted from the handshake or PMKID and laid out as `*`-separated fields:

```
WPA*TYPE*PMKID-or-MIC*MAC_AP*MAC_CLIENT*ESSID*ANONCE*EAPOL*MESSAGEPAIR
```

- `WPA` is a fixed tag; `TYPE` is `01` for a **PMKID** line or `02` for an **EAPOL** (4-way-handshake) line.
- The third field is the **PMKID** (type 01) or the **MIC** (type 02) — the value the cracker must match.
- Then the **AP MAC**, **client MAC**, **ESSID in hex**, the **ANONCE**, the **EAPOL** bytes (carrying the SNONCE), and a **message-pair** bitmask.

So an `.hc22000` is a *derivative*: you cannot open it in Wireshark, it contains no radiotap and no other frames, and it holds only what mode 22000 needs to test passphrases. Think of it as the cracking-ready extract of a capture, not the capture itself — the distinction matters the moment someone asks you to "analyse the hc22000" (you analyse the `.pcapng`; you *crack* the `.hc22000`). What it still is **not** is a recovered key: a valid hashline only means crackable material was present, never that any passphrase was found (Module 6).

### Converting a capture to hc22000

`hcxpcapngtool` (from `hcxtools`) reads a `.pcapng`/`.pcap` and writes the hashline file:

```bash
hcxpcapngtool -o handshake.hc22000 wpa2-handshake-good.pcapng
```

It parses the capture, pulls any usable PMKID (type 01) and complete EAPOL message pairs (type 02), and writes one `.hc22000` line per crackable item — printing a summary of what it found (and, usefully, what it rejected as incomplete). No usable material means **no output line**, which is itself a finding: the capture did not contain a crackable handshake or PMKID. That is the bridge into lesson 05.3 (recognising a complete vs partial handshake) and Module 6 (actually cracking).

### Verifying a supplied capture

Before you trust a capture, confirm it is the exact file its provenance record describes. Every shipped capture is listed in [`labs/common/CAPTURES.md`](../../labs/common/CAPTURES.md) with how it was generated, its licence, and a **SHA-256** checksum:

```bash
sha256sum wpa2-handshake-good.pcapng        # compare to CAPTURES.md
```

> [!IMPORTANT]
> At the time of writing, every capture row in [`labs/common/CAPTURES.md`](../../labs/common/CAPTURES.md) is **PENDING**: the binaries are produced by a real `gen-captures.sh` run on the virtual path and committed with their checksums only afterward. Until then the filenames below are the ones you *will* verify — treat any checksum mismatch, or a missing file, as "do not rely on this capture yet," not as a tooling bug.

## Hands-on

### Guided walkthrough — take a capture apart, layer by layer (path R)

Recorded-data exercise: you read files we ship and transmit nothing.

1. From the module zip ([`labs/module-05/`](../../labs/module-05/)), run `sha256sum wpa2-handshake-good.pcapng` and compare it to the row in [`labs/common/CAPTURES.md`](../../labs/common/CAPTURES.md). (While captures are PENDING, note the expected-vs-actual and move on.)
2. Open the same file in Wireshark. On any frame, expand the **radiotap header** and list two fields it carries (e.g. channel, signal). Then expand the **802.11 header** below it and confirm those radiotap fields are *not* inside the transmitted frame.
3. Read the file's link-layer type (Wireshark: *Statistics → Capture File Properties*, or `tshark -r file -c1`): confirm it is radiotap-plus-802.11, so the radio fields exist at all.
4. Convert it: `hcxpcapngtool -o handshake.hc22000 wpa2-handshake-good.pcapng`. Read the summary, then open `handshake.hc22000` in a **text editor** — note it is one or more `*`-separated lines, not packets, and identify the `TYPE` field (01 PMKID / 02 EAPOL).
5. Try to open `handshake.hc22000` in Wireshark and confirm it is **not** a dissectable capture — this is the point of the lesson.

> [!NOTE]
> **Lab paths:** R (dissect + convert supplied captures — no hardware; proves you can separate the capture layers and produce a hashline, **not** that you captured anything live or that the passphrase cracks). V/P are not used — this is pure format analysis.
> **Start state:** module zip unpacked; Wireshark and `hcxtools` installed ([TOOLS.md](../../TOOLS.md)); supplied captures present (**PENDING** — see [`labs/common/CAPTURES.md`](../../labs/common/CAPTURES.md)).
> **Duration:** ~20 min.
> **Artifacts:** a note of two radiotap fields and the frame's DLT; the `hcxpcapngtool` summary line; `handshake.hc22000` with its `TYPE` field identified; the checksum comparison (or PENDING note).
> **Troubleshooting:** `hcxpcapngtool` prints no output line → the capture held no complete handshake/PMKID (expected for the partial sample — lesson 05.3); "file format not recognised" opening an `.hc22000` in Wireshark → correct, it is a hashline not a capture; no radiotap fields visible → the file's DLT is plain `IEEE802_11`, so no radio metadata was recorded.
> **Cleanup:** none — nothing transmitted or captured; delete `handshake.hc22000` if you do not want to keep it.

## Exercise

A teammate sends you a file called `target.hc22000` and asks you to "open it in Wireshark, confirm the AP's channel and signal strength, and tell me if the handshake is complete." Explain which parts of that request are impossible from this file and why, which parts you *can* answer and from where, and what file you would ask them for instead to answer the rest.

<details>
<summary>Hint</summary>

Walk the three layers. Which of them — radiotap, the 802.11 frames, the container — actually survive into an `.hc22000`? A hashline is an extract; think about what mode 22000 needs versus what it throws away.
</details>

<details>
<summary>Reference answer</summary>

An `.hc22000` is a **hashline file, not a packet capture**, so it cannot be opened in Wireshark and carries **no radiotap** — there is no channel or signal field in it at all, because those are receiver metadata mode 22000 does not use. You therefore **cannot** report the AP's channel or signal from this file. What you *can* read from the hashline itself is the **AP MAC, client MAC, and ESSID (in hex)**, and the **`TYPE` field** tells you whether the crackable material is a PMKID (`01`) or an EAPOL/handshake pair (`02`) — but a present line only proves crackable material exists, not that the handshake is "complete" in the sense of all four messages, nor that it will crack. To answer channel, signal, and handshake completeness properly, ask for the original **`.pcapng`** (ideally radiotap-plus-802.11) and verify it against its SHA-256 before analysing.
</details>

## References

- [The radiotap header](https://www.radiotap.org/) — the pseudo-header fields and the `it_present` bitmap.
- [pcapng format (IETF OPSAWG draft)](https://www.ietf.org/archive/id/draft-ietf-opsawg-pcapng-05.html) — the block structure (Section Header, Interface Description, Enhanced Packet blocks).
- [hcxtools / hcxpcapngtool](https://www.kali.org/tools/hcxtools/) and the [hashcat 22000 format](https://hashcat.net/forum/thread-10253.html) — converting a capture and the hashline fields.
- [`labs/common/CAPTURES.md`](../../labs/common/CAPTURES.md) — provenance and SHA-256 for every shipped capture (currently PENDING).
- [01.3 · The 802.11 frame](../module-01/lesson-03.md) — radiotap vs the transmitted frame, in depth.

## What you should now be able to do

- Separate the radiotap pseudo-header from the 802.11 frame and say which fields live in each.
- Choose pcap or pcapng for a given tool and explain the per-packet metadata pcapng adds.
- Explain that hc22000 is a cracking hashline (not a capture, not a key) and produce one with hcxpcapngtool.
