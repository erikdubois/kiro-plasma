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
#   - Tier 1 "yes great" - the user apps you almost certainly want on top of the
#     minimal Kiro Plasma ISO build (Plasma + ohmychadwm, all apps deselected).
#   - Exclusion is checked against the real installed package list of that build,
#     so nothing here is already present. The minimal build ships NO browser and
#     no image/PDF/media viewer - those gaps are filled here.
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
        anydesk-bin \
        ark \
        brave-bin \
        chromium \
        claude-code \
        dolphin-plugins \
        filelight \
        firefox \
        flameshot-git \
        gimp \
        gwenview \
        inkscape \
        insync \
        kcalc \
        kdenetwork-filesharing \
        kdenlive \
        krita \
        lastpass \
        meld \
        mintstick \
        obs-studio \
        okular \
        signal-in-tray \
        spotify \
        sublime-text-4 \
        visual-studio-code-bin \
        vivaldi \
        vivaldi-ffmpeg-codecs \
        vlc \
        vlc-plugins-all \
        yakuake \
        zapzap

    # opera is AUR-only (not mirrored in chaotic-aur) - install via AUR helper
    install_aur_package opera
}

install_tier1

log_subsection "$(script_name) done"
