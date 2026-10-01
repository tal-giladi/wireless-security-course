---
id: "03.4"
module: 3
minutes: 24
practice_minutes: 40
prerequisites: ["03.1"]
objectives:
  - Separate monitor mode, frame injection, and AP mode as three distinct adapter capabilities.
  - Apply the chipset-first buying rule and verify the exact model and hardware revision before trusting support.
  - Set the regulatory domain, enable monitor mode, and test injection with aireplay-ng, marking unverified hardware.
volatility: implementation
sources:
  - title: "Aircrack-ng — injection test (aireplay-ng -9 / --test)"
    url: https://www.aircrack-ng.org/doku.php?id=injection_test
  - title: "Linux wireless — iw and cfg80211/mac80211 drivers"
    url: https://wireless.wiki.kernel.org/en/users/documentation/iw
  - title: "morrownr/USB-WiFi — maintained adapter and chipset reference"
    url: https://github.com/morrownr/USB-WiFi
  - title: "Linux wireless-regdb and regulatory domain (iw reg)"
    url: https://wireless.wiki.kernel.org/en/developers/regulatory
last_verified: "2026-10-01"
---

# 03.4 · The physical rig — adapter, driver, monitor, injection, and AP mode

The physical path is the only one that proves real radio, and it lives or dies on one fact most buyers get wrong: monitor mode, frame injection, and AP mode are three *separate* capabilities, and an adapter can have one without the others. This lesson teaches the chipset-first buying rule, the exact model-plus-revision verification that stops you buying a dud, and how to bring a verified adapter up — set the regulatory domain, switch it to monitor mode, and prove injection works with `aireplay-ng` — while marking anything you have not personally verified as VERIFY.

> [!WARNING]
> Switching an adapter to monitor mode and injecting frames affects **real radio in range**, not just
> your wire. Do this only against equipment **you own**, on your allowlist, at minimum TX power, on a
> chosen channel, with stop conditions and cleanup ([00.3](../module-00/lesson-03.md)). A private subnet
> does **not** contain radio. Prefer the virtual path for anything that does not strictly need real RF.

## Why this matters

Learners routinely buy an adapter because a blog said its "chipset supports monitor mode," plug it in, and discover it cannot inject — or that the exact unit they received is a different silicon revision from the one the blog tested. The three-capability distinction is what separates a working rig from a drawer of returns. It also matters in the field: a client asks "can you prove the handshake capture is real?" and the answer rests on an adapter whose monitor *and* injection you verified, in a regulatory domain you set correctly. This lesson is implementation-heavy and will date; the chipset-first rule and the verify-before-you-trust habit will not.

## Learning objectives

- Treat **monitor**, **injection**, and **AP mode** as three distinct capabilities, not one "supports monitor" flag.
- Apply the **chipset-first buying rule** and verify the exact **model + hardware revision** before relying on it.
- Set the **regulatory domain** with `iw reg`, enable **monitor mode**, and **test injection** with `aireplay-ng`.

## Prerequisites

- [03.1 · Choosing your path — recorded, virtual, or physical](lesson-01.md) — you have decided an exercise genuinely needs real RF.

## Concept

### Three capabilities, not one

These are separate and must be verified separately (this is why [`../../curriculum/lab-matrix.md`](../../curriculum/lab-matrix.md) has a column for each):

