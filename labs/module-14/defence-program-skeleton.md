# Defence program — skeleton (Lesson 14.1)

Fill this in from your completed `baseline-checklist.md` (Lesson 02.3). The baseline told you *what*
each hardened control is; the program adds *who owns it*, *how often it is checked*, and *the evidence
that proves it still works* (the vulnerable-vs-hardened measurement from the attack module). Keep the
completed document — it is what a decision-maker adopts and what a report's remediation section points to.

**Scope (owned lab only):** list the BSSIDs/SSIDs, APs, and clients you own and this program governs.

```
Scope: __________________________________________________
```

## Control register

| # | Control area | Introduced | Owner | Cadence | Verification (evidence it still works) |
|---|---|---|---|---|---|
| 1 | Segmentation (guest vs internal) | M2.3 | | | |
| 2 | AP administration hygiene | M2.3 | | | |
| 3 | Firmware maintenance | M2.3, M12 | | | |
| 4 | WPS configuration | M2.3, M8 | | | |
| 5 | Client policy (cert validation / MAC rand / auto-join) | M2.3, M9, M11 | | | |
| 6 | Monitoring & rogue detection | M2.3, M9.5 | | | |
| 7 | Protocol baseline (WPA3 / PMF / PSK entropy) | M6, M7 | | | |

*For the verification column, carry over the measurement you used in Lesson 02.3 — e.g. "guest-to-internal
reach attempt blocked," "forged deauth rejected under PMF," "bounded crack exhausted against strong PSK,"
"rogue RADIUS refused by the fleet."*

## Drift log — events that force an out-of-cadence re-verification

List at least three events that would require re-checking a control before its next scheduled review,
and which control each affects.

```
1. Event: ____________________  → re-verify control #____
2. Event: ____________________  → re-verify control #____
3. Event: ____________________  → re-verify control #____
```

*(Examples to beat: a firmware update — re-verify WPS and firmware; a new AP/SSID added — re-verify
segmentation and AP inventory; a support call that touched a client profile — re-verify client policy.)*
