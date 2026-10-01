# Glossary

Core terms used across the course. Each is defined where it first matters; this page is the quick
reference. Terms are added here by the main session as modules land (agents propose additions in
`curriculum/glossary-inbox/`).

- **802.11** — the IEEE family of standards for wireless LAN (Wi-Fi). Amendments add bands, rates, and
  security (e.g. 802.11i added WPA2, 802.11w added management-frame protection).
- **802.1X** — port-based network access control; the framework behind WPA-Enterprise. Carries EAP
  between a supplicant, an authenticator (the AP), and an authentication server (RADIUS).
- **Address fields (Addr1–Addr4 / RA / TA / DA / SA)** — up to four MAC addresses in the 802.11 header;
  Addr1 is the receiver and Addr2 the transmitter of the hop, the rest depending on ToDS/FromDS.
- **AID (Association ID)** — the identifier an AP assigns a client in the association response once it
  is a member of the BSS.
- **AKM (Authentication and Key Management)** — the RSN suite selector that names the security mode
  (PSK, SAE, 802.1X, OWE); it, not the cipher, tells you whether a network is WPA2, WPA3-SAE, or OWE.
- **AP (access point)** — the device that originates a BSS and bridges wireless clients to a network.
- **Association** — the final step by which a client joins a BSS after authentication.
- **Beacon** — a management frame an AP broadcasts periodically advertising its SSID and capabilities.
- **BSS / BSSID / ESS** — a Basic Service Set is one AP's cell; the BSSID is usually the AP's MAC; an
  Extended Service Set is multiple APs sharing one SSID.
- **CCMP / AES** — the modern 802.11 cipher (AES in CCMP mode) for WPA2/WPA3 confidentiality and
  integrity, replacing deprecated TKIP/RC4; GCMP is its counterpart for the newest modes.
- **Channel** — a named centre frequency within a band that a radio tunes to; a receiver hears only the
  channel (and width) it is set to.
- **Channel width** — the spectrum a signal occupies (20/40/80/160 MHz); wider carries more but spreads
  power and overlaps more neighbours, and a capture must match it.
- **dB (decibel)** — a logarithmic *ratio* of two powers; gains/losses add instead of multiplying.
  +3 dB ≈ double power, +10 dB = ten times. Distinct from dBm (which is absolute).
- **dBi** — antenna gain relative to an ideal isotropic radiator; describes how an antenna focuses
  energy into a direction, trading coverage angle for reach (it adds no energy).
- **Deauthentication** — a management frame that ends a client's session. Forgeable unless management
  frames are protected (PMF / 802.11w).
- **DFS (Dynamic Frequency Selection)** — a regulatory requirement on radar-shared 5 GHz channels: an AP
  must listen and vacate on radar. A regulatory behaviour, not a security feature.
- **dBm** — decibels relative to one milliwatt; the unit for RF signal power. +3 dBm ≈ double power.
- **Dragonblood** — a class of side-channel and downgrade vulnerabilities in early SAE/WPA3
  implementations (2019), with vendor mitigations; not a break of SAE's design. See `references/`.
- **EAP** — Extensible Authentication Protocol; the method negotiated inside 802.1X (PEAP, EAP-TTLS,
  EAP-TLS, …). Determines where trust lives and what a client must validate.
- **EAPOL** — EAP over LAN; carries the 4-way handshake messages (and 802.1X EAP) over 802.11.
- **Evil twin** — a rogue AP impersonating a legitimate SSID to attract clients. Success is conditional
  on the target client's behaviour and configuration.
- **FCS (Frame Check Sequence)** — the 4-byte CRC ending an 802.11 frame; a receiver uses it to discard
  corrupted frames.
- **FragAttacks** — a 2021 class of design and implementation flaws in 802.11 frame aggregation and
  fragmentation. See `references/`.
- **Frame Control** — the first 2-byte field of the MAC header, carrying Type/Subtype and flags
  including ToDS, FromDS, and Protected Frame.
- **Free-space path loss** — the weakening of a signal with distance (≈ 6 dB per doubling) and with
  frequency; an open-space upper bound, since obstacles add further loss indoors.
- **Handshake (4-way)** — the WPA2/WPA3-PSK exchange that derives the PTK from the PMK and proves both
  sides know the key, without sending it.
- **hc22000 / `-m 22000`** — hashcat's modern mode and file format for WPA-PBKDF2 PMKID+EAPOL cracking.
- **hostapd** — user-space daemon that turns an interface into an AP; configures WPA2/WPA3/OWE/enterprise.
- **Join state machine** — the 802.11 progression a client follows: unauthenticated/unassociated →
  authenticated/unassociated → authenticated/associated; deauth/disassoc move it back.
- **KRACK** — Key Reinstallation Attack (2017) against the 4-way handshake; patched in supplicants.
- **Kr00k** — a 2020 vulnerability causing some chips to transmit buffered frames encrypted with an
  all-zero key after disassociation. See `references/`.
- **Link budget** — the running sum in dB/dBm of transmit power plus antenna gains minus path and other
  losses, giving the signal level at the receiver; compared against receiver sensitivity.