- **Monitor mode** — the interface captures *all* 802.11 frames on a channel, including other networks' management and control frames, rather than only traffic for an associated client. This is *reception*.
- **Frame injection** — the adapter can *transmit* crafted frames (e.g. a deauth, or `aireplay-ng`'s test frames). Injection is what deauth and some capture-acceleration techniques need, and it is a stricter requirement than monitor.
- **AP mode** — the adapter can *be* an access point under `hostapd` (needed for rogue-AP and some enterprise labs). A chip may do monitor and injection yet make a poor or unsupported AP, or vice versa.

An adapter can support any subset. "It does monitor mode" tells you nothing about injection or AP mode — check each.

### Buy by chipset, then verify the revision

The marketing name on the box is not the silicon inside, and vendors silently change silicon between hardware revisions of the *same model name*. So the rule is **chipset-first**: pick a chipset with known Linux monitor/injection support, then confirm the exact unit you are buying is that chipset at that revision before paying. Known-good chipsets this course leans on ([`../../curriculum/lab-matrix.md`](../../curriculum/lab-matrix.md); a maintained community list is [morrownr/USB-WiFi](https://github.com/morrownr/USB-WiFi)):

| Chipset | Driver | Bands | Notes |
|---|---|---|---|
| **AR9271** | `ath9k_htc` (in mainline kernel) | 2.4 only | long-stable, monitor+injection out of the box; no 5/6 GHz |
| **MT7612U** | `mt76` (mainline) | 2.4/5 | good dual-band mainline support; the course default recommendation |
| **MT7921U** | `mt7921u`/`mt76` (mainline since ~kernel 5.12) | 2.4/5 | newer Wi-Fi 6 dual-band; verify monitor behaviour on your kernel |
| **RTL8812AU** | out-of-tree DKMS (`aircrack-ng/rtl8812au`) | 2.4/5 | capable but DKMS is **fragile across kernels** — pin a known-good kernel |

> [!CAUTION]
> **The TL-WN722N trap.** Only the **v1** is AR9271 (monitor + injection out of the box). The **v2/v3**
> are Realtek **RTL8188EUS** — a different chip that needs an out-of-tree driver and is commonly not
> monitor-capable as shipped. The model name on the box is *identical*; only the tiny "Ver: 2.0" marking
> differs. The same bait applies to many cheap "AC600/AC1300" sticks. **Confirm chipset + hardware
> revision before buying**, not after.

### Mark what you have not verified

A chipset's reputation is not proof *your* unit and *your* kernel work. Until you have personally run the checks below, every capability cell is **VERIFY**, exactly as [`../../curriculum/lab-matrix.md`](../../curriculum/lab-matrix.md) marks them. Record "monitor: verified on kernel X with adapter Y (rev Z) on <date>" only for what you actually tested; never carry a blog's claim into your own evidence.

## Hands-on

Path **P** only — real hardware, owned equipment. You bring up a verified adapter, set the regulatory domain, enable monitor mode, and test injection. Anything you have not confirmed stays VERIFY.

### Guided walkthrough — identify, set region, monitor, test injection

> [!WARNING]
> The injection test transmits real frames. Do it only in a controlled setting against your own gear,
> at minimum TX power, on a channel you own ([00.3](../module-00/lesson-03.md)).

1. Identify the chipset and confirm the revision matches what you intended to buy:

   ```bash
   lsusb                      # read the USB vendor:product ID
   sudo dmesg | tail -40      # see which driver claimed it (ath9k_htc / mt76 / 88XXAU …)
   iw dev                     # the interface name, e.g. wlan1
   ```

2. Set your **regulatory domain** to your country (it governs legal channels and TX power):

   ```bash
   iw reg get                 # current domain
   sudo iw reg set IL         # example: Israel — use YOUR country code
   ```

3. Check and claim the interface, then enable **monitor mode**:

   ```bash
   sudo airmon-ng check kill  # stop NetworkManager/wpa_supplicant that would fight you
   sudo ip link set wlan1 down
   sudo iw dev wlan1 set type monitor
   sudo ip link set wlan1 up
   iw dev wlan1 info          # confirm "type monitor"
   sudo iw dev wlan1 set channel 1
   ```

4. Test **injection** (a separate capability from monitor):

   ```bash
   sudo aireplay-ng -9 wlan1        # -9 is --test; look for "Injection is working!"
   ```

5. Record results honestly in your lab matrix notes: monitor = verified/VERIFY, injection = verified/VERIFY, with adapter model, **revision**, driver, and kernel. Restore the interface when done:

   ```bash
   sudo ./labs/common/reset-lab.sh   # interface -> managed, services restored
   ```

### Lab — bring up and verify a physical adapter

> [!NOTE]
> **Lab paths:** P (owned adapter + owned AP/client — proves real monitor mode, real injection, and the regulatory/driver reality of your hardware; this is the only path that earns physical credit). R and V cannot substitute: they do not touch a driver or transmit a frame.
> **Start state:** a Linux host/VM with the adapter attached and its driver loaded (USB passthrough covered in [03.5](lesson-05.md)); your regulatory domain known; an owned AP on your allowlist.
> **Duration:** ~40 min.
> **Artifacts:** `iw dev wlan1 info` showing `type monitor`; the `aireplay-ng -9` output stating whether injection works; a lab-matrix notes row recording monitor/injection as verified or VERIFY with model + revision + driver + kernel.
> **Troubleshooting:** interface won't enter monitor → `sudo airmon-ng check kill` (NetworkManager holds it), then retry; `iw` says "command failed: Device or resource busy" → the interface is up, bring it down first; no interface appears after plug-in → wrong/unclaimed driver (check `dmesg`), a RTL8812AU DKMS may not match your kernel (pin a known-good kernel); injection "test" sends but gets no ACKs → normal if no AP is in range/on-channel, re-test near your own AP on the same channel; adapter resets on mode change → a known USB-passthrough symptom ([03.5](lesson-05.md)) or an underpowered USB port.
> **Cleanup:** `reset-lab.sh` returns the interface to managed mode and restores services; if you changed the regulatory domain, reset it with `sudo iw reg set <COUNTRY>`.

## Exercise

A learner buys an adapter whose box says "TL-WN722N" because a tutorial praised it, plugs it in, and finds it will not enter monitor mode. Walk through how to diagnose what went wrong, how they *should* have verified before buying, and whether "the chipset supports monitor mode" would have been enough to guarantee injection even on the right unit.

<details>
<summary>Hint</summary>

Which hardware revision has which chipset, and how would `lsusb`/`dmesg` reveal the one they actually received? Then recall that monitor and injection are *separate* — does confirming the chipset settle the injection question?
</details>

<details>
<summary>Reference answer</summary>

**Diagnose:** run `lsusb` and `sudo dmesg` to read the real chipset and driver. They almost certainly received a **v2/v3**, which is a Realtek **RTL8188EUS**, not the **v1**'s Atheros **AR9271** — the box name is identical, only the "Ver: 2.0" marking differs, and the v2/v3 needs an out-of-tree driver and is commonly not monitor-capable as shipped. **Should have:** applied the chipset-first rule — decide on AR9271 (or MT7612U), then confirm the specific unit's chipset *and hardware revision* before paying, rather than trusting the model name. **Was the chipset enough for injection?** No. Even on the right AR9271 unit, "supports monitor mode" is only the reception capability; **injection is a separate capability** that must be verified independently with `aireplay-ng -9`. Until they run that test on their own hardware and kernel, injection stays **VERIFY**.
</details>

## References

- [Aircrack-ng — injection test](https://www.aircrack-ng.org/doku.php?id=injection_test) — `aireplay-ng -9`.
- [Linux wireless — `iw`](https://wireless.wiki.kernel.org/en/users/documentation/iw) and [regulatory domain](https://wireless.wiki.kernel.org/en/developers/regulatory).
- [morrownr/USB-WiFi](https://github.com/morrownr/USB-WiFi) — maintained adapter/chipset reference.
- [`../../curriculum/lab-matrix.md`](../../curriculum/lab-matrix.md) — adapters with separate monitor/injection/AP-mode columns and the TL-WN722N caution.
- [03.5 · Windows-hosted VMs and USB passthrough](lesson-05.md) — getting the adapter into the VM.

## What you should now be able to do

- Separate monitor, injection, and AP mode, and verify each independently rather than assuming one implies the others.
- Buy by chipset and confirm the exact model + hardware revision, avoiding the TL-WN722N-style revision trap.
- Set the regulatory domain, enable monitor mode, test injection, and record what is verified versus VERIFY.
