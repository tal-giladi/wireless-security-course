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
- **aireplay-ng -9 (injection test)** — the aircrack-ng command (`-9`/`--test`) that confirms whether
  frame injection works on a monitor-mode interface; prints "Injection is working!" on success.
- **airodump-ng** — the aircrack-ng suite's live survey/capture tool: a refreshing table of APs (BSSID,
  PWR, CH, ENC/CIPHER/AUTH, ESSID) and clients, able to lock a channel/BSSID to write a capture.
- **AKM (Authentication and Key Management)** — the RSN suite selector that names the security mode
  (PSK, SAE, 802.1X, OWE); it, not the cipher, tells you whether a network is WPA2, WPA3-SAE, or OWE.
- **AP mode (adapter capability)** — an adapter's ability to act as an access point under `hostapd`;
  distinct from monitor and injection — a chip may support one or two of the three but not all.
- **AP (access point)** — the device that originates a BSS and bridges wireless clients to a network.
- **Association** — the final step by which a client joins a BSS after authentication.
- **Beacon** — a management frame an AP broadcasts periodically advertising its SSID and capabilities.
- **Bounded cracking case** — a teaching setup where the supplied wordlist contains the lab passphrase, so
  the crack has a known, achievable, terminating result (success = recovered key + correct method).
- **BSS / BSSID / ESS** — a Basic Service Set is one AP's cell; the BSSID is usually the AP's MAC; an
  Extended Service Set is multiple APs sharing one SSID.
- **CCMP / AES** — the modern 802.11 cipher (AES in CCMP mode) for WPA2/WPA3 confidentiality and
  integrity, replacing deprecated TKIP/RC4; GCMP is its counterpart for the newest modes.
- **Channel** — a named centre frequency within a band that a radio tunes to; a receiver hears only the
  channel (and width) it is set to.
- **Channel hopping** — a scanner cycling its radio across channels to survey everything in range; good
  for an initial survey but poor for capturing one target, since the radio dwells on each only briefly.
- **Channel lock** — parking the radio on one channel (e.g. `airodump-ng --channel`) so it is present
  for a target's frames; the mode used to capture, as opposed to survey.
- **Channel width** — the spectrum a signal occupies (20/40/80/160 MHz); wider carries more but spreads
  power and overlaps more neighbours, and a capture must match it.
- **Chipset-first buying rule** — choose a Wi-Fi adapter by its chipset (known-good Linux support), not
  its model/marketing name, then verify the exact model + hardware revision before buying.
- **dB (decibel)** — a logarithmic *ratio* of two powers; gains/losses add instead of multiplying.
  +3 dB ≈ double power, +10 dB = ten times. Distinct from dBm (which is absolute).
- **dBi** — antenna gain relative to an ideal isotropic radiator; describes how an antenna focuses
  energy into a direction, trading coverage angle for reach (it adds no energy).
- **Deauthentication** — a management frame that ends a client's session. Forgeable unless management
  frames are protected (PMF / 802.11w).
- **DFS (Dynamic Frequency Selection)** — a regulatory requirement on radar-shared 5 GHz channels: an AP
  must listen and vacate on radar. A regulatory behaviour, not a security feature.
- **dBm** — decibels relative to one milliwatt; the unit for RF signal power. +3 dBm ≈ double power.
- **Directed vs broadcast (wildcard) probe request** — a probe naming a specific SSID versus one naming
  none; directed probes can expose a client's saved-network names, which modern clients increasingly avoid.
- **Display filter (Wireshark)** — an expression that hides non-matching frames from view (vs a capture
  filter, which decides what is recorded); 802.11 staples `wlan.fc.type_subtype`, `wlan.addr`, `eapol`.
- **Dissection tree** — Wireshark's expandable, layer-by-layer breakdown of a frame: Frame → Radiotap →
  802.11 MAC header → body (e.g. an EAPOL subtree); the Info column summarises it.
- **DKMS (out-of-tree driver)** — Dynamic Kernel Module Support rebuilds an out-of-tree driver (e.g.
  Realtek RTL8812AU) per kernel; fragile across upgrades, so pin a known-good kernel when a lab needs it.
- **DLT (link-layer header type)** — the datalink type recorded for a capture: `IEEE802_11_RADIO` is
  radiotap-plus-802.11 (channel/signal present), while plain `IEEE802_11` has frames but no radio header.
- **Dragonblood** — a class of side-channel and downgrade vulnerabilities in early SAE/WPA3
  implementations (2019), with vendor mitigations; not a break of SAE's design. See `references/`.
- **EAP** — Extensible Authentication Protocol; the method negotiated inside 802.1X (PEAP, EAP-TTLS,
  EAP-TLS, …). Determines where trust lives and what a client must validate.
