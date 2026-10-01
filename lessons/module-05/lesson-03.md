---
id: "05.3"
module: 5
minutes: 22
practice_minutes: 25
prerequisites: ["05.2"]
objectives:
  - Walk a capture from beacon through probe, authentication, association, to the 4-way handshake.
  - Identify the four EAPOL messages M1-M4 and read the nonces and MIC that each carries.
  - Tell a complete handshake from a partial one and explain why completeness decides crackability.
volatility: implementation
sources:
  - title: "Wireshark display filter reference — eapol (EAPOL-Key messages)"
    url: https://www.wireshark.org/docs/dfref/e/eapol.html
  - title: "IEEE 802.11-2020 — 4-way handshake and the association sequence"
    url: https://standards.ieee.org/ieee/802.11/7028/
  - title: "hashcat -m 22000 — what message pairs are crackable (EAPOL)"
    url: https://hashcat.net/forum/thread-10253.html
last_verified: "2026-10-01"
---

# 05.3 · Following a join and spotting the handshake

A WPA2 join is a fixed sequence you can now read end to end: the AP beacons, the client probes, the two of them run open-system authentication and association, and then — carried in data frames — the four EAPOL messages of the 4-way handshake fly past. This lesson walks that whole arc in a capture, pins down each of the four EAPOL messages and what it carries, and teaches the one judgement everything downstream depends on: whether the handshake you captured is complete enough to crack, or only a fragment that will waste your afternoon.

## Why this matters

Module 6 cracks a handshake, but it can only crack what you actually captured, and the most common failure in wireless work is confidently feeding a cracker a **partial** handshake that contains no crackable material. Being able to look at a capture and say "this is M1 and M2 only — unusable" versus "this has the message pair hashcat needs" is the difference between a clean finding and hours spent attacking nothing. The same reading skill tells you where an evil twin would inject itself, where a deauth would cut the sequence, and why the "authentication" frames prove nothing about the passphrase — all of it visible in the frames you already know how to filter.

## Learning objectives

- Walk a capture from **beacon → probe → authentication → association → 4-way handshake**.
- Identify the four **EAPOL messages M1-M4** and read the **nonces** and **MIC** each carries.
- Tell a **complete** handshake from a **partial** one and explain why completeness decides crackability.

## Prerequisites

- [05.2 · Wireshark for 802.11](lesson-02.md) — you need the dissection tree and the `eapol` / subtype filters to isolate these frames.

## Concept

### The arc of a join, as frames

Filter out the noise and a WPA2-Personal join is the sequence from [01.4](../module-01/lesson-04.md), now a short list of rows between the client and the BSSID:

1. **Beacon** (subtype 8) — the AP advertising the SSID, rates, channel, and its RSN security capabilities.
2. **Probe request / response** (4 / 5) — the client asking, the AP answering (active scan; a purely passive client skips straight from hearing a beacon to step 3).
3. **Authentication** ×2 (subtype 11) — **open-system**: a two-frame formality that verifies **no** credential and always succeeds. A capture reading "Authentication, Success" has shown you no cryptography.
4. **Association request / response** (0 / 1) — the client joins the BSS; the response carries a status code and an Association ID.
5. **The 4-way handshake** — four **EAPOL-Key** messages carried inside **data** frames, *after* association. This is where the passphrase is actually proven.

The whole of steps 1–4 is cleartext management ([05.4](lesson-04.md)); the handshake in step 5 is the part a cracker cares about.

### The four EAPOL messages

The 4-way handshake derives the session keys (the PTK) from the shared PMK without ever sending the passphrase. Four messages, which Wireshark labels **"Message N of 4"** in the Info column when you apply `eapol`:

