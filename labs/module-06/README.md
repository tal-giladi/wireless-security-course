# Module 6 labs — WPA2-Personal: capture, PMKID & cracking

This module is the flagship WPA2-Personal attack-and-defence block. Its labs take you from reading a
4-way handshake, through capturing one (handshake and PMKID), to cracking it — in both the **bounded**
case (recovery expected) and the **strong-password** case (no recovery is the correct outcome) — and
finally to **hardening** your own AP and measuring that the attack now fails. Everything is doable on
the recorded (R) path with zero hardware; the virtual (V) and physical (P) paths add live capture.

> [!WARNING]
> Lessons 06.2 and 06.3 transmit. Deauthentication and `hcxdumptool` association are **over-the-air**
> actions against devices you must **own**, on your [allowlist](../../lessons/module-00/lesson-03.md),
> at minimum TX power, with stop conditions and cleanup. A private subnet does not contain radio. Prefer
> waiting over deauthing, and prefer the virtual path for transmit-heavy practice. On PMF networks, a
> successful deauth is **not** required by any lab here.

## In this module's zip

- This README.
- From [`../common/`](../common/): `hwsim-up.sh`, `hwsim-down.sh`, `setup-check.sh`, `reset-lab.sh`,
  and the generators `gen-captures.sh` (the recorded captures below) and `make-wordlists.sh` (the two
  teaching wordlists). Provenance and checksums for every capture live in
  [`../common/CAPTURES.md`](../common/CAPTURES.md).

## Supplied captures (recorded-data path)

Generated in our own lab on the virtual `mac80211_hwsim` path with synthetic credentials (passphrase
`Lab-WiFi-Passw0rd!`, SSID `Lab-Target-01`); licence CC0. **Full provenance, SHA-256 checksums, and
expected results are in [`../common/CAPTURES.md`](../common/CAPTURES.md).**

| File | What it demonstrates | Expected result |
|---|---|---|
| `wpa2-handshake-good.pcapng` / `.hc22000` | a **clean** 4-way handshake (06.1, 06.2) | cracks with `bounded.txt` → `Lab-WiFi-Passw0rd!` |
| `wpa2-handshake-partial.pcapng` | a **partial** handshake (06.2) | `hcxpcapngtool` extracts **no** hashline — teaches recognising a bad capture |
| `wpa2-pmkid.pcapng` / `.hc22000` | an **RSN PMKID** in EAPOL M1 (06.3) | clientless `-m 22000` crack with `bounded.txt` |
| `wpa2-strong.pcapng` / `.hc22000` | a clean handshake with a **20+ char random** passphrase (06.4, 06.5) | **does NOT crack** with the shipped lists — recommend the control |

> [!IMPORTANT]
> The capture binaries are **PENDING**: they are produced by [`../common/gen-captures.sh`](../common/)
> on the virtual path and committed only after a verified run records their checksums in
> [`../common/CAPTURES.md`](../common/CAPTURES.md). Until then, the lessons' commands are exact but the
> results are **documented, not yet reproduced** — mark anything you run against a missing file as
> unverified, and never hand-write a checksum. See `TODO_FOR_TAL.md`.

## Wordlists

Built by [`../common/make-wordlists.sh`](../common/) — no real secrets, synthetic lab passphrases only:

- `wordlists/bounded.txt` — **contains** `Lab-WiFi-Passw0rd!`; the bounded crack succeeds (known result).
- `wordlists/strong-absent.txt` — deliberately **excludes** the hardened AP's 20+ char random passphrase;
  recovery is not expected, and the correct outcome is to conclude infeasibility and recommend the control.

## Paths supported in this module

| Lesson | Path(s) | What the lab proves | What it does NOT prove |
|---|---|---|---|
| 06.1 handshake in depth | R | locating PMK/PTK inputs in a real handshake; the derivation | live capture, injection, RF |
| 06.2 capturing a handshake | R / V / P | telling clean from partial; (V/P) capturing from a natural join; (P) a single own-client deauth on non-PMF | (R/V) live RF capture or injection |
| 06.3 PMKID clientless capture | R / V / P | recognising/extracting a PMKID; (P) whether a real AP offers one | (R/V) real-firmware PMKID decision; live RF |
| 06.4 offline cracking | R | the `-m 22000` workflow; bounded recovery; correct no-crack outcome + estimate | live capture |
| 06.5 hardening & measuring | R / V / P | vulnerable-vs-hardened measurement; (V/P) which controls real firmware supports | (R/V) real-RF behaviour; firmware limits |

**R and V never grant physical-capture or injection credit**
([`../../curriculum/assessment-rubrics.md`](../../curriculum/assessment-rubrics.md)). Record which path
you actually used.

## Running the labs

Recorded path (no hardware, transmits nothing):

```bash
./labs/common/make-wordlists.sh                         # build bounded.txt + strong-absent.txt
sha256sum -c captures/CHECKSUMS.txt                      # verify supplied captures (once they exist)
hcxpcapngtool -o /tmp/good.hc22000 captures/wpa2-handshake-good.pcapng    # clean -> hashline
hcxpcapngtool -o /tmp/none.hc22000 captures/wpa2-handshake-partial.pcapng # partial -> none
hashcat -m 22000 captures/wpa2-handshake-good.hc22000 wordlists/bounded.txt        # bounded: recovers
hashcat -m 22000 captures/wpa2-strong.hc22000 wordlists/strong-absent.txt          # strong: Exhausted
```

Virtual path (regenerate the captures / reproduce capture end to end):

```bash
sudo ./labs/common/hwsim-up.sh 3
sudo ./labs/common/gen-captures.sh          # writes ./captures/ and ./captures/CHECKSUMS.txt
sudo ./labs/common/hwsim-down.sh
```

Physical path (own gear only — see each lesson's `### Lab` box for the start state, and
[03.4](../../lessons/module-03/lesson-04.md) to verify monitor/injection first).

## Cleanup

The recorded path transmits nothing and needs no cleanup beyond deleting scratch `hc22000`/potfiles.
The virtual lab is torn down by `hwsim-down.sh`; the physical lab by
[`../common/reset-lab.sh`](../common/) (returns interfaces to managed mode, stops services), plus a
regulatory-domain reset if you changed it and restoring any client you set to PMF-required. Never commit
a recovered real passphrase or any non-synthetic capture.
