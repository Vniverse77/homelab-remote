# Laptop setup

The laptop stays at home most of the time, plugged in and always on. It sends the
Wake-on-LAN packet, so it must be on the same LAN as the server for `pc on` to work.

## 1. Install

```bash
sudo pacman -S --needed openssh wakeonlan mosh python
./install.sh laptop
```

Edit `~/.config/homelab-remote/config` and fill in at least `SERVER_IP`, `SERVER_USER`,
`SERVER_MAC`, `LAN_BROADCAST` and `PROJECTS_DIR`.

## 2. Keys

Create two keys. The control key is restricted on the server, so it has no passphrase
(scripts use it unattended). The dev key gives a full shell, so give it a passphrase.

```bash
ssh-keygen -t ed25519 -f ~/.ssh/homelab_control -N "" -C "homelab-control@$(hostname)"
ssh-keygen -t ed25519 -f ~/.ssh/homelab_dev -C "homelab-dev@$(hostname)"

# Restricted control key: may only run pc-remote
echo "command=\"/usr/local/bin/pc-remote\",restrict $(cat ~/.ssh/homelab_control.pub)" \
  | ssh <user>@<server-tailscale-ip> 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys'

# Full dev key
ssh-copy-id -i ~/.ssh/homelab_dev.pub <user>@<server-tailscale-ip>
```

Test:

```bash
pc status
dev
```

## 3. Stay on while plugged in (KDE Plasma)

**System Settings > Power Management**

- *On AC Power*: Sleep automatically **Never**, When laptop lid closed **Do nothing**
- *On Battery*: short screen-off and sleep times, When laptop lid closed **Sleep**

Make it apply before login too:

```bash
sudo mkdir -p /etc/systemd/logind.conf.d
printf '[Login]\nHandleLidSwitch=suspend\nHandleLidSwitchExternalPower=ignore\nHandleLidSwitchDocked=ignore\n' \
  | sudo tee /etc/systemd/logind.conf.d/lid.conf
sudo systemctl kill -s HUP systemd-logind
```

Protect a battery that is always plugged in: **Power Management > Advanced Power Settings >
Battery Charge Limit**, for example stop at 87% and start below 80%.

## 4. Camera (optional)

```bash
sudo pacman -S --needed ffmpeg v4l-utils
paru -S mediamtx            # or mediamtx-bin
sudo ufw allow in on tailscale0 to any port 8554 proto tcp
camera on 1
```

If it fails, check the formats your webcam supports and adjust `CAMERA_INPUT_FORMAT`
and `CAMERA_SIZE` in the config:

```bash
v4l2-ctl --list-formats-ext -d /dev/video0
```

The stream password is created on first use in `~/.config/homelab-remote/camera/password`.
The link never changes, so you can save it once in VLC.

## 5. Allow the phone

Run the SSH server on the laptop, reachable over Tailscale only:

```bash
sudo systemctl enable --now sshd
sudo ufw allow in on tailscale0 to any port 22 proto tcp
```

Then continue with [setup-phone.md](setup-phone.md).
