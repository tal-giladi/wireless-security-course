---
id: "11.5"
module: 11
minutes: 20
practice_minutes: 40
prerequisites: ["11.4"]
objectives:
  - Run the same rogue RADIUS server from 11.1 against a correctly-configured client and show it rejects the server.
  - Collect the client-side log and the packet evidence of the refusal and identify the exact reason it refused.
  - Explain why the rejection happens in phase 1 and why no credential leaves the client.
volatility: implementation
sources:
  - title: "wpa_supplicant configuration and control interface — EAP-TLS alerts and certificate validation events"
    url: https://w1.fi/cgit/hostap/tree/wpa_supplicant/wpa_supplicant.conf
  - title: "RFC 5216 — The EAP-TLS Authentication Protocol (certificate validation)"
    url: https://www.rfc-editor.org/rfc/rfc5216
  - title: "RFC 8446 — The Transport Layer Security (TLS) Protocol Version 1.3 (alerts)"
    url: https://www.rfc-editor.org/rfc/rfc8446
last_verified: "2026-10-01"
---

# 11.5 · A correctly-configured client rejects the rogue server

This is the payoff of the whole enterprise sequence: you point the exact rogue RADIUS server from 11.1 at the client you hardened in 11.4, and instead of leaking a credential, the client refuses — and you capture the evidence that proves it and the precise reason it refused. The rejection is the deliverable. A learner passes this lesson not by breaking anything but by demonstrating, with the log and the packet trace, that a client which validates its server defeats the attack in phase 1 before any credential is sent.

## Why this matters

Everything in Module 11 builds to one demonstrable claim: the credential-capture attack is entirely a client-validation problem, and a correctly-configured client defeats it outright. Saying so is an assertion; *showing* it — same attacker, same SSID, one client leaks and the hardened one refuses with a named reason — is evidence, and evidence is what belongs in a report and a retest. This is also the lesson that operationalises the course principle that proving a protection works is a full, valid outcome: here, the refusal *is* the pass. Being able to point at the TLS alert and say "it refused because the certificate was not issued by our pinned CA" is exactly the retest a blue team runs after deploying the 11.4 configuration.

## Learning objectives

- Run the **same rogue RADIUS server** from [11.1](lesson-01.md) against the **correctly-configured client** from [11.4](lesson-04.md) and show it **rejects** the server.
- Collect the **client-side log** and the **packet evidence** of the refusal, and identify the **exact reason** (untrusted CA / name mismatch).
- Explain why the rejection happens **in phase 1** and why **no credential leaves the client**.

## Prerequisites

- [11.4 · Hardening — trusted CA, server identity, and EAP-TLS](lesson-04.md) — you have a client that pins the lab CA and the expected server name (and, optionally, an EAP-TLS client).

## Concept

### The control or process

The hardened client validates the server certificate in **phase 1** of the EAP conversation, before it runs any inner method or sends any credential ([10.2](../module-10/lesson-02.md)). When the rogue server presents its certificate, the client applies the two pins from 11.4 and refuses if either fails:

- **Untrusted CA.** The rogue server's certificate is not signed by the pinned lab CA (`ca_cert`). The client's TLS layer cannot build a trusted chain and aborts the handshake.
- **Name mismatch.** Even if (hypothetically) the certificate chained to a trusted CA, its name would not match `domain_suffix_match`/`altsubject_match`, and the client aborts.

