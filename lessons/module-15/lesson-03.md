---
id: "15.3"
module: 15
minutes: 14
practice_minutes: 0
prerequisites: ["01.1"]
objectives:
  - Explain what software-defined radio is and what it unlocks for a security practitioner.
  - Distinguish receive-only from transmit-capable SDR hardware and why that distinction matters legally.
  - State the legal limits on receiving and transmitting, and decide when SDR is in or out of scope.
volatility: concept
sources:
  - title: "RTL-SDR — about (receive-only, ~24 MHz–1.7 GHz)"
    url: https://www.rtl-sdr.com/about-rtl-sdr/
  - title: "HackRF One (transmit-capable, 1 MHz–6 GHz) — documentation"
    url: https://hackrf.readthedocs.io/en/latest/
last_verified: "2026-10-02"
---

# 15.3 · SDR — what it unlocks and the legal limits

Software-defined radio turns a general-purpose computer plus a cheap radio front-end into a receiver (and sometimes a transmitter) for almost any RF protocol, which is why it is the gateway to all the adjacent-wireless topics in this module. This lesson is awareness-only: what SDR unlocks, the critical receive-versus-transmit distinction, and the legal limits that make SDR the most caution-forward topic in the course.

## Why this matters

SDR is genuinely powerful: with the right front-end you can observe Wi-Fi, Bluetooth, Zigbee, car-key fobs, pagers, aircraft transponders, and far more, all with one device and software. That same power is exactly why it is legally sensitive — transmitting on almost any band without authorisation is illegal, and even receiving some bands is restricted in some countries. Knowing where the line is keeps a curious learner on the right side of it, and tells you honestly when SDR work is in scope for an engagement and when it is not.

## Learning objectives

- Explain what **SDR** is and what it unlocks for a security practitioner.
- Distinguish **receive-only** from **transmit-capable** hardware and why that matters legally.
- State the **legal limits** on receiving and transmitting, and decide when SDR is in or out of scope.

## Prerequisites

- [01.1 · Radio basics for hackers — spectrum, power, and antennas](../module-01/lesson-01.md) — spectrum, frequency, and power framing you need to reason about what SDR can see.

## Concept

### What SDR is and what it unlocks

In a traditional radio, the demodulation of a specific protocol is fixed in hardware. In SDR, the
hardware just shifts a chunk of spectrum down and digitises it; **software** does the demodulation. One
device can therefore receive many protocols — you change the software, not the radio. For a security
practitioner this unlocks **spectrum awareness** (what is transmitting around a site), protocol
analysis of non-Wi-Fi radios, and research into devices that have no other tooling. Much of the value
is purely **receive-side**: you learn an enormous amount just by listening and decoding.

### Receive-only vs transmit-capable — the distinction that matters

SDR hardware splits into two legally very different classes:

- **Receive-only** (e.g. the **RTL-SDR**, roughly 24 MHz–1.7 GHz): cannot transmit at all. It can only
  listen. This is the safe, cheap entry point and covers most learning.
- **Transmit-capable** (e.g. **HackRF One**, ~1 MHz–6 GHz TX/RX; bladeRF, LimeSDR): can both receive
  and transmit. Transmitting is where the serious legal exposure lives — these devices are explicitly
  **not** certified for compliant transmission, and radiating on a band you are not licensed for is an
  offence in essentially every jurisdiction.

Choosing receive-only hardware is itself a safety control: you cannot accidentally (or be tempted to)
transmit on a band you shouldn't.

### The legal limits — the heart of this lesson

- **Transmitting** on almost any frequency without a licence or specific authorisation is illegal and
  often strictly enforced (interference with licensed services, aviation, cellular, and emergency bands
  is treated very seriously). Test-transmitting "just to see" is exactly the kind of thing this course
  tells you not to do.
- **Receiving** is more permissive but **not** unlimited: some jurisdictions restrict or prohibit
  intercepting certain communications (e.g. cellular, cordless, pager traffic), even passively. "I was
  only listening" is not a universal defence.
- **It varies by country.** TX power, bands, licensing, and interception law differ widely — the same
  rule as the rest of the course: check your jurisdiction, and when in doubt, don't transmit.

> [!CAUTION]
> Transmitting with an SDR is the single most legally dangerous thing in this course. Treat
> transmit-capable hardware as transmit-**disabled** unless you have specific authorisation and licence
> for the exact band and power — and prefer receive-only hardware while learning. Owned devices and
> lawful bands only; see [00.3 · Safety, containment, and the law](../module-00/lesson-03.md).

## Hands-on

By design there is **no SDR attack lab** in this course. If you want to go further safely, the lawful,
owned-equipment starting point is **receive-only**: an RTL-SDR plus free software (e.g. a waterfall
viewer) to observe public, legal-to-receive signals in your area — never to intercept restricted
communications and never to transmit. That exploration belongs in a dedicated SDR resource, not here.

## Exercise

A colleague buys a HackRF "to test their car's key fob" by replaying its signal in the driveway. List
what is wrong with this plan legally and in scope terms, and describe a lawful, owned-equipment way to
satisfy the same curiosity.

<details>
<summary>Hint</summary>

Replaying a fob signal is transmitting on a regulated band with uncertified hardware, and a car key is
a security-relevant transmitter — think about licensing, interference, and whether "my own car" makes
transmitting lawful. Then think about what you can learn purely by receiving.
</details>

<details>
<summary>Reference answer</summary>

Replaying the fob **transmits** on a regulated band with hardware not certified for compliant
transmission, which is unlawful in essentially every jurisdiction regardless of owning the car — owning
the target does not grant a transmit licence, and the band may be shared with other users. It is also
out of scope for this course, which forbids transmit-heavy, legally-sensitive work. A lawful,
owned-equipment alternative is to **receive only**: use an RTL-SDR to *observe* the fob's transmission
(frequency, timing, that a burst occurs) to understand how it behaves, without ever transmitting — and
to take any actual key-fob/relay research into a dedicated, properly-authorised SDR context with the
correct licensing. The learning (how the signal looks) is available on the receive side; the illegal
part (transmitting) adds nothing you're allowed to do here.
</details>

## References

- [RTL-SDR — about](https://www.rtl-sdr.com/about-rtl-sdr/) — the receive-only entry point and its range.
- [HackRF One documentation](https://hackrf.readthedocs.io/en/latest/) — a transmit-capable device and its compliance caveats.
- [00.3 · Safety, containment, and the law](../module-00/lesson-03.md) — the transmit/interception/legal framing that governs SDR.

## What you should now be able to do

- Explain what SDR is and what it unlocks, most of it on the receive side.
- Distinguish receive-only from transmit-capable hardware and why that distinction is legal, not just technical.
- State the legal limits on receiving and transmitting and decide when SDR work is in or out of scope.
