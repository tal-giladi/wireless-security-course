# Module 2 labs — Wi-Fi security protocols & the secure baseline

Module 2 is protocol and defence material, so its "labs" are **recorded-data reading** and a
**secure-baseline audit** — there is no attack here. Everything is the R (recorded-data) path: it proves
you can interpret advertised security and audit a configuration, **not** that you performed any live
capture, injection, or RF work. Those come on the V/P paths from Module 3 onward.

## In this module's zip

Shipped in `labs/module-02/` (this folder):

- `README.md` — this file.
- `baseline-checklist.md` — the reusable secure-baseline checklist (Lesson 02.3). Fill it in and keep it;
  Modules 6, 7, 9, and 11 measure their attacks against it.
- `ap-config-vulnerable.txt`, `ap-config-hardened.txt` — annotated, synthetic `hostapd`-style sample
  configurations to audit against the checklist (Lesson 02.3). Teaching artifacts, not real deployments.

Included automatically from `labs/common/` (added to every module zip):

- `wpa2-handshake-good.pcapng` — complete WPA2 4-way handshake; used in Lesson 02.2 to point out the
  EAPOL messages, ANonce/SNonce, and MIC. Provenance, licence, and SHA-256 are in `labs/common/CAPTURES.md`.
- The shared tooling (`setup-check.sh`, `reset-lab.sh`, `hwsim-*.sh`, generators) you'll use from Module 3 on.

## Module-2-specific captures (recorded-data path)

Two small captures are specific to this module's reading exercises. Like the rest of the course's
captures, they are generated on the virtual (`mac80211_hwsim`) path with synthetic credentials and are
committed only after a verified run, with provenance + SHA-256 recorded. **Status: PENDING** (see the
handoff note below) — until generated, the lessons that use them are read-against-a-supplied-file
exercises whose file is marked pending.

| File | Used in | Expected content / result | Provenance | SHA-256 | Status |
|---|---|---|---|---|---|
| `baseline-beacons.pcapng` | 02.1, 02.4 | beacons from several SSIDs: Open, OWE, WPA2-PSK, WPA3-SAE, transition mode, one WPA2+TKIP example — read the RSNE (AKM, cipher, PMF bits) | our lab, `mac80211_hwsim`, synthetic; CC0 | — | PENDING |
| `wpa3-sae.pcapng` | 02.2 | an SAE commit/confirm authentication exchange — shows there is **no** passphrase-only quantity to crack offline | our lab, `mac80211_hwsim`, synthetic; CC0 | — | PENDING |

**Licence (both):** our own synthetic data, CC0 / public domain, free to redistribute with the course.

## Success criteria

- A completed family table (one row per SSID) from `baseline-beacons.pcapng` naming each network's
  cipher, AKM, and PMF stance, and which SSID is transition mode (Lesson 02.1).
- A note identifying the ANonce, SNonce, and MIC in `wpa2-handshake-good.pcapng`, and a one-sentence
  statement of why `wpa3-sae.pcapng` offers an offline cracker nothing (Lesson 02.2).
- A completed `baseline-checklist.md` marking each control vulnerable/hardened with the deciding config
  line and the measurement that would prove the fix (Lesson 02.3).

## Cleanup

None — every Module 2 exercise is read-only analysis. Nothing is transmitted or captured live.

## Handoff note (not learner-facing)

`baseline-beacons.pcapng` and `wpa3-sae.pcapng` need a small generator on the virtual path (a beacon
set across security modes, and an SAE exchange). The existing `labs/common/gen-captures.sh` produces the
WPA2 handshake/PMKID set only; adding these two is a `labs/common/` change for the main session, after
which fill the SHA-256 column and flip Status to `verified <date>`. Tracked with the course-wide
captures-PENDING item.
