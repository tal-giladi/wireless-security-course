# Module 11 quiz — Enterprise II: attack, harden & retest

This quiz checks that you can reason about the enterprise attack-and-defence sequence as one argument: that credential capture succeeds only because a client fails to validate its server, that capture and relay are different findings, that a captured MSCHAPv2 exchange is a crackable value bounded by password entropy, and that a correctly-configured client defeats the whole attack in phase 1. It also checks that you can state the controls — a pinned private CA, an expected server name, managed profiles, and EAP-TLS — and the evidence that proves they work.

- **Format:** multiple choice, one correct answer each.
- **Pass mark:** 70%.
- **Covers:** [47 · Assessing insecure config — credential capture](../lessons/module-11/lesson-01.md),
  [48 · Cracking captured MSCHAPv2](../lessons/module-11/lesson-02.md),
  [49 · Relay versus capture](../lessons/module-11/lesson-03.md),
  [50 · Hardening — trusted CA, server identity, and EAP-TLS](../lessons/module-11/lesson-04.md),
  [51 · A correctly-configured client rejects the rogue server](../lessons/module-11/lesson-05.md).

The questions are scenario-based: they ask you to classify a finding, decide what evidence supports a claim, and choose a proportionate remediation — not to recall definitions. Remember that this module explicitly lets you pass by demonstrating that a defence works, so several questions turn on recognising a correctly-configured client's refusal as the intended outcome. If you miss several, re-read the relevant lesson before moving on.
