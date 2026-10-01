# TODO for Tal — Wireless Security course

Status: **planning revised per review; no lessons written yet.** Decisions below are needed (or
recommended) before or during content build. Honest unresolved-items list (review deliverable).

## Decisions I need from you
1. **Default adapters.** Pick 1–2 recommended USB adapters for the course default. I'll verify exact
   model+revision driver status at build time; I won't recommend a purchase until verified. See
   `curriculum/lab-matrix.md`.
2. ~~Free or paid~~ → **free** (decided). **Public GitHub repo name** (`tal-giladi/wireless-security-course`?) still needed.
3. ~~OSWP framing~~ → **approved**: "covers most OSWP objectives + modern material, disclosed gaps
   (no WEP hands-on, deep bettercap drills optional), no exam-pass promise."
4. ~~Virtual vs physical~~ → **confirmed**: V first-class for protocol/config/enterprise; **not** a
   substitute for RF/driver/injection; **P optional** (course completable on R+V with zero purchases).

## Things only you can provide / do
- Access to **real hardware** to generate and validate shipped captures (owned APs, adapters, clients)
  — captures must have provenance + SHA-256 + redistribution note.
- A **pilot learner** who didn't write the course (release check, review point 13).
- Confirm your **jurisdiction's radio rules** framing is acceptable (we give general guidance + "check
  local law," not legal advice).

## Known volatile items to re-verify at build time (never guess dates)
- Adapter driver/DKMS status per kernel; 6 GHz monitor/injection support (thin — may be dropped).
- WPA3/Dragonblood status + mitigations + affected implementation versions.
- Tool versions in `TOOLS.md` (hcxdumptool/hashcat/eaphammer/hostapd-* etc.).
- Current OSWP syllabus (re-check before publishing the coverage matrix).

## Captures must be generated on a real run (never invented)
Every shipped capture is `PENDING` until generated. The recorded-data labs reference these; they are
produced by `labs/common/gen-captures.sh` on the virtual (`mac80211_hwsim`) path — no wireless hardware
needed — and committed with real SHA-256 only after a verified run. **Action:** run the generator on a
Linux box once modules settle, paste checksums into `labs/common/CAPTURES.md`, commit the (small) files.
Still-needed generators to add to `gen-captures.sh` (shared file, main session): a beacon set across
security modes (`baseline-beacons.pcapng`, used by M2) and an SAE exchange (`wpa3-sae.pcapng`, M2);
module-01 join/beacon/probe captures + V-path configs referenced by M1 labs.

## Progress
Done & verified (0 import problems): scaffolding, M0, M1, M2. See `BUILD_PROGRESS.md`.

Course is **not** ready to import yet.
