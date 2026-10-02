---
id: "06.1"
module: 6
minutes: 24
practice_minutes: 20
prerequisites: ["05.3", "02.2"]
objectives:
  - Derive the PMK from a WPA2-Personal passphrase and SSID with PBKDF2, and explain why the SSID is the salt.
  - Trace the four EAPOL messages and show how ANonce, SNonce, and the two MACs produce the PTK.
  - Explain why the MIC proves knowledge of the key without transmitting it, and why that enables an offline guess-and-check.
volatility: concept
sources:
  - title: "IEEE 802.11-2020 — RSNA key hierarchy, PBKDF2 PSK-to-PMK, 4-way handshake, EAPOL-Key MIC"
    url: https://standards.ieee.org/ieee/802.11/7028/
  - title: "hashcat wiki — cracking WPA/WPA2 (mode 22000, PBKDF2 reuse across PMKID and EAPOL)"
    url: https://hashcat.net/wiki/doku.php?id=cracking_wpawpa2
last_verified: "2026-10-01"
---

# 06.1 · The 4-way handshake in depth — PSK, PMK, and PTK

The entire WPA2-Personal attack surface in this module rests on one fact you can see in a capture: the 4-way handshake proves both sides know the key without ever sending it, and that same design is exactly what lets an attacker guess the passphrase offline. This lesson derives the key hierarchy from the passphrase down to the per-session key, walks the four EAPOL messages, and shows precisely which captured values an offline cracker feeds back into the same maths — no attack tooling yet, just the mechanism everything later depends on.

## Why this matters

If the handshake is a black box, every capture, PMKID, and cracking decision in this module is memorisation. Once you can derive the PMK and PTK yourself and name what each EAPOL message carries, the attacks become predictable: you know why capturing any single handshake message is not enough, why the SSID changes the hash, why a strong passphrase defeats the whole chain, and why the key itself never crosses the air for you to steal. This is also the cleanest way to explain to a client why their passphrase length — not its punctuation — is the control that matters.

## Learning objectives

- Derive the **PMK** from a passphrase and SSID with **PBKDF2**, and explain why the SSID is the salt.
- Trace the **four EAPOL messages** and show how **ANonce**, **SNonce**, and both MACs produce the **PTK**.
- Explain why the **MIC** proves knowledge of the key without sending it — and why that enables **offline** guess-and-check.

## Prerequisites

- [05.3 · Following a join and spotting the handshake](../module-05/lesson-03.md) — you must be able to find the EAPOL frames in a capture.
- [02.2 · Key hierarchies at a glance — PSK→PMK→PTK, SAE, 802.1X](../module-02/lesson-02.md) — the overview this lesson derives in full.

## Concept

### How it works on the wire

WPA2-Personal turns a human passphrase into session keys in two stages: a slow, one-time derivation of a master key, then a fast per-session exchange that derives the keys actually used to encrypt data.

**Stage 1 — passphrase to PMK (PBKDF2).** The **Pairwise Master Key** is computed once from the passphrase and the network name:

$$\text{PMK} = \text{PBKDF2}(\text{HMAC-SHA1},\ \text{passphrase},\ \text{SSID},\ 4096,\ 256)$$

The SSID is the **salt**, the iteration count is **4096**, and the output is **256 bits**. Two consequences fall straight out of this formula:

- The **SSID changes the hash.** The same passphrase on `Lab-Target-01` and on `Home-WiFi` yields different PMKs, which is why precomputed tables are SSID-specific and why generic rainbow tables do not work against WPA2.
- It is **deterministic and offline-computable.** Nothing secret from the AP is needed to compute a candidate PMK — only the passphrase guess and the SSID, both of which an attacker has. That is the hinge the whole module turns on.

The 4096 iterations make each guess deliberately expensive; that cost, multiplied across a wordlist, is what a defender is really relying on, and it is why passphrase **entropy** (lesson 06.5) — not the 4096 constant — decides whether cracking is feasible.

### The four EAPOL messages

The PMK never encrypts anything directly. Instead the **4-way handshake** uses it to derive a fresh **Pairwise Transient Key (PTK)** per session, carried in four **EAPOL-Key** data frames after association:

