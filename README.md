# homelab-remote

Control your home PC from anywhere and keep working on it while you are away,
using a laptop that lives at home and a phone in your pocket. Everything runs
over [Tailscale](https://tailscale.com); no ports are opened to the internet.

```
   Phone (Termux:Widget)              Laptop (always on at home)            Home server (GPU box)
  +----------------------+  SSH   +---------------------------+  SSH    +----------------------+
  | PC On / Off / Status |------->| pc-phone (password gate)  |-------->| pc-remote (allowlist)|
  | Camera On / Off      |        | pc, camera, dev           |  WoL    | tmux sessions        |
  | Server Dev (mosh)    |---+    | webcam stream (RTSP)      |-------->| coding agents, jobs  |
  +----------------------+   |    +---------------------------+         +----------------------+
                             +--------------------------------- mosh ---------------^
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
- Laptop: `wakeonlan`, `mosh`, `python3`, `flock` (util-linux); for the camera also `ffmpeg` and `mediamtx`
- Phone (optional): Android with [Termux](https://f-droid.org/packages/com.termux/) and
  [Termux:Widget](https://f-droid.org/packages/com.termux.widget/) from F-Droid, plus Tailscale

## Quick start

```bash
git clone https://github.com/<you>/homelab-remote.git
cd homelab-remote

# On the server
./install.sh server

# On the laptop
./install.sh laptop
$EDITOR ~/.config/homelab-remote/config
```

Then follow the guides in order:

1. [Server setup](docs/setup-server.md)
2. [Laptop setup](docs/setup-laptop.md)
3. [Phone setup](docs/setup-phone.md)

## Extras

- [`extras/fish/host-badge.fish`](extras/fish/host-badge.fish) prefixes your fish prompt
  with a colored hostname, so you never run a command on the wrong machine.

## Roadmap

- [x] Power control (Wake-on-LAN, shutdown, restart, status)
- [x] Persistent remote dev sessions (tmux + mosh)
- [x] Password-protected webcam stream with auto-off
- [x] Phone widgets with a password gate
- [ ] **Remote AI** - use the server's GPU and local / free models from the laptop and phone *(coming soon)*
- [ ] AUR package *(planned)*

## A note on the camera

Only point the camera at spaces you are allowed to record. If you share your home,
tell the people who live there. Recording others without consent is illegal in
many places.

## License

[MIT](LICENSE)
