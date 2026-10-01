---
id: "03.5"
module: 3
minutes: 22
practice_minutes: 35
prerequisites: ["03.4"]
objectives:
  - Run a Linux lab VM on a Windows 11 host and pass a USB Wi-Fi adapter through to it.
  - Configure USB passthrough on VirtualBox, and know the VMware and Hyper-V caveats.
  - Diagnose common passthrough failures and fall back to the virtual path when passthrough fights you.
volatility: implementation
sources:
  - title: "Oracle VirtualBox manual — USB support and the Extension Pack"
    url: https://www.virtualbox.org/manual/ch03.html
  - title: "VMware Workstation documentation — USB devices in a virtual machine"
    url: https://docs.vmware.com/en/VMware-Workstation-Pro/index.html
  - title: "Linux mac80211_hwsim — the no-passthrough virtual path fallback"
    url: https://www.kernel.org/doc/html/latest/networking/mac80211_hwsim/mac80211_hwsim.html
last_verified: "2026-10-01"
---

# 03.5 · Windows-hosted VMs and USB passthrough

Tal's environment is Windows 11, so the realistic physical-path setup is a Linux lab VM with a USB Wi-Fi adapter handed through to it — and USB passthrough of a wireless adapter is one of the most reliably frustrating steps in the whole course. This lesson sets up passthrough on VirtualBox (with the Extension Pack), names the VMware and Hyper-V caveats, and walks the failure modes that actually bite — the adapter the host won't release, the reset on mode change, the USB 2 versus 3 controller mismatch — and it is blunt about the escape hatch: when passthrough keeps fighting you, the virtual path needs no passthrough at all.

> [!WARNING]
> Once the adapter reaches the Linux VM, everything from [03.4](lesson-04.md) applies: monitor mode and
> injection transmit real radio. Owned equipment only, allowlist, minimum TX power, stop conditions,
> cleanup ([00.3](../module-00/lesson-03.md)). This lesson only gets the adapter into the VM; it does
> not change what you are allowed to do with it.

## Why this matters

You can do everything in [03.4](lesson-04.md) perfectly and still be stuck, because the adapter never shows up inside Linux — the Windows host claimed it, the hypervisor needs an add-on you didn't install, or the device resets the instant you switch it to monitor mode. These are not exotic problems; they are the default experience, and learners abandon the physical path over them when a ten-minute fix (or a switch to the virtual path) was available. Knowing the passthrough mechanics and the top failure modes turns a dead end into a checklist. It also reinforces the course's core message: the physical path is optional, and `mac80211_hwsim` is always there when the hardware route isn't worth the fight.

## Learning objectives

- Run a **Linux lab VM on Windows 11** and pass a **USB Wi-Fi adapter** through to it.
- Set up passthrough on **VirtualBox** (Extension Pack) and state the **VMware** and **Hyper-V** caveats.
- **Diagnose** the common failures and **fall back to the virtual path** when passthrough is not worth it.

## Prerequisites

- [03.4 · The physical rig — adapter, driver, monitor, injection, and AP mode](lesson-04.md) — you have a verified adapter and know the capabilities you are trying to reach.

## Concept

### The shape of the problem

A USB device can be owned by the **host OS** or by the **guest VM**, but not both at once. On Windows, the adapter appears to the host first; passthrough tells the hypervisor to detach it from Windows and attach it to the Linux guest, where its driver (from [03.4](lesson-04.md)) then claims it. Two things must be true: the hypervisor must be *able* to pass USB devices (VirtualBox needs an add-on for USB 2.0/3.0), and the host must *release* the device so the guest can take it. Most failures are one of those two not happening.

### VirtualBox (the primary documented path)

VirtualBox's base package only does USB 1.1. **USB 2.0/3.0 passthrough requires the Oracle VirtualBox Extension Pack** — install the version that exactly matches your VirtualBox version. Then:

1. Install the Extension Pack (File → Tools → Extension Pack Manager). On a Linux *host* your user must be in the `vboxusers` group; on a Windows host this is not needed.
2. With the VM powered off: **Settings → USB**, choose the controller — **USB 3.0 (xHCI)** for a USB 3 adapter, **USB 2.0 (EHCI)** otherwise — and add a **USB device filter** for your adapter (by its vendor:product ID from `lsusb`/Device Manager) so it attaches automatically.
3. Start the VM; when the adapter is attached to the guest it disappears from Windows and appears in `lsusb` inside Linux, where its driver loads.

> [!CAUTION]
> A controller mismatch is a classic trap: a USB 3 adapter on a VM configured for a USB 2.0 controller
> (or vice versa) may enumerate oddly, drop, or fail to inject. Match the controller to the adapter, and
> if a dual-mode stick misbehaves, try the other controller setting.

### VMware and Hyper-V caveats

- **VMware Workstation** generally handles USB Wi-Fi passthrough well: set the USB controller to the right version in VM settings and connect the device to the guest from the VM's **Removable Devices** menu. It tends to be the smoother commercial option; still match USB 2/3.
- **Hyper-V** is the awkward one: it has **no general raw USB-device passthrough** for arbitrary devices like a Wi-Fi adapter (its device redirection targets a narrower set). For this course, **do not plan on Hyper-V for the physical path** — use VirtualBox or VMware, or use WSL2 only for non-RF work. Note that enabling Hyper-V/WSL2 can also change how VirtualBox/VMware run, so pick one virtualization stack deliberately.

### The escape hatch: the virtual path needs no passthrough

`mac80211_hwsim` creates its radios *inside* the Linux VM, so it needs **no USB passthrough, no Extension Pack, and no adapter at all** ([03.3](lesson-03.md)). If passthrough keeps resetting, enumerating wrong, or refusing to release from Windows, and the exercise is really about the *protocol* rather than real RF, switch to V and keep moving. Reserve the passthrough fight for exercises whose whole point is real monitor/injection — the ones that actually need [03.4](lesson-04.md)'s hardware.

