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
#   - Tier 1 "yes great" - the user apps you almost certainly want on top of a
#     minimal Kiro Plasma ISO. Core Plasma applications plus Erik's daily apps.
#   - Nothing here ships in the kiro-iso packages file (KIB), so it is all extra.
#   - No X11-only tools, no development tooling, no non-Plasma desktop apps.
#
##################################################################################################################################

install_tier1() {
    if ! is_plasma_installed; then
        log_warn "Plasma is not installed - skipping Tier 1 apps"
        return 0
    fi

    log_section "Installing Tier 1 apps (yes great)"

    install_packages \
        ark \
        discover \
        dolphin \
        dolphin-plugins \
        gwenview \
        kdeconnect \
        ktorrent \
        partitionmanager \
        spectacle \
        yakuake \
        insync \
        signal-in-tray \
        spotify \
        zapzap
}

install_tier1

log_subsection "$(script_name) done"
