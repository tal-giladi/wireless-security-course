---
id: "07.4"
module: 7
minutes: 14
practice_minutes: 20
prerequisites: ["07.1"]
objectives:
  - Explain what OWE (Enhanced Open) provides — encryption without authenticating the network.
  - Distinguish the passive-sniffing protection OWE gives from the active rogue/MITM it does not stop.
  - Recognise OWE in a beacon and reason about when it is and is not the right control.
volatility: concept
sources:
  - title: "RFC 8110 — Opportunistic Wireless Encryption"
    url: https://www.rfc-editor.org/rfc/rfc8110
  - title: "Wi-Fi Alliance — Wi-Fi Enhanced Open"
    url: https://www.wi-fi.org/discover-wi-fi/security
last_verified: "2026-10-01"
---

# 07.4 · OWE (Enhanced Open) — encryption without authenticating the network

Opportunistic Wireless Encryption, branded Wi-Fi Enhanced Open, fixes one specific problem with open networks: it encrypts the traffic so a passive eavesdropper on the same open SSID can no longer read it. What it deliberately does not do is authenticate the network — and understanding that boundary precisely is the whole point of this lesson, because it is exactly where people overclaim.

## Why this matters

"Open but encrypted" sounds like it should stop evil twins, and it does not. OWE protects against the passive listener in the coffee shop, not against an attacker who stands up a rogue AP with the same name. If you recommend OWE as protection against rogue APs you will give a false sense of security; if you dismiss it as pointless you will miss a genuine, cheap improvement over plain open networks. The precise framing — encryption yes, network authentication no — is what makes your advice correct.

## Learning objectives

- Explain what **OWE** provides: **encryption without authenticating the network**.
- Distinguish the **passive-sniffing protection** OWE gives from the **active rogue/MITM** it does not stop.
- Recognise OWE in a beacon and reason about when it is, and is not, the right control.

## Prerequisites

- [07.1 · SAE (Dragonfly)](lesson-01.md) — OWE uses a Diffie-Hellman exchange conceptually similar to SAE's key agreement, minus any password.

## Concept

### How OWE works on the wire

OWE (RFC 8110) replaces the "no encryption at all" of a traditional open network with an **unauthenticated Diffie-Hellman** key exchange carried in the association. The client and AP each contribute a public key, derive a shared secret, and from it a PMK and the usual PTK — so the link is encrypted per client, even though no password or certificate was ever involved. To a user it still looks like joining an open network (no prompt), which is the design goal: encryption with zero configuration.

### What it protects — and what it does not

- **Protects:** a **passive** eavesdropper on the same open SSID can no longer read your traffic, because each client has its own derived keys. This is a real improvement over legacy open Wi-Fi, where everything was in the clear.
- **Does NOT protect:** OWE performs **no authentication of the network**. There is no password, certificate, or identity to verify, so a client has no way to tell a legitimate OWE AP from an attacker's OWE AP with the same SSID. An **active** adversary who runs a rogue/evil-twin AP (Module 9) simply completes the OWE exchange *as the AP* and then sits in the middle — OWE encrypts the victim straight to the attacker.

So OWE raises the bar from "anyone nearby can sniff" to "an attacker must actively impersonate the network," which is worth having, but it is categorically **not** a defence against rogue APs or MITM. The thing that authenticates a network is a credential — a PSK (WPA2/WPA3-Personal) or a validated server certificate (Enterprise, Module 10–11) — and OWE has none by design.

### OWE transition mode

To deploy OWE without breaking old clients, APs can run an **OWE transition mode**: a hidden OWE BSS paired with an open BSS, so legacy devices use open and OWE-capable devices use encryption. This aids migration but means legacy clients still get no encryption — note it when assessing.

## Hands-on

### Guided walkthrough — stand up OWE and see the boundary (paths V / P)

1. Configure `hostapd` for OWE (`wpa_key_mgmt=OWE`) on your **own** AP/`mac80211_hwsim` radio and join with an OWE-capable client. Confirm in a capture ([05.2](../module-05/lesson-02.md)) that the data frames are now encrypted (`wlan.fc.protected` set) even though no passphrase was entered.
2. Now reason about the limit: because there is no credential, a second OWE AP you stand up with the same SSID would be indistinguishable to the client. You do **not** need to run the rogue here (that is Module 9) — the point is to see that nothing in the OWE join authenticates the AP.

> [!WARNING]
> LAB TARGET vs REAL NETWORK — configure OWE only on your **own** AP, synthetic SSID/creds
> ([00.3](../module-00/lesson-03.md)). Do not stand up an OWE (or any) AP impersonating a real network.

> [!NOTE]
> **Lab paths:** V (`mac80211_hwsim` + hostapd — shows the OWE exchange, encryption, and the absence of any authentication step) · P (owned AP + OWE-capable client — same, over real RF). Neither needs a successful deauth.
> **Start state:** an owned AP/stack that supports OWE; an OWE-capable client.
> **Duration:** ~20 min. **Artifacts:** a capture showing encrypted data on an "open" network; a note on why the join authenticates nothing.
> **Success criteria:** you demonstrate encryption-without-password AND can explain why a same-SSID rogue would not be detected by the client.
> **Troubleshooting:** client won't use OWE → it isn't OWE-capable (older OS); frames not protected → check `wpa_key_mgmt=OWE` and that the client actually negotiated OWE, not plain open.
> **Cleanup:** stop hostapd, restore the interface — `../../labs/common/reset-lab.sh`.

## Exercise

A café owner reads that "Enhanced Open encrypts guest Wi-Fi" and asks whether switching their open network to OWE will stop the evil-twin attacks they read about. Write the accurate answer: what OWE will and will not do for them, and what (if anything) actually addresses the rogue-AP concern.

<details>
<summary>Hint</summary>

Separate passive sniffing from active impersonation. OWE addresses the first and not the second, because it authenticates nothing. What authenticates a network is a credential the client can verify.
</details>

<details>
<summary>Reference answer</summary>

OWE is a real upgrade over plain open Wi-Fi: it encrypts each guest's traffic, so a **passive** eavesdropper on the same SSID can no longer read it. But it will **not** stop evil twins, because OWE performs **no authentication of the network** — there is no password or certificate, so a client cannot distinguish the café's OWE AP from an attacker's OWE AP with the same name; an **active** rogue simply completes OWE as the AP and MITMs the victim. What actually addresses rogue APs is network authentication the client verifies — a WPA2/WPA3-Personal passphrase the users know, or, for a managed environment, Enterprise with server-certificate validation (Modules 10–11) — plus rogue-AP monitoring (Module 9). Recommend OWE as "better than open," never as anti-evil-twin.
</details>

## References

- [RFC 8110 — Opportunistic Wireless Encryption](https://www.rfc-editor.org/rfc/rfc8110).
- [Wi-Fi Alliance — Enhanced Open](https://www.wi-fi.org/discover-wi-fi/security).
- Module 9 (rogue AP, evil twin & client-side) — the active attack OWE does not stop.

## What you should now be able to do

- Explain that OWE encrypts without authenticating the network, and why that distinction matters.
- Say precisely what OWE stops (passive sniffing) and what it does not (active rogue/MITM).
- Recognise OWE (and OWE transition mode) and recommend it only as an upgrade over open, not as anti-rogue.
