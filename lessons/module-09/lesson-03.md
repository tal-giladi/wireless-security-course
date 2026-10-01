---
id: "09.3"
module: 9
minutes: 20
practice_minutes: 40
prerequisites: ["09.1"]
objectives:
  - Explain that a captive portal harvesting a passphrase is social engineering, not a break of WPA2/WPA3 cryptography.
  - Stand up a controlled portal on an owned rogue AP and capture a synthetic credential from a controlled lab user.
  - State the impact and the defences honestly, keeping the social-engineering boundary explicit throughout.
volatility: implementation
sources:
  - title: "wifiphisher documentation — captive-portal phishing workflow and templates"
    url: https://wifiphisher.org/
  - title: "IEEE 802.11-2020 — association and RSN (why the crypto is untouched by a portal)"
    url: https://standards.ieee.org/ieee/802.11/7028/
  - title: "RFC 8952 — captive portal architecture (terminology and mechanics)"
    url: https://www.rfc-editor.org/rfc/rfc8952
last_verified: "2026-10-01"
---

# 09.3 · Captive portals — social engineering, not a crypto break

A captive portal that tricks a user into typing their Wi-Fi passphrase into a fake page recovers that passphrase by **deception, not decryption** — it does not break WPA2 or WPA3 cryptography, and keeping that distinction explicit is the entire point of this lesson. You will stand up a controlled portal on an owned rogue AP, capture a synthetic credential from a controlled lab user, and learn to state the impact and the defences without ever implying a cryptographic weakness was exploited.

> [!WARNING]
> A captive-portal attack deceives a person into surrendering a secret. Run it **only** against a controlled lab user who has consented, on a network **you own**, with **synthetic** credentials. Never present a portal that imitates a real organisation, never target a person who has not consented, and never capture a real credential. Doing so is fraud/phishing, not a pentest ([00.3](../module-00/lesson-03.md)). Prefer the virtual path.

## Why this matters

Captive-portal credential capture is one of the most *effective* wireless attacks in practice and one of the most *misreported*. Because it ends with the attacker holding the WPA2 passphrase, it is routinely written up as "cracked the WPA2 key" — which is false and misleads the reader about both the attack and its remediation. The key was not cracked; a user was fooled. That distinction changes everything downstream: the control is not a longer passphrase (which does nothing against a user who types it into a fake page) but user awareness, network-identity validation, and policy. A tester who muddles social engineering with cryptanalysis gives the client the wrong fix. This lesson trains the precise framing and the honest impact statement.

## Learning objectives

- Explain that a portal harvesting a passphrase is **social engineering**, not a break of WPA2/WPA3 **cryptography**.
- Stand up a **controlled portal** on an owned rogue AP and capture a **synthetic** credential from a **consented** lab user.
- State the **impact** and the **defences** honestly, keeping the social-engineering boundary explicit.

## Prerequisites

- [09.1 · Rogue-AP mechanics and lures](lesson-01.md) — the portal runs on a rogue AP; you need to be able to stand one up and hand a client an address first.

## Concept

### How the protocol works

A **captive portal** is the legitimate mechanism hotels, cafés, and airports use to intercept a newly-associated client's first web requests and redirect them to a sign-in page (RFC 8952). An attacker reuses the same mechanism maliciously: the rogue AP (lesson 09.1) accepts the client's association, a DHCP server (`dnsmasq`) hands it an address, and a small web server answers **every** HTTP/HTTPS request with a convincing fake page — "router firmware update, please re-enter your Wi-Fi password," or a cloned ISP/hotel login. The user types a secret; the attacker stores it. Nothing in this flow touches the 802.11 key exchange or any cipher. The passphrase arrives because a human typed it into a form, exactly as it would in an email phishing attack — the Wi-Fi layer is merely the delivery channel.

