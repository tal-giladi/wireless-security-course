# Course details (for Academy registration — not imported)

- **Title:** Wireless Security & Wi-Fi Penetration Testing
- **Suggested slug:** `wireless-security`
- **GitHub repo:** `tal-giladi/wireless-security-course`
- **Free or paid:** **free** (decided by Tal).
- **Risk notice (shown before start):** This course teaches real wireless-attack techniques. All labs
  are for networks and devices you personally own, in an isolated setup. Using these techniques against
  any network you are not authorised to test is illegal. Regulatory limits on radio transmission apply.
- **One-line summary:** Learn modern Wi-Fi penetration testing and defence hands-on — from 802.11
  fundamentals to WPA2/WPA3 cracking, enterprise EAP attack-and-harden, rogue APs, and professional
  reporting.
- **Who it's for:** engineers, sysadmins, IT/network and security staff comfortable with Linux and
  TCP/IP who want real wireless red/blue-team skills. Covers most OffSec OSWP (PEN-210) objectives
  (disclosed gaps: WEP hands-on, deep bettercap drills) — it does **not** guarantee an exam pass.
- **Format:** self-paced docsify markdown course, ~16 modules (core + electives). Three lab paths:
  recorded-data (no hardware), virtual (`mac80211_hwsim`), physical (real adapters). Core path
  ~45–60 h study + ~30–45 h practice; electives add ~15–20 h.
- **Prerequisites:** Linux command line, TCP/IP basics (readiness check + prep path in Module 0). No
  prior wireless knowledge needed; does not depend on any other course.
- **Costs beyond the course:** physical path needs owned hardware (USB Wi-Fi adapter(s) ~$30–60 each,
  an AP you own; enterprise/WPS/some WPA3 exercises need more than a phone hotspot). Recorded and
  virtual paths need none.
- **What you will learn:**
  - Read and reason about 802.11 frames, the 4-way handshake, SAE, and 802.1X/EAP.
  - Build and verify a wireless attack lab (adapter → driver → monitor mode → injection).
  - Recon, capture, and analyse wireless networks you own.
  - Capture and crack WPA2 (handshake + PMKID) with hashcat `-m 22000`.
  - Assess WPA3-SAE realistically — downgrade and Dragonblood side-channels.
  - Attack and defend WPA2/WPA3-Enterprise (802.1X / EAP) and WPS.
  - Build rogue APs / evil twins and run client-side and captive-portal attacks in a lab.
  - Scope, execute, and report a professional wireless engagement with concrete remediation.
