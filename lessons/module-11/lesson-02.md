---
id: "11.2"
module: 11
minutes: 22
practice_minutes: 45
prerequisites: ["11.1"]
objectives:
  - Convert a captured MSCHAPv2 exchange into a crackable form and recover the password in the bounded case with hashcat or asleap.
  - Reach the correct no-crack outcome against a strong password — conclude infeasibility, estimate effort, and recommend the control.
  - Explain the DES divide-and-conquer weakness that makes MSCHAPv2 responses offline-crackable and why entropy, not the method, decides the result.
volatility: implementation
sources:
  - title: "hashcat — hash mode 5500 (NetNTLMv1 / NetNTLMv1+ESS, used for MSCHAPv2)"
    url: https://hashcat.net/wiki/doku.php?id=example_hashes
  - title: "Divide and Conquer: Cracking MS-CHAPv2 with a 100% success rate (DES weakness, asleap)"
    url: https://www.cloudcracker.com/blog/2012/07/29/cracking-ms-chap-v2/
  - title: "asleap — recovering MSCHAPv2 challenge/response passwords"
    url: https://github.com/joswr1ght/asleap
last_verified: "2026-10-01"
---

# 11.2 · Cracking captured MSCHAPv2

A captured MSCHAPv2 exchange is not yet a credential — it is a password-derived challenge/response that you now try to turn back into a password. This lesson runs that offline crack two ways: against a **bounded** capture whose synthetic password is in the supplied wordlist (a known, terminating recovery) and against a **strong-password** capture where recovery is not expected and concluding so is the correct outcome. Along the way you will see exactly why MSCHAPv2 responses fall to offline cracking — a DES divide-and-conquer weakness — and why, as with WPA2, the result is decided by password entropy, not by the tool.

> [!CAUTION]
> Only crack MSCHAPv2 exchanges you captured from a network **you own** or are explicitly authorised to test. The exchange here is the synthetic `labuser@lab.local` credential from your own Module 10 lab ([11.1](lesson-01.md)); a captured exchange from any real network carries the same authorisation and interception constraints as the capture did ([00.3](../module-00/lesson-03.md)).

## Why this matters

The capture in 11.1 proves a client is phishable; this lesson decides what that is worth. A weak password turns the capture into a working enterprise identity — often a reused domain account. A strong password turns the *same* capture into a non-finding for recovery, where the honest, reportable outcome is "credentials are exposed but were not recoverable in scope; here is the effort estimate and the control." Reporting both halves with equal confidence — "recovered: here is the account" and "not recovered: here is why and what to fix" — is what separates a credible enterprise assessment from one that either over-claims or gives up. It also lets you say something precise about MSCHAPv2 that is widely misunderstood: its responses are offline-crackable **by construction**, so the defence is never "trust the method" but "do not let the exchange be captured, and do not use weak passwords."

## Learning objectives

- Convert a captured MSCHAPv2 exchange to a crackable form and **recover the password in the bounded case** with `hashcat -m 5500` or `asleap`.
- Reach the correct **no-crack outcome** against a strong password: conclude infeasibility, **estimate effort**, and **recommend the control**.
- Explain the **DES divide-and-conquer** weakness behind the crack and why **entropy**, not the method name, decides the outcome.

## Prerequisites

- [11.1 · Assessing insecure config — credential capture](lesson-01.md) — where the captured MSCHAPv2 challenge/response comes from, and the crackable (`NETNTLM`/`asleap`) output format.

## Concept

### How the protocol works

