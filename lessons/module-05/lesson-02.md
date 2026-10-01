---
id: "05.2"
module: 5
minutes: 22
practice_minutes: 25
prerequisites: ["05.1"]
objectives:
  - Open a monitor-mode capture in Wireshark and navigate the 802.11 dissection tree.
  - Write display filters that isolate frame subtypes, a station, EAPOL frames, and a named SSID.
  - Follow a management or EAPOL exchange between two stations and read it frame by frame.
volatility: implementation
sources:
  - title: "Wireshark display filter reference — wlan (IEEE 802.11)"
    url: https://www.wireshark.org/docs/dfref/w/wlan.html
  - title: "Wireshark display filter reference — eapol"
    url: https://www.wireshark.org/docs/dfref/e/eapol.html
  - title: "Wireshark wiki — capturing and analysing 802.11 (WLAN)"
    url: https://wiki.wireshark.org/CaptureSetup/WLAN
last_verified: "2026-10-01"
---

# 05.2 · Wireshark for 802.11 — dissection and display filters

Wireshark turns a wall of frames into something you can interrogate: the dissection tree shows you every field of a selected frame, and display filters let you cut a thousand-frame capture down to the handful you actually care about. This lesson opens a monitor-mode capture, walks the 802.11 dissection tree from radiotap down to the frame body, and builds the four or five display filters you will reach for in every wireless capture for the rest of the course.

> [!NOTE]
> Wireshark's UI layout, menu paths, and even some filter field names change between releases (`volatility: implementation`). The field names and filters below match the documented display-filter reference at the verification date; confirm against the Wireshark version you installed ([TOOLS.md](../../TOOLS.md)). The *reasoning* — which field answers which question — is stable even when a menu moves.

## Why this matters

From here on, every capture you touch — a join sequence (05.3), a handshake you mean to crack (Module 6), a rogue-AP trace (Module 9) — is read in Wireshark, and the difference between an hour of scrolling and thirty seconds of insight is one good display filter. Knowing that `wlan.fc.type_subtype` names a frame kind, that `wlan.addr` follows one station, and that `eapol` isolates the handshake is what lets you answer "who sent what to whom, and did the key exchange complete" without reading frames one by one. Misreading the dissection tree — attributing a radiotap value to the device, or a field to the wrong address slot — produces confident, wrong findings, so reading it correctly is the whole game.

## Learning objectives

- Open a monitor-mode capture and navigate the **802.11 dissection tree** (radiotap → MAC header → body).
- Write **display filters** that isolate a frame subtype, a station, EAPOL frames, and a named SSID.
- **Follow** a management or EAPOL exchange between two stations and read it frame by frame.

## Prerequisites

- [05.1 · Radiotap and capture formats](lesson-01.md) — you must know the radiotap/802.11/container layering to read the dissection tree without confusing the layers.

## Concept

### The dissection tree

Select a frame and Wireshark expands it top-to-bottom, outermost layer first — which, for a monitor capture, mirrors the layering from 05.1:

1. **Frame** — Wireshark's own per-packet metadata (arrival time, frame number, lengths). Not over-the-air.
2. **Radiotap Header** — the RF pseudo-header: channel, data rate, **Antenna signal (dBm)**, flags. Receiver metadata, never attribute it to the sender.
3. **IEEE 802.11 ...** — the transmitted frame: **Frame Control** (type/subtype, ToDS/FromDS, the **Protected** flag), **Duration**, the **Address** fields, **Sequence Control**, then the frame body.
4. **The body / upper protocol** — for a beacon, the tagged parameters (SSID, supported rates, RSN IE); for a data frame carrying the handshake, an **802.1X Authentication (EAPOL)** subtree.

The packet-list columns up top (No., Time, Source, Destination, Protocol, Info) are a summary of that tree; the **Info** column already names the subtype ("Beacon frame," "Authentication," "Key (Message 2 of 4)"), which is often all you need to spot the frame you want before expanding it.

### Display filters — the four you will always use

A **display filter** hides non-matching frames without deleting them (distinct from a *capture* filter, which decides what gets recorded). The ones that earn their keep on 802.11:

| Goal | Filter | Notes |
|---|---|---|
| One frame subtype | `wlan.fc.type_subtype == 8` | 8 = beacon; 4/5 = probe req/resp; 11 = auth; 0/1 = assoc req/resp; 12 = deauth |
| Everything to/from a station | `wlan.addr == aa:bb:cc:dd:ee:ff` | matches that MAC in **any** address field; `wlan.sa` / `wlan.da` / `wlan.bssid` pin a specific slot |
| The 4-way handshake | `eapol` | EAPOL-Key frames carry the handshake; Wireshark labels each "Message N of 4" |
| A named network | `wlan.ssid == "LAB-WiFi"` | the SSID tag in beacons/probes/assoc; blank for a hidden SSID |
| Only protected data | `wlan.fc.protected == 1` | the Protected Frame bit — an encrypted payload ([05.4](lesson-04.md)) |

Combine them with `and` / `or` / `not` and parentheses, exactly as you would expect:

```
wlan.fc.type_subtype == 8 and wlan.ssid == "LAB-WiFi"     # beacons for one network
wlan.addr == <client> and eapol                            # that client's handshake frames
wlan.fc.type_subtype >= 10 and wlan.fc.type_subtype <= 12  # auth / deauth / disassoc management
```

Two habits save hours. First, type into the filter bar and watch it turn **green** (valid) or **red** (syntax error) before pressing Enter — a red filter matches nothing, which looks exactly like "no such frames." Second, right-click any field in the dissection tree → **Apply as Filter** to let Wireshark write the exact field name for you; this is also how you learn the field names for subtypes beyond the table above.

