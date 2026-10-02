# Build progress — Wireless Security & Wi-Fi Penetration Testing

**Goal:** professional, modern, hands-on wireless-security course (plan.md), OSWP-aligned but updated
for 2026, imports cleanly into Tal's Academy.

**Resume procedure:** read this file + `curriculum/status/*.log` first; skip finished units; never
rewrite a finished lesson. Read `plan.md`, `CLAUDE.md`, `curriculum/course-outline.md`, and the binding
instructions before writing. At most two writing agents, one module each. Commit after every module.
Run `npm run check-course` until 0 problems before declaring done.

## Phase 0 — planning (revised per design review)
- [x] plan.md (rewritten per review)
- [x] curriculum/course-outline.md (rewritten: core/elective, 3 lab paths, OSWP matrix + gaps)
- [x] curriculum/lab-matrix.md
- [x] curriculum/assessment-rubrics.md
- [x] curriculum/lesson-templates.md
- [x] curriculum/course-details.md
- [x] CLAUDE.md · README.md · PUBLISHING_WARNING.md · BUILD_PROGRESS.md · TODO_FOR_TAL.md
- [x] TOOLS.md (versions marked VERIFY — confirm on a real build)
- [x] _sidebar.md (incremental — top links + modules appended as built)
- [x] glossary.md
- [x] references/ (index with standards + original research + tooling)
- [x] labs/common/ (hwsim scripts, gen-captures, wordlists, reset, CAPTURES provenance — captures PENDING real run)
- [x] templates/ (report, authorisation, lab-notebook)

## Phase 1 — content (each = lessons .md + .quiz.yaml + labs + module quiz + log)
- [x] M0 Onboarding & safe lab practice (core) — 3 lessons + quizzes + module quiz, 0 import problems
- [x] M1 RF & 802.11 fundamentals (core) — 4 lessons + quizzes + module quiz, glossary merged, 0 problems
- [x] M2 Wi-Fi security protocols & the secure baseline (core) — 4 lessons + quizzes + module quiz, glossary merged, 0 problems
- [x] M3 Building your lab — three paths (core) — 5 lessons + quizzes + module quiz, glossary merged, 0 problems
- [x] M4 Wireless reconnaissance (core) — 4 lessons + quizzes + module quiz, glossary merged, 0 problems
- [x] M5 Capturing & analysing 802.11 (core) — 4 lessons + quizzes + module quiz, glossary merged, 0 problems
- [x] M6 WPA2-Personal: capture, PMKID & cracking (core) — 5 lessons + quizzes + module quiz, glossary merged, 0 problems
- [x] M7 WPA3-SAE (core) — 5 lessons + quizzes + module quiz, glossary merged, 0 problems
- [x] M8 WPS (elective) — 4 lessons + quizzes + module quiz, glossary merged, 0 problems
- [x] M9 Rogue AP, evil twin & client-side (core) — 5 lessons + quizzes + module quiz, glossary merged, 0 problems
- [x] M10 Enterprise I — architecture, EAP & building the lab (core) — 3 lessons + quizzes + module quiz, glossary merged, 0 problems
- [x] M11 Enterprise II — attack, harden & retest (core) — 5 lessons + quizzes + module quiz, glossary merged, 0 problems
- [x] M12 Protections & residual attacks (elective) — 4 lessons + quizzes + module quiz, glossary merged, 0 problems
- [x] M13 Wireless engagements & methodology (core) — 3 lessons + quizzes + module quiz, glossary merged, 0 problems
- [x] M14 Defence program & reporting (core) — 3 lessons + quizzes + module quiz, glossary merged, 0 problems
- [x] M15 Adjacent wireless (elective, awareness) — 3 lessons + quizzes + module quiz, glossary merged, 0 problems
- [x] Capstone — recorded-data (projects/) — brief + rubric
- [x] Capstone — physical-lab (projects/) — brief + rubric; plus projects/README.md + sample-report.md

## Phase 2 — simulations (optional)
- [x] 802.11 join / frame-exchange animation — `simulations/wifi-join/` (linked from 01.4)
- [x] 4-way-handshake & SAE visualiser — `simulations/handshake/` (linked from 06.1 and 07.1)
- [x] channel/band spectrum map — `simulations/spectrum/` (linked from 01.2)
  All three: inline HTML/CSS/vanilla JS, no network, labelled "educational model", keyboard-operable.

## Phase 3 — QA (plan §13 — beyond import)
Done at build time (recorded here; see TODO_FOR_TAL.md for what still needs Tal):
- [x] `npm run check-course` → **0 problems** (64 lessons, 80 quiz files, 387 questions, A-D 96/95/97/99)
- [x] instructions §10 structural checklist (H1s, front-matter incl. last_verified, 3–5/8–10 quiz counts,
      4 options, correct 0–3 spread, explanations, no disallowed HTML/JSX, no quiz sections in markdown)
- [x] Fixed `##` section set present in all 64 lessons; valid one-paragraph intro after every H1
- [x] Quiz-answer review: per-file correct-position spread balanced; global A-D 96/95/97/99
- [x] Link checks: no broken relative links (importer resolves all), no absolute course-page links, no
      docsify-style links to course files, no progress-tool calls
- [x] Simulation checks (static + in-pane load): no external/network resources, labelled, keyboard-operable,
      no console errors on local load (NOT a full multi-browser a11y audit)
- [x] Synthetic-data check: offensive content uses synthetic creds / owned-lab framing only; sample report synthetic
- [ ] **End-to-end lab runs on real/virtual hardware** — NOT done (needs Linux + hwsim/adapters). Tal.
- [ ] **Capture generation + SHA-256 + claimed-result validation** — captures are PENDING a real
      `labs/common/gen-captures.sh` run; all checksums marked PENDING, none invented. Tal.
- [ ] **External source URL re-verification** — `last_verified` dates reflect build-time checks
      (2026-10-01 / 2026-10-02); volatile items (tool flags, driver/firmware, Dragonblood status) to re-check. Tal.
- [ ] **External pilot** (someone who didn't write it). Tal.

## Decisions / open questions — see TODO_FOR_TAL.md
- Default adapter chipset: recommended **MT7612U** (verify a specific model+revision before buying).
- Repo name: `tal-giladi/wireless-security-course` (recommended); free (decided).

## Who's working on what
- (idle) — **all content complete and committed**: scaffolding, M0–M15 (64 lessons + quizzes + module
  quizzes + labs), both capstones, three simulations, glossary. 0 import problems.
  Remaining = the hardware/pilot QA items above, which only Tal can do.