## Hands-on

Path **P** (the adapter is real and will transmit once in monitor mode) — but the setup step itself is about plumbing the device into the VM. If passthrough fails, the documented fallback is path **V**.

### Guided walkthrough — pass an adapter through on VirtualBox

1. On the Windows host, install the Extension Pack matching your VirtualBox version; note the adapter's vendor:product ID (Device Manager, or `lsusb` once in Linux).
2. VM powered off → **Settings → USB** → enable the controller matching the adapter (USB 3.0 for a USB 3 stick) → add a filter for the adapter.
3. Start the Linux VM and confirm the handover:

   ```bash
   lsusb                 # the adapter's vendor:product ID should now appear inside Linux
   sudo dmesg | tail -40 # the driver (ath9k_htc / mt76 / 88XXAU) should claim it
   iw dev                # a new wlanN interface should exist
   ```

4. Proceed with the [03.4](lesson-04.md) checks (regulatory domain, monitor mode, `aireplay-ng -9` injection test) against your own gear.
5. If any step fails, work the troubleshooting list below; if it still fights you, switch the exercise to the virtual path ([03.3](lesson-03.md)).

### Lab — get a USB adapter into the Linux VM (or fall back)

> [!NOTE]
> **Lab paths:** P (real adapter passed through to a Linux VM on a Windows 11 host — proves you can plumb real hardware into the lab so monitor/injection become possible; the RF capabilities themselves are verified in [03.4](lesson-04.md)). **Fallback: V** (`mac80211_hwsim` inside the same VM needs no passthrough) when passthrough is not worth the fight.
> **Start state:** Windows 11 host; a Linux lab VM (VirtualBox with a matching Extension Pack, or VMware); a verified USB adapter from [03.4](lesson-04.md).
> **Duration:** ~35 min.
> **Artifacts:** `lsusb` inside Linux showing the adapter; a `dmesg` line showing the driver claiming it; a new `wlanN` in `iw dev` — or, on fallback, the `hwsim` interfaces from [03.3](lesson-03.md) with a note that passthrough was abandoned and why.
> **Troubleshooting:** adapter not listed in the VM → Extension Pack missing/mismatched, or no USB filter added; adapter present on host but not guest → Windows still holds it (add the filter, replug, or detach it from the host); device drops/resets when you switch to monitor mode → known passthrough symptom, try the other USB controller version, a powered USB hub, or a different port, else fall back to V; works on USB 2 but not USB 3 (or vice versa) → controller mismatch, change the VM's USB controller to match the adapter; nothing works under Hyper-V → Hyper-V has no general USB passthrough, use VirtualBox/VMware or the virtual path.
> **Cleanup:** detach the adapter from the guest (or stop the VM) to return it to Windows; inside Linux, `reset-lab.sh` restores the interface to managed mode if you entered monitor mode.

## Exercise

A learner on Windows 11 reports: "My adapter works fine in Windows and the VM boots, but `iw dev` in Linux shows no wireless interface, and when I did briefly get it working it reset the moment I switched to monitor mode." Lay out an ordered diagnosis for both symptoms, and state the condition under which you would stop troubleshooting and switch paths.

<details>
<summary>Hint</summary>

The two symptoms have different causes: "no interface at all" is about the *handover* (can the hypervisor pass USB, and did Windows release it?), while "resets on mode change" is about the *USB link* (controller version, power). What add-on and what setting govern each, and what is always available if the exercise only needs the protocol?
</details>

<details>
<summary>Reference answer</summary>

**No interface in Linux (handover):** confirm the VirtualBox **Extension Pack** is installed and matches the VirtualBox version (base package is USB 1.1 only); check a **USB device filter** for the adapter exists so it attaches to the guest; verify Windows actually **released** it (it should vanish from the host when attached to the guest); then check `lsusb` and `dmesg` in Linux to see whether the device appears and whether a driver claimed it. **Resets on mode change (USB link):** this is a classic passthrough symptom — try the **other USB controller version** (match USB 3.0/2.0 to the adapter), a **powered hub** or different port for stable power, and confirm the driver is the expected one. **When to stop:** if the exercise is really about the *protocol* rather than real RF, stop as soon as passthrough costs more than it's worth and switch to the **virtual path** (`mac80211_hwsim`), which needs no passthrough, no Extension Pack, and no adapter. Only keep fighting when the exercise specifically requires real monitor/injection.
</details>

## References

- [Oracle VirtualBox manual — USB support](https://www.virtualbox.org/manual/ch03.html) — the Extension Pack and USB controller settings.
- [VMware Workstation documentation](https://docs.vmware.com/en/VMware-Workstation-Pro/index.html) — connecting USB devices to a guest.
- [Linux `mac80211_hwsim`](https://www.kernel.org/doc/html/latest/networking/mac80211_hwsim/mac80211_hwsim.html) — the no-passthrough fallback.
- [03.3 · Virtual labs with mac80211_hwsim](lesson-03.md) and [03.4 · The physical rig](lesson-04.md).
- [`../../curriculum/lab-matrix.md`](../../curriculum/lab-matrix.md) — Windows-host VM / USB-passthrough notes.

## What you should now be able to do

- Run a Linux lab VM on Windows 11 and pass a USB Wi-Fi adapter through to it on VirtualBox or VMware.
- State why Hyper-V is unsuitable for raw USB Wi-Fi passthrough and match the USB controller to the adapter.
- Diagnose the common passthrough failures and fall back to the virtual path when passthrough is not worth it.
