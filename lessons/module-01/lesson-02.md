---
id: "01.2"
module: 1
minutes: 20
practice_minutes: 10
prerequisites: ["01.1"]
objectives:
  - Describe the 2.4, 5, and 6 GHz bands and how channels and channel width map onto each.
  - Explain 2.4 GHz channel overlap and why 1/6/11 are the non-overlapping choices.
  - Explain DFS and regulatory domains and how band and channel choice affect what you can capture.
volatility: concept
sources:
  - title: "IEEE 802.11-2020 standard (channelisation and operating classes)"
    url: https://standards.ieee.org/ieee/802.11/7028/
  - title: "Wi-Fi Alliance — Wi-Fi security and specifications overview"
    url: https://www.wi-fi.org/discover-wi-fi/security
  - title: "Linux wireless-regdb and iw regulatory domain handling"
    url: https://wireless.docs.kernel.org/en/latest/en/developers/regulatory.html
last_verified: "2026-10-01"
---

# 01.2 · Bands and channels — 2.4, 5, and 6 GHz, width, DFS, and regulatory domains

A Wi-Fi radio can only hear one channel at a time, so before you capture anything you have to know which band and channel a target is on — and why that choice is constrained by physics, regulation, and the width of the channel itself. This lesson maps the three bands onto their channels, explains the overlap that makes 2.4 GHz messy, and introduces DFS and regulatory domains so that "set the right channel" becomes a deliberate decision rather than guesswork.

## Why this matters

Monitor-mode capture is channel-bound: an interface parked on channel 1 will not see a network on channel 36, no matter how strong the signal. Most "my capture is empty" problems are really "wrong channel" or "wrong band" problems. Band and channel choice also shapes containment — a crowded 2.4 GHz channel means more of your transmissions land near networks you don't own. And regulatory domains decide which channels and power levels are even legal for you, a rule [lesson 00.3](../module-00/lesson-03.md) flagged as something you can break by spoofing. Getting bands and channels right is the quiet prerequisite for every capture lab that follows.

## Learning objectives

- Describe the **2.4, 5, and 6 GHz** bands and how **channels** and **channel width** map onto them.
- Explain **2.4 GHz overlap** and why channels **1, 6, and 11** are the usual non-overlapping choices.
- Explain **DFS** and **regulatory domains**, and how band/channel choice affects what you can capture.

## Prerequisites

- [01.1 · Radio basics for hackers](lesson-01.md) — frequency, bandwidth, and the dB intuition you need to understand overlap and width.

## Concept

### How it works on the wire

A **channel** is a named centre frequency within a band; **channel width** is how much spectrum the signal occupies around it (20, 40, 80, or 160 MHz). A receiver tuned to a channel and width hears transmissions that fall within that span.

**2.4 GHz** runs roughly 2.400–2.4835 GHz, divided into channels 1–13 (14 in Japan) spaced only **5 MHz** apart. But a 20 MHz Wi-Fi signal is four times wider than that spacing, so adjacent channels **overlap heavily**. Only channels **1, 6, and 11** are far enough apart (25 MHz) to not overlap in most domains — which is why those three are the standard non-overlapping set, and why 40 MHz channels are a poor fit for the crowded 2.4 GHz band.

**5 GHz** (approximately 5.150–5.895 GHz, in several U-NII sub-bands) offers many more 20 MHz channels that do **not** overlap, and comfortably supports 40, 80, and even 160 MHz widths. More channels means less contention — but higher frequency means shorter range ([lesson 01.1](lesson-01.md)).

**6 GHz** (Wi-Fi 6E/7, roughly 5.925–7.125 GHz, the U-NII-5 through U-NII-8 sub-bands) adds up to 1200 MHz of new spectrum — on the order of 59 fresh 20 MHz channels and up to seven 160 MHz channels — though how much is open varies sharply by country (some regions allow only the lower U-NII-5 portion). It requires WPA3 and has its own discovery mechanisms.

### Width is a trade-off

Wider channels carry more data but spread the same transmit power across more spectrum (lowering power density), collide with more neighbours, and, in the crowded 2.4 GHz band, are usually counter-productive. For capture, width matters because your monitor interface must be set to the **same width** as the target to dissect the frames cleanly; a width mismatch can leave you seeing only part of the traffic.

### DFS — sharing 5 GHz with radar

Parts of the 5 GHz band are shared with radar (weather, military, aviation). On those channels, regulators require **Dynamic Frequency Selection (DFS)**: an AP must listen first and, if it detects a radar pattern, vacate the channel. Two consequences for a tester: a target may **move channels** mid-session when radar appears (your capture suddenly goes quiet), and bringing up your own AP on a DFS channel involves a mandatory listening period before it beacons. DFS is a regulatory behaviour, not a security feature.