- **EAPOL** — EAP over LAN; carries the 4-way handshake messages (and 802.1X EAP) over 802.11.
- **EAPOL message pair (complete vs partial handshake)** — a captured handshake is crackable only with a
  consistent message pair (M1+M2 or M2/M3, matching nonces); a partial one has no testable MIC.
- **Evil twin** — a rogue AP impersonating a legitimate SSID to attract clients. Success is conditional
  on the target client's behaviour and configuration.
- **Exhausted (hashcat status)** — the end state of a run that tried every candidate without a match; it
  proves the passphrase was not in that keyspace, not that the passphrase is strong against another list.
- **FCS (Frame Check Sequence)** — the 4-byte CRC ending an 802.11 frame; a receiver uses it to discard
  corrupted frames.
- **FragAttacks** — a 2021 class of design and implementation flaws in 802.11 frame aggregation and
  fragmentation. See `references/`.
- **Frame Control** — the first 2-byte field of the MAC header, carrying Type/Subtype and flags
  including ToDS, FromDS, and Protected Frame.
- **Frame injection** — an adapter's ability to transmit crafted 802.11 frames (e.g. deauth, aireplay-ng
  test frames); a capability separate from monitor mode — an adapter may capture yet be unable to inject.
- **Free-space path loss** — the weakening of a signal with distance (≈ 6 dB per doubling) and with
  frequency; an open-space upper bound, since obstacles add further loss indoors.
- **Handshake (4-way)** — the WPA2/WPA3-PSK exchange that derives the PTK from the PMK and proves both
  sides know the key, without sending it.
- **Hardware revision trap (TL-WN722N)** — the canonical example: v1 = AR9271 (monitor/injection) but
  v2/v3 = RTL8188EUS (different chip, commonly not monitor-capable). Same box name, tiny version marking.
- **hc22000 / `-m 22000`** — hashcat's modern mode and file format for WPA-PBKDF2 PMKID+EAPOL cracking.
- **hcxdumptool** — the hcxtools capture utility that actively engages an AP to collect a PMKID or
  handshake (not passive); distinct from `hcxpcapngtool`, and its flags change across major versions.
- **hcxpcapngtool** — the hcxtools utility that converts a capture (`.pcapng`) containing a handshake or
  PMKID into the `hc22000` hashline hashcat consumes; distinct from `hcxdumptool` (a capture tool).
- **Hidden SSID** — a network whose beacons omit the SSID name (the length may still leak); obscurity,
  not security — resolved passively from an associating client or actively with a directed probe.
- **hostapd** — user-space daemon that turns an interface into an AP; configures WPA2/WPA3/OWE/enterprise.
- **iw reg** — the Linux command to read (`iw reg get`) or set (`iw reg set <COUNTRY>`) the regulatory
  domain that governs legal channels and TX power.
- **Join state machine** — the 802.11 progression a client follows: unauthenticated/unassociated →
  authenticated/unassociated → authenticated/associated; deauth/disassoc move it back.
- **KCK (Key Confirmation Key)** — the first 128 bits of the PTK, used to compute the MIC on EAPOL
  messages 2 and 3; a correct MIC proves the sender holds the right PMK, which is the offline-crack oracle.
- **Keyspace** — the total set of candidate passphrases a cracking attempt covers; with a device's
  hashrate it gives the time to exhaust a brute force, bounding residual risk for a strong passphrase.
- **Kismet** — a passive wireless detector that builds a long-running database of every AP and client it
  hears (including per-client probed-SSID history) via a web UI, transmitting nothing.
- **KRACK** — Key Reinstallation Attack (2017) against the 4-way handshake; patched in supplicants.
- **Kr00k** — a 2020 vulnerability causing some chips to transmit buffered frames encrypted with an
  all-zero key after disassociation. See `references/`.
- **Lab paths (R / V / P)** — the three separately-credited ways to do a lab: **R** recorded-data
  (supplied captures, no hardware), **V** virtual (`mac80211_hwsim`, no hardware), **P** physical (owned
  adapter + AP + client). R and V never grant physical-capture/injection credit.
- **Link budget** — the running sum in dB/dBm of transmit power plus antenna gains minus path and other
  losses, giving the signal level at the receiver; compared against receiver sensitivity.
- **mac80211_hwsim** — a Linux kernel module that creates simulated 802.11 radios, enabling protocol
  and configuration labs with no hardware. Does **not** reproduce real RF, drivers, or injection.
- **MAC randomisation** — clients using a randomised, non-permanent MAC when scanning (and often per
  network once associated) to resist tracking; not standardised across OSes and not a complete fix.
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
- **Passphrase entropy** — the number of equally-likely possibilities a guesser must cover; for
  human-chosen WPA2 secrets, length raises it far more than character-class rules. The decisive control.
