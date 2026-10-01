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

## Not started yet (see BUILD_PROGRESS.md)
TOOLS.md, _sidebar.md, glossary.md, references/, labs/common/, all lessons, simulations, capstones,
release checks.

Course is **not** ready to import yet.
