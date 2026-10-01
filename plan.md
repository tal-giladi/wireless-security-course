> **Course guidelines (binding):** before writing or changing any course content, read
> `C:\Users\TalGiladi\OneDrive\repos\tals-academy\docs\new-course-instructions.md`. It wins over
> anything in this file or the course outline unless Tal says otherwise in chat.

You are an expert wireless-security instructor, Wi-Fi penetration tester, curriculum designer, and
software engineer.

Build a complete, professional, self-paced **Wireless Security & Wi-Fi Penetration Testing course**
for a general technical audience who wants real-world Wi-Fi attack and defence skills, from RF
fundamentals through professional practice. Methodology and understanding first, tools second; every
attack paired with its defence and measured against a hardened configuration.

This revision incorporates a detailed design review (see §13 for the change log). The priorities are
**a coherent, achievable core course**, **honest scope and expectations**, **precise technical
claims**, and **three clearly-separated lab paths** — not a longer list of attack names.

---

## 1. Audience, readiness, and prerequisites (public course)

**Who this is for:** engineers, sysadmins, IT/network staff, and security practitioners who want
hands-on wireless-security skills — both offensive and defensive — and a realistic path toward OSWP.
No prior wireless knowledge is assumed; all RF and 802.11 specifics are taught from scratch.

**Required background (taught briefly here only where essential, not assumed from any other course):**
- Comfortable in a **Linux shell**: navigate, edit files, install packages, read man pages, run
  commands with `sudo`, read command output.
- **TCP/IP basics**: IP/MAC addressing, DHCP, DNS, ports, the idea of OSI layers 1–3.
- **General security literacy**: what a credential/hash is, why encryption matters, the idea of a
  threat model. Helpful but not required: any prior pentest exposure.

**Readiness self-check (ship in Module 0):** ~10 short questions across Linux CLI, networking, and
security. A learner who misses several is pointed to an **optional preparation path** (concise
external primers + a one-page "catch-up" reference we write). Required learning in this course must
**not** depend on access to any sibling course; where a concept from `../pen-tester-course` or
`../ai-security-course` helps, we **summarise it inline** and offer an optional link for depth.

---

## 2. Scope, paths, and honest expectations

The course is split into a **core path** and **advanced/elective modules**. Module 0 publishes, per
path, estimated **study time**, **practice time**, **hardware needs**, and **extra cost**.

- **Core path** (recommended for everyone): foundations, lab setup, recon, capture/analysis,
  WPA2-Personal (handshake/PMKID/cracking + hardening), WPA3-SAE, rogue AP / evil twin / client-side,
  Enterprise (two modules), engagements & reporting, defence program. Rough budget: **~45–60 h study
  + ~30–45 h practice** (refined as lessons land).
- **Advanced / electives:** WPS, protections & residual attacks (PMF/KRACK/FragAttacks/Kr00k),
  adjacent wireless (BLE/Zigbee/RFID/SDR — **awareness only**). Clearly flagged optional.

**What we will NOT claim:** that finishing this course alone makes someone ready to run every kind of
professional wireless engagement, or guarantees passing OSWP. We claim: it builds the core skills and
covers most OSWP objectives, with an explicit gap list (§3) the learner can close separately.

---

## 3. OSWP / PEN-210 positioning (verified, corrected)

Verified against the current OffSec PEN-210 module list (16 modules): *IEEE 802.11; Wireless Networks;
Wi-Fi Encryption; Linux Wireless Tools/Drivers/Stacks; Wireshark Essentials; Frames & Network
Interactions; Aircrack-ng Essentials; Cracking Authentication Hashes; Attacking WPS; Rogue Access
Points; Attacking WPA Enterprise; Attacking Captive Portals; bettercap Essentials; Kismet Essentials;
Determining Chipsets & Drivers; Manual Network Connections.* Exam: 4-hour practical, three scenarios,
recover the key and connect.

**Correction from the first draft:** enterprise attacks, rogue APs, WPS, and captive portals are
**already in the official syllabus** — we must **not** present them as our unique additions. What we
genuinely add / modernise beyond PEN-210's published scope:
- **WPA3-SAE** (Dragonfly), transition-mode downgrade, Dragonblood class, OWE — OSWP's module list is
  WPA2/Enterprise-centric and does not feature a WPA3 module.
- **PMKID clientless capture** and **hashcat `-m 22000` / hc22000** cracking (OSWP leans on the
  Aircrack-ng suite).
- **PMF / 802.11w** and the **KRACK / FragAttacks / Kr00k** residual-attack context.
- A serious **defence + reporting** track woven throughout, not just offence.

