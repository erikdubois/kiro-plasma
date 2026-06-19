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
#   - Tier 3 "unlikely" - user apps that are nice to have but most people will not
#     reach for on a default Plasma box: office suites, email clients, note apps,
#     extra PDF tools, scanning, plus a handful of Qt/neutral utilities.
#   - None are present in the minimal Kiro Plasma ISO build. Same rules: no
#     X11-only, no non-Plasma desktop apps, no development tooling.
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
        font-manager \
        gcolor3 \
        gscan2pdf \
        hardinfo2 \
        isoimagewriter \
        kamoso \
        kcharselect \
        kclock \
        kdiskmark \
        kfind \
        kmag \
        kmail \
        kweather \
        libreoffice-fresh \
        neochat \
        nomacs \
        obsidian \
        onboard \
        onlyoffice-bin \
        orca \
        pacmanlogviewer \
        pdfarranger \
        pika-backup \
        qalculate-qt \
        qpdfview \
        resources \
        shortwave \
        simple-scan \
        skanpage \
        system-config-printer \
        thunderbird \
        timeshift \
        upscayl-bin \
        vorta \
        xournalpp
}

install_tier3

log_subsection "$(script_name) done"
