---
id: "06.4"
module: 6
minutes: 24
practice_minutes: 45
prerequisites: ["06.2", "06.3"]
objectives:
  - Run the hashcat mode 22000 workflow against a hc22000 file and recover a passphrase in the bounded case.
  - Reach the correct no-crack outcome against a strong passphrase — conclude infeasibility, estimate effort, and recommend the control.
  - Use aircrack-ng as an alternative cracker and explain how keyspace and hashrate bound what is recoverable.
volatility: implementation
sources:
  - title: "hashcat wiki — cracking WPA/WPA2 with mode 22000 (hc22000, PMKID and EAPOL)"
    url: https://hashcat.net/wiki/doku.php?id=cracking_wpawpa2
  - title: "aircrack-ng documentation — WPA/WPA2 dictionary cracking"
    url: https://www.aircrack-ng.org/doku.php?id=aircrack-ng
last_verified: "2026-10-01"
---

# 06.4 · Offline cracking with hashcat — bounded and strong-password cases

Cracking is where the whole module pays off or, just as importantly, correctly does not: you feed a captured `hc22000` to hashcat and either recover the passphrase or conclude — with evidence — that it is out of reach and recommend the control. This lesson runs the `-m 22000` workflow on both a **bounded** capture whose passphrase is in the supplied wordlist (a known, terminating result) and a **strong-password** capture whose passphrase is in neither list (where *not* cracking is the right answer), and shows aircrack-ng as the alternative.

> [!CAUTION]
> Only crack captures of networks **you own** or are explicitly authorised to test. A `hc22000` file is derived from a captured handshake or PMKID; possessing or cracking one for a network you do not own carries the same authorisation and interception constraints as the capture did ([00.3](../module-00/lesson-03.md)).

## Why this matters

Beginners treat a failed crack as a failure. In professional wireless work it is often the **correct, reportable outcome**: a strong passphrase that resists your agreed wordlist and is infeasible to brute-force is the control working, and saying so — with an effort estimate — is a real finding. Meanwhile the bounded case teaches the mechanics end to end so you trust the workflow. Getting both halves right is what lets you report "recovered: here is the passphrase" and "not recovered: here is why, and here is the recommendation" with equal confidence.

## Learning objectives

- Run the **hashcat `-m 22000`** workflow on a `hc22000` file and recover a passphrase in the **bounded** case.
- Reach the correct **no-crack** outcome against a **strong** passphrase: conclude infeasibility, **estimate effort**, and **recommend the control**.
- Use **aircrack-ng** as an alternative and explain how **keyspace and hashrate** bound what is recoverable.

## Prerequisites

- [06.2 · Capturing a handshake](lesson-02.md) — where the EAPOL `hc22000` comes from.
- [06.3 · PMKID clientless capture](lesson-03.md) — where the PMKID `hc22000` comes from (same mode 22000).

## Concept

### How the protocol works

`hashcat -m 22000` is "WPA-PBKDF2-PMKID+EAPOL": one mode that cracks **both** a captured EAPOL handshake (type 02) and a captured PMKID (type 01), because both reduce to the same offline check from lesson 06.1 — guess a passphrase, compute `PMK = PBKDF2(guess, SSID, 4096, 256)`, then recompute the captured MIC (EAPOL) or PMKID and compare. The `hc22000` file, produced by `hcxpcapngtool`, carries everything the check needs (SSID, MACs, nonces, and the MIC or PMKID). The 4096 PBKDF2 iterations make each guess expensive, so throughput is measured in modest hashes-per-second, not billions — which is exactly why passphrase entropy decides feasibility.

### Why the weakness exists

The weakness is never hashcat; it is a **guessable passphrase**. Because the check is a fast-to-verify, offline oracle, any passphrase a wordlist or a feasible brute-force reaches will fall. The defence is to put the passphrase outside that reach (lesson 06.5). This is why the two cases below are the whole point: the tool is identical, only the passphrase's entropy differs, and that difference is the finding.

### Prerequisites & affected configurations

You need a valid `hc22000` (from lesson 06.2 or 06.3) and a wordlist. The module ships two wordlists via `labs/common/make-wordlists.sh`: **`bounded.txt`**, which contains the lab passphrase `Lab-WiFi-Passw0rd!`, and **`strong-absent.txt`**, which deliberately does **not** contain the hardened AP's 20+‑character random passphrase. The captures and their `hc22000` conversions are **PENDING** a verified generation run (`labs/common/gen-captures.sh`, `CAPTURES.md`) — the commands below are exact and will work unchanged once the files land; until then, treat the expected results as documented, not yet reproduced.

### How a tester recognises it

A recovered passphrase appears in hashcat's output next to the hash (status `Cracked`), and `hashcat --show hash.hc22000 wordlist` reprints it from the potfile. An exhausted run ends with status **`Exhausted`** and no recovery — the explicit signal that the passphrase was **not** in the wordlist, which is the diagnostic you report in the strong case.

### Manual method

Both cases use the same two-step method: convert (done in 06.2/06.3), then run mode 22000 against a wordlist. The only difference is which wordlist and which capture — and therefore which outcome is correct.