1. **Message 1 (AP → client):** the AP sends its nonce, **ANonce**. No MIC yet — the client cannot compute one until it has both nonces.
2. **Message 2 (client → AP):** the client sends its nonce, **SNonce**, with a **MIC**. The client now has everything to derive the PTK, and the MIC proves it did.
3. **Message 3 (AP → client):** the AP confirms (it derived the same PTK), carries the **GTK** for broadcast/multicast, and is itself MIC-protected.
4. **Message 4 (client → AP):** the client acknowledges; keys are installed and encrypted data can flow.

The PTK is derived on both sides, never transmitted:

$$\text{PTK} = \text{PRF}(\text{PMK},\ \text{"Pairwise key expansion"},\ \min(\text{AA},\text{SPA}) \,\|\, \max(\text{AA},\text{SPA}) \,\|\, \min(\text{ANonce},\text{SNonce}) \,\|\, \max(\text{ANonce},\text{SNonce}))$$

where **AA** is the AP's MAC and **SPA** the client's MAC. Both nonces and both MACs travel in the clear inside the handshake, so a capturing attacker sees every PTK input **except the PMK** — and the PMK is exactly what the passphrase guess reconstructs.

### Why the weakness exists

The **MIC** on messages 2 and 3 is a keyed integrity code computed with the **KCK**, the first 128 bits of the PTK. Because the PTK depends on the PMK, a correct MIC proves the sender holds the right PMK — and therefore the right passphrase — **without the passphrase or the PMK ever being sent.** That is good security against replay and forgery over the air. But it is also a complete, self-checking oracle for an offline attacker:

1. Guess a passphrase.
2. Compute $\text{PMK} = \text{PBKDF2}(\text{guess}, \text{SSID}, 4096, 256)$.
3. Derive the candidate PTK using the captured nonces and MACs, take the KCK.
4. Compute the MIC over the captured EAPOL message and compare it to the captured MIC.

A match means the guess is the passphrase. No AP, no network, no further packets — just the captured handshake and arithmetic. This is why the attack is **offline** and why nothing you do on the AP after capture can stop it: the defender's only lever is making step 1 hopeless (lesson 06.5).

> [!IMPORTANT]
> The handshake is a proof of knowledge, not a transmission of the key. "Capturing the handshake" never captures the passphrase or the PMK — it captures the **inputs and the answer** to a check you can then run offline, as many times as you like, against your own guesses.

### What the cracker actually needs

To run that check, a cracker needs: the **SSID** (the PBKDF2 salt), both **MACs** (AA, SPA), both **nonces** (ANonce, SNonce), and one captured **MIC** with the EAPOL frame it covers. ANonce comes from message 1; SNonce and a usable MIC come from message 2 (messages 2+3, or a well-formed pair, are the practical minimum — a lone message 1 has no MIC to test against). Lesson 06.2 is about obtaining a capture that actually contains these; lesson 06.3 shows a shortcut (PMKID) that skips the client nonce entirely; lesson 06.4 runs the check with `hashcat -m 22000`.

Step through the handshake (and compare it with SAE) interactively (educational model):

[Simulation: 4-way handshake and SAE visualiser](../../simulations/handshake/index.html)

## Hands-on

This lesson is foundation and supports the recorded-data path only: you read a known-good handshake and locate every value the maths above consumes. No transmission, no attack tooling.

### Guided walkthrough — find every PTK input in a supplied handshake (path R)

1. From the module zip (`labs/module-06/`), open `captures/wpa2-handshake-good.pcapng` in Wireshark (this capture is **PENDING** a verified generation run — see the lab README; the steps are identical once it lands).
2. Filter to `eapol` and confirm you see four **EAPOL-Key** messages in order.
3. In **message 1**, read the **ANonce** (WPA Key Nonce) and the AP's MAC (**AA**). In **message 2**, read the **SNonce**, the client's MAC (**SPA**), and the **WPA Key MIC**.
4. Note the **SSID** from a nearby beacon/probe or association frame — this is the PBKDF2 salt.
5. On paper, list the six inputs a cracker needs (SSID, AA, SPA, ANonce, SNonce, one MIC+frame) and tick each off against what you just read. Confirm the **passphrase and PMK appear nowhere**.