**Disclosed certification-preparation gaps** (consequence of Tal's modern-first, no-deep-legacy rule):
- **WEP** and legacy ciphers: OSWP still touches encryption history and the exam environment can be
  legacy-flavoured. We teach WEP as a short link-only "legacy & deprecated" note, **no lab**. A learner
  targeting OSWP must practise WEP separately — we say so plainly and link a resource.
- **bettercap / specific-tool fluency** the exam may expect: we teach the technique and name the tool;
  deep tool-specific drills are an optional add-on, flagged.

Deliver this as an **objective coverage matrix with explicit gaps** (in `curriculum/course-outline.md`),
not a blanket "exam-ready" promise.

---

## 4. Three lab paths (distinct, separately credited)

Wireless is physical; we are honest about what each path proves. **A recorded-data learner is never
credited with having performed physical capture or injection.** Each path has its own completion
criteria (detailed in `curriculum/assessment-rubrics.md`).

1. **Recorded-data analysis — no wireless hardware.** Supplied, validated captures
   (`.pcap`/`.pcapng`/`.hc22000`). Proves: frame/handshake/EAP *interpretation*, cracking workflow,
   reasoning. Cannot prove: live capture, injection, RF behaviour.
2. **Virtual protocol labs — a Linux VM using `mac80211_hwsim`** (kernel module that simulates 802.11
   radios; pair with `hostapd`/`wpa_supplicant`). Proves: protocol flows, AP/supplicant/RADIUS
   configuration, association logic, many attack *mechanics* end-to-end without radios. **Does not**
   reproduce real RF, real drivers, range, interference, regulatory behaviour, or hardware-specific
   monitor/injection quirks — state this on every virtual lab.
3. **Physical wireless labs — real adapters, APs, test clients.** The only path that proves real
   monitor mode, injection, capture, range, and interference handling. Requires owned hardware (§5).

Every lab page states **which paths it supports** and, for each, what it does and does not demonstrate.
Where possible, a lab offers more than one path so no learner is blocked.

---

## 5. Reproducible lab environment (specify before any purchase)

Produce `curriculum/lab-matrix.md` **before** recommending purchases. It must cover, with separate
columns for **monitor**, **injection**, and **AP-mode** capability (they are not the same):

- **Wi-Fi adapters:** exact model **and hardware revision** (e.g. "Alfa AWUS036NHA (AR9271)",
  "AWUS036ACM (MT7612U)", and the Realtek 88XXAU family via maintained DKMS) — verify per revision,
  because a chipset/marketing name does **not** guarantee support; note bands (2.4/5/6 GHz), driver,
  driver status, and known-bad revisions. Mark anything unverified as unverified.
- **APs / target devices:** which exercises need a real AP with specific features — **WPA3-SAE &
  transition mode**, **WPS**, **WPA-Enterprise/802.1X** — and which can use `hostapd`. Explicitly
  state that an **ordinary phone hotspot does NOT provide Enterprise, WPS, or every WPA3 exercise**.
- **Test clients:** a controlled client we can configure (including a correctly-configured enterprise
  client that *rejects* a rogue server) — real device and/or VM supplicant.
- **Host OS / kernel / software:** a **tested Windows-hosted VM path** (Tal is on Windows 11) with
  **USB-passthrough setup and troubleshooting** (VirtualBox/VMware/Hyper-V caveats, common failure
  modes), plus the Linux distro + kernel range and **pinned software versions** (`aircrack-ng`,
  `hcxtools`/`hcxdumptool`, `hashcat`, `hostapd`/`hostapd-mana`/`hostapd-wpe`, `wpa_supplicant`,
  `freeradius`, `eaphammer`, `bettercap`, `kismet`, `iw`). Record fallbacks for each.

Keep version-pinned tool inventory in root `TOOLS.md`. Mark unsupported/untested combinations
explicitly. Never invent verification dates (§12 of instructions, and review point 13).

---

## 6. Precise, qualified attack claims (per technique)

Every attack lesson documents: **prerequisites**, **affected configurations**, **expected evidence**,
and **why it may fail**. Specific corrections the content must honour:

- **WPA2 PMKID:** collection is available only when the AP includes a PMKID in the first EAPOL message
  (RSN PMKID); not universal and not fully passive (you associate/probe the AP). "Clientless" means "no
  other client needed," not "works everywhere, silently." State detection signals.
- **WPA3:** clearly separate (a) **WPA3-SAE only**, (b) **transition mode** (SAE + WPA2-PSK
  advertised — the real downgrade surface), (c) **implementation vulnerabilities** (Dragonblood
  timing/cache side-channels, with the affected implementation versions and the vendor mitigations),
  and (d) **historical research vs current status**. SAE itself yields no offline-crackable hash — say
  so and show why.
- **PMF / 802.11w:** explain what it protects (management frames, incl. deauth) and its limits.
  **Do not make successful deauthentication a prerequisite** for WPA3 labs — on PMF-enabled networks
  deauth is rejected; design labs around that reality.
- **OWE (Enhanced Open):** provides **encryption without authenticating the network** — protects
  against passive sniffing on open networks, not against an active rogue/MITM. State this precisely.
- **Evil twin / KARMA / MANA / client association:** success is **conditional on actual client
  behaviour and configuration** (PNL contents, MAC randomisation, "auto-join," OS version, enterprise
  profile validation). Frame every claim as "a client that does X is vulnerable to Y," with the
  controlled-client config that demonstrates it — and a hardened client that does not.
- **Captive-portal / credential capture:** this is **tricking a lab user into submitting a
  passphrase**, which is social engineering — it is **not breaking WPA3 (or any) cryptography**. Keep
  that distinction explicit wherever a portal appears.

Support all distinctions with current standards (IEEE 802.11), original research (Dragonblood, KRACK,
FragAttacks, Kr00k), and vendor advisories.

---

## 7. Enterprise as a proper sequence (not one overloaded module)

Split Enterprise across **two modules / five lessons**, separating **credential capture** from
**relay** (they are different):
1. **Architecture & EAP methods** — supplicant / authenticator / RADIUS; PEAP, EAP-TTLS, EAP-TLS;
   where trust lives.
2. **Build a working enterprise lab** — local **CA + FreeRADIUS + supplicant**, a correctly issued
   server cert, and a client profile. (Virtual path via `mac80211_hwsim` + VMs is first-class here.)
3. **Assess insecure configurations** — credential **capture** against clients that don't validate the
   server cert (`hostapd-wpe`/`eaphammer`), then crack captured MSCHAPv2 (bounded).
4. **Relay vs capture** — explain and (where lab-safe) demonstrate relaying, distinguished clearly
   from offline credential capture.
5. **Harden & retest** — trusted-CA configuration, expected server identity, managed client profiles,
   certificate lifecycle, **EAP-TLS**; include a **correctly-configured client that rejects the rogue
   server**, with the log/packet **evidence** explaining *why* it refused.

---

## 8. Defence taught early and throughout (not only at the end)

Introduce a **secure wireless baseline in Module 2** and **revisit it in every major module**:
guest/internal **segmentation**, AP administration hygiene, **firmware maintenance**, **WPS
configuration**, **client policies** (server-cert validation, MAC randomisation, auto-join), and
**monitoring / rogue detection**. **Every major lab compares an intentionally vulnerable configuration
with a hardened one and measures the difference** (e.g. deauth succeeds without PMF, is rejected with
PMF; PMKID present vs suppressed; rogue capture succeeds vs client rejects it).

---

## 9. Lesson structure — subject-appropriate within the binding one-section-set rule

Instructions §4 require **one fixed set of `##` sections in every lesson** (adapt with `###`). So we do
**not** use three different top-level section sets. The review's intent is met a compliant way: a single
`##` set course-wide, with lesson-kind differences expressed as **optional `###` subsections** — so a
foundation or reporting lesson simply omits attack-only `###`s like "why the weakness exists."

Fixed `##` set (every lesson): **Why this matters → Learning objectives → Prerequisites → Concept →
Hands-on → Exercise → References → What you should now be able to do.** Full spec, including which
`###`s each lesson kind uses and the GitHub-alert lab box (no `<div>`), is in
`curriculum/lesson-templates.md`. Front-matter stays exactly the documented fields — no custom keys;
lab-path support is stated in the body.

Always distinguish the **guided walkthrough** (`### Guided walkthrough`, we show the steps) from the
**independent exercise** (`## Exercise`, learner reasons, no inline solution; hints in `<details>`).

---

## 10. Labs and assessments that prove understanding (review point 10)

Every lab specifies: **known starting state**, **estimated duration**, **expected artifacts**,
**success criteria**, **troubleshooting**, **cleanup/reset**, and **progressive hints**. Plus:

- **Validated captures with provenance:** every shipped capture records how it was generated (our lab,
  owned equipment, synthetic creds), **redistribution permission/licence**, and a **SHA-256 checksum**.
  Ship **both successful and unsuccessful** examples (e.g. a clean handshake and a partial one).
- **Bounded cracking:** supply a wordlist + a passphrase with a **known achievable result** so the
  exercise terminates, **and** a **strong-password example where recovery is not expected** — the
  learning outcome there is "correctly conclude it won't crack and recommend the control."
- A learner can **pass an assessment by correctly demonstrating that a protection works** (e.g.
  showing PMF rejects the deauth, or the hardened client rejects the rogue RADIUS), not only by
  recovering a key. Rubrics in `curriculum/assessment-rubrics.md`.
- Quizzes: multiple-choice in `.quiz.yaml`, 3–5 per lesson / 8–10 per module, per instructions §5.

---

## 11. Capstones (two, substantive) — review point 11

Provide **separate recorded-data and physical-lab capstones** in `projects/`. Assess **reconnaissance,
interpretation, justified technique selection, evidence quality, remediation, and retesting** — not
merely obtaining a key. Supply a **sample report and a rubric** covering scope, findings, impact,
**limitations**, remediation priorities, and **residual risk**, including a concise **executive
summary** alongside technical evidence.

---

## 12. Safety, containment, legality (moved into onboarding — review point 12)

Put safety and containment in **Module 0**, not only the last module:

- **A private subnet does NOT isolate radio transmissions.** Deauth/beacons/probes leave the wire.
  Teach: **target allowlists** (BSSIDs/SSIDs you own), **controlled test clients**, **minimum
  necessary transmission** (lowest TX power, specific channel, directional/attenuated where possible),
  **stop conditions**, and **cleanup**. Prefer **virtual (`mac80211_hwsim`) or RF-shielded** setups
  for transmit-heavy exercises where practical.
- **Accurate legal guidance, not sweeping claims:** frame around **authorisation**, **interception**,
  **interference**, and **local radio regulations** (TX power, DFS, band licensing vary by country);
  tell learners to check their jurisdiction. Offensive exercises are restricted to **controlled lab
  equipment the learner owns** and **synthetic credentials** (`Lab-WiFi-Passw0rd!`, `LAB-FLAG-{uuid}`).
- Every offensive page repeats LAB TARGET vs REAL NETWORK and the authorisation requirement; risky
  pages open with `> [!WARNING]` / `> [!CAUTION]`. Root `PUBLISHING_WARNING.md` lists pre-publish review.

---

## 13. Release checks beyond import (review point 13)

`npm run check-course` → 0 problems verifies **structure, not teaching quality or lab correctness.**
Before "done," also require and **record what was actually tested** (in `TODO_FOR_TAL.md` /
`BUILD_PROGRESS.md`):
- **Representative end-to-end lab runs** on at least one real path per major module (note which path).
- **Quiz-answer review** (correct keys sane, distractors plausible, positions spread).
- **Capture validation** (every shipped capture parses, matches its checksum, and produces the claimed
  result with the documented tool/version).
- **Link checks** (internal + external references resolve).
- **Simulation accessibility checks** (keyboard, labels, no network, sandbox-safe).
- **A pilot run by someone who did not write the course.**
- **Explicitly mark** unsupported commands, untested hardware combinations, and unverified labs.
  **Never invent `last_verified` dates** — only date what was actually checked.

### Change log vs first draft
Added public audience + readiness (§1); core/elective split with time/cost (§2); corrected OSWP claim
and added gap disclosure (§3); three distinct, separately-credited lab paths (§4); lab matrix before
purchases, with Windows VM/USB-passthrough and per-capability columns (§5); precise attack-claim
qualifications (§6); enterprise expanded into a 5-lesson sequence with capture-vs-relay and a
rejecting client (§7); defence baseline early and vulnerable-vs-hardened per lab (§8); three lesson
templates (§9); rigorous lab/assessment + capture provenance/checksums + bounded & strong-password
cracking (§10); two substantive capstones with report/rubric (§11); containment in onboarding and
accurate legal guidance (§12); substantive release checks (§13).

---

## 14. Working method & deliverables

Academy layout per instructions §2. Planning artifacts (not imported): `curriculum/course-outline.md`
(final module/lesson + dependency map + OSWP matrix + core/elective + time/cost), `curriculum/
lab-matrix.md`, `curriculum/assessment-rubrics.md`, `curriculum/lesson-templates.md`,
`curriculum/course-details.md`; plus `CLAUDE.md`, `BUILD_PROGRESS.md`, `TOOLS.md`,
`PUBLISHING_WARNING.md`, and `TODO_FOR_TAL.md` (the honest unresolved-items list for Tal).

Candidate **simulations** (plain HTML/CSS/vanilla JS, sandbox-safe): 802.11 join / frame-exchange;
4-way-handshake and SAE visualiser; channel/band spectrum map. Mark "educational model."

Per instructions §9: at most two writing agents, one module each; shared files edited only by the main
session; finish each lesson fully (`.md` + `.quiz.yaml`) before the next; log to
`curriculum/status/module-NN.log`; commit after every module; run the dry-run import to 0 problems
**and** the §13 checks before done.

## 15. Definition of done
A coherent core course a general learner can complete; three lab paths each with honest, separate
completion criteria; precise attack claims; enterprise taught as a build→attack→harden→retest
sequence; defence woven throughout with vulnerable-vs-hardened measurement; two substantive capstones
with rubrics; 0 import problems **plus** the §13 end-to-end/pilot checks recorded; every lab safe,
owner-only, resettable; unresolved items listed for Tal.