### Regulatory domains

Which channels exist, which need DFS, and what transmit power is allowed are all set by a **regulatory domain** — an ISO 3166 country code. On Linux the kernel enforces this through the **wireless-regdb** database and the **`iw`** tool. You can read the current domain and, as a preview of Module 3, set it:

```bash
iw reg get                 # show the current regulatory domain
sudo iw reg set IL         # request a domain (country code) — Module 3 covers this properly
```

> [!WARNING]
> Setting a regulatory domain other than the one you are legally in — to unlock channels or power your country forbids — can be unlawful and increases interference and your over-the-air footprint ([00.3](../module-00/lesson-03.md)). Set it to your real jurisdiction. The command appears here only to show where this lives; you configure it deliberately in Module 3.

The domain is not cosmetic: it changes which channels your adapter will even transmit on and at what power, so it directly affects both what you can do and what is legal.

Explore channels, widths, and overlap interactively (educational model):

[Simulation: channel and band spectrum map](../../simulations/spectrum/index.html)

## Hands-on

### Guided walkthrough — map a capture to its band, channel, and width

This is a recorded-data exercise — you read channel metadata from supplied captures and transmit nothing.

1. From the module zip (`labs/module-01/`), open `captures/multi-channel-beacons.pcapng` in Wireshark.
2. For each beacon, read the radiotap **Channel frequency** and work out the **band** (2.4 vs 5 vs 6 GHz) and the **channel number**. Note any **HT/VHT/HE** information elements that reveal the channel **width**.
3. List which channels are in use. Identify any two 2.4 GHz networks that are on **overlapping** channels (e.g. 1 and 3) versus the non-overlapping 1/6/11 set.
4. Pick the channel you would park a monitor interface on to capture a given target, and write down why a capture on a different channel would come back empty.

> [!NOTE]
> **Lab paths:** R (read band/channel/width from supplied captures — no hardware; proves you can map a target to the channel you must tune to, not that you captured live). V/P not used here.
> **Start state:** module zip unpacked; Wireshark installed.
> **Duration:** ~10 min.
> **Artifacts:** a table of networks → band/channel/width, with the capture channel you'd choose per target.
> **Cleanup:** none — nothing transmitted or captured.

## Exercise

A learner parks their monitor interface on 2.4 GHz channel 6 at 20 MHz width and captures for ten minutes, but sees nothing from the AP they care about — which a neighbour tells them is "on channel 6 as well." List the band/channel/width reasons the capture could still be empty, and how you would confirm each before blaming the adapter.

<details>
<summary>Hint</summary>

"Channel 6" is ambiguous: is it 2.4 GHz channel 6 or a 5/6 GHz channel that also carries the number? Could the AP be on a DFS channel it moved to? Could a width mismatch (the AP on 40/80 MHz) mean you're only hearing part of its spectrum? Each has a different confirmation step.
</details>

<details>
<summary>Reference answer</summary>

Several band/channel/width causes, none of them a broken adapter: (1) wrong band — channel numbers repeat across bands, so a 5 GHz AP "on 6" is a different frequency your 2.4 GHz capture never covers; confirm by scanning all bands. (2) The AP is on a **DFS** 5 GHz channel and moved when radar appeared, so it is no longer where you expect; confirm with a fresh scan. (3) **Width mismatch** — the AP runs 40/80 MHz and your 20 MHz capture only catches part of it or misses the primary channel; confirm by matching the target's width. (4) The AP genuinely changed channel. Confirm band and channel with a scan first, then match width, and only then suspect hardware.
</details>

## References

- IEEE 802.11-2020 — channelisation, operating classes, and DFS requirements (`../../references/README.md`).
- [Wi-Fi Alliance — security and specifications](https://www.wi-fi.org/discover-wi-fi/security) — 6 GHz (Wi-Fi 6E) and WPA3 requirement context.
- [Linux wireless-regdb and `iw` regulatory handling](https://wireless.docs.kernel.org/en/latest/en/developers/regulatory.html) — how the regulatory domain is enforced; configured in Module 3.

## What you should now be able to do

- Describe the 2.4, 5, and 6 GHz bands and how channels and channel width map onto each.
- Explain 2.4 GHz overlap and why 1/6/11 are the non-overlapping choices.
- Explain DFS and regulatory domains and reason about why a capture on the wrong band, channel, or width comes back empty.
