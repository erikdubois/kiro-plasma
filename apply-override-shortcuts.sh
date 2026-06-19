#!/bin/bash
set -euo pipefail
#####################################################################
# Author    : Erik Dubois
# Website   : https://kiroproject.be
#####################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
#   Purpose:
#   - Apply the Kiro keybindings that CANNOT ride the add-only
#     /usr/share/applications + X-KDE-Shortcuts mechanism because they
#     have to override a built-in KWin action. Two groups:
#       1. Super+Shift+Q  -> KWin "Close Window" (Alt+F4 is kept).
#       2. The Super+F#    -> app launches that collide with Plasma's
#          virtual-desktop / present-windows / move-mouse defaults
#          (VS Code, Inkscape, GIMP, Meld, VLC, VirtualBox, virt-manager).
#   - For each F-key app: free the conflicting key from the KWin action,
#     then bind the key to that app's launcher via a [services] entry.
#     Only done when the app is actually installed, so no dead keys.
#   - Writes into the CURRENT user's ~/.config/kglobalshortcutsrc via
#     kwriteconfig6 and reloads kglobalaccel so it takes without logout.
#
#   Why: the kiro-plasma-keybindings package is strictly add-only and
#   never touches KWin defaults. These overrides are the deliberate
#   exception, kept in a script so existing users can opt in per-machine.
#
#   Note: this overwrites the affected KWin actions. The active key is
#   changed; KDE's default field and friendly name are preserved.
#
#####################################################################

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

#####################################################################
# Colors
#####################################################################
if command -v tput >/dev/null 2>&1 && [[ -t 1 ]]; then
    RED="$(tput setaf 1)"
    GREEN="$(tput setaf 2)"
    YELLOW="$(tput setaf 3)"
    BLUE="$(tput setaf 4)"
    CYAN="$(tput setaf 6)"
    RESET="$(tput sgr0)"
else
    RED="" GREEN="" YELLOW="" BLUE="" CYAN="" RESET=""
fi

#####################################################################
# Logging
#####################################################################
log_section() {
    echo
    echo "${GREEN}############################################################################${RESET}"
    echo "$1"
    echo "${GREEN}############################################################################${RESET}"
    echo
}

log_info() {
    echo
    echo "${BLUE}############################################################################${RESET}"
    echo "$1"
    echo "${BLUE}############################################################################${RESET}"
    echo
}

log_warn() {
    echo
    echo "${YELLOW}############################################################################${RESET}"
    echo "$1"
    echo "${YELLOW}############################################################################${RESET}"
    echo
}

log_error() {
    echo
    echo "${RED}############################################################################${RESET}"
    echo "$1"
    echo "${RED}############################################################################${RESET}"
    echo
}

log_success() {
    echo
    echo "${GREEN}############################################################################${RESET}"
    echo "$1"
    echo "${GREEN}############################################################################${RESET}"
    echo
}

#####################################################################
# Error handling
#####################################################################
on_error() {
    local lineno="$1"
    local cmd="$2"
    echo
    echo "${RED}ERROR on line ${lineno}: ${cmd}${RESET}"
    echo
    sleep 10
}

trap 'on_error "$LINENO" "$BASH_COMMAND"' ERR

#####################################################################
# Config
#####################################################################
# kglobalshortcutsrc value = <active shortcuts>,<default>,<friendly name>
# Multiple active shortcuts are separated by a literal TAB.
CLOSE_WINDOW_VALUE=$'Alt+F4\tMeta+Shift+Q,Alt+F4,Close Window'

# Super+F# app launches that collide with a KWin default.
# Each line: "<desktop-id candidates>|<shortcut>|<KWin action key to free>|<label>"
# The first candidate that resolves to an installed .desktop wins.
APP_ENTRIES=(
    "code visual-studio-code code-oss|Meta+F2|Switch to Desktop 2|VS Code"
    "org.inkscape.Inkscape inkscape|Meta+F3|Switch to Desktop 3|Inkscape"
    "org.gimp.GIMP gimp|Meta+F4|Switch to Desktop 4|GIMP"
    "org.gnome.meld meld|Meta+F5|MoveMouseToFocus|Meld"
    "vlc|Meta+F6|MoveMouseToCenter|VLC"
    "virtualbox org.virtualbox.VirtualBox|Meta+F7|ExposeClass|VirtualBox"
    "virt-manager|Meta+F9|Expose|virt-manager"
)

