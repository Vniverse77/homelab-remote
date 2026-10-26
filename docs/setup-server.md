# Server setup

The server is the always-on (or wake-on-demand) machine, usually the one with the GPU.

## 1. Install

```bash
sudo pacman -S --needed openssh tmux mosh curl
./install.sh server
```

This installs `/usr/local/bin/pc-remote` and `/etc/sudoers.d/homelab-remote`, which lets
your user run only `systemctl poweroff` and `systemctl reboot` without a password.

## 2. Enable Wake-on-LAN

In BIOS / UEFI, enable **Wake on LAN** (sometimes called *Power On by PCI-E*) and disable
**ErP / Deep Sleep**, otherwise the network card has no power while the PC is off.

Check the card in Linux and note its MAC address:

```bash
sudo ethtool <iface> | grep Wake-on     # "g" means magic packet is enabled
ip link show <iface> | grep ether        # MAC address for SERVER_MAC
```

If it shows `d`, enable it permanently with NetworkManager:

```bash
nmcli -t -f NAME,DEVICE connection show --active
sudo nmcli connection modify "<connection>" 802-3-ethernet.wake-on-lan magic
```

## 3. Stay reachable while you are away

When you are away, nothing at home can wake the server, so keep it on and make it
come back after a power cut:

```bash
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

In BIOS set **Restore on AC Power Loss** (also *AC Back* / *Power On After Power Fail*)
to **Power On**.

## 4. Firewall (ufw)

Allow everything only on the Tailscale interface:

```bash
sudo ufw default deny incoming
sudo ufw allow in on tailscale0 to any port 22 proto tcp
sudo ufw allow in on tailscale0 to any port 60000:61000 proto udp   # mosh
sudo ufw enable
sudo ufw status verbose
```

Remove any older `ALLOW Anywhere` rules for SSH or remote desktop, and check that your
router does not forward any ports to this machine.

## 5. tmux

A small config that works well from a phone too:

```bash
printf 'set -g mouse on\nset -g history-limit 50000\nset -g default-terminal "tmux-256color"\n' > ~/.tmux.conf
```

## 6. Authorize the laptop

This happens from the laptop, see [setup-laptop.md](setup-laptop.md). Afterwards
`~/.ssh/authorized_keys` on the server contains two lines from the laptop:

```
command="/usr/local/bin/pc-remote",restrict ssh-ed25519 AAAA... homelab-control@laptop
ssh-ed25519 AAAA... homelab-dev@laptop
```

Once key login works, consider disabling password logins in `/etc/ssh/sshd_config`:

```
PasswordAuthentication no
KbdInteractiveAuthentication no
```
