#!/usr/bin/env bash
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/common/common.sh"

log_section "Running $(script_name)"

pause_if_debug

##################################################################################################################################
# Author    : Erik Dubois
# Website   : https://www.erikdubois.be
# Youtube   : https://youtube.com/erikdubois
##################################################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
#   Purpose:
#   - Tier 2 "maybe" - useful Plasma user apps you might add depending on taste.
#   - Encrypted-folder tooling, Samba sharing from Dolphin, a password manager.
#   - None of these ship in the kiro-iso packages file (KIB).
#
##################################################################################################################################

install_tier2() {
    if ! is_plasma_installed; then
        log_warn "Plasma is not installed - skipping Tier 2 apps"
        return 0
    fi

    log_section "Installing Tier 2 apps (maybe)"

    install_packages \
        cryfs \
        encfs \
        gocryptfs \
        kdenetwork-filesharing \
        lastpass
}

install_tier2

log_subsection "$(script_name) done"
