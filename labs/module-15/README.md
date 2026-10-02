# Module 15 labs — adjacent wireless (awareness)

This elective module is **awareness-only** and has **no attack labs** by design. Its "hands-on" is
limited to safe, receive/observe activities on devices you own — never intercepting restricted
communications and never transmitting.

> [!CAUTION]
> The adjacent radios here (BLE, Zigbee/Thread, RFID/NFC, SDR) carry their own legal limits.
> Transmitting with an SDR is the most legally dangerous activity in the whole course. Owned devices
> and lawful bands only; prefer receive-only hardware; check your jurisdiction. See
> [00.3 · Safety, containment, and the law](../../lessons/module-00/lesson-03.md).

## What (safely) to do, if anything

- **BLE:** scan your **own** BLE devices with a phone app to see advertisements/GATT services — observe
  only. Deep BLE testing belongs in a dedicated resource.
- **Zigbee/Thread, RFID/NFC:** recognise and inventory them at a site; understand the concerns at a high
  level. No cloning/replay labs here.
- **SDR:** if you go further, start **receive-only** (e.g. RTL-SDR) on signals you may lawfully receive.
  No transmitting.

## No shipped captures or tools

This module ships no captures and no attack tooling. It points to reputable, owned-equipment resources
for each technology so a learner can continue safely and lawfully outside this course.
