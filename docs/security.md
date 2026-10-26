# Security

## Threat model

| If an attacker has... | They can | They cannot |
|---|---|---|
| Access to your LAN or a cafe Wi-Fi | Nothing: every port is open on `tailscale0` only | Reach SSH, mosh or the camera |
| The laptop's control key | Shut down, restart or ping the server | Get a shell, read files, run commands |
| Your unlocked phone | See the widgets | Run any of them without the laptop's password |
| Your phone and the laptop's password | Power-control the server, start the camera | Get a shell on the laptop or the server |
| The camera link | Watch the stream while it is on | Turn it on, or use it outside your tailnet |

## Design choices

- **Forced commands.** Both gates (`pc-phone`, `pc-remote`) use `command=` in
  `authorized_keys`, so the key can never run anything else. They match the requested
  command exactly against an allowlist; anything else, including `;` tricks, is refused.
- **No secrets on the phone.** The phone stores only keys; the password is checked by the
  laptop through PAM (`sudo -v`), with the usual attempt limits and journal logging.
  Fingerprint PAM modules skip remote sessions, so the password is always asked over SSH.
- **Passphrase on full-access keys.** The dev keys (laptop and phone) open a real shell
  on the server, so they should always have a passphrase.
- **Camera hardening.** mediamtx only accepts publishing from localhost, needs a password
  for viewers, has RTMP / HLS / WebRTC / SRT disabled and runs as a transient systemd
  unit with `RuntimeMaxSec`, so it cannot be left on by accident.

## Checklist

- [ ] `ufw default deny incoming` on both machines
- [ ] All homelab ports allowed `on tailscale0` only
- [ ] No port forwarding on the router
- [ ] Password login disabled in `sshd_config` once keys work
- [ ] Tailscale key expiry left **on** for the laptop and the phone
- [ ] If a device is lost: remove it in the Tailscale admin console and delete its line
      from `authorized_keys`

## Reporting

Found a problem? Please open an issue without exploit details, or contact the maintainer
privately first.
