---
id: "03.3"
module: 3
minutes: 20
practice_minutes: 40
prerequisites: ["03.1"]
objectives:
  - Load mac80211_hwsim and list the simulated radios it creates with no wireless hardware.
  - Stand up an AP with hostapd and a client with wpa_supplicant, and watch the client join.
  - State plainly what the virtual path does not reproduce — real RF, drivers, range, interference, injection.
volatility: implementation
sources:
  - title: "Linux mac80211_hwsim simulated-radio documentation"
    url: https://www.kernel.org/doc/html/latest/networking/mac80211_hwsim/mac80211_hwsim.html
  - title: "hostapd documentation (configuration)"
    url: https://w1.fi/hostapd/
  - title: "wpa_supplicant documentation (configuration)"
    url: https://w1.fi/wpa_supplicant/
last_verified: "2026-10-01"
---

# 03.3 · Virtual labs with mac80211_hwsim — simulated radios, hostapd, and wpa_supplicant

The virtual path gives you real 802.11 protocol behaviour with no radio, no transmission, and no purchase: a kernel module conjures simulated Wi-Fi interfaces, you run a genuine AP on one and a genuine client on another, and you watch an actual association happen inside your VM. This lesson loads `mac80211_hwsim` with the course helper, brings up an AP with `hostapd`, joins it with `wpa_supplicant`, and confirms the link — and it is equally clear about what this does *not* give you, because a simulated radio is not an antenna.

> [!NOTE]
> Everything here runs inside a Linux VM and transmits nothing over the air. The virtual path is the
> containment-friendly default for protocol and configuration work ([00.3](../module-00/lesson-03.md)).
> Tool and kernel versions move; record what you actually run (see [`../../TOOLS.md`](../../TOOLS.md)).

## Why this matters

Most of wireless attacking and defending is really about the *protocol*: how an AP advertises itself, how a client associates, how a handshake derives keys, how an enterprise supplicant decides whether to trust a server. All of that is reproducible without a single photon leaving your machine, which means you can practise it safely, repeatably, and for free — and you can break it and reset in seconds. `mac80211_hwsim` is the backbone of the virtual path used throughout the course: the same `hostapd`/`wpa_supplicant` skills you build here reappear in WPA2, WPA3, rogue-AP, and enterprise modules. Knowing exactly where the simulation ends — real RF, drivers, range, interference, injection — keeps you from over-claiming what a virtual lab proved.

## Learning objectives

- Load `mac80211_hwsim` with [`../../labs/common/hwsim-up.sh`](../../labs/common/) and list the simulated radios.
- Configure and run **`hostapd`** as an AP and **`wpa_supplicant`** as a client, and observe the join.
- State precisely what the virtual path **does not reproduce**, and why that limits the credit it earns.

## Prerequisites

- [03.1 · Choosing your path — recorded, virtual, or physical](lesson-01.md) — you have identified which exercises you will run virtually.

## Concept

### What mac80211_hwsim actually is

`mac80211_hwsim` is a mainline Linux kernel module that creates fully simulated 802.11 radios attached to the kernel's `mac80211` stack. To user space they look like ordinary `wlanN` interfaces: `iw` lists them, `hostapd` can run an AP on one, `wpa_supplicant` can associate another to it, and frames pass between them *through the kernel*, not over the air. Because the radios are software, you can create several at once (`radios=N`) and give each a role — AP, client, monitor — which is exactly what the course's capture-generation and join labs rely on.

Crucially, the protocol stack above the radio is **the same code a real adapter uses**. So the beacon, the open-system authentication, the association, and the 4-way handshake you observe are genuine 802.11 exchanges — not a mock-up. That is why the virtual path legitimately proves you understand the protocol flow and can configure the daemons.

### What it does not reproduce

This is the honest boundary you must state on every virtual lab:

- **Real RF** — no modulation, no signal strength, no multipath. Radiotap RSSI values are synthetic.
- **Real drivers** — you never touch `ath9k_htc`, `mt76`, or a Realtek DKMS driver, so none of their quirks appear.
- **Range and interference** — there is no distance, no neighbouring network, no channel congestion.
- **Regulatory behaviour** — no real DFS radar events, no TX-power enforcement against the air.
- **Hardware monitor/injection quirks** — a simulated monitor interface behaves ideally; whether *your* adapter can inject a frame is a question only the physical path answers.

So a virtual lab can prove "I can configure an AP and a client and watch them associate" but never "my hardware captures handshakes off the air." Per [`../../curriculum/assessment-rubrics.md`](../../curriculum/assessment-rubrics.md), **V is not credited as P**.

### The join you will watch

The sequence is the same one from [01.4](../module-01/lesson-04.md): the client discovers the AP (beacon/probe), does open-system authentication (the formality), associates, and — on a secured BSS — runs the 4-way handshake. On `hwsim` you see every step in the `hostapd` and `wpa_supplicant` debug logs and confirm the result with `iw dev <iface> link`.

## Hands-on

Path **V** only. You load the simulated radios, run an AP and a client, and watch a real association. Nothing transmits.

### Guided walkthrough — stand up an AP and a client

1. Bring up the simulated radios (two is enough for an AP + client):

   ```bash
   sudo ./labs/common/hwsim-up.sh 2      # loads mac80211_hwsim -> wlan0, wlan1
   iw dev | awk '/Interface/{print $2}'  # confirm two interfaces
   ```

