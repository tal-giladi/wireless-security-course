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

## Progress — content complete
All content is written and **passes the Academy dry-run importer with 0 problems**: Modules 0–15
(64 lessons, each with its `.quiz.yaml`; 16 module quizzes; 387 questions), both capstones in
`projects/`, three simulations, the glossary, TOOLS.md, references, and templates. See `BUILD_PROGRESS.md`
for the per-phase record of what was checked.

**The course is structurally ready to import** (repo: `tal-giladi/wireless-security-course`, public,
free). The import itself will work with no edits. What remains before calling it *done* for learners is
the hardware/teaching-quality QA below — none of which blocks the import, and all of which need you.

## Still needs you (can't be done at build time)
1. **Generate the shipped captures** on a Linux box (virtual path, no wireless HW needed):
   `cd labs/common && sudo ./hwsim-up.sh 3 && sudo ./gen-captures.sh && sudo ./hwsim-down.sh`, then paste
   the real SHA-256 values into `labs/common/CAPTURES.md` and commit the (small) capture files. Until
   then every capture is marked **PENDING** and the recorded-data labs say so — **no checksum was invented.**
   The generator still needs a beacon-set and SAE-exchange step added for the M2/M7 captures (noted below).
2. **Run at least one end-to-end lab per major module** on real or virtual hardware and record the path
   tested (plan §13). Mark anything that doesn't reproduce.
3. **Re-verify volatile facts** before publishing: adapter driver/DKMS status per kernel, tool flags
   (hcxdumptool/hashcat/eaphammer/hostapd-*), WPA3/Dragonblood status, and the current OSWP syllabus.
   `last_verified` dates in the lessons are **2026-10-01/02 build-time checks** — re-date only what you re-check.
4. **A pilot** by someone who didn't write the course (plan §13).
5. Confirm the **jurisdiction/legal framing** reads acceptably for your audience.

## Decisions (recommended defaults taken; change if you disagree)
- Default adapter chipset: **MT7612U** (dual-band, mainline `mt76`). Verify a specific in-stock
  model+revision before the course tells anyone to buy — the course already teaches the chipset-first rule.
- Repo `tal-giladi/wireless-security-course`, **free** (your earlier decision). OSWP framing: covers most
  objectives + modern material, disclosed gaps (no WEP hands-on, deep bettercap optional), no pass promise.
