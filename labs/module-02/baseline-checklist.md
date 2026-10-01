# Secure wireless baseline checklist (Lesson 02.3)

Fill this in once by auditing `ap-config-vulnerable.txt` and `ap-config-hardened.txt`, then **keep it**:
Modules 6, 7, 9, and 11 ask you to measure an attack against this hardened baseline. For each control,
mark the state, record the **deciding config line**, and note the **measurement** that would prove the fix.

> Audit only equipment you own (Lesson 00.3). This is a defence/audit exercise — no attack is run here.

## Controls

### 1. Segmentation (guest vs internal)
- [ ] Guest and internal clients are on separate SSIDs/VLANs, with client isolation and a firewall deny rule guest→internal.
- Deciding line(s): __________  (e.g. `ap_isolate=`, separate SSID, gateway firewall rule)
- Measurement: from a guest client, reaching an internal host __succeeds / is blocked__.

### 2. AP administration hygiene
- [ ] Default admin password changed; remote/WAN management disabled; unused services off.
- Deciding line(s): __________
- Measurement: management reachable from WAN / guest VLAN __yes / no__.

### 3. Firmware maintenance
- [ ] Firmware current; vendor advisories tracked; patched on a schedule.
- Deciding note: __________
- Measurement: known-CVE attack (KRACK/FragAttacks/Kr00k, Module 12) __applies / patched__.

### 4. WPS configuration
- [ ] WPS disabled (or push-button only, time-boxed; external PIN never left enabled).
- Deciding line(s): __________  (e.g. `wps_state=`, `config_methods=`)
- Measurement: Pixie Dust / PIN attack (Module 8) __has a target / no WPS__.

### 5. Protocol & PMF
- [ ] WPA3-SAE with PMF required where possible; CCMP only (no TKIP); PMF required/at least capable.
- Deciding line(s): __________  (e.g. `wpa_key_mgmt=`, `rsn_pairwise=`, `ieee80211w=`)
- Measurement: forged deauth __succeeds (PMF off) / rejected (PMF required)__ (Modules 6, 7, 12);
  passive capture yields __crackable handshake/PMKID (PSK) / nothing offline (SAE)__.

### 6. PSK strength (if PSK is used at all)
- [ ] Long, high-entropy passphrase (or SAE).
- Deciding line(s): __________  (e.g. `wpa_passphrase=`, `sae_password=`)
- Measurement: bounded crack __recovers a weak passphrase / fails against a strong one__ (Module 6).

### 7. Client policy
- [ ] Enterprise clients validate the RADIUS server cert and identity; MAC randomisation on; auto-join and PNL pruned.
- Deciding note: __________  (client-side, not in the AP config)
- Measurement: rogue RADIUS __captures creds (unhardened) / client refuses and logs why (hardened)__ (Module 11.5);
  evil twin of a remembered SSID __attracts the client / is ignored__ (Module 9).

### 8. Monitoring / rogue detection
- [ ] Known BSSIDs/SSIDs inventoried; rogue-AP / deauth-flood monitoring in place (manual scan minimum, WIDS/WIPS ideally).
- Deciding note: __________
- Measurement: a rogue AP in range is __detected / missed__ (Modules 9.5, 14).

## Deprecated-cipher check (Lesson 02.4)
- [ ] No WEP anywhere; no TKIP offered (CCMP/AES only). Any WEP/TKIP found is a **finding**, not a lab.
- Deciding line(s): __________  (e.g. `wpa_pairwise=`, `rsn_pairwise=`)
