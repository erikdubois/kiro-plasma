#!/usr/bin/env bash

##################################################################################################################
# Author    : Erik Dubois
# Website   : https://www.erikdubois.be
# Youtube   : https://youtube.com/erikdubois
# Github    : https://github.com/erikdubois
# Github    : https://github.com/kirodubes
##################################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
#   Purpose:
#   - Orchestrator for the Kiro Plasma extra-software setup.
#   - Assumes you are already on a minimal Kiro Plasma ISO install: Plasma is
#     present and nemesis_repo / repos are configured. It does NOT set up repos,
#     route non-Arch systems or install the desktop itself.
#   - It only adds extra user apps on top of the minimal ISO, grouped in tiers:
#       100 Tier 1 - yes great      (enabled by default)
#       200 Tier 2 - maybe          (commented - enable if wanted)
#       300 Tier 3 - unlikely       (commented - enable if wanted)
#       400 Tier 4 - could not place (commented - enable if wanted)
#       500 Kiro Plasma integration (enabled by default)
#
#   Enable or disable a tier by commenting / uncommenting its run_glob line.
#   For an interactive picker instead, run ./1-choose-tiers.sh
#
##################################################################################################################

export DEBUG=false

WORKING_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
echo "Working directory             : ${WORKING_DIR}"

source "${WORKING_DIR}/common/common.sh"

log_section "Running $(script_name)"

# This setup only makes sense on a Plasma system.
if ! is_plasma_installed; then
    log_warn "Plasma is not installed - this setup targets a Kiro Plasma ISO. Aborting."
    exit 1
fi

###################################################################################
# Numbered tier pipeline. Comment / uncomment to taste.
###################################################################################
log_warn "Start of the tier scripts - comment lines you do not want"

run_glob "${WORKING_DIR}/100-*"   # Tier 1 - yes great
# run_glob "${WORKING_DIR}/200-*" # Tier 2 - maybe
# run_glob "${WORKING_DIR}/300-*" # Tier 3 - unlikely
# run_glob "${WORKING_DIR}/400-*" # Tier 4 - could not place

run_glob "${WORKING_DIR}/500-*"   # Kiro Plasma integration

log_warn "End current choices"