| Msg | Direction | Carries | Why it matters to a cracker |
|---|---|---|---|
| **M1** | AP → client | **ANonce** (AP's random nonce); may carry an **RSN PMKID** | PMKID (if present) is independently crackable ([06.3](../module-06/lesson-03.md)) |
| **M2** | client → AP | **SNonce** (client's nonce) + a **MIC** over the EAPOL body | M1+M2 give the nonces and a MIC — the core crackable pair |
| **M3** | AP → client | installs the keys; includes the GTK, with a MIC | confirms the AP derived the same PTK |
| **M4** | client → AP | acknowledgement, with a MIC | confirms the client installed the key |

By M2 the client has everything to compute the PTK (it knows the PMK from the passphrase, both nonces, and both MACs); the MIC in M2 is computed with that PTK. That is exactly why **M1 + M2 together are the crackable core**: an attacker guesses a passphrase, derives a candidate PTK from the two nonces and two MACs, and checks it against the M2 MIC. hashcat's `-m 22000` consumes precisely this as a `TYPE 02` EAPOL message pair ([05.1](lesson-01.md)).

### Complete versus partial — and why it decides everything

A capture is only as useful as the message pair inside it:

- **Complete (crackable):** you have a consistent **M1 and M2** (or a captured **PMKID** in M1) for the same AP/client/ANonce/SNonce. `hcxpcapngtool` extracts a `.hc22000` line; hashcat can test passphrases. Having M3/M4 as well is reassuring but the M1+M2 (or M2+M3) pairing is what carries the crackable MIC.
- **Partial (not crackable):** you have, say, only M1 (an ANonce and nothing to check it against), or messages from mismatched attempts, or EAPOL frames whose MIC covers a handshake you did not fully capture. `hcxpcapngtool` emits **no line** — not because the tool failed, but because there is nothing to crack. This is a legitimate, common outcome: the client finished associating before you locked the channel, a deauth cut the exchange, or the retransmissions never lined up.

> [!IMPORTANT]
> "I captured a handshake" is not a result until you have confirmed a usable message pair. Reading `eapol` and seeing *some* EAPOL frames is not enough — check that M1 and M2 belong to the **same** AP/client with matching nonces, or let `hcxpcapngtool` make the call by whether it writes a hashline. A partial handshake that *looks* captured is the single biggest time sink in Module 6.

You will compare the two directly in the lab: a **good** capture that converts and (in Module 6) cracks to the synthetic `Lab-WiFi-Passw0rd!`, and a **partial** capture that correctly yields nothing. Learning to tell them apart *before* cracking is the point.

## Hands-on

### Guided walkthrough — walk a join, then judge the handshake (path R)

Recorded-data exercise: you read captures we ship and transmit nothing.

1. From the module zip ([`labs/module-05/`](../../labs/module-05/)), open `wpa2-handshake-good.pcapng`. (Captures are **PENDING** — [`labs/common/CAPTURES.md`](../../labs/common/CAPTURES.md); until then, use any WPA2 join capture you have.)
2. Reconstruct the arc: filter management frames and find, in order, a **beacon**, the **probe** exchange, the two **authentication** frames, and the **association** request/response between your client and the BSSID.
3. Apply `eapol`. Confirm the Info column shows **Message 1 of 4 → 4 of 4**. Expand **M1** and read the **ANonce** (and note whether an **RSN PMKID** is present); expand **M2** and read the **SNonce** and the **MIC**.
4. Convert: `hcxpcapngtool -o good.hc22000 wpa2-handshake-good.pcapng`. Confirm it writes a `TYPE 02` (EAPOL) line — a crackable pair.
5. Now open `wpa2-handshake-partial.pcapng` and repeat steps 3–4. Note which EAPOL messages are missing or mismatched, and confirm `hcxpcapngtool` writes **no** hashline. Write one sentence on *why* this capture is unusable.

> [!NOTE]
> **Lab paths:** R (walk and judge supplied captures — no hardware; proves you can trace a join and tell a complete handshake from a partial one, **not** that you captured either live). V/P not used here — capturing a live handshake is Module 6.
> **Start state:** module zip unpacked; Wireshark and `hcxtools` installed ([TOOLS.md](../../TOOLS.md)); the **good** and **partial** captures present (**PENDING** — [`labs/common/CAPTURES.md`](../../labs/common/CAPTURES.md)).
> **Duration:** ~25 min.
> **Artifacts:** an ordered list of the join frames; the ANonce/SNonce/MIC you read from M1/M2; the two `hcxpcapngtool` results (one hashline, one none); one sentence explaining why the partial capture is unusable.
> **Troubleshooting:** `eapol` shows fewer than four messages → likely a partial capture (that is the lesson, not a bug); nonces look unrelated between M1 and M2 → mismatched attempts, not a single usable handshake; `hcxpcapngtool` silent on the good file → confirm you opened the good capture and that it verified against its checksum; "Authentication, Success" mistaken for the key check → that is open-system, see [01.4](../module-01/lesson-04.md).
> **Cleanup:** none — nothing transmitted or captured; delete any `.hc22000` you do not keep.

## Exercise

Two learners each say they "captured the handshake" for the same lab AP. Learner A's capture, filtered on `eapol`, shows only **Message 1 of 4**, repeated several times. Learner B's shows **Message 1 and Message 2 of 4** with matching AP/client MACs and consistent nonces. Without running any cracker, say which capture is usable and which is not, explain in terms of what a cracker actually tests, and state what each learner would see if they ran `hcxpcapngtool` on their file.

<details>
<summary>Hint</summary>

What does a cracker compute a candidate PTK from, and what does it check that PTK against? Which message carries the value being checked? Then ask what Learner A's file is missing to even attempt that check.
</details>

<details>
<summary>Reference answer</summary>

**Learner B's capture is usable; Learner A's is not.** A cracker guesses a passphrase, derives the PMK, then derives a candidate **PTK** from the two nonces (ANonce from M1, SNonce from M2) and the two MACs, and checks that PTK against the **MIC carried in M2** (or M3). Learner A has only **M1** — an ANonce and no MIC to test anything against — so there is nothing to crack, no matter how many times M1 repeats; it is a partial handshake. Learner B has a consistent **M1+M2** pair for the same AP/client with matching nonces, which is exactly the crackable core. Running `hcxpcapngtool`: Learner B's file produces a **`TYPE 02` EAPOL hashline** (ready for hashcat `-m 22000`); Learner A's file produces **no output line at all**, correctly reporting that no crackable material is present. The lesson: "I saw EAPOL frames" is not "I captured a handshake" — you need the message pair.
</details>

## References

- [Wireshark display-filter reference — eapol](https://www.wireshark.org/docs/dfref/e/eapol.html) — the EAPOL-Key fields behind "Message N of 4," the nonces, and the MIC.
- [IEEE 802.11-2020](https://standards.ieee.org/ieee/802.11/7028/) — the association sequence and the 4-way handshake.
- [hashcat 22000 format](https://hashcat.net/forum/thread-10253.html) — the EAPOL message pair that becomes a crackable `TYPE 02` line.
- [01.4 · Joining a network](../module-01/lesson-04.md) — the join sequence, and why open-system auth proves nothing.
- [05.1 · Capture formats](lesson-01.md) — how the handshake becomes an hc22000 hashline.

## What you should now be able to do

- Walk a capture from beacon through association to the four EAPOL messages of the handshake.
- Identify M1-M4, read the ANonce/SNonce/MIC, and say which pair a cracker actually uses.
- Tell a complete, crackable handshake from a partial one before wasting time trying to crack it.