- **mac80211_hwsim** — a Linux kernel module that creates simulated 802.11 radios, enabling protocol
  and configuration labs with no hardware. Does **not** reproduce real RF, drivers, or injection.
- **Management / control / data frames** — the three 802.11 frame types: management (beacons, probes,
  auth, assoc, deauth), control (ACK, RTS/CTS), and data (payload, incl. EAPOL).
- **MFPC / MFPR** — the RSN Capabilities bits for PMF: Management Frame Protection **Capable** and
  **Required**. WPA3-SAE sets required; transition mode sets capable-but-not-required.
- **MIC (Message Integrity Code)** — a keyed checksum over a handshake message, derived from the PTK; in
  WPA2-PSK the captured MIC is what a cracker recomputes per passphrase guess and compares.
- **Monitor mode** — an interface mode that captures all 802.11 frames on a channel, including other
  networks' management/control frames. Distinct from promiscuous mode on wired NICs.
- **MSCHAPv2** — a challenge/response auth used inside PEAP/EAP-TTLS; its captured exchange is
  offline-crackable, which is the basis of the enterprise credential-capture lab.
- **Nonce (ANonce / SNonce)** — the fresh random values from the AP (ANonce) and client (SNonce) in the
  4-way handshake; with the PMK and both MACs they derive a unique per-session PTK.
- **Open System authentication** — the legacy two-frame 802.11 "authentication" step used by modern
  WPA2/WPA3; verifies no credential and always succeeds — not the security handshake.
- **OWE (Enhanced Open)** — opportunistic wireless encryption; encrypts traffic on "open" networks
  **without authenticating the network** — stops passive sniffing, not an active rogue/MITM.
- **Passive vs active scanning** — discovery by listening for beacons (client transmits nothing) versus
  sending probe requests (faster, but the client transmits and may reveal preferred SSIDs).
- **PBKDF2** — the key-derivation function turning a WPA2-Personal passphrase + SSID (salt, 4096
  iterations) into the PMK; deterministic, so a guessed passphrase can be recomputed offline.
- **PMF / 802.11w** — Protected Management Frames; cryptographically protects deauth/disassoc and other
  management frames. Required in WPA3. Changes which attacks are possible.
- **PMK / PTK / GTK** — Pairwise Master Key (derived from the PSK or 802.1X); Pairwise Transient Key
  (per-session, from the 4-way handshake); Group Temporal Key (for broadcast/multicast).
- **PMKID** — an identifier some APs include in the first EAPOL message, derived from the PMK; when
  present it enables clientless capture. Not universal and **not fully passive**.
- **PNL (Preferred Network List)** — the list of SSIDs a client remembers and may probe/auto-join;
  central to KARMA/MANA and evil-twin viability.
- **Probe request / probe response** — the active-scanning management frames: a client's request (which
  can expose its PNL) and an AP's reply advertising its parameters.
- **PSK** — pre-shared key; the passphrase-derived secret in WPA2/WPA3-Personal.
- **Radiotap** — a header prepended to captured 802.11 frames carrying RF metadata (channel, signal,
  rates); present in monitor-mode captures.
- **RADIUS** — the AAA server protocol used as the 802.1X authentication server (e.g. FreeRADIUS).
- **RC4** — the stream cipher underneath WEP and TKIP; fast but with documented keystream biases and
  deprecated in Wi-Fi — seeing RC4 signals a legacy WEP/TKIP configuration.
- **Regulatory domain** — an ISO 3166 country code setting which channels and transmit powers are legal;
  enforced on Linux via `wireless-regdb` and `iw reg`. Spoofing it can be unlawful.
- **Rogue AP** — any AP not sanctioned by the network owner, whether an evil twin or an unmanaged one.
- **RSN** — Robust Security Network; the 802.11i security framework (information element advertised in
  beacons) covering WPA2/WPA3.
- **RSNE (RSN element)** — the RSN information element in beacons/probe responses listing group cipher,
  pairwise ciphers, AKM suites, and RSN Capabilities (incl. PMF bits); an Open network carries none.
- **RSSI** — received signal strength, the power at which your receiver heard a frame (radiotap, in
  dBm); it is receiver metadata, not an announced transmit power.
- **SAE (Dragonfly)** — Simultaneous Authentication of Equals; WPA3-Personal's password-authenticated
  key exchange. Yields **no offline-crackable hash** from a passive capture.
- **SSID** — the human-readable network name advertised by an AP.
- **Supplicant** — the client-side 802.1X/EAP entity (e.g. `wpa_supplicant`).
- **TKIP** — a transitional WPA cipher built on RC4; deprecated. Legacy note only, no lab.
- **ToDS / FromDS** — two Frame Control bits (DS = distribution system) that set what each address field
  means and the frame's direction (uplink, downlink, or AP-to-AP bridging).
- **Transition mode** — a BSS advertising both WPA3-SAE and WPA2-PSK for compatibility; the real
  downgrade surface for WPA3-Personal.
- **WEP** — the original, broken 802.11 encryption. Legacy note only, no lab (OSWP-prep gap disclosed).
- **WPS** — Wi-Fi Protected Setup; PIN/push-button onboarding with a long history of flaws (Pixie Dust,
  online PIN brute). Elective module; recommend disabling.
