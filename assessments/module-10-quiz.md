# Module 10 quiz — Enterprise I: architecture, EAP & building the lab

This quiz checks that you can reason about enterprise Wi-Fi as a three-role system — supplicant, authenticator, and RADIUS server — tell the EAP methods apart by where trust is anchored, and explain what breaks when a client stops validating the server. It also checks that you understand the pieces of the lab you built: the local CA, the server certificate, the authenticator's RADIUS settings, and how to verify a successful authentication.

- **Format:** multiple choice, one correct answer each.
- **Pass mark:** 70%.
- **Covers:** [28 · 802.1X roles and the relay](../lessons/module-10/lesson-01.md),
  [29 · EAP methods — PEAP, EAP-TTLS, EAP-TLS](../lessons/module-10/lesson-02.md),
  [30 · building the enterprise lab](../lessons/module-10/lesson-03.md).

The questions are scenario-based: they ask you to decide who authenticates whom, where trust lives, and why a particular configuration is safe or exploitable — not to recall definitions. These distinctions are the foundation of the attack-and-harden sequence in the next module, so if you miss several, re-read the relevant lesson before continuing.