#####################################################################
# Functions
#####################################################################
check_prereqs() {
    log_section "Checking prerequisites"
    if ! command -v kwriteconfig6 >/dev/null 2>&1; then
        log_error "kwriteconfig6 not found — this script needs KDE Plasma 6"
        exit 1
    fi
    log_success "kwriteconfig6 present"
}

apply_close_window() {
    log_section "Adding Super+Shift+Q to KWin 'Close Window'"
    kwriteconfig6 --file kglobalshortcutsrc \
        --group kwin --key "Window Close" "${CLOSE_WINDOW_VALUE}"
    log_success "Close Window = Alt+F4 + Super+Shift+Q"
}

# Resolve the first installed .desktop id from a space-separated candidate list.
find_desktop_id() {
    local cand dir
    for cand in $1; do
        for dir in \
            "${HOME}/.local/share/applications" \
            /usr/share/applications \
            /usr/local/share/applications \
            /var/lib/flatpak/exports/share/applications \
            "${HOME}/.local/share/flatpak/exports/share/applications"; do
            if [[ -f "${dir}/${cand}.desktop" ]]; then
                printf '%s' "${cand}.desktop"
                return 0
            fi
        done
    done
    return 1
}

# Remove one shortcut (tab-separated token) from the active field of a KWin
# action, preserving its default and friendly-name fields.
free_kwin_key() {
    local key="$1" combo="$2" cur active rest newactive
    cur="$(kreadconfig6 --file kglobalshortcutsrc --group kwin --key "${key}" 2>/dev/null || true)"
    if [[ -z "${cur}" ]]; then
        log_warn "[kwin] '${key}' has no current value — leaving it alone"
        return 0
    fi
    active="${cur%%,*}"   # first field (may hold tab-separated alternates)
    rest="${cur#*,}"      # default,friendly
    newactive="$(printf '%s' "${active}" | tr '\t' '\n' | grep -vxF "${combo}" | paste -sd '\t' -)"
    [[ -z "${newactive}" ]] && newactive="none"
    kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "${key}" "${newactive},${rest}"
}

apply_app_shortcuts() {
    log_section "Applying Super+F# app-launch overrides"
    local entry cands shortcut kwin_key label id
    for entry in "${APP_ENTRIES[@]}"; do
        IFS='|' read -r cands shortcut kwin_key label <<< "${entry}"
        if ! id="$(find_desktop_id "${cands}")"; then
            log_warn "${label} not installed — leaving ${shortcut} on the Plasma default"
            continue
        fi
        free_kwin_key "${kwin_key}" "${shortcut}"
        kwriteconfig6 --file kglobalshortcutsrc \
            --group services --group "${id}" --key "_launch" "${shortcut}"
        log_success "${label} → ${shortcut}   ([services][${id}], freed [kwin] '${kwin_key}')"
    done
}

reload_kglobalaccel() {
    log_section "Reloading kglobalaccel"
    # Best-effort: restart the running shortcut daemon so the new bindings are
    # live now. It is D-Bus / user-service activated, so it comes back on its
    # own. If neither path works, the bindings still apply at next login.
    if systemctl --user try-restart plasma-kglobalaccel.service >/dev/null 2>&1; then
        log_success "kglobalaccel user service restarted"
    elif command -v kquitapp6 >/dev/null 2>&1 && kquitapp6 kglobalacceld >/dev/null 2>&1; then
        log_success "kglobalacceld restarted"
    else
        log_warn "Could not reload kglobalaccel automatically — log out and back in to activate"
    fi
}

verify() {
    log_section "Verifying"
    command -v kreadconfig6 >/dev/null 2>&1 || { log_info "kreadconfig6 not available — skipping read-back"; return 0; }
    local current
    current="$(kreadconfig6 --file kglobalshortcutsrc --group kwin --key "Window Close" 2>/dev/null || true)"
    echo "  Close Window = ${CYAN}${current}${RESET}"

    local entry cands shortcut kwin_key label id val
    for entry in "${APP_ENTRIES[@]}"; do
        IFS='|' read -r cands shortcut kwin_key label <<< "${entry}"
        id="$(find_desktop_id "${cands}" || true)"
        [[ -z "${id}" ]] && continue
        val="$(kreadconfig6 --file kglobalshortcutsrc --group services --group "${id}" --key "_launch" 2>/dev/null || true)"
        echo "  ${label} (${id}) = ${CYAN}${val}${RESET}"
    done
}

#####################################################################
# Main
#####################################################################
main() {
    check_prereqs
    apply_close_window
    apply_app_shortcuts
    reload_kglobalaccel
    verify
    log_success "$(basename "$0") done"
}

main "$@"
