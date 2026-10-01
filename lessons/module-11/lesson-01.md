---
id: "11.1"
module: 11
minutes: 24
practice_minutes: 50
prerequisites: ["10.3"]
objectives:
  - Stand up a rogue RADIUS server with hostapd-wpe or eaphammer against the known-good enterprise lab from Module 10.
  - Capture a PEAP/EAP-TTLS inner MSCHAPv2 challenge/response from a client that does not validate the server certificate.
  - Explain precisely why the capture succeeds only because the client skipped server validation, and what a validating client would do instead.
volatility: implementation
sources:
  - title: "hostapd-mana / hostapd-wpe — EAP WPE attack theory (rogue RADIUS credential capture)"
    url: https://github.com/sensepost/hostapd-mana/wiki/EAP-WPE-Attack-Theory
  - title: "eaphammer — Attacking WPA EAP and WPA2 EAP networks"
    url: https://github.com/s0lst1c3/eaphammer/wiki/VIII.-Attacking-WPA-EAP-and-WPA2-EAP-Networks
  - title: "RFC 2759 — Microsoft PPP CHAP Extensions, Version 2 (MSCHAPv2)"
    url: https://www.rfc-editor.org/rfc/rfc2759
last_verified: "2026-10-01"
---

# 11.1 · Assessing insecure config — credential capture

The enterprise network you built in Module 10 has one setting that decides everything: whether the client validates the server before it speaks. This lesson removes that check on the client and stands a rogue RADIUS server in front of it, so the client builds its PEAP tunnel to the attacker and sends an MSCHAPv2 challenge/response into it — a captured credential you will crack in the next lesson. The whole attack exists in one narrow condition, and you will prove to yourself that it does: it works **only** because the client skipped server validation, and a correctly-configured client (lesson 11.5) defeats it outright.

> [!WARNING]
> This is an offensive lesson. A rogue RADIUS server impersonates a real authentication server; run it **only** against the owned Module 10 lab, with the synthetic identity and credentials, on simulated radios (path V) or an isolated owned rig (path P). Pointing a rogue server at a network you do not own — or capturing anyone's real enterprise credentials — is interception and, over the air, interference ([00.3](../module-00/lesson-03.md)). A private subnet does not contain radio.

## Why this matters

Enterprise Wi-Fi is sold as "no shared passphrase to crack," and that is true — but the credential-capture attack sidesteps the whole key hierarchy by going after the one thing a careless client still hands over: a password-derived MSCHAPv2 exchange, tunnelled to whoever answers. In real assessments this is the single most common enterprise finding, and it is almost never a protocol flaw — it is a client that was never told which CA and which server name to trust. Learning to demonstrate the capture, and to state the exact precondition that made it possible, is what turns "we use PEAP" into an actionable finding: *your clients do not validate the server, therefore any rogue RADIUS in range harvests credentials.* Get the precondition wrong and you will either over-claim (blaming the protocol) or miss the finding entirely.

## Learning objectives

- Stand up a **rogue RADIUS server** (`hostapd-wpe` or `eaphammer`) advertising the lab SSID against the Module 10 network.
- **Capture** a PEAP (or EAP-TTLS) inner **MSCHAPv2 challenge/response** from a client configured **not** to validate the server certificate.
- Explain precisely **why the capture succeeds only because the client skipped validation**, and what a validating client does instead (forward reference to [11.5](lesson-05.md)).

## Prerequisites

- [10.3 · Build the lab — CA, FreeRADIUS, supplicant, and a client profile](../module-10/lesson-03.md) — you have a working enterprise network and the validating `client-peap.conf` to compare against.

## Concept

### How the protocol works

Recall the two-phase shape from [10.2](../module-10/lesson-02.md): PEAP and EAP-TTLS first build a TLS tunnel in which **the server presents a certificate**, then run an inner method — for PEAP, **EAP-MSCHAPv2** — that authenticates the *client* with a password-derived challenge/response. The client's only defence against talking to the wrong server is made in phase 1, *before* the inner method runs: validate the certificate's CA and name, and refuse if either is wrong. MSCHAPv2 itself provides the server no way to prove it already knows the password — it is a one-sided challenge/response — so a tunnel to a rogue server completes just as happily as a tunnel to the real one.

### Why the weakness exists

The weakness is **not** in MSCHAPv2's cryptography and not in PEAP's design; it is the client's **phase-1 trust decision being absent**. When a supplicant has no `ca_cert` configured (and no `domain_suffix_match`), it accepts any certificate the server offers — self-signed, wrong name, wrong CA, it does not care — and proceeds to tunnel its credentials to that server. A rogue RADIUS server exploits exactly this: it answers for the lab SSID, presents *a* certificate (its own, unrelated to the lab CA), and because the client checks nothing, it terminates the client's tunnel and reads the inner MSCHAPv2 exchange in the clear on its side. A client that performs the two checks from 10.2 would abort in phase 1 and never send the inner exchange at all — which is the whole point of 11.5.

