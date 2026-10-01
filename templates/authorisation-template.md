# Scope & authorisation (template)

Fill this in **before** transmitting anything. In this course the only legitimate answer to "who owns
the targets?" is **you** — your own APs, adapters, and test clients. This template is the professional
habit the course builds; in a real engagement a signed version of it is what separates testing from a
crime.

> [!WARNING]
> A private subnet does **not** isolate radio. Deauth, beacons, and probes leave the wire and reach
> every device in range, including networks you do not own. Authorisation plus transmission limits —
> not network segmentation — is what keeps you lawful and safe.

## Authorisation

- **Systems owner:** (you, for this course's labs)
- **Authorised by / date / expiry:** 
- **Written authorisation reference:** (for real engagements — a signed statement of work)

## Target allowlist (only these)

| SSID | BSSID (MAC) | Band / channel | Owner | In scope? |
|---|---|---|---|---|
| `Lab-Target-01` | `aa:bb:cc:…` | 2.4 GHz ch 1 | me | yes |

Anything not listed here is **out of scope** and must not be probed, deauthenticated, or captured.

## Transmission limits

- Channel(s): 
- Maximum TX power (use the lowest that works): 
- Directional antenna / attenuation / RF shielding used? 
- Prefer the **virtual (`mac80211_hwsim`)** path for transmit-heavy work where practical.

## Stop conditions

- Stop immediately if a device **not** on the allowlist associates, deauthenticates, or is affected.
- Stop if you observe interference with any production or neighbouring network.
- Stop at the end of the authorised time window.

## Credentials & cleanup

- Synthetic credentials only (e.g. `Lab-WiFi-Passw0rd!`, `LAB-FLAG-{uuid}`). No real secrets.
- Cleanup checklist: stop `hostapd`/rogue AP, restore client configuration, delete captured synthetic
  credentials, return adapters to managed mode, reset regulatory domain if changed.

## Local law

Radio regulations (TX power, DFS channels, band licensing) and interception/interference law vary by
country. This course gives general guidance, not legal advice — confirm the rules for your jurisdiction
before you transmit.
