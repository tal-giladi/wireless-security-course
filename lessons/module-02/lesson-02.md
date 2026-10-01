---
id: "02.2"
module: 2
minutes: 25
practice_minutes: 20
prerequisites: ["02.1"]
objectives:
  - Trace the key hierarchy from passphrase or 802.1X to PMK, then to PTK and GTK via the 4-way handshake.
  - Explain why a captured WPA2-PSK handshake is offline-crackable but a passive SAE capture is not.
  - Identify the EAPOL handshake messages and the quantities (nonces, MIC) that make PSK material attackable.
volatility: concept
sources:
  - title: "IEEE 802.11-2020 standard (key hierarchy, 4-way handshake, SAE)"
    url: https://standards.ieee.org/ieee/802.11/7028/
  - title: "Wi-Fi Alliance — WPA3 Specification (SAE key derivation)"
    url: https://www.wi-fi.org/discover-wi-fi/security
  - title: "Dragonblood — Vanhoef & Ronen, analysis of the Dragonfly/SAE handshake (2019)"
    url: https://wpa3.mathyvanhoef.com/
last_verified: "2026-10-01"
---

# 02.2 · Key hierarchies at a glance — PSK, PMK, PTK, SAE, and 802.1X

Every Wi-Fi encryption mode ends up at the same place — a fresh per-session key protecting your frames — but the road it takes to get there decides whether an attacker who captures the exchange can crack it offline. This lesson walks the key hierarchy at a conceptual level, from where the master key comes from (a passphrase, an 802.1X exchange, or SAE) down through the 4-way handshake to the keys that actually encrypt traffic, and it pins down the single most important consequence for an attacker: WPA2-PSK leaves crackable material in a passive capture and SAE does not.

## Why this matters

This is the hinge the whole offensive half of the course turns on. In Module 6 you will capture a WPA2 handshake and throw a wordlist at it; in Module 7 you will try the same against WPA3-SAE and find there is nothing to throw a wordlist *at*. Neither result makes sense unless you understand where the crackable value comes from and why SAE removes it. You do not need the full cryptographic depth yet — that arrives in Modules 6 and 7 — but you do need the shape of the hierarchy so that "capture the handshake" and "SAE has no offline hash" are statements you understand rather than slogans you repeat.

## Learning objectives

- Trace the key hierarchy: passphrase or 802.1X exchange → PMK → PTK (per session) and GTK, derived in the 4-way handshake.
- Explain why a captured WPA2-PSK 4-way handshake is offline-crackable, while a passively captured SAE exchange yields no offline-crackable hash.
- Identify the four EAPOL handshake messages and the quantities (ANonce, SNonce, MIC) a cracker actually uses.

## Prerequisites

- Lesson 02.1 — the protocol family. You need to know which AKM a network advertises (PSK, SAE, 802.1X) because that is exactly what decides which path through this hierarchy applies.

## Concept

### The shape of the hierarchy

Whatever the mode, WPA2/WPA3 converge on a two-layer idea:

- A **Pairwise Master Key (PMK)** — a per-network-or-per-session master secret. *Where it comes from differs by mode.*
- A **Pairwise Transient Key (PTK)** — a fresh per-session key derived from the PMK plus values exchanged live, used to actually encrypt unicast traffic. A **Group Temporal Key (GTK)** protects broadcast/multicast and is distributed to clients during the handshake.

The PMK is the long-lived secret; the PTK is the disposable per-session key. The 4-way handshake is the ceremony that turns one into the other without ever sending either across the air.

### Where the PMK comes from (this is the whole game)

**WPA2-Personal (PSK).** The PMK is derived from the passphrase and the SSID with PBKDF2:

$$\text{PMK} = \text{PBKDF2}(\text{HMAC-SHA1},\ \text{passphrase},\ \text{SSID},\ 4096,\ 256)$$

The SSID is the salt and 4096 is the iteration count. Because the PMK is a deterministic function of passphrase and SSID, anyone who guesses the passphrase can recompute the PMK offline — no network needed. That is the door every WPA2 cracking attack walks through.

**WPA2/WPA3-Enterprise (802.1X).** There is no shared passphrase. The PMK is produced by the **EAP** exchange between the supplicant and the RADIUS server and delivered to the AP. It is effectively random per session, not a function of a guessable secret, so you cannot recompute it from a wordlist. (The attackable material in Enterprise is elsewhere — a captured MSCHAPv2 exchange against a client that does not validate the server cert — covered in Modules 10–11.)

**WPA3-Personal (SAE).** Still one passphrase, but SAE (Dragonfly) is a **password-authenticated key exchange**: the two sides run a Diffie-Hellman-style exchange, mixing in the password, and *agree* on a PMK. Critically, what crosses the air is a commit/confirm exchange, not a value you can run a passphrase guess against offline. A passive observer sees the SAE frames but **cannot derive an offline-crackable hash** from them — there is no PBKDF2-of-passphrase sitting in the capture. To test a passphrase guess against SAE you must interact with the network for each guess (online, rate-limited, and detectable), which is a different and far weaker attack than offline cracking.

### The 4-way handshake — PMK to PTK

Once both sides have a PMK (however they got it), the **4-way handshake** (carried in EAPOL frames) derives the PTK. Conceptually:

$$\text{PTK} = \text{PRF}(\text{PMK},\ \text{"Pairwise key expansion"},\ \text{MACs} \parallel \text{nonces})$$