> [!IMPORTANT]
> Say this precisely in a report: the finding is "**the client does not validate the RADIUS server certificate**," not "PEAP is insecure." The same PEAP server and the same MSCHAPv2 method are perfectly safe in front of a validating client. The vulnerability lives entirely in client configuration.

### Prerequisites & affected configurations

To capture, you need: a rogue RADIUS/AP (`hostapd-wpe` or `eaphammer`) advertising the **same SSID** as the lab network; a **client that does not validate the server** — here, the `client-peap-insecure.conf` from Module 10 (no `ca_cert`, no `domain_suffix_match`), representing a real device whose profile was set up by hand or without a managed CA; and the client attempting to join (naturally, or because its real network is unavailable). It works against **PEAP/MSCHAPv2** and **EAP-TTLS** tunnelled password methods. It does **not** work against a validating client (it aborts in phase 1), and it yields nothing reusable against **EAP-TLS**, where the client sends a certificate, not a password ([10.2](../module-10/lesson-02.md)).

### How a tester recognises it

You know the condition is present before you attack by reading the client profile or policy: **no trusted-CA pin and no expected-server-name** means phishable. During the attack, success looks like the rogue server logging an inner identity and an MSCHAPv2 **challenge/response pair** for that identity — `hostapd-wpe` prints the username, the server challenge, the peer challenge, and the response, and writes them in both `asleap` and hashcat/John formats. A *validating* client, by contrast, produces a TLS alert and no inner exchange — you will capture that refusal in 11.5 and recognise it as the hardened outcome.

### Manual method

Conceptually the rogue server is just your Module 10 FreeRADIUS with the certificate check inverted and verbose credential logging turned on: it accepts any client, logs the inner challenge/response, and does not care whether the password is actually correct (it never verifies it — it only needs the client to *send* the exchange). You do not hand-build it; the two tools below are the standard, auditable implementations. The key manual act is the comparison: run it once against the **insecure** client and once against the **validating** client and watch only the first leak.

### Tooling

Path **V** is first-class: both tools run inside the VM on `mac80211_hwsim`, transmitting nothing.

**`hostapd-wpe`** (hostapd with the "Wireless Pwnage Edition" patch) — a rogue authenticator plus inner-credential logger:

```bash
# Advertise the SAME SSID as the lab network on the AP radio (wlan0).
# hostapd-wpe ships an example config and its own (attacker) certificate.
sudo hostapd-wpe /etc/hostapd-wpe/hostapd-wpe.conf
# ^ set ssid=LAB-ENTERPRISE; it presents ITS cert (not the lab CA's) and logs inner MSCHAPv2.
```

**`eaphammer`** — automates the same against WPA/WPA2-EAP, generating a certificate and harvesting credentials:

```bash
# One-time: generate the attacker certificate eaphammer will present.
./eaphammer --cert-wizard
# Stand up the rogue AP for the lab SSID and capture EAP credentials:
sudo ./eaphammer -i wlan0 --essid LAB-ENTERPRISE --creds
```

Either way, when the **insecure** client (`client-peap-insecure.conf`) tries to join, the tool records the inner MSCHAPv2 exchange. A captured line looks like (synthetic identity):

```text
username:    labuser@lab.local
challenge:   <8-byte server challenge, hex>
response:    <24-byte MSCHAPv2 response, hex>
jtr NETNTLM: labuser@lab.local:$NETNTLM$<challenge>$<response>
```

> [!NOTE]
> `hostapd-wpe`/`eaphammer` flags, config paths, and output formats drift across versions (`volatility: implementation`, [`../../TOOLS.md`](../../TOOLS.md)). Treat a changed flag or a moved config file as a troubleshooting exercise — read the tool's own `--help`/wiki for the version you installed, not an old blog.

### Verification & expected evidence

Success is a logged MSCHAPv2 **challenge/response** for the synthetic identity, exported in a crackable format (the `NETNTLM`/`asleap` line) — that line is the artifact you carry into [11.2](lesson-02.md). Note what it is **not**: it is not the password, and it is not a key you can use to connect. It is a password-*derived* exchange that must still be cracked offline, and (11.2) that cracking is bounded by the password's strength. Capturing it proves the client is phishable; it does not yet prove the password is weak.

### Why it may fail