### Tooling

**Bounded case — expected to recover:**

```bash
# Capture already converted to hc22000 in lesson 06.2/06.3.
hashcat -m 22000 wpa2-handshake-good.hc22000 ./wordlists/bounded.txt
hashcat -m 22000 wpa2-handshake-good.hc22000 ./wordlists/bounded.txt --show   # reprint the result
# Expected: recovers  Lab-WiFi-Passw0rd!  (the known, terminating result)
# The PMKID capture cracks identically with the SAME mode:
hashcat -m 22000 wpa2-pmkid.hc22000 ./wordlists/bounded.txt
```

**Strong-password case — expected NOT to recover:**

```bash
hashcat -m 22000 wpa2-strong.hc22000 ./wordlists/strong-absent.txt
# Expected: Status ...... Exhausted   (no recovery — the passphrase is not in the list)
# A brute-force mask shows WHY going further is infeasible, without actually finishing it:
hashcat -m 22000 wpa2-strong.hc22000 -a 3 '?a?a?a?a?a?a?a?a?a?a' --keyspace
# ^ prints the keyspace; combined with your device's H/s (hashcat -b -m 22000) you ESTIMATE the time.
```

**Alternative — aircrack-ng (dictionary, from the pcap directly):**

```bash
aircrack-ng -w ./wordlists/bounded.txt -b AA:BB:CC:DD:EE:FF wpa2-handshake-good.pcapng
# Recovers the bounded passphrase; "KEY FOUND! [ Lab-WiFi-Passw0rd! ]". aircrack-ng is CPU dictionary
# cracking straight from the capture — convenient, but hashcat (-m 22000, GPU) scales far better.
```

> [!NOTE]
> Flags drift across versions (`TOOLS.md`, `volatility: implementation`). If a run errors, check `hashcat --help` / `aircrack-ng --help` for the installed version rather than assuming the capture is bad — you already validated the capture in lesson 06.2.

### Verification & expected evidence

- **Bounded:** status `Cracked`, the passphrase `Lab-WiFi-Passw0rd!` shown, run terminates quickly. Evidence = the cracked line and `--show` output.
- **Strong:** status `Exhausted`, no passphrase, plus a **keyspace/hashrate estimate** showing a full brute-force is infeasible in any realistic engagement window. Evidence = the `Exhausted` status, the estimate, and the written recommendation to lengthen the passphrase / move to WPA3-SAE (lesson 06.5). *This is a pass, not a failure.*

### Why it may fail (and when "failure" is the right answer)

- **Passphrase not in the wordlist** — `Exhausted`. In the strong case this is the **intended** result; in the bounded case it means you used the wrong list (use `bounded.txt`).
- **Infeasible brute force** — a high-entropy passphrase's keyspace is astronomically large at ~thousands of H/s; the correct move is to estimate and stop, not to run forever.
- **Bad capture** — but you already checked this in 06.2 (`hcxpcapngtool` produced a hashline), so a valid `hc22000` that will not crack is about the passphrase, not the capture.
- **Wrong SSID bound into the hash** — the PBKDF2 salt is the SSID; a hashline for a different SSID will never match guesses for yours.

### Impact

A recovered passphrase is full network access — the complete compromise WPA2-Personal is meant to prevent. But the realistic impact statement is conditional: "recoverable **because** the passphrase was weak/guessable." Reporting the *reason* (entropy) rather than just the result is what makes the finding actionable, and it points straight at the remediation.

### Remediation & blue-team view

The only durable fix is a **passphrase outside feasible reach** — long and high-entropy — which makes every captured handshake or PMKID `Exhausted` (lesson 06.5). WPA3-SAE removes the offline-crackable value entirely (Module 7). Operationally, rotate any passphrase known to have been captured, and prefer length over complexity rules that merely frustrate users without adding real entropy. The blue-team takeaway from this lesson is concrete: run the **same crack against your own capture** as an assurance check — if your wordlist (or a feasible mask) recovers your passphrase, so can an attacker, and you change it.

## Hands-on

### Guided walkthrough — crack the bounded case, then correctly fail the strong case (path R)

1. Build the wordlists: `./labs/common/make-wordlists.sh` → `wordlists/bounded.txt`, `wordlists/strong-absent.txt`.
2. **Bounded:** `hashcat -m 22000 wpa2-handshake-good.hc22000 wordlists/bounded.txt`. Confirm it recovers `Lab-WiFi-Passw0rd!`. Repeat with `wpa2-pmkid.hc22000` — same mode, same result.
3. **Strong:** `hashcat -m 22000 wpa2-strong.hc22000 wordlists/strong-absent.txt`. Confirm **`Exhausted`**, no recovery.
4. Estimate the brute-force effort for the strong passphrase: `hashcat -b -m 22000` (your H/s) and a `--keyspace` on a representative mask; compute an order-of-magnitude time and write the **recommendation** (longer passphrase / WPA3-SAE).
5. Repeat the bounded crack with `aircrack-ng -w wordlists/bounded.txt ... wpa2-handshake-good.pcapng` to see the CPU-dictionary alternative.

