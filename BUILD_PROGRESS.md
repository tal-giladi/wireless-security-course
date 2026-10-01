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
- [ ] M5 Capturing & analysing 802.11 (core)
- [ ] M6 WPA2-Personal: capture, PMKID & cracking (core)
- [ ] M7 WPA3-SAE (core)
- [ ] M8 WPS (elective)
- [ ] M9 Rogue AP, evil twin & client-side (core)
- [ ] M10 Enterprise I — architecture, EAP & building the lab (core)
- [ ] M11 Enterprise II — attack, harden & retest (core)
- [ ] M12 Protections & residual attacks (elective)
- [ ] M13 Wireless engagements & methodology (core)
- [ ] M14 Defence program & reporting (core)
- [ ] M15 Adjacent wireless (elective, awareness)
- [ ] Capstone — recorded-data (projects/)
- [ ] Capstone — physical-lab (projects/)

## Phase 2 — simulations (optional)
- [ ] 802.11 join / frame-exchange animation
- [ ] 4-way-handshake & SAE visualiser
- [ ] channel/band spectrum map

## Phase 3 — QA (plan §13 — beyond import)
- [ ] npm run check-course → 0 problems
- [ ] instructions §10 checklist
- [ ] end-to-end lab run per major module (record path tested)
- [ ] quiz-answer review · capture validation (parse+checksum+result) · link checks · sim a11y checks
- [ ] external pilot (someone who didn't write it)
- [ ] TODO_FOR_TAL.md ready + repo + commit; unverified items marked

## Decisions / open questions — see TODO_FOR_TAL.md
- Default adapters; free/paid + repo name;
  OSWP framing; how far virtual substitutes for physical; recorded-capture set per module.

## Who's working on what
- (idle) — planning revised. Next writer: resolve TODO_FOR_TAL §1–2, then TOOLS.md + _sidebar.md
  skeleton + labs/common, then M0.
