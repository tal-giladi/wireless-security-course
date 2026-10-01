# Module 7 labs — WPA3-SAE

These labs are mostly **virtual-first**: `mac80211_hwsim` + `hostapd` + `wpa_supplicant` reproduce SAE,
transition mode, OWE, PMF, and the SAE-only hardening end-to-end without hardware. The physical path adds
real RF but changes none of the logic. Dragonblood (07.3) is **not** exploited here — its timing/cache
side-channels cannot be reliably reproduced on a virtual radio, so that lesson's lab is a version/H2E
determination (path R/V), by design.

> [!WARNING]
> LAB TARGET vs REAL NETWORK — configure and test only your **own** AP/stack with synthetic credentials
> ([00.3](../../lessons/module-00/lesson-03.md)). WPA3 mandates PMF, so **no** lab step here depends on a
> successful deauth. Never stand up an AP (SAE, OWE, or transition) impersonating a real network.

## Paths and what each proves

| Lesson | V (`mac80211_hwsim`) | P (owned AP) |
|---|---|---|
| 07.1 SAE | shows commit/confirm and that no offline hash is produced | same over real RF |
| 07.2 transition vs SAE-only | shows both-AKM beacon vs single-AKM, WPA2 client join vs refusal | same, real clients |
| 07.3 Dragonblood | shows H2E vs hunting-and-pecking **configuration** only — NOT the side-channel | determine real firmware/H2E status |
| 07.4 OWE | shows encrypted data with no password and no network authentication | same, OWE-capable client |
| 07.5 harden & verify | fully reproduces SAE-only + PMF-required + H2E and the refused WPA2 client | same over real RF |

## Tools

`hostapd`, `wpa_supplicant` (SAE/OWE/PMF config), `tshark`/Wireshark for beacons and the SAE exchange,
`labs/common/hwsim-up.sh` / `hwsim-down.sh` / `reset-lab.sh`. Versions VERIFY at build;
`sae_pwe`/`ieee80211w` keys must match your installed `hostapd`.

## Starting state, artifacts, success, cleanup

- **Start:** an owned stack supporting SAE, PMF, H2E; a WPA2-only and a WPA3 client (real or `wpa_supplicant`); OWE-capable client for 07.4.
- **Artifacts:** beacon captures (both-AKM vs SAE-only+MFPR), SAE commit/confirm capture, OWE encrypted-data capture, refused-WPA2-client log, a Dragonblood version/H2E verdict.
- **Success:** demonstrate the hardened SAE-only config and the removed downgrade surface; classify Dragonblood exposure with evidence; show OWE encrypts but authenticates nothing. Proving a protection works is a full pass.
- **Cleanup:** stop hostapd/supplicant, restore interfaces — `../common/reset-lab.sh`.

Module-specific capture `wpa3-sae.pcapng` is referenced for the R option and is PENDING a real
generation run (see `../common/CAPTURES.md`; the generator needs an SAE-exchange step added).
