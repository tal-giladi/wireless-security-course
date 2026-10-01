---
id: "01.1"
module: 1
minutes: 18
practice_minutes: 10
prerequisites: ["00.1"]
objectives:
  - Relate frequency, wavelength, and band to how far a Wi-Fi signal travels and how it is received.
  - Reason in dB and dBm — add and subtract gains and losses, and read RSSI from a capture.
  - Explain antenna gain and directionality and how they, with TX power, bound capture range and containment.
volatility: concept
sources:
  - title: "IEEE 802.11-2020 standard (PHY, power, and channel definitions)"
    url: https://standards.ieee.org/ieee/802.11/7028/
  - title: "The radiotap header (RF metadata in monitor-mode captures)"
    url: https://www.radiotap.org/
last_verified: "2026-10-01"
---

# 01.1 · Radio basics for hackers — spectrum, power, and antennas

Wi-Fi is radio, and every capture, every attack, and every containment decision in this course is shaped by how radio behaves in the physical world. This lesson gives you just enough RF — spectrum, the decibel, transmit power, and antennas — to reason about why a signal reaches one room but not the next, how far your monitor interface can hear, and why "minimum necessary transmission" from Module 0 is a number you can actually estimate rather than a slogan.

## Why this matters

A tester who cannot reason about RF makes two expensive mistakes. The first is over-transmitting: cranking TX power or bolting on a high-gain antenna "to be sure," which in a lab spills your frames across property lines and breaks the containment rules from [lesson 00.3](../module-00/lesson-03.md). The second is misreading a capture: blaming a tool when the real problem is that the target was simply too far away or too weak to hear cleanly. Both mistakes come from treating radio as magic. A little RF literacy turns capture range and blast radius into quantities you can estimate before you transmit.

## Learning objectives

- Relate **frequency**, **wavelength**, and **band** to propagation and reception.
- Work in **dB and dBm** — combine gains and losses, and read signal strength (RSSI) from a capture.
- Explain **antenna gain** and **directionality**, and how they and TX power bound your capture range and containment.

## Prerequisites