### Lab

> [!NOTE]
> **Lab paths:**
> R (read the supplied `wpa2-handshake-good.pcapng` — no hardware; proves you can locate the key-hierarchy inputs in a real handshake and reason about the derivation, **not** that you captured it live).
> **Start state:** the recorded-data toolchain from [03.2](../module-03/lesson-02.md) (Wireshark/tshark); the supplied capture from the module zip. No AP, no client, no transmission.
> **Duration:** ~20 min.
> **Artifacts:** an annotated list mapping each PTK/PMK input to the exact frame and field it was read from, plus a one-line statement of why the PMK is absent.
> **Success criteria:** you can point to ANonce, SNonce, both MACs, a MIC, and the SSID in the capture, and explain in your own words why a correct MIC proves key knowledge without revealing the key.
> **Troubleshooting:** no EAPOL frames (wrong capture or a protected-frames filter hiding them — clear filters, confirm you opened the `-good` file); only message 1 visible (a partial capture — that is the subject of lesson 06.2, not this one); SSID not in the handshake frames (read it from a beacon in the same capture).
> **Cleanup:** none — nothing was started. The recorded-data path transmits nothing; `../../labs/common/reset-lab.sh` is only needed once you build live labs.

> [!NOTE]
> **LAB TARGET vs REAL NETWORK:** the supplied capture was generated in our own lab on simulated radios with the synthetic passphrase `Lab-WiFi-Passw0rd!` and SSID `Lab-Target-01`. It contains no real-network traffic. You never transmit in this lesson; the authorisation rules ([00.3](../module-00/lesson-03.md)) still frame everything that follows.

## Exercise

A colleague says: "If I capture the 4-way handshake, I've captured the Wi-Fi password — I just need to read it out of the packets." Explain precisely why this is wrong, name what the handshake *does* contain, and describe the offline procedure that actually turns a captured handshake into a recovered passphrase (and why that procedure can fail).

<details>
<summary>Hint</summary>

What is actually transmitted in messages 1 and 2 — nonces and a MIC, or the PMK? Recall that the MIC is computed *with* a key derived from the PMK. What would you have to do to go from "I have the MIC and the nonces" to "I know the passphrase," and what makes that step sometimes hopeless?
</details>

<details>
<summary>Reference answer</summary>

The passphrase and the PMK are never transmitted. The handshake carries the two **nonces** (ANonce, SNonce), both **MACs**, and a **MIC** on messages 2 and 3 — plus the **SSID** is available from nearby frames. The MIC is a keyed check computed from the PTK, which is derived from the PMK, which is derived from the passphrase and SSID. So the capture is not the password; it is the **inputs and the correct answer** to a check. The offline procedure: for each guessed passphrase, compute `PMK = PBKDF2(guess, SSID, 4096, 256)`, derive the candidate PTK from the captured nonces and MACs, compute the MIC over the captured EAPOL frame, and compare to the captured MIC — a match reveals the passphrase. It fails when the true passphrase is not in the wordlist and has enough entropy that brute force is infeasible in scope (lesson 06.5): the check is sound, but you never guess the right input.
</details>

## References

- IEEE 802.11-2020 — RSNA key hierarchy, PBKDF2 PSK→PMK, the 4-way handshake, and the EAPOL-Key MIC (`../../references/README.md`).
- [hashcat wiki — cracking WPA/WPA2](https://hashcat.net/wiki/doku.php?id=cracking_wpawpa2) — how mode 22000 reuses the same PBKDF2 across PMKID and EAPOL (lesson 06.4).
- [02.2 · Key hierarchies at a glance](../module-02/lesson-02.md) — the overview this lesson derived in full.

## What you should now be able to do

- Derive the PMK from a passphrase and SSID with PBKDF2 and explain why the SSID is the salt and the result is offline-computable.
- Trace the four EAPOL messages and show how the nonces and MACs produce the PTK while the PMK stays secret.
- Explain why the MIC proves key knowledge without sending the key, and why that is exactly what makes an offline guess-and-check possible.