- **The client validates the server** — with `ca_cert` + `domain_suffix_match` set (the Module 10 `client-peap.conf`), the client aborts in phase 1 with a TLS alert and sends **no** inner exchange. This is not a tooling failure; it is the attack correctly defeated (11.5).
- **SSID mismatch** — the client only joins an SSID in its profile; the rogue AP must advertise the lab SSID exactly.
- **EAP-TLS client** — no password is ever sent, so there is nothing to capture even if the client mis-validates.
- **Wrong radio / radio busy** (V) — run `reset-lab.sh` and re-create the `hwsim` radios; the real FreeRADIUS/hostapd from 10.3 must be stopped first so the rogue owns the SSID.

### Impact

A captured MSCHAPv2 exchange is a crackable, reusable credential if the password is weak: recover it (11.2) and you have a valid enterprise identity — often a domain account reused far beyond Wi-Fi. The impact statement is conditional and precise: "credentials are **exposed to any rogue RADIUS in range** because clients do not validate the server; whether they are then **recovered** depends on password entropy." That phrasing separates the configuration finding (always true here) from the cracking outcome (conditional), which is exactly how 11.1 and 11.2 divide.

### Remediation & blue-team view

The fix is entirely client-side and is the subject of 11.4–11.5: pin the organisation's **private CA** (`ca_cert`) and the **expected server name** (`domain_suffix_match`) in a **managed profile users cannot edit**, and ideally move to **EAP-TLS** so there is no password to phish. A blue team also watches for a **second AP advertising a known enterprise SSID** and for RADIUS logs that show authentications the real server never issued. None of these defences touch the protocol — they make the client refuse the rogue, which you will prove in 11.5.

## Hands-on

### Guided walkthrough — capture from the insecure client, then watch the validating client refuse

Reuse the Module 10 lab. The only new pieces are the rogue server and swapping which client profile you bring up.

1. **Reset and bring up two simulated radios** (AP + client), with the real 10.3 services stopped so the rogue owns the SSID:

   ```bash
   sudo ./labs/common/reset-lab.sh
   sudo ./labs/common/hwsim-up.sh 2       # wlan0 (rogue AP), wlan1 (client)
   ```

2. **Start the rogue RADIUS server** on `wlan0`, advertising `LAB-ENTERPRISE` (either tool):

   ```bash
   sudo hostapd-wpe /etc/hostapd-wpe/hostapd-wpe.conf   # ssid=LAB-ENTERPRISE in the conf
   # or: sudo ./eaphammer -i wlan0 --essid LAB-ENTERPRISE --creds
   ```

3. **Bring up the INSECURE client** on `wlan1` — the Module 10 `client-peap-insecure.conf` (no `ca_cert`, no `domain_suffix_match`):

   ```bash
   sudo wpa_supplicant -i wlan1 -c ./labs/module-10/client-peap-insecure.conf -d
   ```

4. **Read the capture.** In the rogue server's output, confirm the inner **MSCHAPv2 challenge/response** for `labuser@lab.local` and that it was written in a crackable (`NETNTLM`/`asleap`) format. Save that line — it is the input to [11.2](lesson-02.md).

5. **Now repeat with the VALIDATING client** (`client-peap.conf`): bring it up against the same rogue server and confirm it **aborts in phase 1** with a certificate/TLS alert and the rogue logs **no** inner exchange. This is the contrast you will formalise in 11.5.

6. **Tear down:**

   ```bash
   # Ctrl-C the rogue server and wpa_supplicant
   sudo ./labs/common/hwsim-down.sh
   sudo ./labs/common/reset-lab.sh
   ```

### Lab

> [!NOTE]
> **Lab paths:** V (`mac80211_hwsim` + `hostapd-wpe`/`eaphammer` + `wpa_supplicant` in a Linux VM — first-class; proves you can stand up a rogue RADIUS server and capture an inner MSCHAPv2 exchange from a non-validating client, and that a validating client refuses; does **not** reproduce real RF, drivers, range, interference, regulatory behaviour, or hardware AP/monitor quirks). P optional — swap the simulated radios for an owned adapter in AP mode and an owned client; the rogue-server and capture steps are identical and transmit **real radio in range** (owned equipment, allowlist, minimum TX, stop conditions).
> **Start state:** the Module 10 enterprise lab built and working ([10.3](../module-10/lesson-03.md)); the real 10.3 FreeRADIUS/hostapd **stopped**; `hostapd-wpe` and/or `eaphammer` installed (versions `VERIFY`, [`../../TOOLS.md`](../../TOOLS.md)); the `client-peap-insecure.conf` and `client-peap.conf` profiles to hand; nothing transmitted over the air (V).
> **Duration:** ~50 min.
> **Artifacts:** the rogue server's log showing the captured inner **MSCHAPv2 challenge/response** for `labuser@lab.local` in a crackable (`NETNTLM`/`asleap`) format (the input to 11.2); a second log showing the **validating** client aborting in phase 1 with **no** inner exchange.
> **Success criteria:** you capture the MSCHAPv2 exchange from the **insecure** client **and** you demonstrate that the **validating** client sends nothing — and you can state that the capture succeeded *only because* the first client skipped server validation. Demonstrating the validating client's refusal is itself a valid, full outcome (it is the 11.5 pass).
> **Troubleshooting:** no client joins → rogue SSID does not match the profile's `ssid`; validating client "fails" to leak → that is the **correct** result, not a bug (try the insecure profile to see the leak); rogue server won't start → the real 10.3 services still hold the radio (stop them, `reset-lab.sh`); tool flag/config path differs → check the installed version's `--help`/wiki; EAP-TLS client → nothing to capture by design.
> **Cleanup:** Ctrl-C the rogue server and `wpa_supplicant`; `sudo ./labs/common/hwsim-down.sh` then `sudo ./labs/common/reset-lab.sh` (the catch-all — managed mode, stops services). Delete the synthetic captured exchange when done; nothing was transmitted on V, so there is no RF cleanup.

