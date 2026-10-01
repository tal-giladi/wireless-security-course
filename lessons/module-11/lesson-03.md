---
id: "11.3"
module: 11
minutes: 20
practice_minutes: 30
prerequisites: ["11.1"]
objectives:
  - Distinguish offline credential capture from live relay as two different enterprise findings with different evidence and impact.
  - State the preconditions under which a live EAP/credential relay is possible and when it is lab-safe to demonstrate.
  - Choose and justify the correct finding and wording for a given observation, without conflating capture and relay.
volatility: concept
sources:
  - title: "eaphammer — GTC downgrade and credential relay against WPA EAP networks"
    url: https://github.com/s0lst1c3/eaphammer/wiki/VIII.-Attacking-WPA-EAP-and-WPA2-EAP-Networks
  - title: "RFC 2759 — Microsoft PPP CHAP Extensions, Version 2 (MSCHAPv2)"
    url: https://www.rfc-editor.org/rfc/rfc2759
  - title: "hostapd-mana / hostapd-wpe — EAP WPE attack theory"
    url: https://github.com/sensepost/hostapd-mana/wiki/EAP-WPE-Attack-Theory
last_verified: "2026-10-01"
---

# 11.3 · Relay versus capture

The last two lessons captured a credential and cracked it offline; this lesson draws the line between that and a different attack it is routinely confused with — relaying the credential live to authenticate in real time. They look superficially alike (both start with a rogue server in front of a careless client), but they are different findings with different preconditions, evidence, and impact, and writing one when you mean the other is a real reporting error. You will reason through both, state precisely when a live relay is even possible, and keep the demonstration conceptual except where it is genuinely lab-safe.

> [!WARNING]
> This lesson discusses an offensive technique (live relay). Any practical element runs **only** against the owned Module 10 lab with synthetic identities, on simulated radios (path V). A relay that forwards a real user's credential to a real network is unauthorised access to that network — out of scope here and in most jurisdictions an offence ([00.3](../module-00/lesson-03.md)). Keep relay conceptual unless every endpoint is yours.

## Why this matters

"We captured credentials" and "we relayed into the network" are two different sentences in a report, with two different impacts and two different fixes emphasised. Capture is an **offline** problem: you obtain a password-derived exchange and its value depends on cracking it later (11.2). Relay is a **live** problem: you forward the client's authentication to the real server as it happens, so you may gain access **without ever knowing the password**. Conflating them leads to classic mistakes — claiming "we got in" when you only have an uncracked exchange, or dismissing a strong-password network as safe when a live relay could still ride the user's authentication. Knowing which one you are looking at, and which preconditions each needs, is what makes the finding accurate.

## Learning objectives

- **Distinguish** offline credential capture (11.1–11.2) from live relay as two findings with different evidence and impact.
- State the **preconditions** under which a live EAP/credential relay is possible, and when it is **lab-safe** to demonstrate.
- Choose and justify the **correct finding and wording** for a given observation, without conflating the two.

## Prerequisites

- [11.1 · Assessing insecure config — credential capture](lesson-01.md) — the rogue-server setup and the captured MSCHAPv2 exchange that both attacks begin from.

## Concept

### How the protocol works — the shared starting point

Both attacks begin identically: a client that does not validate the server builds its PEAP/EAP-TTLS tunnel to a rogue RADIUS server ([11.1](lesson-01.md)). What the rogue server *does* with the inner exchange is where they diverge.

- **Capture (offline):** the rogue server simply **logs** the inner MSCHAPv2 challenge/response and lets the authentication fail or complete against itself. You walk away with a password-derived value to crack later (11.2). No access is gained at capture time; the payoff is deferred and conditional on password strength.
- **Relay (live):** the rogue server, instead of just logging, acts as a **man-in-the-middle between the client and the *real* RADIUS server** — forwarding the client's inner responses to the legitimate server as they arrive and passing the server's challenges back, so the real server sees a valid authentication. If it completes, the attacker may ride that authenticated session **without ever recovering the password**.

### Why the weakness exists

Both exploit the same root cause — the client not validating the server — so the attacker can insert itself into phase 1. But relay needs more than capture does, and that extra requirement is why it is a distinct, often *harder* finding:

- **A reachable, live real server.** Relay forwards to the genuine RADIUS server in real time, so the attacker must have a path to it and the authentication must be happening *now*. Capture needs neither — it works offline and after the fact.
- **A relayable challenge/response structure, with timing.** MSCHAPv2's challenge/response can in principle be forwarded, but the attacker must sit in the live exchange and satisfy the real server's challenge within the protocol's timing. Tunnel binding and server-side protections can break this.
- **The usual mitigations bite relay specifically.** A validating client defeats *both* (it never tunnels to the attacker). But even against a careless client, protections like **channel/tunnel binding** (e.g. cryptobinding in PEAP) and well-configured servers can allow capture while frustrating a clean live relay.

