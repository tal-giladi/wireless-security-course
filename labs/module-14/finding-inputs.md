# Report finding — supplied inputs (Lesson 14.2)

A lab result for you to turn into one complete report finding, its remediation, a one-line residual-risk
statement, and an executive summary, using `../../templates/report-template.md`. All values are
synthetic (course virtual-path lab); treat the passphrase as you would a real secret when deciding what
to quote versus redact.

## The result

- **Target (in scope, owned lab):** SSID `LAB-OFFICE`, BSSID `02:00:00:aa:bb:01`.
- **Security:** WPA2-PSK, **PMF disabled** (`ieee80211w=0`), CCMP.
- **Passphrase recovered:** `Lab-WiFi-Passw0rd!` is a *strong* example; for this finding the lab used the
  **weak** variant `summer2024` (8+ chars, lowercase+digits, dictionary-adjacent) — recovered.
- **How:** a 4-way handshake was captured when a lab client reconnected, converted to `hc22000`, and
  cracked with the supplied wordlist (bounded case — the passphrase was in the list).
- **Evidence artifact:** `wpa2-handshake-good.pcapng` (see `../common/CAPTURES.md` for its recorded
  SHA-256 and provenance) and the derived `labresult-office.hc22000`.
- **Tooling (pinned, see root `TOOLS.md`):** `hcxpcapngtool`, `hashcat -m 22000`.

## The environment (for impact framing)

`LAB-OFFICE` is a single flat network. The same SSID carries the (synthetic) internal file share
`\\LAB-FILES` and the staff laptops. There is no guest segmentation. A tester within radio range of the
building could reach the flat network once the passphrase is known.

## What to produce

1. **Finding:** title + justified severity (argue it against the assets above, not a bare score);
   affected configuration (exact); evidence (name the artifact + its checksum; note the passphrase is
   synthetic so you quote it, but a real secret would be redacted); why-it-works / why-it-may-fail (a
   connecting client was needed; a strong passphrase would not have fallen to the bounded list);
   asset-framed impact.
2. **Remediation** with its verification measurement (strong passphrase and/or WPA3-SAE; enable PMF;
   add guest/internal segmentation) — proven by the bounded crack now being exhausted and forged deauth
   being rejected.
3. **Residual risk:** one sentence (what is fixed, what remains, why).
4. **Executive summary:** 3–6 sentences, no jargon, written last — true and complete on its own.