- **PBKDF2** — the key-derivation function turning a WPA2-Personal passphrase + SSID (salt, 4096
  iterations) into the PMK; deterministic, so a guessed passphrase can be recomputed offline.
- **pcap (classic)** — the original libpcap file format: a global header then one record per packet, with
  a single link-layer type for the whole file; read everywhere but carries no per-packet annotations.
- **pcapng** — the next-generation capture format (Wireshark's default): typed blocks holding multiple
  interfaces and per-packet comments; converting pcapng → pcap is lossy.
- **PMF / 802.11w** — Protected Management Frames; cryptographically protects deauth/disassoc and other
  management frames. Required in WPA3. Changes which attacks are possible.
- **PMK / PTK / GTK** — Pairwise Master Key (derived from the PSK or 802.1X); Pairwise Transient Key
  (per-session, from the 4-way handshake); Group Temporal Key (for broadcast/multicast).
- **PMKID** — an identifier some APs include in the first EAPOL message, derived from the PMK; when
  present it enables clientless capture. Not universal and **not fully passive**.
- **PMKID derivation (PMK Name)** — the PMKID is `HMAC-SHA1-128(PMK, "PMK Name" || AA || SPA)` over the
  two (known) MACs, so a captured PMKID is an offline oracle for the passphrase, like the handshake MIC.
- **PMKID suppression** — disabling an AP's RSN-PMKID advertisement (where roaming does not need it) to
  remove the clientless path; defence-in-depth only, firmware-dependent, no substitute for passphrase entropy.
- **PNL (Preferred Network List)** — the list of SSIDs a client remembers and may probe/auto-join;
  central to KARMA/MANA and evil-twin viability.
- **Probe request / probe response** — the active-scanning management frames: a client's request (which
  can expose its PNL) and an AP's reply advertising its parameters.
- **Protected Frame flag (`wlan.fc.protected`)** — the Frame Control bit marking a frame whose payload is
  encrypted (CCMP/GCMP); the MAC header stays cleartext, so addresses/subtype/sequence remain readable.
- **Provenance (of a capture)** — the record of how and by whom a capture was generated (owned equipment,
  synthetic credentials) plus its redistribution licence; required alongside a checksum before shipping.
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
- **SHA-256 checksum** — a 64-hex fingerprint of a file's exact bytes; comparing a computed hash to a
  recorded one proves byte-for-byte integrity, but nothing about where the file came from (see provenance).
- **SSID** — the human-readable network name advertised by an AP.
- **Strong-password (no-crack) case** — a teaching setup where the passphrase is in no supplied list and
  high-entropy, so recovery is not expected; the correct outcome is to conclude infeasibility and
  recommend the control. Failing to crack is the right answer.
- **Supplicant** — the client-side 802.1X/EAP entity (e.g. `wpa_supplicant`).
- **TKIP** — a transitional WPA cipher built on RC4; deprecated. Legacy note only, no lab.
- **ToDS / FromDS** — two Frame Control bits (DS = distribution system) that set what each address field
  means and the frame's direction (uplink, downlink, or AP-to-AP bridging).
- **Traffic analysis (metadata)** — drawing conclusions from the cleartext parts of a capture (MACs,
  SSIDs, timing, handshake/PMKID presence) without reading the encrypted payload — the key-less limit.
- **Transition mode** — a BSS advertising both WPA3-SAE and WPA2-PSK for compatibility; the real
  downgrade surface for WPA3-Personal.
- **Triangulation (AP location estimation)** — inferring an AP's likely position from many observations
  of its BSSID at different GPS points, weighted by signal; one observation only bounds where it was heard.
- **tshark** — Wireshark's command-line counterpart; takes the same display filters
  (e.g. `tshark -r file.pcapng -Y eapol`), used to script repeatable checks over a capture.
- **USB passthrough** — detaching a USB device from the host so a guest VM can claim it; on VirtualBox it
  needs the Extension Pack, and Hyper-V has no general raw USB passthrough for a Wi-Fi adapter.
- **Wardriving** — surveying wireless networks while moving, logging each AP/client's broadcast metadata
  (BSSID, SSID, channel, security) tagged with a GPS position; passive observation, not interception.
- **WEP** — the original, broken 802.11 encryption. Legacy note only, no lab (OSWP-prep gap disclosed).
- **WiGLE (Wireless Geographic Logging Engine)** — a public database aggregating GPS-tagged network
  metadata into a searchable map; it stores metadata and estimated locations, not traffic or credentials,
  and a listing is information, not authorisation to test.
- **WPS** — Wi-Fi Protected Setup; PIN/push-button onboarding with a long history of flaws (Pixie Dust,
  online PIN brute). Elective module; recommend disabling.