where the inputs include both device MAC addresses and two random **nonces** — the **ANonce** (from the AP) and **SNonce** (from the client). The four messages:

1. **AP → client:** ANonce (now the client can compute the PTK).
2. **Client → AP:** SNonce plus a **MIC** (a keyed checksum over the message, proving the client derived the right PTK).
3. **AP → client:** GTK (encrypted) plus a MIC.
4. **Client → AP:** acknowledgement.

The MIC is the attacker's lever in WPA2-PSK: it is computed with a key derived from the PMK. A cracker captures the handshake (the nonces, MACs, and MIC), then for each candidate passphrase computes a candidate PMK → candidate PTK → candidate MIC and checks whether it matches the captured MIC. A match means the guess was the passphrase. All of that happens offline. This is exactly why the captured material matters and why the passphrase's strength is the only thing standing in the way (Module 6).

For SAE there is no such captured quantity that is a function of the passphrase alone — the confirm values depend on the live Diffie-Hellman exchange — so the same offline recompute-and-compare simply has nothing to compare against.

### A note on PMKID

Some APs include a **PMKID** in the first handshake message, derived from the PMK, the AP MAC, and the client MAC. When present (not universal, and gathering it is not fully passive — you associate), it gives a cracker the same offline recompute-and-compare path without needing to capture a full 4-way handshake. We treat this properly in Module 6.3; for now, just note it is another artefact derived from the PSK-based PMK — and therefore another thing SAE does not hand out.

## Hands-on

### Guided walkthrough — spotting the crackable quantities

A reading exercise on supplied captures; no radio, no cracking. Using the handshake captures in `../../labs/module-02/` and Wireshark:

1. Open `wpa2-handshake-good.pcapng` (shipped in `labs/common/`, included in every module zip). Filter with `eapol` to show only the EAPOL frames. Confirm you can see the four messages of one 4-way handshake.
2. In message 1, find the **WPA Key Nonce** — this is the ANonce. In message 2, find the SNonce and the **WPA Key MIC**. These are the quantities a cracker feeds into the recompute-and-compare loop.
3. Note the **Key Information** flags that distinguish the four messages, and which message carries the (encrypted) GTK.
4. Open `wpa3-sae.pcapng` and filter for the SAE authentication frames (commit and confirm). Confirm there is **no** EAPOL key MIC that is a function of the passphrase alone — i.e. nothing to run a wordlist against offline. Write one sentence on what an offline cracker would have to work with here (answer: nothing).

> [!NOTE]
> **Lab paths:** R — supplied captures, no hardware (proves you can *read* the handshake and reason about what is and is not offline-crackable). It does **not** prove live capture or cracking; those are Module 6 on the R/V/P paths.
> **Start state:** `wpa2-handshake-good.pcapng` (from `labs/common/`) and `wpa3-sae.pcapng` (module-02 capture) from the module zip; Wireshark installed.
> **Duration:** ~20 min.
> **Artifacts:** a short note naming the ANonce, SNonce, and MIC in the WPA2 capture, and a one-sentence statement of why the SAE capture offers an offline cracker nothing.
> **Cleanup:** none (read-only analysis).

## Exercise

Two colleagues disagree. One says "WPA3 is just WPA2 with a longer key, so a captured WPA3 handshake cracks the same way, only slower." The other says "a captured SAE exchange can't be cracked offline at all, no matter how much hardware you throw at it." Using the key hierarchy, explain which colleague is right and *why*, and state precisely what an attacker who wants to test passphrase guesses against an SAE network is forced to do instead.

<details>
<summary>Hint</summary>

Ask where the crackable value in WPA2 comes from: the PMK is PBKDF2(passphrase, SSID), so the captured MIC can be recomputed from a guessed passphrase entirely offline. Does SAE put any passphrase-only function into the captured frames? If not, each guess has to be tested against the live network.
</details>

<details>
<summary>Reference answer</summary>

The second colleague is right. In WPA2-PSK the PMK is a deterministic function of the passphrase and SSID (PBKDF2), so a captured handshake's MIC can be recomputed and compared for each guessed passphrase entirely offline — more hardware just means more guesses per second. SAE never places a passphrase-only quantity into the exchange: the commit/confirm values depend on the live Diffie-Hellman exchange, so there is nothing in a passive capture to recompute-and-compare against. "Longer key" is the wrong mental model; the difference is structural, not a matter of key length or speed. An attacker who wants to test passphrase guesses against SAE must interact with the network **once per guess** — an online, rate-limited, and detectable attack — which is categorically weaker than offline WPA2 cracking.
</details>

## References

- IEEE 802.11-2020 — PMK/PTK/GTK hierarchy, 4-way handshake, SAE (`../../references/README.md`).
- Wi-Fi Alliance — WPA3 Specification: SAE key establishment (`../../references/README.md`).
- Dragonblood (Vanhoef & Ronen, 2019) — analysis of the Dragonfly/SAE handshake (`../../references/README.md`).
- Glossary: PSK, PMK, PTK, GTK, Handshake (4-way), SAE, EAPOL, PMKID (`../../glossary.md`).

## What you should now be able to do

- Trace, at a conceptual level, how a passphrase (PBKDF2), an 802.1X exchange, or SAE produces a PMK, and how the 4-way handshake turns a PMK into a PTK and distributes the GTK.
- Explain why a captured WPA2-PSK handshake is offline-crackable and a passively captured SAE exchange is not.
- Point to the ANonce, SNonce, and MIC in a captured handshake and say what a cracker does with them.