### How a tester recognises which one applies

You are looking at **capture** when your evidence is a **logged inner exchange** you take away to crack — the attacker's server terminated the tunnel and nothing was forwarded. You are looking at **relay** when your evidence is a **live authenticated session or an `Access-Accept` from the *real* server** obtained by forwarding the client's responses — access without a recovered password. The decisive question is: *did anything reach the legitimate server in real time, and did the attacker gain live access?* If no, it is capture; if yes, it is relay.

### Prerequisites & affected configurations (and lab-safety)

- **Capture** needs only: a non-validating client + a rogue server (11.1). Fully lab-safe on path V — nothing leaves your VM.
- **Relay** additionally needs: a **live legitimate RADIUS server reachable from the attacker** and an exchange that can be forwarded within timing. **This is only lab-safe when the "real" server is also yours** — i.e. you relay between your rogue server and your own Module 10 FreeRADIUS, entirely inside the VM. Tools such as `eaphammer` can automate relay-style and GTC-downgrade attacks; keep any such demonstration confined to owned endpoints. Relaying toward any server you do not own is unauthorised access and out of scope.

> [!IMPORTANT]
> Relay is **not** "capture, but faster." It is a different finding: capture yields a *deferred, password-strength-bounded* credential; relay yields *immediate access without the password*. A strong password that defeats cracking (11.2) does **not** by itself defeat relay — only validating the server (and tunnel binding / EAP-TLS) does.

### Manual method (conceptual)

Conceptually, relay is the rogue server from 11.1 wired to a second RADIUS *client* leg pointed at the real server: inner responses from the victim are forwarded upstream, upstream challenges are passed back down. You will not build a cross-network relay here; the lab-safe version loops both legs through your own lab (rogue server ↔ your own 10.3 FreeRADIUS) so you can watch a forwarded exchange reach a legitimate `Access-Accept` without the attacker holding the password. Everything stays inside the VM.

### Impact

- **Capture:** exposure of a crackable credential; impact realised **later and only if** the password is weak (11.2). Report as exposure + conditional recovery.
- **Relay:** potential **immediate network access** riding the user's authentication, **independent of password strength**; impact realised **at the moment of the attack**. Report as live access (or the demonstrated potential for it), a materially higher-severity finding when its preconditions hold.

### Remediation & blue-team view

The primary control defeats both because both depend on the client talking to the attacker: **validate the server** (trusted private CA + expected name, managed profile — 11.4) and prefer **EAP-TLS**. Against relay specifically, **tunnel/channel binding** (cryptobinding) and server-side policies that bind the inner authentication to the outer tunnel raise the bar further. A blue team distinguishes the two in its own telemetry: capture may leave little on the real server, while relay produces **real-server authentications the attacker triggered** — anomalous source, timing, or AP — which is a detection opportunity.

## Hands-on

### Guided walkthrough — separate the two findings, and loop a lab-safe relay

All on path V, inside the VM, synthetic identities only.

1. **Re-run capture (from 11.1)** against the insecure client and note the evidence: a **logged inner MSCHAPv2 exchange**, nothing forwarded, no live access. Label this finding "credential capture (offline)."
2. **Reason about relay preconditions.** For the same insecure client, list what relay would additionally require: a reachable live real server (here, your own 10.3 FreeRADIUS), a forwardable exchange within timing, and the absence of tunnel binding that would break it. Decide whether each holds in your lab.
3. **Lab-safe relay loop (optional, owned endpoints only).** If you choose to demonstrate, configure the rogue server to forward the inner exchange to your **own** Module 10 FreeRADIUS and observe a legitimate `Access-Accept` produced by forwarding the victim's responses — the attacker never learns the password. Confirm both legs are your own lab and nothing leaves the VM.
4. **Write both findings side by side** for the same client: what each requires, what evidence each produced, and the different impact statement for each.

### Lab