- [00.1 · What you'll learn, the three lab paths, and expectations](../module-00/lesson-01.md) — you need the recorded-data path framing and the containment mindset from Module 0.

## Concept

### How it works on the wire

Wi-Fi encodes bits onto a radio wave — an electromagnetic oscillation at a **frequency** measured in hertz. Wi-Fi uses two long-standing bands, **2.4 GHz** and **5 GHz**, and a newer **6 GHz** band (covered in [lesson 01.2](lesson-02.md)). Frequency and **wavelength** are inversely related: wavelength = speed of light / frequency, so 2.4 GHz has a wavelength of about 12.5 cm and 5 GHz about 6 cm. That difference is not trivia — it drives behaviour. Lower-frequency 2.4 GHz waves diffract around obstacles and penetrate walls better, so they travel farther indoors; higher-frequency 5/6 GHz waves carry more channels and higher rates but attenuate faster and are blocked more easily. "2.4 reaches, 5 performs" is the rule of thumb that falls out of the physics.

A signal also occupies **bandwidth** — a span of spectrum around the centre frequency (20 MHz up to 160 MHz, [lesson 01.2](lesson-02.md)). Wider channels carry more data but spread the same transmit power over more spectrum and collide with more neighbours.

### Thinking in decibels

RF power spans many orders of magnitude, so it is expressed logarithmically. A **decibel (dB)** is a *ratio*: `dB = 10 · log10(P_out / P_in)`. Because it is logarithmic, you **add** dB values instead of multiplying ratios. Two numbers are worth memorising: **+3 dB ≈ double** the power, and **+10 dB = ten times** the power (and the negatives halve and tenth it).

A **dBm** is an *absolute* power, referenced to one milliwatt: 0 dBm = 1 mW, 20 dBm = 100 mW, 30 dBm = 1 W. Gains and losses in dB simply add to a dBm level. A worked link budget:

| Element | Value |
|---|---|
| Transmitter output | 20 dBm |
| Transmit antenna gain | +5 dBi |
| Path loss (across the room) | −60 dB |
| Receive antenna gain | +5 dBi |
| **Signal at the receiver** | **−30 dBm** |

If the receiver's **sensitivity** (the weakest signal it can decode at a given rate) is −90 dBm, a −30 dBm signal is 60 dB above the floor — a very strong link. Received strength is reported as **RSSI** and surfaces in captures through the radiotap header ([lesson 01.3](lesson-03.md)) as an "antenna signal" in dBm. Reading it tells you how well you heard a device, which is often the difference between a clean capture and a useless one.

### Free-space loss, in intuition

Signal weakens with distance because the same energy spreads over an ever-larger sphere. In free space, loss grows with the **square of the distance** (doubling the distance costs about 6 dB) and also rises with frequency, which is part of why 5 GHz has shorter effective range than 2.4 GHz at the same power. Indoors, walls, furniture, and bodies add their own losses on top, so real range is always worse than the free-space figure — useful as an upper bound, never a promise.

### Antennas: gain and directionality

An antenna is **passive** — it adds no energy. "Gain," measured in **dBi** (relative to an ideal isotropic radiator), describes how it *focuses* energy: a high-gain antenna concentrates the signal into a narrower beam, trading coverage angle for reach in that direction. An **omnidirectional** antenna radiates roughly equally in a horizontal doughnut; a **directional** one (patch, Yagi) focuses into a lobe. Gain helps on both ends — a directional antenna lets you hear a distant target *and*, by pointing away from everything else, hear less of what you shouldn't. For containment that is exactly the property you want.

> [!NOTE]
> **Tie back to [00.3](../module-00/lesson-03.md):** "minimum necessary transmission" now has levers you can quantify — lower TX power (fewer dBm), a lower-gain or directional antenna aimed only at your own gear, and the band/channel choice from [lesson 01.2](lesson-02.md). The goal is the smallest link budget that still works, not the largest.

## Hands-on

### Guided walkthrough — read signal strength from a supplied capture

This is a recorded-data exercise: you reason about RF from a capture we ship, transmitting nothing.

1. From the module zip (`labs/module-01/`), open `captures/beacon-sample.pcapng` in Wireshark (full dissection comes in Module 5 — here you only read RF metadata).
2. Select a beacon frame and expand the **radiotap header**. Note the **Channel frequency** and the **Antenna signal (dBm)** fields.
3. Compare two beacons from different APs. The one with the stronger (closer to zero) dBm value was heard better. Write down both values and which AP you heard more clearly.
4. Estimate: if one AP reads −45 dBm and another −75 dBm, the first is **30 dB** — about 1000× — stronger at your receiver. Note which you could reliably capture a handshake from.

> [!NOTE]
> **Lab paths:** R (read RF metadata from a supplied capture — no hardware; proves you can interpret signal strength and channel, not that you captured anything live). V/P are not used in this foundation lesson.
> **Start state:** module zip unpacked; Wireshark installed.
> **Duration:** ~10 min.
> **Artifacts:** a note of the channel and dBm for two beacons, and which link was stronger.
> **Cleanup:** none — nothing was transmitted or captured.

## Exercise

A learner wants to capture frames from an AP across a large room and reasons: "The signal is weak, so I'll raise my adapter's TX power to maximum and add a 15 dBi directional antenna." Separate what actually helps *reception* from what does not, and explain what their plan does to lab containment. State what you would change.

<details>
<summary>Hint</summary>

Capturing is receiving. Which of "TX power" and "antenna gain" affects what your adapter can *hear*, and which only affects what it *sends*? Then recall that antenna gain is reciprocal (helps transmit and receive) while a directional antenna also changes *where* your energy goes — and what that means for the Module 0 containment rules.
</details>

<details>
<summary>Reference answer</summary>

TX power affects only transmission, so raising it does nothing for a passive capture — it just increases the over-the-air blast radius and can breach containment and local power limits ([00.3](../module-00/lesson-03.md)). The 15 dBi directional antenna genuinely helps reception, because antenna gain is reciprocal: it raises the received signal in the direction it is pointed, and by focusing away from everything else it also reduces what you pick up from networks you don't own — good for containment. The fix: leave TX power low (you are only listening), use the directional antenna aimed solely at your own AP, and if you must transmit later, keep it the minimum that works.
</details>

## References

- IEEE 802.11-2020 — PHY, transmit power, and channel definitions (`../../references/README.md`).
- [The radiotap header](https://www.radiotap.org/) — the RF metadata fields (signal, channel) you read above; revisited in [lesson 01.3](lesson-03.md).
- [00.3 · Safety, containment, and the law](../module-00/lesson-03.md) — minimum necessary transmission.

## What you should now be able to do

- Relate frequency, wavelength, and band to how a Wi-Fi signal propagates and is received.
- Reason in dB and dBm — add gains and losses across a link and read RSSI from a capture.
- Explain how antenna gain, directionality, and TX power set your capture range and your containment blast radius.