Either way the client sends a **TLS alert** (e.g. a fatal `unknown_ca` or certificate/handshake-failure alert — [RFC 8446](https://www.rfc-editor.org/rfc/rfc8446)) and tears the tunnel down. Because this happens **before** the inner MSCHAPv2 exchange, the rogue server records **no credential** — there is nothing to capture. With an EAP-TLS client the guarantee is even stronger: no password exists to send regardless of validation.

### Vulnerable vs hardened — and how to measure

You are measuring the same before/after as 11.4, now from the client's and the wire's perspective, with the refusal as the primary artifact:

- **Vulnerable client (11.1):** completes phase 1, runs MSCHAPv2, rogue server **logs a credential**. Evidence: a captured exchange.
- **Hardened client (this lesson):** aborts phase 1 with a **TLS alert**, logs the validation failure and its reason, sends **no** inner exchange; rogue server's capture is **empty**. Evidence: the client log line naming the reason, plus a packet trace showing the server `Certificate` followed by the client's `Alert` and no inner method.

The pass is producing that hardened evidence and stating the reason. Key client-side log signals to collect:

```text
# wpa_supplicant (hardened PEAP/EAP-TLS) meeting the rogue server — reason named:
CTRL-EVENT-EAP-TLS-CERT-ERROR ... reason='unknown CA' / 'Certificate chain failed'
# or, when the CA is (hypothetically) trusted but the name is wrong:
CTRL-EVENT-EAP-TLS-CERT-ERROR ... reason='Domain suffix mismatch'
CTRL-EVENT-EAP-FAILURE          # authentication aborted; NO inner exchange sent
```

Note the absence that matters: there is **no** `CTRL-EVENT-EAP-SUCCESS` and the rogue server prints **no** MSCHAPv2 line. The negative result — nothing captured — is the evidence, confirmed by the explicit error reason.

## Hands-on

### Guided walkthrough — make the hardened client refuse, and capture why (paths V / P)

1. **Stand up the same rogue server** from 11.1 for `LAB-ENTERPRISE` on `wlan0` (real 10.3 services stopped):

   ```bash
   sudo ./labs/common/reset-lab.sh
   sudo ./labs/common/hwsim-up.sh 2
   sudo hostapd-wpe /etc/hostapd-wpe/hostapd-wpe.conf    # or eaphammer, as in 11.1
   ```

2. **Start a capture** on the client radio so you have the packet evidence:

   ```bash
   # capture the EAPOL/EAP exchange on wlan1 (monitor or the client's own frames) to rogue-reject.pcapng
   ```

3. **Bring up the HARDENED client** from 11.4 (pinned CA + `domain_suffix_match`) on `wlan1`:

   ```bash
   sudo wpa_supplicant -i wlan1 -c /etc/lab/client-peap-hardened.conf -d
   ```

4. **Collect the refusal evidence.** In the `wpa_supplicant` log, find the `CTRL-EVENT-EAP-TLS-CERT-ERROR` with its reason (`unknown CA` / chain failure) and the `CTRL-EVENT-EAP-FAILURE`; confirm there is **no** `EAP-SUCCESS`. In the rogue server's output, confirm **no** MSCHAPv2 exchange was logged. In the packet capture, find the server `Certificate` message followed by the client `Alert` and the absence of any inner method.
5. **Name the reason.** Write one sentence: the client refused because the rogue certificate was **not issued by the pinned lab CA** (and/or the name did not match), so the tunnel was aborted in phase 1 and no credential was sent.
6. **(Optional) Repeat with the EAP-TLS client** to show that even without a password there is nothing to capture.
7. **Tear down:**

   ```bash
   # Ctrl-C the rogue server and wpa_supplicant; stop the capture
   sudo ./labs/common/hwsim-down.sh
   sudo ./labs/common/reset-lab.sh
   ```

### Lab

> [!NOTE]
> **Lab paths:** V (`mac80211_hwsim` + the 11.1 rogue server + the hardened `wpa_supplicant` client, in the VM — proves the correctly-configured client rejects the rogue server and lets you collect the log + packet evidence and the reason; does **not** reproduce real RF, drivers, range, interference, or hardware quirks). P optional — owned adapter in AP mode (rogue) and an owned hardened client; identical steps, transmitting real radio in range.
> **Start state:** the hardened client profile from [11.4](lesson-04.md) (pinned lab CA + `domain_suffix_match`), the 11.1 rogue server available, the real 10.3 services stopped, a capture tool ready; nothing transmitted over the air (V).
> **Duration:** ~40 min.
> **Artifacts:** the `wpa_supplicant` log showing `CTRL-EVENT-EAP-TLS-CERT-ERROR` with the reason and `CTRL-EVENT-EAP-FAILURE` and **no** `EAP-SUCCESS`; the rogue server's log showing **no** captured MSCHAPv2 exchange; a `rogue-reject.pcapng` packet trace showing the server `Certificate`, the client `Alert`, and no inner method; a one-sentence statement of the reason.
> **Success criteria:** the hardened client **rejects the rogue server** and you can show both the client-side reason and the empty rogue capture, and explain that the refusal occurred in phase 1 so no credential was sent. **Demonstrating this rejection is the full pass for the module's defensive outcome** — no attack needs to succeed anywhere.
> **Troubleshooting:** client connects/leaks instead of refusing (the hardened profile is not actually loaded, or `ca_cert`/`domain_suffix_match` is unset/typo'd — the insecure state from 11.1); no `CERT-ERROR` line (raise `wpa_supplicant` debug with `-d`/`-dd`); cannot find the alert in the capture (filter the TLS handshake and look for the `Alert` after the server `Certificate`); rogue server won't start (real 10.3 services still hold the radio — `reset-lab.sh`); unsure the capture is empty (search the rogue log for the identity — it should be absent).
> **Cleanup:** Ctrl-C the rogue server and `wpa_supplicant`, stop the capture; `sudo ./labs/common/hwsim-down.sh` then `sudo ./labs/common/reset-lab.sh`. Keep the refusal evidence as your retest artifact; delete synthetic keys/profiles you will not reuse. Nothing transmitted on V.

> [!WARNING]
> **LAB TARGET vs REAL NETWORK:** the rogue server impersonates your **own** lab SSID only, and the only client you test is your **own** hardened lab client with synthetic credentials ([00.3](../module-00/lesson-03.md)). Never run the rogue server against a real network, even to "prove the fix" — a real validating client's refusal is not yours to test. On path P the rogue server transmits real radio; owned equipment, allowlist, minimum TX, stop conditions.

## Exercise

You have deployed the 11.4 configuration and need to hand a blue team a repeatable **retest** that proves enterprise clients now reject a rogue RADIUS server. Describe the retest as a procedure with an explicit, checkable pass condition, say exactly what evidence demonstrates the fix, and explain how you would distinguish a genuine rejection from a client that merely "failed to connect" for an unrelated reason.

<details>
<summary>Hint</summary>

A pass here is a specific negative plus a specific positive: what must be **absent** (from the rogue server and the client) and what must be **present** (a particular client log reason and a packet event)? And "didn't connect" is not the same as "refused the certificate" — which log line proves it was the certificate check and not, say, a wrong SSID or a dead radio?
</details>

<details>
<summary>Reference answer</summary>

The retest: stand up a rogue RADIUS server advertising the enterprise SSID with a certificate **not** issued by the organisation's CA, on owned/controlled equipment; bring up a representative managed client; capture the client log and a packet trace. **Pass condition (explicit and checkable):** the rogue server logs **no** inner credential exchange for the client **and** the client logs a certificate-validation failure with a named reason (`CTRL-EVENT-EAP-TLS-CERT-ERROR`, reason `unknown CA` / chain failure or `Domain suffix mismatch`) followed by `EAP-FAILURE`, with **no** `EAP-SUCCESS`, and the packet trace shows the server `Certificate` followed by a client TLS `Alert` and no inner method. **Evidence of the fix:** the empty rogue capture plus the named client-side reason and the alert in the trace — the absence of a captured credential *and* the explicit reason together. **Distinguishing a genuine rejection from an unrelated "failed to connect":** a mere failure (wrong SSID, dead radio, timeout) produces no certificate-error reason and no server `Certificate`→client `Alert` sequence; a genuine rejection names the certificate/CA/name failure specifically. You confirm it by also running the **vulnerable** profile against the same rogue server and seeing it leak — proving the rogue server and attack are working and that the hardened client's refusal is the certificate validation, not an incidental failure.
</details>

## References

- [wpa_supplicant.conf and control interface — certificate validation and EAP-TLS cert-error events](https://w1.fi/cgit/hostap/tree/wpa_supplicant/wpa_supplicant.conf) — the `CTRL-EVENT-EAP-TLS-CERT-ERROR` reasons and the validation settings.
- [RFC 5216 — EAP-TLS](https://www.rfc-editor.org/rfc/rfc5216) — server (and client) certificate validation in the handshake.
- [RFC 8446 — TLS 1.3 (alerts)](https://www.rfc-editor.org/rfc/rfc8446) — the alert the client sends when validation fails.
- [11.1 · Credential capture](lesson-01.md) and [11.4 · Hardening](lesson-04.md) — the attack you are now defeating and the configuration that defeats it.

## What you should now be able to do

- Run the same rogue RADIUS server from 11.1 against a correctly-configured client and show it rejects the server.
- Collect the client-side log and packet evidence of the refusal and name the exact reason (untrusted CA / name mismatch).
- Explain why the rejection happens in phase 1 and why no credential leaves the client — and present that rejection as the retest that proves the fix.
