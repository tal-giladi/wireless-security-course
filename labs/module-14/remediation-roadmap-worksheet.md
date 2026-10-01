# Remediation roadmap — worksheet (Lesson 14.3)

Four findings against a small owned-lab network. Build a prioritised, verifiable roadmap, state residual
risk, and write a short note to the (non-technical) owner. All data is synthetic (course virtual-path
lab).

## The network

A 15-person office, single flat SSID `LAB-OFFICE` carrying staff laptops **and** the file share
`\\LAB-FILES`. Two APs: `AP-1` and `AP-2`. One legacy handheld stock scanner that supports only WPA2.

## The four findings

1. **Weak WPA2 passphrase** on `LAB-OFFICE` (recovered from a bounded crack). The flat network also
   carries the file share.
2. **PMF disabled** across both APs (`ieee80211w=0`) — forged deauth disconnects clients.
3. **WPS PIN enabled** on `AP-2` (Pixie Dust exposure).
4. **Legacy scanner cannot do WPA3** — a constraint on any SAE-only migration.

## Worksheet

### 1. Prioritise (order the four; one line of asset-framed severity rationale each)

```
1st: finding #__ — rationale: ____________________________________________
2nd: finding #__ — rationale: ____________________________________________
3rd: finding #__ — rationale: ____________________________________________
4th: finding #__ — rationale: ____________________________________________
```

### 2. Make each verifiable (control + vulnerable-vs-hardened retest)

| Finding | Control / change | Retest that proves it (before → after) |
|---|---|---|
| #1 weak PSK | | |
| #2 PMF off | | |
| #3 WPS PIN | | |
| #4 legacy scanner | | |

*(Pull each retest from its module: bounded crack exhausted — M6.4; forged deauth rejected — M6.5/M7/M12.1;
no WPS in a scan — M8.4; for #4, a segmented WPA2 SSID is a mitigation, not a full fix.)*

### 3. Residual risk (fixed / remains / why — two or three sentences)

```
____________________________________________________________________________
____________________________________________________________________________
```

### 4. Owner note (2–3 sentences: lead with impact + fix, acknowledge the legacy-device constraint,
state residual risk plainly)

```
____________________________________________________________________________
____________________________________________________________________________
```
