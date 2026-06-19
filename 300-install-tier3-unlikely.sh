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
#   - Tier 3 "unlikely" - apps that were considered for the ISO but deliberately
#     left out: they sit COMMENTED in kiro-iso/archiso/packages.x86_64.
#   - Source-driven list, then filtered to drop X11-only, non-Plasma desktop and
#     development entries. What remains are user apps (office suites, email
#     clients, PDF/note tools, scanning) plus a few core KDE apps that the ISO
#     keeps commented (kate, okular, kmail). konsole is excluded - it is part of
#     Plasma for us.
#
##################################################################################################################################

install_tier3() {
    if ! is_plasma_installed; then
        log_warn "Plasma is not installed - skipping Tier 3 apps"
        return 0
    fi

    log_section "Installing Tier 3 apps (unlikely)"

    install_packages \
        betterbird-bin \
        cherrytree \
        claws-mail \
        featherpad \
        gscan2pdf \
        kate \
        kmail \
        libreoffice-fresh \
        obsidian \
        okular \
        onlyoffice-bin \
        pdfarranger \
        qpdfview \
        simple-scan \
        thunderbird \
        wps-office \
        xournalpp
}

install_tier3

log_subsection "$(script_name) done"
