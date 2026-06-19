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
#   - Tier 4 "the rest" - allowed on a Plasma box but not a clear user app, so it
#     could not be confidently placed in Tier 1/2/3.
#   - Mostly theming/integration glue and a stray fetch tool. Install only if you
#     specifically want them.
#
##################################################################################################################################

install_tier4() {
    if ! is_plasma_installed; then
        log_warn "Plasma is not installed - skipping Tier 4 packages"
        return 0
    fi

    log_section "Installing Tier 4 packages (could not place)"

    install_packages \
        breeze \
        ffmpegthumbs \
        kde-gtk-config \
        packagekit-qt6
}

install_tier4

log_subsection "$(script_name) done"
