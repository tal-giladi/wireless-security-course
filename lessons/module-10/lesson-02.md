---
id: "10.2"
module: 10
minutes: 25
practice_minutes: 20
prerequisites: ["10.1"]
objectives:
  - Distinguish PEAP, EAP-TTLS, and EAP-TLS by how each authenticates the client and where trust is anchored.
  - Explain precisely what a supplicant must validate about the server certificate, and what breaks when it does not.
  - Justify why EAP-TLS is the strong endpoint and when the tunnelled password methods are acceptable.
volatility: concept
sources:
  - title: "RFC 3748 — Extensible Authentication Protocol (EAP)"
    url: https://www.rfc-editor.org/rfc/rfc3748
  - title: "RFC 5216 — The EAP-TLS Authentication Protocol"
    url: https://www.rfc-editor.org/rfc/rfc5216
  - title: "RFC 5281 — EAP Tunneled TLS Authentication Protocol (EAP-TTLSv0)"
    url: https://www.rfc-editor.org/rfc/rfc5281
last_verified: "2026-10-01"
---

# 10.2 · EAP methods — PEAP, EAP-TTLS, and EAP-TLS

The access point relays EAP blindly, so the real security of an enterprise network is decided entirely by which EAP method runs inside the tunnel and whether the client checks the server at the other end of it. This lesson compares the three methods you will meet in practice — PEAP (MSCHAPv2 inside a TLS tunnel), EAP-TTLS, and EAP-TLS (mutual certificates) — and for each one pins down where trust is anchored and what the supplicant must validate, because that single decision is the hinge the Module 11 attacks swing on.

## Why this matters

You learned in [10.1](lesson-01.md) that the AP never interprets the method and that trust lives in the server certificate the client is supposed to validate. This lesson makes that concrete: the difference between a solid enterprise deployment and one an attacker walks into is almost never the protocol name on the box — it is which EAP method is configured and whether the client was told to verify the server. PEAP and EAP-TTLS protect a password inside a tunnel; if the client does not validate the tunnel's far end, that password goes straight to a rogue RADIUS server (the whole of Module 11.1). EAP-TLS removes the password entirely and authenticates both ends with certificates. Understanding exactly what each method puts at risk — and what the client must check to prevent it — is what lets you both assess an insecure deployment and design the hardened one you will build and retest later in the sequence.

## Learning objectives

- Distinguish **PEAP**, **EAP-TTLS**, and **EAP-TLS** by how the *client* authenticates and where trust is anchored.
- State precisely what a supplicant must validate about the server certificate (trusted CA **and** expected identity), and what an attacker gains when it does not.
- Explain why **EAP-TLS** is the strong endpoint of the enterprise sequence, and when the tunnelled-password methods are an acceptable choice.

## Prerequisites

- [10.1 · 802.1X — supplicant, authenticator, and RADIUS](lesson-01.md) — you know the three roles, the EAPOL-to-RADIUS relay, and that trust rests on the server certificate and the AP↔RADIUS secret.

## Concept

### The common shape: an outer TLS tunnel, then an inner method

Every method here begins the same way. The supplicant and the RADIUS server negotiate a **TLS tunnel** (the "outer" or "phase 1" exchange), during which **the server presents a certificate**. What happens next — the "inner" or "phase 2" exchange — is where the three methods differ. Holding that two-phase shape in mind keeps the comparison clean: phase 1 is about *authenticating the server to the client and building a protected channel*; phase 2 is about *authenticating the client to the server inside that channel*.

The reason phase 1 matters so much: the client's defence against a rogue RADIUS server is made **in phase 1, before any credential is sent**. If the client accepts any certificate the server offers, it has already lost — phase 2 then delivers the credential into the attacker's tunnel.

### How it works on the wire — the three methods

**PEAP (Protected EAP), with MSCHAPv2 inside.** The common enterprise default. Phase 1 builds the TLS tunnel authenticating the *server* by its certificate; the client normally has no certificate. Phase 2 runs **EAP-MSCHAPv2** — a username and a challenge/response derived from the user's password — *inside* the tunnel. So the user authenticates with a **password**, protected by the tunnel. Security depends entirely on the tunnel being terminated by the *real* server: if the client validates the certificate, the MSCHAPv2 exchange is safe inside TLS; if it does not, the client runs MSCHAPv2 against the attacker, who captures a crackable challenge/response (Module 11.2).

