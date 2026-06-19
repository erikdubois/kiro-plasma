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
#   - The Kiro Plasma integration layer from nemesis_repo: keybindings, Dolphin
#     service menus and the Surf'n Plasma icon themes.
#   - This is not a "choose your apps" tier - it is the Kiro-on-Plasma baseline.
#   - Skip cleanly when Plasma is not present.
#
##################################################################################################################################

install_plasma_extras() {
    if ! is_plasma_installed; then
        log_warn "Plasma is not installed - skipping Kiro Plasma extras"
        return 0
    fi

    log_section "Plasma detected - installing Kiro Plasma integration"

    install_packages \
        kiro-plasma-keybindings \
        kiro-plasma-servicemenus \
        surfn-plasma-dark-icons-git \
        surfn-plasma-light-icons-git
}

install_plasma_extras

log_subsection "$(script_name) done"
