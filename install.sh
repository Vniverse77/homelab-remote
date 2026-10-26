#!/usr/bin/env bash
# install.sh - install homelab-remote on the laptop or on the home server.
#
#   ./install.sh laptop    install pc, dev, camera, pc-phone into ~/.local/bin
#   ./install.sh server    install pc-remote and a narrow sudoers rule (needs sudo)
#
# Override the laptop install location with PREFIX, e.g. PREFIX=/usr/local ./install.sh laptop
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$HOME/.config/homelab-remote"

usage() { sed -n '2,7p' "$0" | sed 's/^# \{0,1\}//'; }

check_deps() {
  local missing=() dep
  for dep in "$@"; do
    command -v "$dep" >/dev/null || missing+=("$dep")
  done
  if (( ${#missing[@]} )); then
    echo "Note: missing optional/required tools: ${missing[*]}"
  fi
}

install_laptop() {
  local bin="${PREFIX:-$HOME/.local}/bin"
  mkdir -p "$bin"
  local f
  for f in pc dev camera pc-phone; do
    install -m 755 "$REPO_DIR/bin/$f" "$bin/$f"
    echo "Installed $bin/$f"
  done

  mkdir -p "$CONFIG_DIR"
  chmod 700 "$CONFIG_DIR"
  if [[ ! -e $CONFIG_DIR/config ]]; then
    install -m 600 "$REPO_DIR/config.example" "$CONFIG_DIR/config"
    echo "Created $CONFIG_DIR/config - edit it before first use."
  else
    echo "Kept existing $CONFIG_DIR/config"
  fi

  if [[ -d $HOME/.config/fish ]]; then
    install -m 644 "$REPO_DIR/extras/fish/host-badge.fish" "$HOME/.config/fish/host-badge.fish"
    echo "Installed ~/.config/fish/host-badge.fish (add 'source ~/.config/fish/host-badge.fish'"
    echo "  at the end of ~/.config/fish/config.fish to enable it)"
  fi

  check_deps ssh tailscale wakeonlan mosh ffmpeg mediamtx python3 flock
  case ":$PATH:" in
    *":$bin:"*) ;;
    *) echo "Warning: $bin is not in your PATH." ;;
  esac
  echo
  echo "Next: see docs/setup-laptop.md"
}

install_server() {
  local user="${SUDO_USER:-$USER}"
  local rule="/etc/sudoers.d/homelab-remote"
  local tmp
  tmp="$(mktemp)"
  trap 'rm -f "$tmp"' EXIT

  printf '%s ALL=(root) NOPASSWD: /usr/bin/systemctl poweroff, /usr/bin/systemctl reboot\n' \
    "$user" > "$tmp"
  sudo visudo -cf "$tmp" >/dev/null
  sudo install -m 440 -o root -g root "$tmp" "$rule"
  echo "Installed $rule for user $user"

  sudo install -m 755 "$REPO_DIR/server/pc-remote" /usr/local/bin/pc-remote
  echo "Installed /usr/local/bin/pc-remote"

  sudo visudo -c >/dev/null && echo "sudoers check: OK"
  check_deps sshd tailscale curl tmux mosh-server
  echo
  echo "Next: see docs/setup-server.md"
}

case "${1:-}" in
  laptop) install_laptop ;;
  server) install_server ;;
  *) usage; exit 2 ;;
esac
