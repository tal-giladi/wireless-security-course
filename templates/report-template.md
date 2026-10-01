# Wireless engagement report (template)

Copy this into your own document and fill every section. A good wireless report is read by two
audiences: a decision-maker who reads only the executive summary, and an engineer who reproduces and
fixes each finding. Serve both. Obtaining a key is not the deliverable — **justified findings, honest
limitations, and verified remediation** are.

## Executive summary

Three to six sentences, no jargon. What was tested, the overall risk, the two or three things that most
need fixing, and whether exploitation was demonstrated or inferred. State residual risk in one line.

## Scope & authorisation

- Networks / BSSIDs / SSIDs in scope (the allowlist). Everything else was explicitly out of scope.
- Who authorised the test, when, and the time window.
- Transmission constraints agreed (channel(s), TX power, directional/shielded), and stop conditions.
- Lab paths used and what each proves (R recorded-data · V virtual · P physical RF).

## Methodology

Tools and versions, recon approach (passive/active), capture method, and analysis workflow. Enough
that a peer could repeat it.

## Findings

One subsection per finding. For each:

- **Title & severity** (with the rationale for the severity).
- **Affected configuration** — the precise conditions (e.g. "WPA2-PSK, PMF disabled, 8-char lowercase
  passphrase"; "enterprise client that does not validate the RADIUS server certificate").
- **Evidence** — the capture / log / command output that proves it, with artifact filenames and
  checksums. Redact real secrets; lab uses synthetic credentials.
- **Why it works / why it may fail** — the mechanism, and the preconditions that must hold.
- **Impact** — what an attacker gains, framed to the client's assets, not a generic CVSS recital.

## Limitations

What you did **not** test and why (out of scope, no hardware for a path, time box, PMF prevented a
technique). A finding absent from this report is not a guarantee of safety. Be explicit.

## Remediation

Prioritised, concrete, and verifiable. For each finding, the control and how to confirm it took effect
(the vulnerable-vs-hardened measurement — e.g. "deauth now rejected with PMF", "PMKID suppressed",
"client rejects the rogue RADIUS").

## Retest & residual risk

What you retested after remediation and the result, plus the risk that remains (e.g. "passphrase
strengthened but WPS still enabled"; "SAE-only configured but legacy clients dropped"). Residual risk
is a sentence a decision-maker can act on.