For an **open** or keyless twin the association completes with no secret, so the portal is reached immediately. For a WPA2-PSK network the *silent* twin cannot complete the handshake without the key (lesson 09.2) — which is why the portal exists: it asks the user for the very passphrase the twin lacks. Tools often precede this with deauthentication of the real AP (non-PMF only) to make the fake "please reconnect" story believable; that step is an over-the-air DoS (lesson 06.2) and, like everywhere in this course, is restricted to owned equipment and never required for the lesson's success.

### Why the weakness exists

The weakness is **human trust in an unauthenticated network name**, compounded by the fact that an open/PSK client has no way to verify the AP's identity (lesson 09.2). There is no cryptographic flaw: WPA2's PBKDF2/handshake and WPA3's SAE are untouched. The portal works precisely because the user cannot distinguish a legitimate sign-in prompt from a forged one — a user-interface and trust problem, not a protocol one. This is why the remediation is about people and policy, and why claiming a crypto break would point the client at the wrong defence.

### Prerequisites & affected configurations

- **Any client whose user can be induced to submit a secret** is in scope for the social-engineering risk — the condition is a person, not a cipher.
- An **open/keyless association** is reached without any secret, so the portal appears immediately; a **PSK** network needs the user to supply the key the twin lacks.
- **HTTPS to real sites still warns:** a portal cannot forge a valid certificate for a real domain, so a user who notices the browser's certificate warning (or that the "site" is plain HTTP) has a tell — modern browsers make the forged page less seamless than it once was. State this honestly: the attack relies on users *not* noticing.
- **Managed/enterprise clients with provisioned profiles** that validate the network are far less exposed because the user is not the trust anchor.

### How a tester recognises it

This is an attack you *perform* in a consented lab, not one you detect passively. You know it worked when your controlled lab user submits the synthetic credential and your portal logs it. You recognise it is **social engineering** — and must be reported as such — because success required a *person to act*, not a computation to complete: no handshake was cracked, no cipher defeated, no key derived. If you could remove the human and still obtain the secret, it would be a crypto attack; you cannot, so it is not.

### Manual method

On an owned lab with a **consented** controlled user and synthetic creds only:

```bash
# 1. Rogue AP on a SYNTHETIC open SSID (lesson 09.1) so the client associates with no secret.
# 2. Hand the client an address and capture all DNS/HTTP to the portal:
#    dnsmasq: dhcp-range + address=/#/<portal-ip>   (resolve everything to the portal)
# 3. A minimal local web server serves one fake "reconnect / re-enter Wi-Fi password" page
#    and writes whatever is submitted to a local log. SYNTHETIC page, synthetic creds only.
# 4. The consented lab user submits  Lab-WiFi-Passw0rd!  -> it appears in the portal log.
```

Framework tools (e.g. `wifiphisher`) automate steps 1–3 with ready templates; on this course you use a **generic, non-branded** template and a synthetic SSID, never a template imitating a real ISP, hotel, or employer.

### Tooling

- **`hostapd`/`hostapd-mana` + `dnsmasq`** — the rogue AP and the DHCP/DNS that force all names to the portal.
- **A minimal local web server** — serves the single fake page and logs the submitted synthetic secret (no real credential ever handled).
- **`wifiphisher`** — automates the portal workflow with templates; technique-first, generic template only, owned/consented lab only.
- **`aireplay-ng --deauth`** — the *optional* non-PMF nudge to make "please reconnect" believable; an over-the-air DoS, owned client only, never required.

> [!NOTE]
> Portal tooling and templates are **`volatility: implementation`** and change often; browser HTTPS/certificate behaviour that undermines forged pages changes too. Verify against current tool and browser behaviour at test time, and keep the template generic and non-branded.

### Verification & expected evidence

The evidence is the portal log containing the **synthetic** passphrase your consented user typed, plus the `hostapd` association line showing the client was on your AP. Crucially, your write-up records **what produced the secret**: a user submitting a form — not a cracked handshake, not a recovered PMKID, not any cipher work. If asked "did you break WPA2?", the honest answer is no: you obtained the passphrase by deception; the cryptography was never defeated.

