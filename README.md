<div align="center">

```
 _                          _       _                                    _
| |__   ___  _ __ ___   ___| | __ _| |__        _ __ ___ _ __ ___   ___ | |_ ___
| '_ \ / _ \| '_ ` _ \ / _ \ |/ _` | '_ \ _____| '__/ _ \ '_ ` _ \ / _ \| __/ _ \
| | | | (_) | | | | | |  __/ | (_| | |_) |_____| | |  __/ | | | | | (_) | ||  __/
|_| |_|\___/|_| |_| |_|\___|_|\__,_|_.__/      |_|  \___|_| |_| |_|\___/ \__\___|
```

**Wake your home PC, shut it down and keep working on it, from anywhere.**
A laptop that stays at home is the gateway, your phone is the remote, Tailscale is the wire.

[![AUR](https://img.shields.io/aur/version/homelab-remote?label=AUR&logo=archlinux&color=1793d1)](https://aur.archlinux.org/packages/homelab-remote)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![shellcheck](https://github.com/Vniverse77/homelab-remote/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/Vniverse77/homelab-remote/actions/workflows/shellcheck.yml)

```console
$ yay -S homelab-remote
$ homelab setup        # guided TUI: laptop, server, camera, phone
$ pc on                # wake the server, wait until it answers
$ dev                  # jump into a tmux session on it (mosh)
```

</div>

## How it fits together

Everything runs over [Tailscale](https://tailscale.com); no ports are opened to the internet.

```
   Phone (Termux:Widget)              Laptop (always on at home)            Home server (GPU box)
  +----------------------+  SSH   +---------------------------+  SSH    +----------------------+
  | PC On / Off / Status |------->| pc-phone (password gate)  |-------->| pc-remote (allowlist)|
  | Camera On / Off      |        | pc, camera, dev           |  WoL    | tmux sessions        |
  | Server Dev (mosh)    |---+    | webcam stream (RTSP)      |-------->| coding agents, jobs  |
  +----------------------+   |    +---------------------------+         +----------------------+
                             +--------------------------------- mosh ---------------^
```

## Install

**Arch Linux / CachyOS / Manjaro (AUR):**

```bash
yay -S homelab-remote      # or: paru -S homelab-remote
homelab setup
```

**Any other Linux (from source):**

```bash
git clone https://github.com/Vniverse77/homelab-remote.git
cd homelab-remote
./bin/homelab setup
```

## Features

| Command | Runs on | What it does |
|---|---|---|
| `pc on` | laptop | Wakes the server with Wake-on-LAN and waits until it is reachable |
| `pc off` / `pc restart` | laptop | Countdown, optional warning if Ollama has models loaded, then shut down / restart |
| `pc status` | laptop | Shows whether the server is up (`--json` for scripts) |
| `dev [name]` | laptop | Attaches to a persistent tmux session on the server via mosh, waking it first |
| `camera on [min]` / `off` / `status` | laptop | Streams the webcam (+ mic) as password-protected RTSP, auto-off after a timeout |
| Phone widgets | phone | One-tap buttons that call the laptop; every tap asks for the laptop's password |
| `homelab setup` / `doctor` | laptop | Guided setup of everything, and a health check with clear fixes |

## Security model

- **Tailscale only.** Every port (SSH, mosh, RTSP) is allowed on the `tailscale0`
  interface only. Nothing is exposed to the LAN or the internet.
- **Restricted keys.** The laptop's control key can only run `pc-remote` on the server
  (poweroff, reboot, ping, Ollama status). The phone's key can only run `pc-phone`
  on the laptop. A stolen key cannot open a shell.
- **Password gate.** `pc-phone` asks for the laptop's login password on every command,
  so an unlocked phone is not enough.
- **Narrow sudo.** The server only allows `systemctl poweroff` and `systemctl reboot`
  without a password, and only for your user.
- **Camera.** The stream needs a random per-device password, is reachable over
  Tailscale only and stops by itself after a timeout.

Details: [docs/security.md](docs/security.md)

## Requirements

- Two Linux machines with systemd (tested on Arch / CachyOS) and Tailscale on both
- Server: wired Ethernet with Wake-on-LAN enabled in BIOS, `sshd`, `tmux`, `mosh`
- Laptop: `python3`, `wakeonlan`, `mosh`, `flock` (util-linux); for the camera also `ffmpeg`,
  `v4l-utils` and `mediamtx`. The wizard offers to install what is missing.
  Optional: [`gum`](https://github.com/charmbracelet/gum) for a nicer wizard, `qrencode` for the phone QR code
- Phone (optional): Android with [Termux](https://f-droid.org/packages/com.termux/) and
  [Termux:Widget](https://f-droid.org/packages/com.termux.widget/) from F-Droid, plus Tailscale

## Quick start

Everything is set up from the laptop. Make sure Tailscale is connected on the laptop
and the server, and that you can log in to the server with your password once.

The wizard:

- installs the commands into `~/.local/bin`
- lets you pick the server from your tailnet and detects its MAC address, network and project folder
- creates the SSH keys and authorizes them on the server (the control key is restricted)
- sets the server up over SSH: `pc-remote`, a narrow sudoers rule, tmux / mosh,
  Wake-on-LAN, no-sleep and a Tailscale-only firewall
- detects your webcam format and opens the camera port on Tailscale only
- prints one line (and a QR code) to paste into Termux, which links the phone and creates the widgets
- reuses everything that already exists, and asks before every change

Check everything at any time:

```bash
homelab doctor
```

Prefer doing it by hand? See the manual guides:
[server](docs/setup-server.md), [laptop](docs/setup-laptop.md), [phone](docs/setup-phone.md).
For a non-interactive install use `./install.sh laptop` and `./install.sh server`.

## Extras

- [`extras/fish/host-badge.fish`](extras/fish/host-badge.fish) prefixes your fish prompt
  with a colored hostname, so you never run a command on the wrong machine.

## Roadmap

- [x] Power control (Wake-on-LAN, shutdown, restart, status)
- [x] Persistent remote dev sessions (tmux + mosh)
- [x] Password-protected webcam stream with auto-off
- [x] Phone widgets with a password gate
- [x] Setup wizard (`homelab setup`) and health check (`homelab doctor`)
- [ ] **Remote AI** - use the server's GPU and local / free models from the laptop and phone *(coming soon)*
- [x] AUR package ([homelab-remote](https://aur.archlinux.org/packages/homelab-remote))
- [ ] Always-on servers without Wake-on-LAN (Raspberry Pi, laptops on Wi-Fi)

## A note on the camera

Only point the camera at spaces you are allowed to record. If you share your home,
tell the people who live there. Recording others without consent is illegal in
many places.

## License

[MIT](LICENSE)
