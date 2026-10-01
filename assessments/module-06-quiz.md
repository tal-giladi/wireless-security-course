# Module 6 quiz — WPA2-Personal: capture, PMKID & cracking

This quiz checks that you can reason about the full WPA2-Personal attack-and-defence chain: how the 4-way handshake proves key knowledge without sending the key, how a handshake or a PMKID is obtained (and the honest caveats on each), how offline cracking succeeds in the bounded case and correctly fails in the strong-password case, and how hardening measurably closes the attack.

- **Format:** multiple choice, one correct answer each.
- **Pass mark:** 70%.
- **Covers:** [06.1 the 4-way handshake](../lessons/module-06/lesson-01.md),
  [06.2 capturing a handshake](../lessons/module-06/lesson-02.md),
  [06.3 PMKID clientless capture](../lessons/module-06/lesson-03.md),
  [06.4 offline cracking with hashcat](../lessons/module-06/lesson-04.md),
  [06.5 hardening WPA2-Personal](../lessons/module-06/lesson-05.md).

The questions are scenario-based and deliberately reward honesty about scope: several have a correct answer that is "recognise the attack does not apply here, and recommend the control," because that judgement is exactly what the module teaches. Expect to reason about PMF, PMKID availability, and passphrase entropy rather than to recall commands. If a question on the no-crack outcome or on PMKID availability trips you up, re-read 06.4 and 06.3 before moving on.