### Why it may fail

- **The user doesn't submit** — no person fooled, no secret; the attack has no cryptographic fallback.
- **HTTPS/certificate warnings tip the user off** — a forged page cannot present a valid cert for a real domain; an alert user stops.
- **PSK client never associates** to show the portal (silent twin lacks the key and you did not, or could not, nudge a PMF client) — present the open-SSID path instead, or accept that the condition isn't met.
- **Managed client ignores the prompt** — provisioned trust means the user isn't the decision-maker.

### Impact

If the lab user submits, the attacker holds the passphrase and can then join the *real* network and mount further attacks — a serious impact. But report it as what it is: **credential theft via social engineering**, with impact bounded by what that credential unlocks and whether other controls (segmentation, per-user auth, MFA on services) limit its use. The remediation that follows from an honest framing is user awareness and network-identity validation — **not** "use a longer passphrase," which is useless against a user who types it into a fake page.

### Remediation & blue-team view

Defences are human and policy, not cryptographic: **user awareness** (a legitimate network never pops a page demanding your Wi-Fi password; certificate warnings mean stop); **network-identity validation** so the user isn't the trust anchor — enterprise with server-cert validation (Module 11), managed client profiles, and avoiding open/guest networks that make silent association trivial; **rogue detection** (lesson 09.5) to spot the portal AP; and **minimising what a stolen passphrase unlocks** through segmentation and per-service authentication. OWE encrypts the guest link but, as always, does not authenticate the network, so it does not stop a portal twin. The through-line: because the attack is social engineering, the controls target people and trust, and a strong passphrase is not among them.

## Hands-on

### Guided walkthrough — a consented portal with synthetic creds (paths V / P)

1. **Consent and scope.** Confirm the lab user is you or a colleague who has **agreed** to the exercise; the SSID is synthetic; the credential is `Lab-WiFi-Passw0rd!`. Record this.
2. **Rogue AP + addressing.** Start the 09.1 rogue AP on a synthetic **open** SSID; run `dnsmasq` to hand an address and resolve all names to the portal.
3. **Serve the generic portal.** Run a minimal local web server with a **non-branded** "reconnect / re-enter Wi-Fi password" page that logs submissions.
4. **Capture.** The consented user associates and submits the synthetic passphrase; confirm it appears in the portal log and that `hostapd` shows the association.
5. **Write the honest line.** Draft the finding sentence: "a consented lab user submitted the synthetic passphrase to a fake portal — social engineering; WPA2/WPA3 cryptography was not broken." Note the HTTPS/certificate tell that an alert user would catch.
6. Tear everything down and delete the synthetic credential from the log.

### Lab

