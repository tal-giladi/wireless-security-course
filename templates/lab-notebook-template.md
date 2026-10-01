# Lab notebook (template)

One entry per lab. The point is reproducibility and honest scope: a reader (including future you)
should be able to tell exactly what you did, on which path, and what it proved. Completion is recorded
**per path** — recorded-data and virtual work never counts as physical capture/injection.

```
Lab: <module>.<lesson> — <title>
Date: <YYYY-MM-DD>
Path used: R (recorded-data) | V (virtual mac80211_hwsim) | P (physical RF)
Credited as: analysis — recorded data | protocol lab — virtual radios | practical — physical RF

Starting state:
  - <what was configured / which capture / which interfaces>
Tools & versions:
  - <tool> <version>
Commands run:
  - <command>            # what it did and why
Artifacts produced:
  - <filename>           # SHA-256: <…>   expected result: <…>
Observations:
  - <what you saw, including why an attack failed if it did>
Vulnerable vs hardened (where applicable):
  - vulnerable: <measurement>   hardened: <measurement>   difference: <…>
Cleanup done:
  - [ ] services stopped   [ ] client restored   [ ] synthetic creds deleted   [ ] interfaces reset
```
