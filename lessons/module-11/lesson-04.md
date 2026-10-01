---
id: "11.4"
module: 11
minutes: 22
practice_minutes: 45
prerequisites: ["11.1"]
objectives:
  - Configure a client to validate the enterprise server with a pinned private CA and an expected server identity.
  - Deliver that configuration in a managed profile users cannot override, and account for the certificate lifecycle.
  - Explain how EAP-TLS removes the phishable password entirely, and measure the vulnerable-versus-hardened difference.
volatility: implementation
sources:
  - title: "wpa_supplicant configuration — ca_cert, domain_suffix_match, altsubject_match, EAP-TLS"
    url: https://w1.fi/cgit/hostap/tree/wpa_supplicant/wpa_supplicant.conf
  - title: "RFC 5216 — The EAP-TLS Authentication Protocol"
    url: https://www.rfc-editor.org/rfc/rfc5216
  - title: "RFC 9190 — EAP-TLS 1.3 (EAP-TLS with TLS 1.3)"
    url: https://www.rfc-editor.org/rfc/rfc9190
last_verified: "2026-10-01"
---

# 11.4 · Hardening — trusted CA, server identity, and EAP-TLS

Every attack in this module depended on one thing: the client not checking who it was talking to. This defence lesson closes that hole directly — pin the organisation's private CA, pin the expected server name, deliver both in a managed profile the user cannot weaken, keep the certificates healthy over time, and, where you can, remove the phishable password altogether with EAP-TLS. Then you measure the difference against the vulnerable baseline so the fix is evidence, not assertion.

## Why this matters

The enterprise findings in 11.1–11.3 are not protocol bugs to patch; they are configuration gaps to close on the client. That makes hardening unusually decisive here: a single pair of settings, enforced so users cannot turn them off, converts a network that leaks credentials to any rogue RADIUS into one that refuses them — which you will prove in 11.5. The practitioner who can *write and deliver* that configuration, justify EAP-TLS as the endpoint, and show the before/after is worth far more than one who can only run the attack. This lesson is also where the "a learner passes by demonstrating the protection works" principle lands for enterprise: configuring and verifying the hardened client is a full outcome.

## Learning objectives

- Configure a client to **validate the server**: pin the organisation's **private CA** (`ca_cert`) and the **expected server identity** (`domain_suffix_match` / `altsubject_match`).
- Deliver that configuration in a **managed profile users cannot override**, and account for the **certificate lifecycle** (issuance, renewal, revocation).
- Explain how **EAP-TLS** removes the phishable password, and **measure** the vulnerable-versus-hardened difference.

## Prerequisites

- [11.1 · Assessing insecure config — credential capture](lesson-01.md) — the rogue-server attack and the exact client gap (no `ca_cert`, no `domain_suffix_match`) this lesson closes.

## Concept

### The control or process

A hardened enterprise client rests on four controls, with one migration goal:

- **Pin the private CA (`ca_cert`).** Configure the client to trust **only the organisation's own CA** — the one that signed your Module 10 RADIUS server certificate — not the public trust store. This is the single most important line: without it, the client validates nothing and the rogue server's unrelated certificate is accepted. Trusting a broad public CA set is nearly as bad as trusting none, because an attacker can present a certificate that legitimately chains to some public CA.
- **Pin the expected server identity (`domain_suffix_match`).** Even with the right CA, require the certificate's name to match the **specific server you expect** (e.g. `domain_suffix_match="radius.lab.local"`, or `altsubject_match` for a SAN). This stops a valid-but-wrong certificate — including one an attacker obtained legitimately for another name — from being accepted.
- **Deliver it in a managed profile.** The two pins only help if the user cannot delete them or click through a "trust this certificate?" prompt. Push the profile via MDM/Group Policy/configuration profile so `ca_cert` and `domain_suffix_match` are **enforced and non-editable**. A correct setting a user can disable is not a control.
- **Mind the certificate lifecycle.** The server certificate and the CA have validity periods; plan **issuance, renewal before expiry, and revocation**. A server certificate that expires silently causes mass auth failures; a CA or server key compromise requires reissuing and re-pinning. Track expiry dates and automate renewal.