> [!NOTE]
> **Lab paths:**
> V (`mac80211_hwsim` + `hostapd` + `dnsmasq` + a local portal + a controlled `wpa_supplicant`/browser client — proves the portal *mechanics* and the capture flow end to end; a controlled, consented user is **required**. Does **not** reproduce real-user susceptibility, real RF, or real browser/OS captive-portal UX faithfully).
> P (owned AP-mode adapter + an owned client/browser operated by a consented lab user — shows the genuine OS captive-portal handoff and browser certificate behaviour).
> **Start state:** V — hwsim radios up ([03.3](../module-03/lesson-03.md)); 09.1 rogue AP working; `dnsmasq` and a local web server available. P — AP-mode adapter + owned client; reg domain set. Synthetic open SSID `Lab-Open-01`; synthetic credential `Lab-WiFi-Passw0rd!`; a **generic, non-branded** portal template.
> **Duration:** ~25 min (V) / ~40 min (P).
> **Artifacts:** the portal log containing the submitted **synthetic** credential; the `hostapd` association line; a one-sentence finding that explicitly labels the result social engineering and states the crypto was untouched; a note of the certificate/HTTPS tell.
> **Success criteria:** you capture the synthetic credential from the **consented** lab user through the portal **and** your write-up correctly frames it as social engineering rather than a crypto break. Equally valid: the consented user *notices the certificate warning and declines*, and you record that the control (user awareness) worked — a protection-works pass.
> **Troubleshooting:** client associates but no portal (DNS not redirected — check `dnsmasq address=/#/`); page loads but submission not logged (web-server write path); real HTTPS sites throw cert errors (expected — that is the user's tell, not a bug); PSK twin never reaches the portal (use the open-SSID path).
> **Cleanup:** stop the web server, `dnsmasq`, `hostapd`; delete the captured synthetic credential and any template; `../../labs/common/reset-lab.sh`; on V, `../../labs/common/hwsim-down.sh`.

> [!CAUTION]
> **LAB TARGET vs REAL NETWORK, and a person, not a device:** the portal may imitate **only a generic, synthetic** page, the user must have **consented**, and the credential must be **synthetic**. Never imitate a real organisation's page, never target a non-consenting person, never capture a real secret. That is phishing/fraud, outside any pentest authorisation ([00.3](../module-00/lesson-03.md)).

## Exercise

A colleague's draft reads: "Using a captive portal we cracked the WPA2 passphrase of the guest network in under five minutes — recommend increasing passphrase length to 20 characters." Explain why both the characterisation and the recommendation are wrong, and rewrite the finding and remediation so they reflect what actually happened.

<details>
<summary>Hint</summary>

Ask what actually produced the passphrase: a computation against a handshake, or a person typing into a form? Then ask what a longer passphrase would change for a user who types it into a fake page. Match the remediation to the real mechanism.
</details>

<details>
<summary>Reference answer</summary>

**Why the characterisation is wrong:** nothing was "cracked." The passphrase was obtained because a user submitted it to a forged page — social engineering, with the Wi-Fi layer only as the delivery channel. WPA2's PBKDF2/handshake cryptography was never attacked; remove the human and the secret is not obtained. Calling it a crack misstates the mechanism and misleads the reader. **Why the recommendation is wrong:** passphrase length is irrelevant to this attack — a 20-character passphrase is just as easily typed into a fake portal as an 8-character one. The recommendation addresses offline cracking (Module 6), a different attack, and does nothing here. **Rewrite — finding:** "A consented lab user was induced to submit the guest passphrase to a fake captive portal served by a rogue AP. This is credential theft via social engineering; WPA2 cryptography was not broken. Impact: a stolen guest passphrase lets an attacker join the guest network, bounded by guest segmentation and per-service authentication." **Rewrite — remediation:** user awareness (no legitimate network demands your Wi-Fi password via a pop-up; heed certificate warnings); prefer networks that validate their own identity (enterprise with server-cert validation / managed profiles) so the user is not the trust anchor; rogue-AP detection; and limit what a guest passphrase unlocks via segmentation — not a longer passphrase.
</details>

## References

- [wifiphisher documentation](https://wifiphisher.org/) — the captive-portal phishing workflow and templates (generic, non-branded use only).
- [RFC 8952 — Captive Portal Architecture](https://www.rfc-editor.org/rfc/rfc8952) — the legitimate mechanism the attack abuses.
- IEEE 802.11-2020 — association and RSN: the cryptography a portal does **not** touch (`../../references/README.md`).
- [09.2 · Evil twin — conditional on client behaviour](lesson-02.md) — why a PSK silent twin needs the key the portal then asks the user to supply.

## What you should now be able to do

- State clearly that a passphrase-harvesting portal is social engineering, not a WPA2/WPA3 crypto break, and say why that distinction changes the remediation.
- Stand up a consented, synthetic-credential portal on an owned rogue AP and capture the result with honest evidence.
- Recommend the people-and-policy defences that actually counter it, and reject "use a longer passphrase" as a non-fix for this attack.
