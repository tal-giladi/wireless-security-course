---
id: "00.2"
module: 0
minutes: 15
practice_minutes: 15
prerequisites: ["00.1"]
objectives:
  - Self-assess readiness across Linux CLI, TCP/IP, and general security literacy.
  - Identify your specific gaps and the targeted way to close each before the technical modules.
  - Use the one-page catch-up reference and know when you are ready to continue.
volatility: concept
sources:
  - title: "The Linux Documentation Project — introductory guides"
    url: https://tldp.org/guides.html
last_verified: "2026-10-01"
---

# 00.2 · Readiness self-check and preparation path

This course teaches all the RF and 802.11 material from scratch, but it assumes you can already work in
a Linux shell, you understand TCP/IP basics, and you have general security literacy. This lesson is a
short, honest self-check so you find out *now* — not three modules in — whether to spend an evening on
a prep primer first.

## Why this matters

Almost every frustration learners hit in wireless labs traces back to a missing fundamental, not to
wireless itself: not knowing how to read `ip` output, not understanding what a DHCP lease or a port is,
not having a mental model of a credential or a hash. A focused hour closing a real gap now saves many
hours of confusion later. Equally, if you already have these skills, you shouldn't waste time — this
lesson helps you confirm that and move on.

## Learning objectives

- Honestly self-assess across **Linux CLI**, **TCP/IP**, and **security literacy**.
- Identify your specific gaps and a **targeted** way to close each.
- Know the signal that you are ready to continue to Module 1.

## Prerequisites

[Lesson 00.1](lesson-01.md). Nothing technical yet — that's what this lesson checks.

## Concept

### How to use the self-check

Treat each item below as "could I do this right now, at a terminal, without looking it up?" This is a
**self-assessment, not a graded quiz** — there is no answer key, because the honest answer is whether
you can actually perform the task. If you miss several items in a section, that section is a gap; see
the prep path at the end.

### Linux command line

- [ ] Navigate the filesystem and inspect files (`cd`, `ls -la`, `cat`, `less`, `find`).
- [ ] Edit a text file from the terminal (`nano`/`vim`) and save it.
- [ ] Install a package and read its man page (`apt install …`, `man iw`).
- [ ] Run a command with `sudo` and understand why it's needed.
- [ ] Redirect and pipe output (`cmd > file`, `cmd | grep …`), and read exit status.
- [ ] Read the output of `ip addr` / `ip link` and identify an interface and its state.

### TCP/IP basics

- [ ] Explain the difference between an **IP address** and a **MAC address**.
- [ ] Describe what **DHCP** does and what a lease is.
- [ ] Describe what **DNS** resolves and roughly how.
- [ ] Explain what a **port** is and give an example (e.g. 443).
- [ ] Place IP, MAC, and "the wireless link" on **OSI layers 1–3** at a high level.

### Security literacy

- [ ] Explain what a **credential** and a **hash** are, and why you can't trivially reverse a hash.
- [ ] Explain why **encryption** matters for data in transit.
- [ ] Describe, in one sentence, what a **threat model** is.

### The one-page catch-up reference

If you missed items, here is the minimum to shore up before Module 1 — each is a term and the one idea
to hold:

- **Interface / link state:** a network interface can be *up* or *down* and has a MAC address; wireless
  interfaces additionally have a *mode* (managed, monitor, AP). You'll meet modes in Module 3.
- **MAC vs IP:** MAC identifies a device on the local link (layer 2); IP identifies it on the wider
  network (layer 3). Wi-Fi attacks live mostly at layer 2.
- **DHCP/DNS:** after you join a network, DHCP hands you an IP; DNS turns names into IPs. A rogue AP can
  provide both — that's part of why evil twins work (Module 9).
- **Hash:** a one-way fingerprint of data. Cracking WPA2 means guessing a passphrase, hashing each
  guess the same way, and comparing — not reversing anything (Module 6).
- **Threat model:** who you're defending against and what they can do. Every defence in this course is
  judged against a stated threat, not "secure" in the abstract.

## Hands-on

### Guided walkthrough — confirm a working Linux shell

You don't need the wireless lab yet; you need a Linux shell (a VM is fine — Module 3 builds the full
lab). Confirm the basics work:

```bash
whoami
ip addr                      # identify your interface(s) and their state
sudo apt update              # confirms sudo + package manager (Debian/Kali/Ubuntu)
man iw | head -n 20          # reading a man page you'll use a lot later
```

> [!NOTE]
> **Lab paths:** R (no wireless hardware needed — any Linux shell/VM). **Start state:** a Linux
> environment you can run commands in. **Duration:** ~15 min. **Artifacts:** a checked self-assessment
> and, if needed, a short list of gaps to close. **Cleanup:** none.

If `ip`, `sudo`, or `man` aren't available or behave unexpectedly, resolve that before continuing — the
rest of the course assumes they work.

## Exercise

From your self-check, write down your **weakest section** and one concrete action to close it (a
specific primer, a 30-minute exercise, a man page to read). If you missed nothing, write "ready" and
why. The goal is a deliberate decision, not a vague "I'll pick it up as I go."

<details>
<summary>Hint — targeted resources by gap</summary>

- Linux CLI: work through an introductory shell guide (e.g. a TLDP guide) and practise in a VM.
- TCP/IP: any "networking in 60 minutes" primer that covers addressing, DHCP, DNS, and ports.
- Security literacy: read a short explainer on hashing vs encryption and on threat modelling.
</details>

## References

- The Linux Documentation Project — introductory guides (`references/README.md`).
- [Readiness and prerequisites](../../README.md) — the course's stated entry requirements.

## What you should now be able to do

- Self-assess your Linux, networking, and security readiness honestly.
- Name your specific gaps and a targeted way to close each.
- Decide, deliberately, whether you're ready for Module 1 or need a short prep detour first.