2. Write a minimal WPA2 AP config and start `hostapd` on `wlan0`:

   ```bash
   cat > /tmp/lab-ap.conf <<'EOF'
   interface=wlan0
   driver=nl80211
   ssid=LAB-JOIN
   hw_mode=g
   channel=1
   wpa=2
   wpa_key_mgmt=WPA-PSK
   rsn_pairwise=CCMP
   wpa_passphrase=Lab-WiFi-Passw0rd!
   EOF
   sudo hostapd -dd /tmp/lab-ap.conf
   ```

3. In a second terminal, write a client config and join on `wlan1`:

   ```bash
   cat > /tmp/lab-client.conf <<'EOF'
   network={
     ssid="LAB-JOIN"
     key_mgmt=WPA-PSK
     psk="Lab-WiFi-Passw0rd!"
   }
   EOF
   sudo wpa_supplicant -i wlan1 -c /tmp/lab-client.conf -d
   ```

4. Watch the logs: authentication → association → the 4-way handshake (EAPOL M1–M4) → `CTRL-EVENT-CONNECTED`. Confirm the link:

   ```bash
   iw dev wlan1 link          # expect "Connected to <BSSID>"
   ```

5. Tear it all down:

   ```bash
   sudo ./labs/common/hwsim-down.sh     # removes the simulated radios
   # or the catch-all: sudo ./labs/common/reset-lab.sh
   ```

### Lab — watch a real join on simulated radios

> [!NOTE]
> **Lab paths:** V (`mac80211_hwsim` + `hostapd` + `wpa_supplicant` in a Linux VM — proves you can configure an AP and a client and reproduce the discovery/auth/association/handshake flow end to end; does **not** reproduce real RF, drivers, range, interference, regulatory behaviour, or hardware monitor/injection quirks).
> **Start state:** a Linux VM with `mac80211_hwsim` available and `hostapd`, `wpa_supplicant`, `iw` installed (see [`../../TOOLS.md`](../../TOOLS.md)); no wireless hardware; nothing transmitted over the air.
> **Duration:** ~40 min.
> **Artifacts:** the `hostapd` log showing a station authenticating and associating; the `wpa_supplicant` log showing the EAPOL handshake and `CTRL-EVENT-CONNECTED`; the `iw dev wlan1 link` line naming the simulated BSSID.
> **Troubleshooting:** module not loaded → `sudo modprobe mac80211_hwsim radios=2` (or re-run `hwsim-up.sh`); interface names differ → list with `iw dev`; `hostapd` exits immediately → check the conf path and that the radio is free (`sudo ./labs/common/reset-lab.sh` first); client never connects → confirm the SSID, PSK, and channel match and that both interfaces belong to `hwsim`; `nl80211: could not configure driver mode` → another process holds the interface (`sudo airmon-ng check kill` or reset).
> **Cleanup:** stop `hostapd`/`wpa_supplicant`, run `hwsim-down.sh`. Nothing was transmitted, so there is no RF cleanup.

> [!NOTE]
> **LAB TARGET vs REAL NETWORK:** the `LAB-JOIN` BSS exists only inside the kernel's simulated radios —
> it has no antenna and radiates nothing. The SSID and passphrase are synthetic. This is the
> containment-friendly way to study joins and handshakes ([00.3](../module-00/lesson-03.md)).

## Exercise

After completing the virtual join, a learner writes: "I associated a client to my AP over Wi-Fi and captured the handshake, so my setup can capture handshakes off the air." Identify every claim in that sentence that the virtual path does *not* support, and rewrite it as an accurate statement of what they proved.

<details>
<summary>Hint</summary>

Separate "the client associated and I saw the handshake" (true on `hwsim`) from "over Wi-Fi / off the air / my setup can capture" (claims about real RF and hardware). Which of those does a simulated radio actually exercise, and which does only the physical path?
</details>

<details>
<summary>Reference answer</summary>

The unsupported claims are "**over Wi-Fi**," "**off the air**," and "**my setup can capture handshakes**" — all three assert real RF and real hardware behaviour. On `mac80211_hwsim` no radio transmits; the frames pass through the kernel, the radiotap signal values are synthetic, and no driver's monitor/injection behaviour was tested. What the learner *did* prove is genuine and worth stating: "I configured an AP with `hostapd` and a client with `wpa_supplicant`, and observed the full discovery → authentication → association → 4-way-handshake flow on simulated radios." That earns **virtual-path** credit for understanding the protocol and the configuration — not physical-capture credit, which only a real adapter pulling a handshake from the air would earn.
</details>

## References

- [Linux `mac80211_hwsim`](https://www.kernel.org/doc/html/latest/networking/mac80211_hwsim/mac80211_hwsim.html) — the simulated radios.
- [hostapd](https://w1.fi/hostapd/) and [wpa_supplicant](https://w1.fi/wpa_supplicant/) — AP and client configuration.
- [01.4 · Joining a network](../module-01/lesson-04.md) — the join sequence you reproduce here.
- [`../../curriculum/assessment-rubrics.md`](../../curriculum/assessment-rubrics.md) — why V is not credited as P.
- [`../../labs/common/`](../../labs/common/) — `hwsim-up.sh`, `hwsim-down.sh`, `reset-lab.sh`.

## What you should now be able to do

- Load `mac80211_hwsim` and list the simulated radios it creates with no hardware.
- Run `hostapd` as an AP and `wpa_supplicant` as a client, and observe a real join end to end.
- State exactly what the virtual path does not reproduce, and why it earns virtual — not physical — credit.
