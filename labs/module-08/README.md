# Module 8 labs — WPS (elective)

These labs are for the **elective** WPS module. The practical attack is Pixie Dust (08.2); the practical
defence is disabling WPS and measuring it (08.4). The online PIN brute (08.3) has **no lab** by the
course's deprecation rule.

> [!WARNING]
> LAB TARGET vs REAL NETWORK — WPS scanning and attacks are only acceptable against an AP **you own**,
> on your allowlist, with synthetic credentials ([00.3](../../lessons/module-00/lesson-03.md)). `wash` is
> passive; `reaver`/`bully` transmit — keep TX power minimal and stop if anything off-allowlist appears.

## Paths and what each proves

| Lab | V (`mac80211_hwsim`) | P (owned AP) |
|---|---|---|
| 08.2 Pixie Dust | shows the WPS exchange and tooling flow, but `hostapd` seeds nonces properly, so it **cannot** reproduce a vulnerable chipset | the only path that proves a real Pixie Dust outcome (success or resistant) |
| 08.4 harden & measure | shows the WPS IE appear/disappear via `hostapd` config | proves the before/after attack result on real firmware |

## Tools

`wash` and `reaver` (with `pixiewps`) / `bully` — see `TOOLS.md`. Versions are VERIFY at build time;
`reaver` flags (`-K` Pixie Dust, `-l` lock wait) change across forks — read the installed `--help`.

## Known starting state, artifacts, success, cleanup

- **Start:** an owned AP with WPS enabled (for the vulnerable baseline); a monitor/injection-capable
  adapter ([03.4](../../lessons/module-03/lesson-04.md)) for the physical path.
- **Artifacts:** `wash` output before/after, the Pixie Dust attempt result before/after, a per-device
  scoped finding for your report.
- **Success:** recover the PIN/PSK on a vulnerable owned AP **or** correctly conclude a patched AP
  resists Pixie Dust; then show WPS removed after remediation. A clean "not vulnerable" is a full pass.
- **Cleanup:** stop `wash`/`reaver`, restore the interface to managed mode, re-enable only intended
  settings — `../common/reset-lab.sh`.

No shipped captures are specific to this module beyond the WPS beacon referenced in 08.1/08.3, which is
PENDING a real generation run (see `../common/CAPTURES.md`).
