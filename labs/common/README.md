# Shared lab files (`labs/common/`)

These files are added to **every** module's zip. They set up and tear down the lab safely on the
virtual (`mac80211_hwsim`) and physical paths, generate the recorded-data captures so the recorded path
is reproducible, and record provenance for everything shipped.

> [!WARNING]
> Every script here is for **your own lab**. `hwsim-*.sh` transmits nothing over the air (simulated
> radios). The physical helpers change your adapter's mode and regulatory domain — read
> `curriculum/lab-matrix.md` and your local radio rules first. Synthetic credentials only
> (`Lab-WiFi-Passw0rd!`, `LAB-FLAG-<uuid>`).

## Files

| File | Purpose | Path |
|---|---|---|
| `setup-check.sh` | Verify required tools are installed and report versions; check interface capabilities. | R/V/P |
| `hwsim-up.sh` | Load `mac80211_hwsim` with N simulated radios; print the `wlanX` interfaces. | V |
| `hwsim-down.sh` | Unload `mac80211_hwsim` and clean up. | V |
| `gen-captures.sh` | Generate the course's recorded-data captures on the virtual path and write checksums. | V → R |
| `make-wordlists.sh` | Build the **bounded** (contains the passphrase) and **strong-password** (no-crack) wordlists. | R |
| `reset-lab.sh` | Stop services, remove rogue APs, restore interfaces to managed mode, delete synthetic creds. | V/P |
| `CAPTURES.md` | Provenance + SHA-256 + expected-result record for every shipped capture. | R |

## Reproducing the recorded-data captures

The recorded-data path needs validated captures. Rather than ship opaque binaries, the captures are
**generated from scripts on the virtual path** (no wireless hardware), so anyone can reproduce and
verify them:

```bash
sudo ./hwsim-up.sh 3
sudo ./gen-captures.sh        # writes captures + SHA-256 into ./captures/ and updates CAPTURES.md
sudo ./hwsim-down.sh
```

> [!NOTE]
> Capture files and their checksums are committed **only after they have actually been generated and
> verified** on a real run — never hand-written. Until then `CAPTURES.md` marks each entry `PENDING`
> and the recorded-data labs point here. See `TODO_FOR_TAL.md`.

## Cleanup

Always finish a session with:

```bash
sudo ./reset-lab.sh
```