**EAP-TTLS (Tunneled TLS).** Structurally very similar to PEAP — phase 1 builds a server-certificate-authenticated TLS tunnel, the client usually has no certificate — but phase 2 is more flexible: it can carry legacy non-EAP methods (PAP, CHAP, MSCHAPv2) as plain AVPs inside the tunnel. TTLS with inner **PAP** is common where the RADIUS server must check the password against a backend (LDAP, a database) that needs the cleartext password; that cleartext is only ever exposed *inside* the TLS tunnel — which again means the client validating the certificate is the entire safety margin. The trust model is identical to PEAP: **server authenticated by certificate, client authenticated by a password inside the tunnel.**

**EAP-TLS (mutual certificates), RFC 5216.** The strong endpoint. Phase 1 still authenticates the server by its certificate — but the **client also presents a certificate**, and the server validates *it*. There is **no password anywhere in the exchange**. Authentication is mutual and certificate-based: the client proves possession of a private key, the server proves possession of its own. Because there is no password, there is nothing for a rogue server to phish and nothing to crack offline even if an exchange is captured. The cost is operational: every client needs an issued certificate and a way to manage its lifecycle (enrolment, renewal, revocation) — which is exactly why organisations reach for PEAP/TTLS first and why migrating to EAP-TLS is a project, not a checkbox.

### Where trust lives — and what "validate the server" actually means

For all three methods, phase 1 anchors trust in the **server certificate**. "The client validates the server" is not one check but two, and both must pass:

1. **Trust chain:** the server certificate chains to a **CA the client is configured to trust** — ideally the organisation's own private CA, *not* "any CA in the public trust store." A client that trusts a broad public CA set can be fooled by any certificate that chains to any of them.
2. **Expected identity:** the certificate's name matches the **specific server name the client expects** (configured as `domain_suffix_match` / `altsubject_match` in `wpa_supplicant`, or "server name" in an OS profile). Without this, a valid certificate for *some other* name — even one the attacker legitimately obtained — would be accepted.

When **either** check is missing or misconfigured, the tunnelled-password methods (PEAP, EAP-TTLS) collapse: the client builds a tunnel to the attacker's RADIUS server and sends its MSCHAPv2 or PAP credentials inside it. This is not a flaw in PEAP or TTLS — it is the client failing to do the one job phase 1 exists for. EAP-TLS narrows the blast radius further: even a client that mis-validates the server still never sends a reusable password, because it authenticates with a certificate and private key it never transmits.

> [!IMPORTANT]
> The enterprise attack surface is a **client configuration** question far more than a protocol question.
> "We use PEAP" tells you almost nothing; "our clients validate our private CA and the exact server name,
> via a managed profile users cannot edit" tells you it is probably safe. You will measure this difference
> directly in Module 11 — a careless client leaks, a correctly configured client refuses and logs why.

### A one-screen summary

| Method | Phase 1 (server auth) | Phase 2 (client auth) | Client credential | What a rogue server gets if the client skips validation |
|---|---|---|---|---|
| PEAP | Server certificate | EAP-MSCHAPv2 in tunnel | Password | A crackable MSCHAPv2 challenge/response |
| EAP-TTLS | Server certificate | PAP/CHAP/MSCHAPv2 in tunnel | Password | The password (cleartext with inner PAP) |
| EAP-TLS | Server certificate | Client certificate | Certificate + private key | Nothing reusable — no password is ever sent |

## Hands-on

Recorded path again — you compare the method and trust model across supplied captures and a supplicant profile; you build and run the real server in [10.3](lesson-03.md).

### Guided walkthrough — identify the method and locate the trust decision

Using the captures and the sample profile in `../../labs/module-10/`:

1. Open `enterprise-eap-success.pcapng` (from 10.1) in Wireshark and filter `eap`. Walk the phase-1 handshake: find the server's **Certificate** message in the TLS exchange. This is the certificate the client is supposed to validate.
2. Identify the method: a `tls` client handshake carrying a **client Certificate** too indicates **EAP-TLS**; a server-only certificate followed by an encrypted inner exchange indicates **PEAP** or **EAP-TTLS**. Note which this capture shows.
3. Open the sample `wpa_supplicant` profile `client-peap.conf` (text file in the zip). Find the `ca_cert`, `domain_suffix_match` (or `altsubject_match`), `identity`, and `phase2` lines. Write, in one sentence each, what each line causes the client to check or send.
4. Now open `client-peap-insecure.conf`: it omits `ca_cert` and `domain_suffix_match`. On paper, state exactly what this client will do when it meets a rogue RADIUS server, and which line's absence causes it.
5. Contrast with `client-eaptls.conf`: note that it has `client_cert` and `private_key` and **no `password`**. State what a rogue server captures from this client even if validation is weak.