### Following an exchange

Once a filter narrows to one conversation, read it in order. For a **management** exchange (a join) you expect, between the client and the BSSID, a probe request/response, two authentication frames, then association request/response — the sequence from [01.4](../module-01/lesson-04.md), now visible as rows. For the **EAPOL** exchange, `eapol` leaves just the four key messages; the Info column's "Message 1/2/3/4 of 4" lets you confirm the handshake ran to completion (the subject of 05.3). Because the 802.11 MAC header is never encrypted, you can do all of this — addressing, subtypes, sequence, handshake presence — with **no key at all**; only the data *payload* is protected ([05.4](lesson-04.md)).

> [!TIP]
> `tshark` is Wireshark's command-line twin and takes the **same display filters**, which is how you script a check: `tshark -r capture.pcapng -Y eapol` prints just the handshake frames. Reach for it when you want a repeatable one-liner rather than a click-through.

## Hands-on

### Guided walkthrough — filter and follow a supplied capture (path R)

Recorded-data exercise: you read a capture we ship and transmit nothing.

1. From the module zip ([`labs/module-05/`](../../labs/module-05/)), open `wpa2-handshake-good.pcapng` in Wireshark. (Captures are **PENDING** — see [`labs/common/CAPTURES.md`](../../labs/common/CAPTURES.md); until then, drive the same steps on any monitor capture you have.)
2. Select a **beacon** and expand the tree: read the **radiotap** signal, then under **IEEE 802.11** read Frame Control (type/subtype), the addresses, and in the body the **SSID** tag. Confirm the radiotap signal is not inside the 802.11 part.
3. Apply `wlan.fc.type_subtype == 8` and confirm only beacons remain; change `8` to `11` (auth) and watch the list change. Note the filter bar colour each time.
4. Filter to one station: `wlan.addr == <the client MAC>`; then narrow to its handshake with `wlan.addr == <client> and eapol`.
5. With `eapol` alone, read the Info column and confirm you can see **Message 1 of 4** through **Message 4 of 4** in order — the handshake you will crack in Module 6.
6. Repeat one filter as a `tshark` one-liner: `tshark -r wpa2-handshake-good.pcapng -Y eapol` and confirm the same frames print.

> [!NOTE]
> **Lab paths:** R (filter and follow supplied captures — no hardware; proves you can navigate the dissection tree and write display filters, **not** that you captured anything live). V/P not used — this is analysis of a recorded file.
> **Start state:** module zip unpacked; Wireshark/`tshark` installed ([TOOLS.md](../../TOOLS.md)); supplied capture present (**PENDING** — [`labs/common/CAPTURES.md`](../../labs/common/CAPTURES.md)).
> **Duration:** ~25 min.
> **Artifacts:** the five filters you used, each with the frame count it produced; a one-line note of the client/BSSID MACs; the `tshark -Y eapol` output.
> **Troubleshooting:** filter bar red → syntax/field-name error, fix before pressing Enter (a red filter matches nothing); a filter matches nothing though frames exist → check band/addresses and that you used the right subtype number; no EAPOL frames → the capture may hold only a partial handshake (lesson 05.3); unsure of a field name → right-click the field → Apply as Filter.
> **Cleanup:** none — nothing transmitted or captured.

## Exercise

A learner wants "just the deauthentication frames aimed at my lab client" from a busy capture, and types `wlan.addr = 12` into the filter bar. The bar turns red and nothing shows, and they conclude there were no deauths. Explain the two separate mistakes in that filter, write the filter they actually meant, and say how they could have had Wireshark write the correct field name for them.

<details>
<summary>Hint</summary>

Look at the operator and at what `12` is supposed to mean. One mistake is syntax (what does a single `=` do in a display filter?); the other is semantics (a deauth is a *subtype*, and an address is a MAC, not the number 12). What does a red filter bar tell you before you even press Enter?
</details>

<details>
<summary>Reference answer</summary>

Two mistakes. **Syntax:** Wireshark's comparison operator is `==` (or `eq`), not a single `=`, so `wlan.addr = 12` is invalid — which is exactly why the bar went **red**, and a red filter matches nothing, so "nothing shows" says nothing about whether deauths exist. **Semantics:** `12` is the deauthentication *subtype*, not an address — `wlan.addr` expects a MAC. The learner conflated "frame kind" with "which station." What they meant is a subtype filter combined with the client's address, e.g. `wlan.fc.type_subtype == 12 and wlan.addr == <client-MAC>`. They could have avoided guessing the field name entirely by selecting a deauth frame, right-clicking its subtype (or address) field in the dissection tree, and choosing **Apply as Filter**, which writes the exact field name and value for them. The lesson: trust the green/red indicator, and let the tree author your filters.
</details>

## References

- [Wireshark display-filter reference — wlan](https://www.wireshark.org/docs/dfref/w/wlan.html) — `wlan.fc.type_subtype`, `wlan.addr`, `wlan.ssid`, `wlan.fc.protected` and the rest.
- [Wireshark display-filter reference — eapol](https://www.wireshark.org/docs/dfref/e/eapol.html) — the EAPOL-Key fields behind "Message N of 4."
- [Wireshark WLAN capture wiki](https://wiki.wireshark.org/CaptureSetup/WLAN) — monitor-mode capture and 802.11 dissection.
- [01.4 · Joining a network](../module-01/lesson-04.md) — the management sequence you follow here as filtered rows.

## What you should now be able to do

- Open a monitor capture and navigate the 802.11 dissection tree without confusing radiotap with the frame.
- Write display filters for a subtype, a station, EAPOL, and a named SSID, and combine them.
- Follow a management or EAPOL exchange frame by frame and confirm a handshake ran to completion.
