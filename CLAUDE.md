# Build guide — Wireless Security & Wi-Fi Penetration Testing course

> **Course guidelines (binding):** before writing or changing any course content, read
> `C:\Users\TalGiladi\OneDrive\repos\tals-academy\docs\new-course-instructions.md`. It wins over
> anything in this file or `plan.md` unless Tal says otherwise in chat.

Docsify static markdown course (no build step) that imports into Tal's Academy. Takes an experienced
software engineer to professional wireless-security / Wi-Fi penetration-testing capability — red,
blue, and purple. Source brief: `plan.md`. Full map: `curriculum/course-outline.md`. Sibling course
conventions: `../pen-tester-course`, `../ai-security-course`.

## Layout (Academy spec — see instructions §2)
- `README.md` — H1 = title; first paragraph = catalog description.
- `_sidebar.md` — the only structure the importer reads. Every lesson/quiz/module listed here.
- `lessons/module-NN/lesson-MM.md` + `lesson-MM.quiz.yaml` — lesson + its multiple-choice quiz.
- `assessments/module-NN-quiz.md` (+ `.quiz.yaml`) — module quiz (8–10 scenario Qs).
- `labs/module-NN/` (+ `labs/common/`) — lab files → the module zip. Recorded captures live here.
- `templates/`, `projects/` (capstone), `simulations/<name>/index.html`, `assets/`, `glossary.md`,
  `references/`, `TOOLS.md`, `PUBLISHING_WARNING.md`.
- `curriculum/`, `brief/`, `output/` — planning only, NEVER imported.

## Lesson structure (plan §9; full spec `curriculum/lesson-templates.md`)
**One fixed `##` set in every lesson** (instructions §4): Why this matters → Learning objectives →
Prerequisites → Concept → Hands-on → Exercise → References → What you should now be able to do. Adapt
per lesson kind with `###` **inside** those sections (foundation omits attack-only `###`s like "why the
weakness exists"; attacks add recognise/manual/tooling/verify/why-it-may-fail/impact/remediation;
defence adds vulnerable-vs-hardened). **No custom front-matter keys** — state lab paths in the body;
lab box is a `> [!NOTE]`, never a `<div>`. Split `### Guided walkthrough` from the independent
`## Exercise` (no inline solution, hints in `<details>`). **Never** "run tool → get key" without the
mechanism.

## Non-negotiable rules
- **Three lab paths (plan §4), separately credited:** R recorded-data (no HW), V virtual
  `mac80211_hwsim`, P physical. Every lab states which paths it supports and **what each proves / does
  not prove**. R/V never grant physical-capture/injection credit. See `curriculum/lab-matrix.md`.
- **Qualify every attack claim (plan §6):** PMKID availability (not universal, not fully passive);
  WPA3 SAE-only vs transition vs implementation-bug vs history + Dragonblood mitigations/versions; PMF
  limits (**don't require successful deauth for WPA3 labs**); OWE = encryption without network auth;
  evil-twin/KARMA/MANA conditional on client config; captive portal = social-eng, **not** a crypto break.
- **Modernity / deprecation rule:** WEP, TKIP, WPS online brute, RC4/DES-era crypto get a one-paragraph
  "Legacy & deprecated" note + link, never a lab. Disclose resulting OSWP-prep gaps (WEP, bettercap).
  Badge F/C/E/D.
- **Defence early & throughout (plan §8):** secure baseline in M2, revisited; **every major lab
  compares vulnerable vs hardened and measures the difference**; enterprise = build→attack→harden→retest
  with a correctly-configured client that rejects the rogue server.
- **Safety & containment in onboarding (plan §12):** M0 teaches that a private subnet does NOT isolate
  radio; target allowlists, controlled clients, minimum TX, stop conditions, cleanup; prefer V/shielded
  for transmit-heavy work. Offensive labs target ONLY owned equipment, synthetic creds
  (`Lab-WiFi-Passw0rd!`, `LAB-FLAG-{uuid}`), resettable, no Internet targets. Accurate legal guidance
  (authorisation/interception/interference/local radio law), not sweeping claims.
- **Labs & captures (plan §10; rubrics in `assessment-rubrics.md`):** each lab = known start state,
  duration, expected artifacts, success criteria, troubleshooting, cleanup, hints. Shipped captures =
  provenance + licence + **SHA-256**, success **and** failure examples. Cracking = bounded (known
  result) **and** strong-password (no-crack, correct outcome = recommend the control).
- **Quizzes:** multiple-choice only, in `.quiz.yaml`; 3–5 per lesson, 8–10 per module; `correct`
  spread across 0–3; plausible distractors; parse every file. A learner may pass by proving a protection works.
- **Citations:** IEEE 802.11, RFCs, vendor advisories, CVE/CWE, original research (Dragonblood, KRACK,
  FragAttacks, Kr00k). Set `last_verified` only to what was actually checked — **never invent dates**;
  mark volatile implementation detail `volatility: implementation` and untested combos explicitly.

## Working method (instructions §9)
At most two writing agents, one module each; shared files (`_sidebar.md`, `glossary.md`, `README.md`,
`TOOLS.md`, `labs/common/`) edited only by the main session; agents drop glossary additions in
`curriculum/glossary-inbox/module-NN.md`. Finish each lesson fully before the next; log to
`curriculum/status/module-NN.log`; update `BUILD_PROGRESS.md`; commit after every module.

## Before done (plan §13 — structure check is NOT enough)
`cd ../../tals-academy && npm run check-course -- ../course-creator/wireless-security-course` until
`0 problems`, then instructions §10, **plus**: representative end-to-end lab run per major module (note
path), quiz-answer review, capture validation (parse + checksum + claimed result), internal+external
link checks, simulation accessibility checks, and a pilot by someone who didn't write the course.
**Record what was actually tested** in `BUILD_PROGRESS.md`/`TODO_FOR_TAL.md`; mark anything unverified.

## Status / handoff
`BUILD_PROGRESS.md` = unit checklist + resume procedure. `TODO_FOR_TAL.md` = what Tal must decide/do.
Commit and push after each module. Attribution lines per session instructions.
