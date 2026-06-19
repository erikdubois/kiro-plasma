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
#   - Mostly theming/integration glue. Install only if you specifically want it.
#   - None are present in the minimal Kiro Plasma ISO build.
#
##################################################################################################################################

install_tier4() {
    if ! is_plasma_installed; then
        log_warn "Plasma is not installed - skipping Tier 4 packages"
        return 0
    fi

    log_section "Installing Tier 4 packages (could not place)"

    install_packages \
        ffmpegthumbs \
        hardcode-fixer-git \
        packagekit-qt6 \
        python-pywal
}

install_tier4

log_subsection "$(script_name) done"