MSCHAPv2 ([RFC 2759](https://www.rfc-editor.org/rfc/rfc2759)) authenticates a client with a challenge/response over the **NT hash** of the password. The server sends an 8-byte authenticator challenge; the client derives an 8-byte challenge from that plus its own peer challenge and the username, then computes a 24-byte response by splitting the 16-byte NT hash into **three 7-byte DES keys** (the last padded with zeros) and DES-encrypting the challenge under each. The captured exchange carries the challenge, the response, and the username — everything an offline attacker needs to test password guesses.

### Why the weakness exists

That three-DES construction is the weakness. The recovery reduces to finding the NT hash whose three DES keys produce the captured response — and the **third DES key is only two bytes of the NT hash padded with five zero bytes**, so it has at most 2<sup>16</sup> possibilities and is recovered almost instantly, which in turn constrains the search for the rest. Published work shows MSCHAPv2 responses reduce to **breaking a single DES key** (a bounded, GPU/FPGA-feasible 2<sup>56</sup> or, via a precomputed lookup, near-instant recovery of the NT hash). The practical consequence: once you have the exchange, recovering the **NT hash** is cheap, and recovering the **password** is then an ordinary offline guess-and-check against that hash — exactly the entropy-bound problem you met with WPA2 ([06.4](../module-06/lesson-04.md)). The method cannot be "configured" to resist this; the only defences are not leaking the exchange (11.4–11.5) and strong passwords.

### Prerequisites & affected configurations

You need a captured MSCHAPv2 exchange (from [11.1](lesson-01.md)) in a crackable format and a wordlist. The module ships the exchange in two forms via the lab scripts: a **bounded** capture whose synthetic password `Lab-WiFi-Passw0rd!` is present in `bounded.txt` (reused from Module 6, `labs/common/make-wordlists.sh`), and a **strong** capture whose 20+-character random password is **absent** from `strong-absent.txt`. These captured exchanges and their converted hashlines are **PENDING** a verified generation run (`labs/common/gen-captures.sh`, [`../common/CAPTURES.md`](../../labs/common/CAPTURES.md)) — the commands below are exact and will work unchanged once the files land; until then treat the expected results as documented, not yet reproduced.

### How a tester recognises it

A recovered password shows in hashcat's output with status `Cracked` (and `hashcat --show` reprints it from the potfile), or `asleap` prints `password: ...`. An exhausted run ends with status **`Exhausted`** and no recovery — the explicit signal that the password was **not** in the wordlist, which is precisely the diagnostic you report in the strong case.

### Manual method

Two steps: get the exchange into the right format (11.1's tools already emit a `NETNTLM`/`asleap` line), then run it against a wordlist. The bounded and strong cases use the identical method; only the wordlist and the capture differ, and therefore so does the correct outcome.

### Tooling

**Bounded case — expected to recover.** `hostapd-wpe`/`eaphammer` write a hashcat `-m 5500` (NetNTLMv1) line; crack it:

```bash
# hash.5500 holds the captured NETNTLM line for labuser@lab.local (from 11.1).
hashcat -m 5500 hash.5500 ./wordlists/bounded.txt
hashcat -m 5500 hash.5500 ./wordlists/bounded.txt --show        # reprint the recovered password
# Expected: recovers  Lab-WiFi-Passw0rd!  (the known, terminating result)
```

`asleap` is the classic dedicated alternative, straight from the challenge/response:

```bash
asleap -C <server-challenge-hex> -R <response-hex> -W ./wordlists/bounded.txt
# Expected: "password: Lab-WiFi-Passw0rd!"
```

**Strong-password case — expected NOT to recover:**

```bash
hashcat -m 5500 hash-strong.5500 ./wordlists/strong-absent.txt
# Expected: Status ...... Exhausted   (no recovery — the password is not in the list)
# Estimate why going further is infeasible, without running it to completion:
hashcat -m 5500 hash-strong.5500 -a 3 '?a?a?a?a?a?a?a?a?a?a?a?a' --keyspace
# ^ prints the keyspace; with your device's H/s (hashcat -b -m 5500) you ESTIMATE the time.
```

> [!NOTE]
> There is also a **DES "shucking" path** (recover the NT hash first via a single-DES solve — mode `14000`
> or a precomputed service — then crack the password from the hash). It makes recovering the *hash*
> near-certain, but recovering the *password* from the hash is still entropy-bound, so it does **not**
> change the strong-password conclusion. Tool modes/flags drift across versions (`volatility: implementation`,
> [`../../TOOLS.md`](../../TOOLS.md)) — check `hashcat --help` / `asleap -h` for the version you installed.

### Verification & expected evidence

- **Bounded:** status `Cracked`, password `Lab-WiFi-Passw0rd!` shown, `--show`/`asleap` confirms, run terminates quickly. Evidence = the cracked line.
- **Strong:** status `Exhausted`, no password, plus a **keyspace/hashrate estimate** showing a full brute-force is infeasible in a realistic engagement window. Evidence = the `Exhausted` status, the estimate, and the written recommendation. *This is a pass, not a failure.*

### Why it may fail (and when "failure" is the right answer)

- **Password not in the wordlist** — `Exhausted`. In the strong case this is the **intended** result; in the bounded case it means you used the wrong list (use `bounded.txt`).
- **Infeasible brute force** — a high-entropy password's keyspace is astronomically large; the correct move is to estimate and stop, not run forever.
- **Malformed hashline** — the capture converted wrong; re-export from the 11.1 tool, not an old format. You already confirmed the exchange was captured in 11.1, so this is a format issue, not a missing credential.
- **Wrong challenge paired with the response** — `asleap` needs the challenge and response from the *same* exchange; mixing captures yields no recovery.

### Impact

A recovered password is a valid enterprise identity — frequently the user's primary domain credential, usable well beyond Wi-Fi. State the impact conditionally: "recoverable **because** the password was weak/guessable, exposed **because** the client did not validate the server." That two-part statement ties the cracking outcome (11.2) back to the configuration finding (11.1) and points straight at both controls.

### Remediation & blue-team view

MSCHAPv2 cannot be hardened against this offline crack, so the durable fixes are upstream: stop the exchange being captured at all by **validating the server** (11.4–11.5), remove the password with **EAP-TLS**, and enforce **high-entropy passwords** so a captured exchange goes `Exhausted`. Operationally, **rotate any credential known to have been captured** and prefer length over complexity rules. The blue-team assurance check mirrors Module 6: crack your *own* captured lab exchange — if your wordlist recovers it, so can an attacker, and you change the password and (better) the client configuration.

## Hands-on

### Guided walkthrough — crack the bounded case, then correctly fail the strong case (path R)

1. Build the wordlists (same script as Module 6): `./labs/common/make-wordlists.sh` → `wordlists/bounded.txt`, `wordlists/strong-absent.txt`.
2. **Bounded:** `hashcat -m 5500 hash.5500 wordlists/bounded.txt`. Confirm it recovers `Lab-WiFi-Passw0rd!`. Repeat with `asleap -C ... -R ... -W wordlists/bounded.txt` to see the dedicated alternative.
3. **Strong:** `hashcat -m 5500 hash-strong.5500 wordlists/strong-absent.txt`. Confirm **`Exhausted`**, no recovery.
4. Estimate the brute-force effort for the strong password: `hashcat -b -m 5500` (your H/s) and a `--keyspace` on a representative mask; compute an order-of-magnitude time and write the **recommendation** (strong passwords, validate the server, EAP-TLS).
5. Write the two-line finding: the configuration exposure (always true) and the recovery outcome (conditional).

### Lab

> [!NOTE]
> **Lab paths:** R (supplied captured MSCHAPv2 exchanges + the two generated wordlists — no hardware; proves you can run the cracking workflow, recover the bounded password, and reach the correct no-crack conclusion for the strong one; it does **not** prove live capture — that is [11.1](lesson-01.md) on path V/P). This lesson is recorded-data analysis by design.
> **Start state:** the recorded toolchain ([03.2](../module-03/lesson-02.md)) with `hashcat` and `asleap`; the module zip's captured exchanges (`hash.5500`, `hash-strong.5500` — **PENDING** a verified generation run, [`../common/CAPTURES.md`](../../labs/common/CAPTURES.md)); wordlists built by `make-wordlists.sh`.
> **Duration:** ~45 min (most of it estimating and writing up the strong case, not waiting on a crack).
> **Artifacts:** the recovered bounded password (hashcat `--show` / `asleap` output); the strong case's **`Exhausted`** status plus a written effort estimate and control recommendation; the two-part finding tying exposure (11.1) to recovery (11.2).
> **Success criteria:** **(a)** you recover `Lab-WiFi-Passw0rd!` from the bounded exchange, **and (b)** you correctly conclude the strong password will **not** crack in scope, back it with a keyspace/hashrate estimate, and recommend the control. **Correctly failing to crack the strong case is a full pass** — key recovery is not required for it.
> **Troubleshooting:** bounded crack says `Exhausted` (wrong wordlist — use `bounded.txt`); hashcat rejects the line (format/version — re-export from the 11.1 tool, check `--help`); `asleap` recovers nothing (challenge and response from different captures — pair them); very low H/s with the DES-shuck path is expected; file still `PENDING` (not yet generated — treat the result as documented).
> **Cleanup:** nothing transmits here. Remove scratch hashlines/potfiles you do not need (`hashcat --potfile-path`) and **never commit a recovered real password**. `../../labs/common/reset-lab.sh` exists for the live labs (11.1, 11.5), not this one.

> [!NOTE]
> **LAB TARGET vs REAL NETWORK:** every exchange here was captured in our own lab with the synthetic identity `labuser@lab.local` and synthetic passwords. Crack only your own or authorised captures; an MSCHAPv2 exchange from someone else's network is out of bounds ([00.3](../module-00/lesson-03.md)).

## Exercise

You captured an MSCHAPv2 exchange from a client you are authorised to test. Your agreed 10-million-word list runs to `Exhausted`, and the client asks, "So our enterprise Wi-Fi is safe, right — you couldn't get in?" Write the honest answer: distinguish the two separate findings in play, say what an `Exhausted` crack does and does not prove, what you would estimate to bound the residual risk, and what you would recommend — without overstating either safety or danger.

<details>
<summary>Hint</summary>

There are two findings, not one: *were credentials exposed* (what did 11.1 show about the client?) and *were they recovered* (what does `Exhausted` tell you?). `Exhausted` means the password was not in *that* list — not that it is strong, and not that a better-targeted list would also fail. What extra fact turns "not in my list" into a defensible statement, and which control makes the exposure itself go away?
</details>

<details>
<summary>Reference answer</summary>

Separate the two findings. **Exposure:** the fact that you captured an MSCHAPv2 exchange at all means the client did **not** validate the server (11.1) — that is a real, standing finding regardless of whether you cracked it, because any rogue RADIUS in range would harvest the same exchange. **Recovery:** the `Exhausted` crack proves only that the password was **not in the wordlist you used** — not that it is strong, and not that a larger or better-targeted attacker list would fail. So you cannot declare the Wi-Fi "safe": the credentials were exposed, and whether they fall depends on the password's **entropy**. To bound the residual risk you need that entropy — a long random password makes recovery infeasible at realistic hashrates (estimate the keyspace vs your H/s and state the order of magnitude); a memorable phrase could still fall to a smarter list. Honest answer: "Your client leaked an MSCHAPv2 exchange because it does not validate the RADIUS server — that is the finding to fix first, independent of cracking. The captured password resisted a 10-million-word list; whether it resists a determined attacker depends on its entropy. Fix the exposure by enforcing server-certificate validation via a managed profile and moving toward EAP-TLS; strengthen the password meanwhile." The decisive recommendations are the controls (validate the server / EAP-TLS / entropy), not a blanket verdict.
</details>

## References

- [hashcat — example hashes (mode 5500, NetNTLMv1, used for MSCHAPv2)](https://hashcat.net/wiki/doku.php?id=example_hashes) — the `-m 5500` format and workflow.
- [Divide and conquer: cracking MS-CHAPv2 (the DES weakness)](https://www.cloudcracker.com/blog/2012/07/29/cracking-ms-chap-v2/) — why MSCHAPv2 responses reduce to breaking a single DES key, and the role of the zero-padded third key.
- [asleap](https://github.com/joswr1ght/asleap) — recovering MSCHAPv2 challenge/response passwords from the captured exchange.
- [11.1 · Credential capture](lesson-01.md) and [06.4 · Offline cracking](../module-06/lesson-04.md) — where the exchange comes from and the bounded/strong-password discipline.
- [`../common/CAPTURES.md`](../../labs/common/CAPTURES.md) and [`../common/make-wordlists.sh`](../../labs/common/make-wordlists.sh) — the PENDING captured exchanges and the bounded/strong wordlists.

## What you should now be able to do

- Convert a captured MSCHAPv2 exchange to a crackable form and recover the password in the bounded case with `hashcat -m 5500` or `asleap`.
- Reach the correct no-crack outcome against a strong password — conclude infeasibility, estimate effort, and recommend the control.
- Explain the DES divide-and-conquer weakness that makes MSCHAPv2 responses offline-crackable, and why entropy and not leaking the exchange — not the method name — decide the result.