> [!NOTE]
> **Lab paths:** V (`mac80211_hwsim` + the rogue server from 11.1 + your own Module 10 FreeRADIUS + `wpa_supplicant`, all inside the VM — proves you can tell capture from relay by their preconditions and evidence, and, optionally, loop a relay between **your own** endpoints; does **not** reproduce real RF, drivers, range, interference, or hardware quirks). There is deliberately **no** cross-network or over-the-air relay path — relaying toward a server you do not own is out of scope.
> **Start state:** the Module 10 lab ([10.3](../module-10/lesson-03.md)) and the 11.1 rogue-server setup available; the insecure and validating client profiles to hand; both RADIUS endpoints (rogue and real) are **yours**.
> **Duration:** ~30 min (mostly reasoning and write-up; the optional relay loop is short).
> **Artifacts:** a side-by-side comparison of the two findings for the same client (preconditions, evidence, impact); the 11.1 capture log as the "capture" evidence; optionally, a lab-safe relay log showing a legitimate `Access-Accept` obtained by forwarding, with the attacker holding no password.
> **Success criteria:** you correctly classify capture vs relay from the evidence, state relay's extra preconditions and when it is lab-safe, and write distinct, accurate findings for each. Demonstrating only the reasoning and the capture (no live relay) is a **full pass** — the relay loop is optional and owned-endpoints-only.
> **Troubleshooting:** relay loop produces no `Access-Accept` (timing/tunnel binding broke it — a valid observation to report, not a failure); unsure which finding you have (ask: did anything reach the legitimate server live, and was live access gained?); tempted to relay to a non-lab server (stop — out of scope and unlawful).
> **Cleanup:** Ctrl-C the rogue server, any relay leg, the real FreeRADIUS, and `wpa_supplicant`; `sudo ./labs/common/hwsim-down.sh` then `sudo ./labs/common/reset-lab.sh`. Delete synthetic logs when done; nothing transmitted on V.

> [!WARNING]
> **LAB TARGET vs REAL NETWORK:** a relay is lab-safe **only** when both the rogue server and the "real" server it forwards to are **yours**. Forwarding any client's authentication to a network you do not own is unauthorised access ([00.3](../module-00/lesson-03.md)). When in doubt, keep relay conceptual and demonstrate only capture.

## Exercise

You observe, against an authorised client that does not validate the server: your rogue RADIUS server logged an MSCHAPv2 exchange, and separately you confirmed the client's real enterprise server is reachable from your test position and uses PEAP without cryptobinding. A teammate writes: "**We relayed in and have network access.**" You have a logged exchange but did not forward anything. Decide what you can and cannot claim, name the finding(s) you can actually report, and state what would have to be true (and lab-safe) to claim a relay.

<details>
<summary>Hint</summary>

Evidence decides the finding. What did you actually do — log an inner exchange, or forward responses to the real server and gain a live session? Which of those did you have evidence for? And what extra conditions (and ownership) would a *claimed* relay require before it is both true and in scope?
</details>

<details>
<summary>Reference answer</summary>

You can claim **credential capture**: the client does not validate the server and leaked an MSCHAPv2 exchange to your rogue server — a standing exposure finding, with recovery conditional on password strength (11.2). You **cannot** claim relay or "network access": you logged an exchange but **forwarded nothing** and gained **no live session**, so there is no evidence of relay regardless of how favourable the preconditions look. Reachability of the real server and PEAP-without-cryptobinding describe a *potential* relay path, not a demonstrated one — you may report that potential as an elevated risk, clearly labelled as not demonstrated. To actually claim a relay you would need to have **forwarded the client's inner responses to the legitimate server in real time and obtained an `Access-Accept`/live access** — and, crucially, that is only lab-safe and in scope if the "real" server is **also yours** (or explicitly authorised). Against the client's genuine production server it would be unauthorised access and out of bounds. The accurate writeup is therefore: one confirmed finding (capture/exposure), one labelled-as-potential finding (relay path exists but was not demonstrated), and the shared remediation — validate the server, add cryptobinding, move to EAP-TLS.
</details>

## References

- [eaphammer — GTC downgrade and relay against WPA EAP networks](https://github.com/s0lst1c3/eaphammer/wiki/VIII.-Attacking-WPA-EAP-and-WPA2-EAP-Networks) — automation that can log (capture) or forward (relay-style) inner exchanges; owned endpoints only.
- [hostapd-mana / hostapd-wpe — EAP WPE attack theory](https://github.com/sensepost/hostapd-mana/wiki/EAP-WPE-Attack-Theory) — the rogue-server mechanics both attacks share.
- [RFC 2759 — MSCHAPv2](https://www.rfc-editor.org/rfc/rfc2759) — the challenge/response structure that is logged (capture) or forwarded (relay).
- [11.1 · Credential capture](lesson-01.md) and [11.2 · Cracking captured MSCHAPv2](lesson-02.md) — the offline half this lesson distinguishes relay from.

## What you should now be able to do

- Distinguish offline credential capture from live relay as two findings with different preconditions, evidence, and impact.
- State what a live EAP/credential relay additionally requires and when demonstrating it is lab-safe (owned endpoints only).
- Choose and justify the correct finding and wording for a given observation, without claiming relay from capture evidence.
