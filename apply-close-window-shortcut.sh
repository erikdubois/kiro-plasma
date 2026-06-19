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
#   - Add Super+Shift+Q as a second trigger for KDE Plasma's built-in
#     "Close Window" action (the default Alt+F4 is kept).
#   - Writes the binding into the CURRENT user's
#     ~/.config/kglobalshortcutsrc via kwriteconfig6 and reloads
#     kglobalaccel so it takes without logging out.
#
#   Why: the kiro-plasma-keybindings package seeds this binding through
#   /etc/skel, which only reaches NEW accounts. Existing users run this
#   once to retrofit the same shortcut into their live session.
#
#   Note: this overwrites the "Close Window" entry; if you previously
#   rebound it to something custom, that custom key is replaced by
#   Alt+F4 + Super+Shift+Q.
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
SHORTCUT_VALUE=$'Alt+F4\tMeta+Shift+Q,Alt+F4,Close Window'

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

apply_shortcut() {
    log_section "Adding Super+Shift+Q to KWin 'Close Window'"
    kwriteconfig6 --file kglobalshortcutsrc \
        --group kwin --key "Window Close" "${SHORTCUT_VALUE}"
    log_success "Binding written to ~/.config/kglobalshortcutsrc"
}

reload_kglobalaccel() {
    log_section "Reloading kglobalaccel"
    # Best-effort: restart the running shortcut daemon so the new binding is
    # live now. It is D-Bus / user-service activated, so it comes back on its
    # own. If neither path works, the binding still applies at next login.
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
    if command -v kreadconfig6 >/dev/null 2>&1; then
        local current
        current="$(kreadconfig6 --file kglobalshortcutsrc --group kwin --key "Window Close" 2>/dev/null || true)"
        echo "  Window Close = ${CYAN}${current}${RESET}"
        if [[ "${current}" == *"Meta+Shift+Q"* ]]; then
            log_success "Super+Shift+Q is bound to Close Window"
        else
            log_warn "Super+Shift+Q not found in the value — check kglobalshortcutsrc manually"
        fi
    else
        log_info "kreadconfig6 not available — skipping read-back check"
    fi
}

#####################################################################
# Main
#####################################################################
main() {
    check_prereqs
    apply_shortcut
    reload_kglobalaccel
    verify
    log_success "$(basename "$0") done"
}

main "$@"
