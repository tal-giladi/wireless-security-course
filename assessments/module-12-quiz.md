# Module 12 quiz — Modern protections & famous attacks as context

> **Elective / advanced module.** This quiz checks the judgement this module is built on: knowing exactly
> what PMF protects and its limits, and reading KRACK, FragAttacks, and Kr00k as patched classes you verify
> per device rather than live universal breaks.

This module is **path R throughout** — analysis and reading, not exploitation. The questions reward the
honest, precise position: a PMF-required network that makes forged deauth ineffective (which is why the
WPA3 labs never depend on a deauth), and a per-device "patched / not affected / not determinable" verdict
backed by versions, chipsets, and capability bits — not a headline.

- **Format:** multiple choice, one correct answer each.
- **Pass mark:** 70%.
- **Covers:** [12.1 PMF / 802.11w](../lessons/module-12/lesson-01.md),
  [12.2 KRACK](../lessons/module-12/lesson-02.md),
  [12.3 FragAttacks and Kr00k](../lessons/module-12/lesson-03.md),
  [12.4 reading a wireless CVE into a check](../lessons/module-12/lesson-04.md).

A high-value answer here is the correctly scoped verdict — "not exposed, here is the evidence" or "not
applicable" — as much as identifying a genuinely unpatched device.