> [!WARNING]
> **LAB TARGET vs REAL NETWORK:** the only SSID you may impersonate and the only client you may capture from are the **owned Module 10 lab** with the synthetic identity `labuser@lab.local` and `Lab-WiFi-Passw0rd!`. A rogue RADIUS server aimed at any real enterprise SSID harvests real users' credentials — interception, and over the air interference ([00.3](../module-00/lesson-03.md)). Prefer the virtual path.

## Exercise

A colleague runs the rogue-server capture against two of your lab clients. Client A (the insecure profile) leaks an MSCHAPv2 exchange; Client B (the validating profile) does not. The colleague writes the finding as: "**PEAP is broken — it leaks credentials to any attacker. Recommend disabling PEAP and the whole enterprise SSID.**" Rewrite the finding accurately: state the real root cause, why only one client leaked, what you actually captured (and what you did *not*), and a proportionate remediation. Do not perform any cracking — this is a written correction.

<details>
<summary>Hint</summary>

Two clients, same server, same PEAP, same method — only the client configuration differed. What one thing did Client B do that Client A did not, and in which phase? And is a captured MSCHAPv2 challenge/response the same thing as a recovered password?
</details>

<details>
<summary>Reference answer</summary>

PEAP is not broken and the method is irrelevant to the difference: both clients used the same rogue server and the same PEAP/MSCHAPv2. **Client A leaked because its profile performed no server validation** (no `ca_cert`, no `domain_suffix_match`), so in phase 1 it accepted the attacker's unrelated certificate and tunnelled its inner MSCHAPv2 exchange to the rogue server. **Client B refused in phase 1** precisely because it validated the CA and the expected server name, so it never sent an inner exchange — proof the protocol is fine and the fault is configuration. What was captured is an MSCHAPv2 **challenge/response**, a password-*derived* value, **not** the password itself and not a usable key; it must still be cracked offline (11.2) and may not fall if the password is strong. Proportionate remediation: fix the **client configuration** — enforce `ca_cert` (the org's private CA) and `domain_suffix_match` via a **managed profile users cannot edit** (11.4), and migrate toward **EAP-TLS** to remove the password entirely (11.5) — not disable PEAP or the enterprise SSID, which would punish the correctly-configured Client B for Client A's misconfiguration.
</details>

## References

- [hostapd-mana / hostapd-wpe — EAP WPE attack theory](https://github.com/sensepost/hostapd-mana/wiki/EAP-WPE-Attack-Theory) — how a rogue RADIUS server captures the inner MSCHAPv2 exchange from a non-validating client.
- [eaphammer — Attacking WPA EAP and WPA2 EAP networks](https://github.com/s0lst1c3/eaphammer/wiki/VIII.-Attacking-WPA-EAP-and-WPA2-EAP-Networks) — automating the rogue-AP credential capture and the `--cert-wizard`/`--creds` workflow.
- [RFC 2759 — MSCHAPv2](https://www.rfc-editor.org/rfc/rfc2759) — the challenge/response construction that the capture records.
- [10.2 · EAP methods](../module-10/lesson-02.md) and [10.3 · Build the lab](../module-10/lesson-03.md) — the two phases, the trust decision, and the insecure/validating profiles you reuse here.
- [11.5 · A correctly-configured client rejects the rogue server](lesson-05.md) — the defeat of this attack, with the refusal evidence.

## What you should now be able to do

- Stand up a rogue RADIUS server (`hostapd-wpe`/`eaphammer`) against the owned Module 10 enterprise lab and advertise its SSID.
- Capture a PEAP/EAP-TTLS inner MSCHAPv2 challenge/response from a client that does not validate the server certificate, in a crackable format.
- State precisely why the capture succeeds only because the client skipped server validation — and that a validating client defeats it in phase 1.