- **Migration goal — EAP-TLS.** PEAP/EAP-TTLS protect a password; EAP-TLS ([RFC 5216](https://www.rfc-editor.org/rfc/rfc5216); TLS 1.3 variant in [RFC 9190](https://www.rfc-editor.org/rfc/rfc9190)) replaces it with a **client certificate and private key the client never transmits**. There is then **no password to phish and nothing to crack offline** even if a client mis-validates. The cost is operational — per-client certificate enrolment, renewal, and revocation — which is why organisations reach for validating PEAP first and treat EAP-TLS as the destination.

```text
# Hardened PEAP client (wpa_supplicant) — the two pins plus the method.
network={
    ssid="LAB-ENTERPRISE"
    key_mgmt=WPA-EAP
    eap=PEAP
    identity="labuser@lab.local"
    password="Lab-WiFi-Passw0rd!"
    ca_cert="/etc/lab/lab-ca.pem"          # pin the ORG private CA — not the public store
    domain_suffix_match="radius.lab.local" # pin the EXPECTED server name
    phase2="auth=MSCHAPV2"
}

# Hardened EAP-TLS client — no password anywhere.
network={
    ssid="LAB-ENTERPRISE"
    key_mgmt=WPA-EAP
    eap=TLS
    identity="labuser@lab.local"
    ca_cert="/etc/lab/lab-ca.pem"
    domain_suffix_match="radius.lab.local"
    client_cert="/etc/lab/labuser.pem"     # client proves possession of a private key
    private_key="/etc/lab/labuser.key"
    private_key_passwd="Lab-Key-Passw0rd!"
}
```

> [!NOTE]
> Config key names and defaults drift across `wpa_supplicant`/OS-profile versions (`volatility: implementation`, [`../../TOOLS.md`](../../TOOLS.md)). On some builds, omitting `ca_cert` makes validation silently *optional*, which is exactly the insecure state — never rely on a default; set the pins explicitly and verify (11.5).

### Vulnerable vs hardened — and how to measure

The measurement is whether the client sends a credential to a rogue server, shown by re-running the 11.1 attack against each configuration:

- **Vulnerable (no pins):** against the 11.1 rogue RADIUS server, the client completes phase 1, runs the inner method, and the rogue server **logs an MSCHAPv2 exchange**. Evidence of the hole: a captured credential.
- **Hardened (CA + name pinned, managed):** against the **same** rogue server, the client **aborts in phase 1** with a TLS/certificate alert and the rogue server logs **no inner exchange**. Evidence of the fix: a refusal and an empty capture.
- **EAP-TLS (hardened further):** even a client with weak validation sends **no password**; a rogue server captures nothing reusable. Evidence: no password-bearing exchange exists to capture.

That before/after — "rogue server captured a credential" vs "rogue server captured nothing; client refused and logged why" — is the deliverable. Producing the hardened refusal is a full, valid outcome; you formalise exactly that refusal, with its log/packet evidence, in [11.5](lesson-05.md).

## Hands-on

### Guided walkthrough — harden the client, then measure against the rogue server (paths V / P)

1. **Baseline (vulnerable).** Bring up the 11.1 rogue RADIUS server for `LAB-ENTERPRISE` and the **insecure** client (`client-peap-insecure.conf`); confirm the rogue server **captures** an MSCHAPv2 exchange. This is your "before."
2. **Harden the client.** Write the hardened PEAP profile above: pin `ca_cert` to your Module 10 lab CA (`lab-ca.pem`) and set `domain_suffix_match` to your server's name. (Treat it as "managed": in the lab you enforce it by using only this profile; in production it is pushed non-editable.)
3. **Measure.** Re-run the **same** rogue server against the hardened client; confirm it **aborts in phase 1** and the rogue server logs **no inner exchange**. Record the client-side alert and the empty rogue capture — the "after."
4. **Go further with EAP-TLS.** Swap to the EAP-TLS profile (client certificate + key issued by your lab CA, no password). Re-run the rogue server; confirm there is **no password exchange to capture** regardless of validation.
5. **Note the lifecycle.** Record the server (and client, for EAP-TLS) certificate expiry dates and the renewal/revocation plan you would use in production.

> [!WARNING]
> LAB TARGET vs REAL NETWORK — harden and test only your **own** Module 10 lab with synthetic
> identities and the lab CA ([00.3](../module-00/lesson-03.md)). The rogue server used for measurement
> impersonates your lab SSID only; never run it against a real network. On path P, AP mode and the
> rogue server transmit **real radio in range** — owned equipment, allowlist, minimum TX, stop conditions.

### Lab

> [!NOTE]
> **Lab paths:** V (`mac80211_hwsim` + the 11.1 rogue server + `wpa_supplicant` with the hardened profile + your Module 10 CA/FreeRADIUS, in the VM — proves you can configure CA/name pinning and EAP-TLS and measure that the rogue server captures nothing; does **not** reproduce real RF, drivers, range, interference, or hardware quirks). P optional — owned adapter in AP mode and an owned client; the CA/profile/EAP-TLS steps are identical and transmit real radio.
> **Start state:** the Module 10 lab ([10.3](../module-10/lesson-03.md)) with its CA (`lab-ca.pem`) and server certificate; the 11.1 rogue server available; the insecure and (to be written) hardened profiles; for EAP-TLS, a client certificate + key issued by the lab CA.
> **Duration:** ~45 min.
> **Artifacts:** the "before" rogue-server log capturing an MSCHAPv2 exchange from the insecure client; the hardened PEAP profile (pinned CA + `domain_suffix_match`); the "after" rogue-server log showing **no** inner exchange plus the client's phase-1 alert; an EAP-TLS profile and a note that no password is sent; a recorded certificate expiry/renewal/revocation plan.
> **Success criteria:** you produce the before/after measurement — rogue server captures a credential from the vulnerable client and **captures nothing** from the hardened client — and you can explain which lines caused the refusal and how EAP-TLS removes the password. **Producing the hardened "capture nothing" result is a full pass** — no attack needs to succeed.
> **Troubleshooting:** hardened client still leaks (the profile is not actually in use, or `ca_cert`/`domain_suffix_match` is unset/typo'd — the exact insecure default); hardened client won't connect to the **real** server either (`domain_suffix_match` does not match the real server cert name — check the issued name, then tighten); EAP-TLS client rejected (client cert not issued by the pinned CA, or key passphrase wrong); certificate "expired" errors (lifecycle — reissue from the lab CA).
> **Cleanup:** Ctrl-C the rogue server, real FreeRADIUS, and `wpa_supplicant`; `sudo ./labs/common/hwsim-down.sh` then `sudo ./labs/common/reset-lab.sh`. Delete synthetic keys/profiles you will not reuse; nothing transmitted on V.

> [!NOTE]
> **LAB TARGET vs REAL NETWORK:** the CA, server and client certificates, identity, and passwords are all synthetic and local to your Module 10 lab. Never pin a real organisation's CA or point these profiles at a network you do not own.

## Exercise

An organisation runs PEAP and, after reading 11.1, an admin adds `ca_cert` pointing at the system public trust store on each laptop and tells users "you can tick 'validate server certificate' in the Wi-Fi settings if you want extra security." Explain why this does **not** close the credential-capture hole, name the specific changes that would, and state what you would additionally recommend to remove the password-phishing risk entirely.

<details>
<summary>Hint</summary>

Two problems hide here: *which* CA is trusted, and *who* can turn the setting off. Trusting the public store is not the same as trusting the org's own CA — why does that still let a rogue server in? And is a checkbox the user controls a "control"? What method takes the password off the table?
</details>

<details>
<summary>Reference answer</summary>

Pointing `ca_cert` at the **public trust store** does not close the hole, because the rogue RADIUS server can present a certificate that legitimately chains to *some* public CA (or the attacker can obtain one), and the client — trusting any public CA and checking no specific name — accepts it and tunnels its credentials. And making validation a **user-toggleable checkbox** means it is not a control at all: users will leave it off, click through prompts, or disable it to "fix" a connection problem. The changes that actually close it: pin **the organisation's own private CA** (not the public store) so only certificates from that CA are trusted, pin the **expected server name** (`domain_suffix_match`/`altsubject_match`) so a valid-but-wrong certificate is rejected, and deliver both in a **managed profile users cannot edit or override** (MDM/Group Policy). Together these make the client refuse the rogue server in phase 1 (11.5). To remove the password-phishing risk entirely rather than configure around it, migrate to **EAP-TLS**: the client authenticates with a certificate and private key it never sends, so there is no password for a rogue server to phish or to crack — at the cost of running client-certificate enrolment and lifecycle management.
</details>

## References

- [wpa_supplicant.conf — `ca_cert`, `domain_suffix_match`, `altsubject_match`, EAP-TLS](https://w1.fi/cgit/hostap/tree/wpa_supplicant/wpa_supplicant.conf) — the exact client settings that pin the CA, the server name, and the method.
- [RFC 5216 — The EAP-TLS Authentication Protocol](https://www.rfc-editor.org/rfc/rfc5216) — mutual certificate authentication and why no password is sent.
- [RFC 9190 — EAP-TLS 1.3](https://www.rfc-editor.org/rfc/rfc9190) — EAP-TLS over TLS 1.3.
- [11.1 · Credential capture](lesson-01.md) and [10.2 · EAP methods](../module-10/lesson-02.md) — the hole this closes and the two-check trust model.
- [11.5 · A correctly-configured client rejects the rogue server](lesson-05.md) — the measured proof that this configuration works.
- [02.3 · The secure wireless baseline](../module-02/lesson-03.md) — where managed client policy sits in the standing baseline.

## What you should now be able to do

- Configure a client to validate the enterprise server by pinning the organisation's private CA and the expected server identity.
- Deliver that configuration in a managed profile users cannot override, and account for the certificate lifecycle.
- Explain how EAP-TLS removes the phishable password, and measure the vulnerable-versus-hardened difference against the rogue server.
