# Glossary

Core terms used across the course. Each is defined where it first matters; this page is the quick
reference. Terms are added here by the main session as modules land (agents propose additions in
`curriculum/glossary-inbox/`).

- **802.11** — the IEEE family of standards for wireless LAN (Wi-Fi). Amendments add bands, rates, and
  security (e.g. 802.11i added WPA2, 802.11w added management-frame protection).
- **802.1X** — port-based network access control; the framework behind WPA-Enterprise. Carries EAP
  between a supplicant, an authenticator (the AP), and an authentication server (RADIUS).
- **AP (access point)** — the device that originates a BSS and bridges wireless clients to a network.
- **Association** — the final step by which a client joins a BSS after authentication.
- **Beacon** — a management frame an AP broadcasts periodically advertising its SSID and capabilities.
- **BSS / BSSID / ESS** — a Basic Service Set is one AP's cell; the BSSID is usually the AP's MAC; an
  Extended Service Set is multiple APs sharing one SSID.
- **Deauthentication** — a management frame that ends a client's session. Forgeable unless management
  frames are protected (PMF / 802.11w).
- **dBm** — decibels relative to one milliwatt; the unit for RF signal power. +3 dBm ≈ double power.
- **Dragonblood** — a class of side-channel and downgrade vulnerabilities in early SAE/WPA3
  implementations (2019), with vendor mitigations; not a break of SAE's design. See `references/`.
- **EAP** — Extensible Authentication Protocol; the method negotiated inside 802.1X (PEAP, EAP-TTLS,
  EAP-TLS, …). Determines where trust lives and what a client must validate.
- **EAPOL** — EAP over LAN; carries the 4-way handshake messages (and 802.1X EAP) over 802.11.
- **Evil twin** — a rogue AP impersonating a legitimate SSID to attract clients. Success is conditional
  on the target client's behaviour and configuration.
- **FragAttacks** — a 2021 class of design and implementation flaws in 802.11 frame aggregation and
  fragmentation. See `references/`.
- **Handshake (4-way)** — the WPA2/WPA3-PSK exchange that derives the PTK from the PMK and proves both
  sides know the key, without sending it.
- **hc22000 / `-m 22000`** — hashcat's modern mode and file format for WPA-PBKDF2 PMKID+EAPOL cracking.
- **hostapd** — user-space daemon that turns an interface into an AP; configures WPA2/WPA3/OWE/enterprise.
- **KRACK** — Key Reinstallation Attack (2017) against the 4-way handshake; patched in supplicants.
- **Kr00k** — a 2020 vulnerability causing some chips to transmit buffered frames encrypted with an
  all-zero key after disassociation. See `references/`.
- **mac80211_hwsim** — a Linux kernel module that creates simulated 802.11 radios, enabling protocol
  and configuration labs with no hardware. Does **not** reproduce real RF, drivers, or injection.
- **Management / control / data frames** — the three 802.11 frame types: management (beacons, probes,
  auth, assoc, deauth), control (ACK, RTS/CTS), and data (payload, incl. EAPOL).
- **Monitor mode** — an interface mode that captures all 802.11 frames on a channel, including other
  networks' management/control frames. Distinct from promiscuous mode on wired NICs.
- **MSCHAPv2** — a challenge/response auth used inside PEAP/EAP-TTLS; its captured exchange is
  offline-crackable, which is the basis of the enterprise credential-capture lab.
- **OWE (Enhanced Open)** — opportunistic wireless encryption; encrypts traffic on "open" networks
  **without authenticating the network** — stops passive sniffing, not an active rogue/MITM.
- **PMF / 802.11w** — Protected Management Frames; cryptographically protects deauth/disassoc and other
  management frames. Required in WPA3. Changes which attacks are possible.
- **PMK / PTK / GTK** — Pairwise Master Key (derived from the PSK or 802.1X); Pairwise Transient Key
  (per-session, from the 4-way handshake); Group Temporal Key (for broadcast/multicast).
- **PMKID** — an identifier some APs include in the first EAPOL message, derived from the PMK; when
  present it enables clientless capture. Not universal and **not fully passive**.
- **PNL (Preferred Network List)** — the list of SSIDs a client remembers and may probe/auto-join;
  central to KARMA/MANA and evil-twin viability.
- **PSK** — pre-shared key; the passphrase-derived secret in WPA2/WPA3-Personal.
- **Radiotap** — a header prepended to captured 802.11 frames carrying RF metadata (channel, signal,
  rates); present in monitor-mode captures.
- **RADIUS** — the AAA server protocol used as the 802.1X authentication server (e.g. FreeRADIUS).
- **Rogue AP** — any AP not sanctioned by the network owner, whether an evil twin or an unmanaged one.
- **RSN** — Robust Security Network; the 802.11i security framework (information element advertised in
  beacons) covering WPA2/WPA3.
- **SAE (Dragonfly)** — Simultaneous Authentication of Equals; WPA3-Personal's password-authenticated
  key exchange. Yields **no offline-crackable hash** from a passive capture.
- **SSID** — the human-readable network name advertised by an AP.
- **Supplicant** — the client-side 802.1X/EAP entity (e.g. `wpa_supplicant`).
- **TKIP** — a transitional WPA cipher built on RC4; deprecated. Legacy note only, no lab.
- **Transition mode** — a BSS advertising both WPA3-SAE and WPA2-PSK for compatibility; the real
  downgrade surface for WPA3-Personal.
- **WEP** — the original, broken 802.11 encryption. Legacy note only, no lab (OSWP-prep gap disclosed).
- **WPS** — Wi-Fi Protected Setup; PIN/push-button onboarding with a long history of flaws (Pixie Dust,
  online PIN brute). Elective module; recommend disabling.
