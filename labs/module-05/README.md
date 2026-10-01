# Module 5 labs — Capturing & analysing 802.11

Module 5 is **pure analysis**. Every lab is the **recorded-data (R)** path: you read, filter, follow,
and convert captures we ship, and you **transmit and capture nothing**. There is no virtual or physical
lab in this module — live capture of a handshake belongs to Module 6. Because nothing is transmitted,
there is nothing to clean up and no RF risk; the only discipline is analysing **only** captures you are
authorised to hold (`../../lessons/module-00/lesson-03.md`).

> [!IMPORTANT]
> Every capture this module uses is currently **PENDING**. The binaries are produced by a real
> `gen-captures.sh` run on the virtual path (`../common/`) and committed with their SHA-256 checksums
> only after that run — see `../common/CAPTURES.md` and the captures item in `../../TODO_FOR_TAL.md`.
> Until then, drive each walkthrough on any monitor-mode capture you already have; the filenames below
> are the ones you **will** verify and use.

## In this module's zip

- This README.
- `captures/` — the supplied captures the lessons read (all listed in `../common/CAPTURES.md` with
  provenance, licence, SHA-256, and expected result). No capture is committed until it is generated and
  verified; checksums are never hand-written.
- From `../common/`: `CAPTURES.md` (the provenance/checksum register) and `gen-captures.sh` (the
  generator that produces and checksums the capture set on the virtual path).

This module ships **no** `hostapd`/`wpa_supplicant` configs of its own — it does not stand up any radio.
It consumes the captures the Module 6 generator writes.

## Captures used by this module (path R)

All are **generated in our own lab on the virtual `mac80211_hwsim` path with synthetic credentials**
(`Lab-WiFi-Passw0rd!`), CC0 / redistributable, and recorded in `../common/CAPTURES.md`. Status is
**PENDING** for the whole set until a verified generation run.

| File | Used in | What it demonstrates |
|---|---|---|
| `wpa2-handshake-good.pcapng` | 05.1, 05.2, 05.3, 05.4 | a complete join + a **complete** 4-way handshake; converts to a crackable hc22000 |
| `wpa2-handshake-good.hc22000` | 05.1 | the hashline produced from the good capture (a `TYPE 02` EAPOL line) |
| `wpa2-handshake-partial.pcapng` | 05.3 | an **incomplete** handshake — `hcxpcapngtool` writes no line; teaches recognising a bad capture |
| `wpa2-pmkid.pcapng` | 05.3 (reference) | an **RSN PMKID** in EAPOL M1 — a `TYPE 01` line, crackable without a full handshake |

> [!NOTE]
> Captures contain only synthetic SSIDs and credentials and **no real user traffic or payloads**.
> Before relying on any file, confirm it **parses**, **matches its recorded SHA-256** in
> `../common/CAPTURES.md`, and **produces the claimed result** with the pinned tool versions
> (`../../TOOLS.md`) — this is the capture-validation release check (course `CLAUDE.md`).

## What the recorded-data path proves here (and what it does not)

| Lesson | The lab proves you can… | It does **not** prove… |
|---|---|---|
| 05.1 capture formats | separate radiotap/802.11/container layers; convert a capture to hc22000; verify a checksum | that you captured anything live, or that the passphrase cracks |
| 05.2 Wireshark | navigate the dissection tree and write display filters that isolate frames | live capture, real RF, or monitor-mode hardware behaviour |
| 05.3 join & handshake | trace a join and tell a complete handshake from a partial one before cracking | capturing a handshake over the air (that is Module 6) |
| 05.4 protected vs cleartext | classify readable metadata vs protected payload and scope a claim honestly | decryption of payloads, or any live collection |

**R never grants virtual or physical capture/injection credit** (`../../curriculum/assessment-rubrics.md`).

## Tools this module needs

From `../../TOOLS.md` (record the versions you actually install):

- **Wireshark / tshark** — 802.11 dissection and display filters (05.2, 05.3, 05.4).
- **hcxtools** (`hcxpcapngtool`) — convert a capture to an hc22000 hashline (05.1, 05.3).
- **coreutils** (`sha256sum`) — verify a capture against `../common/CAPTURES.md`.

No adapter, no monitor mode, no AP, no `sudo` radio setup — this module runs entirely on a captured file
and a text editor.

## Cleanup

None. Recorded-data analysis transmits and captures nothing, so there is no service to stop and no RF to
reset. Delete any `*.hc22000` you generate and do not wish to keep; do not retain captures from networks
you do not own.
