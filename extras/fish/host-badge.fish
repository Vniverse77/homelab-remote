# host-badge.fish - prefix your existing fish prompt with a colored hostname,
# so you always know which machine a terminal belongs to.
# Part of homelab-remote.
#
# Works on top of any prompt (default, CachyOS, Starship, Tide). Source it at
# the END of ~/.config/fish/config.fish so it wraps the final prompt:
#   source ~/.config/fish/host-badge.fish
#
# Pick colors per host with universal variables (optional):
#   set -U host_badge_color_laptop cyan
#   set -U host_badge_color_server magenta
#   set -U host_badge_servers msi homeserver   # hostnames treated as servers

status is-interactive; or return
functions -q fish_prompt; or return
functions -q __host_badge_orig_prompt; and return

functions -c fish_prompt __host_badge_orig_prompt

function __host_badge_restore_status
    return $argv[1]
end

function fish_prompt
    set -l last_status $status
    set -l host (string lower (prompt_hostname))

    set -q host_badge_color_laptop; or set -l host_badge_color_laptop cyan
    set -q host_badge_color_server; or set -l host_badge_color_server magenta

    set -l servers
    set -q host_badge_servers[1]; and set servers (string lower -- $host_badge_servers)

    if contains -- $host $servers
        set_color --bold $host_badge_color_server
    else
        set_color --bold $host_badge_color_laptop
    end
    printf '[%s] ' $host
    set_color normal

    __host_badge_restore_status $last_status
    __host_badge_orig_prompt
end
