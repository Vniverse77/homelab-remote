# Phone setup (Android)

The phone holds no logic. Every widget is a one-line shortcut that connects to the
laptop, where `pc-phone` asks for the laptop's password and runs the command.

## 1. Apps

Install from **F-Droid** (the Play Store build of Termux is outdated, and both apps
must come from the same source):

- Termux
- Termux:Widget

Install Tailscale and VLC from any store. Keep Tailscale connected.

## 2. Key for the laptop

In Termux (replace `<laptop-user>` and `<laptop-ip>`):

```bash
pkg update && pkg install openssh
ssh-keygen -t ed25519 -f ~/.ssh/homelab_phone -N "" -C "homelab-phone"
echo "command=\"/home/<laptop-user>/.local/bin/pc-phone\",restrict,pty $(cat ~/.ssh/homelab_phone.pub)" \
  | ssh <laptop-user>@<laptop-ip> 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys'
```

`restrict,pty` blocks everything except a terminal for the allowed commands, so the
countdown and the password prompt are visible on the phone.

## 3. Widgets

```bash
LAPTOP="<laptop-user>@<laptop-ip>"
mkdir -p ~/.shortcuts
for pair in "PC On:pc on" "PC Off:pc off" "PC Restart:pc restart" "PC Status:pc status" \
            "Camera On:camera on" "Camera Off:camera off"; do
  name=${pair%%:*}
  c=${pair#*:}
  printf '#!/data/data/com.termux/files/usr/bin/bash\nssh -t -i ~/.ssh/homelab_phone %s "%s"\nsleep 3\nexit\n' \
    "$LAPTOP" "$c" > ~/.shortcuts/"$name"
  chmod +x ~/.shortcuts/"$name"
done
ls ~/.shortcuts
```

Long-press the home screen > **Widgets** > **Termux:Widget**, then tap the refresh icon.

## 4. Direct dev access to the server (optional)

For when the laptop is not at home. This key gives a full shell, so give it a
passphrase; Termux asks for it on every connection.

```bash
pkg install mosh
ssh-keygen -t ed25519 -f ~/.ssh/homelab_server -C "homelab-server@phone"
ssh-copy-id -i ~/.ssh/homelab_server.pub <server-user>@<server-ip>
printf '#!/data/data/com.termux/files/usr/bin/bash\nmosh --ssh="ssh -i ~/.ssh/homelab_server" %s -- tmux new-session -A -s main -c %s\n' \
  "<server-user>@<server-ip>" "<projects-dir>" > ~/.shortcuts/"Server Dev"
chmod +x ~/.shortcuts/"Server Dev"
```

In tmux on the phone, use the `CTRL` key on Termux's extra key row: `CTRL`, `b`, then `d`
detaches and leaves everything running.

## 5. Camera in VLC

Run `camera on 1` on the laptop once and copy the `rtsp://` link. In VLC choose
**More > New stream** and paste it. The link never changes, so after that the flow is:
**Camera On** widget > password > tap the saved stream in VLC.

The link contains the stream password. Move it with KDE Connect or LocalSend,
not through a chat app.