### Lab

> [!NOTE]
> **Lab paths:**
> R (supplied `hc22000`/`pcapng` files + the two generated wordlists — no hardware; proves you can run the cracking workflow, recover the bounded key, and reach the correct no-crack conclusion for the strong one; it does **not** prove live capture).
> **Start state:** the recorded toolchain ([03.2](../module-03/lesson-02.md)) with `hashcat`, `hcxtools`, `aircrack-ng`; the module zip's captures (**PENDING** a verified generation run — `CAPTURES.md`); wordlists built by `make-wordlists.sh`.
> **Duration:** ~45 min (most of it is estimating and writing up the strong case, not waiting on a crack).
> **Artifacts:** the recovered bounded passphrase (hashcat `--show` output); the strong case's **`Exhausted`** status plus a written effort estimate and control recommendation; the aircrack-ng recovery line for comparison.
> **Success criteria:** **(a)** you recover `Lab-WiFi-Passw0rd!` from both the handshake and the PMKID capture with `bounded.txt`, **and (b)** you correctly conclude the strong passphrase will **not** crack in scope, back it with a keyspace/hashrate estimate, and recommend the control. **Correctly failing to crack the strong case is a full pass** — key recovery is not required for it.
> **Troubleshooting:** bounded crack says `Exhausted` (wrong wordlist — use `bounded.txt`); no hashline to crack (capture was partial — back to 06.2, or the file is still `PENDING`); very low H/s is normal for WPA (PBKDF2 is deliberately slow — do not interpret it as a fault); hashcat refuses the file (check the `hc22000` format / tool version, not the passphrase).
> **Cleanup:** none transmits; remove scratch `hc22000`/potfiles you do not need (`hashcat --potfile-path`), and never commit a recovered real passphrase. `../../labs/common/reset-lab.sh` exists for the live labs, not this one.

> [!NOTE]
> **LAB TARGET vs REAL NETWORK:** every capture here was generated in our own lab with synthetic credentials (`Lab-WiFi-Passw0rd!`, SSID `Lab-Target-01`). Crack only your own or authorised captures; a `hc22000` from someone else's network is out of bounds ([00.3](../module-00/lesson-03.md)).

## Exercise

You are handed a valid `hc22000` (it parses, hashcat accepts it) for an AP you are authorised to test. Your agreed 10-million-word list runs to `Exhausted` with no recovery, and the client asks, "So is our Wi-Fi secure?" Write the honest answer: what you can and cannot conclude from an `Exhausted` run, what you would estimate to bound the residual risk, and what you would recommend — without overstating either safety or danger.

<details>
<summary>Hint</summary>

`Exhausted` tells you the passphrase was not in *that* wordlist — it does not prove the passphrase is strong, and it does not prove it is weak against a *different* list an attacker might have. What additional fact (passphrase length/entropy, or a brute-force keyspace vs your hashrate) would you need to turn "not in my list" into a defensible risk statement? And what is the one control that makes the question moot?
</details>

<details>
<summary>Reference answer</summary>

An `Exhausted` run proves only that the passphrase is **not in the wordlist you used** — not that it is strong, and not that a larger or better-targeted attacker wordlist would also fail. So you cannot declare the Wi-Fi "secure" on that basis alone. To bound residual risk you need the **passphrase's entropy**: if it is long and random, a brute force over its keyspace at realistic WPA hashrates (thousands of H/s due to PBKDF2's 4096 iterations) is infeasible for any practical engagement — you estimate the order of magnitude and state it. If it is short or structured (a word plus digits), a smarter wordlist or mask could still recover it, so "not cracked by my list" is weak assurance. Honest answer: "Your passphrase resisted a 10-million-word dictionary; whether it resists a determined attacker depends on its entropy. If it is a long random passphrase, the residual risk is low and a full brute force is infeasible; if it is a memorable phrase, increase its length/entropy or move to WPA3-SAE, which removes the offline-crackable material entirely." The decisive recommendation is the control (entropy / WPA3-SAE, lesson 06.5), not a blanket verdict.
</details>

## References

- [hashcat wiki — cracking WPA/WPA2 (mode 22000)](https://hashcat.net/wiki/doku.php?id=cracking_wpawpa2) — the `hc22000` workflow for both EAPOL and PMKID.
- [aircrack-ng — WPA/WPA2 dictionary cracking](https://www.aircrack-ng.org/doku.php?id=aircrack-ng) — the CPU-dictionary alternative.
- [`../common/CAPTURES.md`](../../labs/common/CAPTURES.md) and [`../common/make-wordlists.sh`](../../labs/common/make-wordlists.sh) — the PENDING captures and the bounded/strong wordlists.

## What you should now be able to do

- Run the hashcat mode 22000 workflow on a `hc22000` file and recover a passphrase in the bounded case (handshake and PMKID alike).
- Reach the correct no-crack outcome against a strong passphrase — conclude infeasibility, estimate effort, and recommend the control.
- Use aircrack-ng as an alternative and explain how keyspace and hashrate decide what is recoverable in scope.