### Lab

> [!NOTE]
> **Lab paths:** R — supplied enterprise captures plus sample supplicant profiles, no hardware (proves you can *identify the EAP method and locate the trust decision* in a capture and a client config). This lab does **not** prove live authentication, credential capture, or any RF behaviour — those come with the running server in [10.3](lesson-03.md) and the attack in Module 11.
> **Start state:** `enterprise-eap-success.pcapng`, `client-peap.conf`, `client-peap-insecure.conf`, `client-eaptls.conf` from the module zip; Wireshark installed; no lab network built.
> **Duration:** ~20 min.
> **Artifacts:** a short table naming the method observed, the frame where the server certificate appears, and a per-line explanation of the three supplicant profiles' trust settings — including which single line's absence makes the insecure profile phishable.
> **Success criteria:** you can state, for each profile, whether it would send credentials to a rogue RADIUS server and exactly why.
> **Troubleshooting:** cannot find the certificate frame → filter `tls.handshake.type == 11`; inner method unreadable → expected, it is inside the tunnel; unsure if EAP-TLS → look for a *second* (client) Certificate message, absent in PEAP/TTLS.
> **Cleanup:** none (read-only analysis).

> [!NOTE]
> **LAB TARGET vs REAL NETWORK:** the captures and profiles use a synthetic identity and the lab CA only. Never point a real supplicant profile containing live credentials at anything but your own lab server.

## Exercise

An organisation tells you, "We're secure — we use PEAP, which is industry standard, and all our laptops connect fine." Explain why that statement, by itself, does not tell you whether the deployment is secure, name the two specific client-side checks you would need to confirm, and state which one additional method you would recommend if they want to remove the risk entirely rather than merely configure around it.

<details>
<summary>Hint</summary>

"Connects fine" and "the client validates the server" are different things — a client that validates nothing also connects fine, and connects fine to an attacker too. What are the two halves of server validation from the Concept section? And which method takes the password — the thing being phished — off the table altogether?
</details>

<details>
<summary>Reference answer</summary>

"We use PEAP" describes only the method, not the trust configuration, and PEAP's safety depends **entirely** on the client validating the server certificate — which "all our laptops connect fine" does not demonstrate, because a client that validates nothing also connects fine (and would connect to a rogue server just as happily). The two checks to confirm are: (1) the client is configured to trust a **specific CA** — the organisation's own private CA, not the public trust store — so only certificates from that CA are accepted; and (2) the client checks the **expected server name/identity** (`domain_suffix_match` / `altsubject_match` or the OS profile's server-name field), so a valid certificate for some other name is rejected. Both must be enforced via a **managed profile users cannot override**. If they want to eliminate the risk rather than configure around it, recommend **EAP-TLS**: it replaces the password with client certificates, so there is no reusable credential for a rogue server to phish or to crack offline, at the cost of running certificate enrolment and lifecycle management.
</details>

## References

- [RFC 3748 — EAP](https://www.rfc-editor.org/rfc/rfc3748) — the EAP framework and the request/response model phases run over.
- [RFC 5216 — The EAP-TLS Authentication Protocol](https://www.rfc-editor.org/rfc/rfc5216) — mutual certificate authentication and key derivation.
- [RFC 5281 — EAP-TTLSv0](https://www.rfc-editor.org/rfc/rfc5281) — tunnelled inner methods (PAP/CHAP/MSCHAPv2).
- [10.1 · 802.1X roles and the relay](lesson-01.md) — why the AP never interprets the method, so the client's trust decision is decisive.
- Glossary: EAP, MSCHAPv2, RADIUS, supplicant (`../../glossary.md`).

## What you should now be able to do

- Distinguish PEAP, EAP-TTLS, and EAP-TLS by how the client authenticates (tunnelled password vs client certificate) and where trust is anchored.
- State the two checks a supplicant must perform on the server certificate — trusted CA and expected identity — and describe what a rogue RADIUS server captures when either is missing.
- Explain why EAP-TLS is the strong endpoint and when tunnelled-password methods are an acceptable, correctly-configured choice.
