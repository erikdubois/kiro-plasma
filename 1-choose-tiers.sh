#!/usr/bin/env bash

##################################################################################################################################
# Author    : Erik Dubois
# Website   : https://www.erikdubois.be
# Youtube   : https://youtube.com/erikdubois
##################################################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
##################################################################################################################################

set -Euo pipefail
shopt -s nullglob

WORKING_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "${WORKING_DIR}/common/common.sh"

##################################################################################################################################
# Purpose
# - Interactive picker for the Kiro Plasma tier scripts (100/200/300/400/500).
# - Discovers the numbered tier scripts, shows a checklist via dialog/whiptail.
# - Lets you select one or more tiers, install all at once, or just describe them.
# - Uses the shared logging / helper functions from common/common.sh.
##################################################################################################################################

ALL_OPTION="__ALL__"
DESCRIBE_OPTION="__DESCRIBE__"

get_dialog_bin() {
    command -v dialog || command -v whiptail
}

# Discover the numbered tier scripts in the repo root (skip 0-* and 1-* launchers).
collect_scripts() {
    local file base
    for file in "${WORKING_DIR}"/[1-9]*-*.sh; do
        [[ -f "${file}" ]] || continue
        base="$(basename "${file}")"
        [[ "${base}" == 1-* ]] && continue
        printf '%s\n' "${base}"
    done | sort
}

build_menu_items() {
    local script desc
    local items=()

    items+=( "${ALL_OPTION}"      "Install all tiers"                              "OFF" )
    items+=( "${DESCRIBE_OPTION}" "Describe selected tiers (don't run anything)"   "OFF" )

    for script in "$@"; do
        desc="$(extract_purpose "${WORKING_DIR}/${script}" | head -1)"
        desc="${desc:0:60}"
        items+=( "${script}" "${desc}" "OFF" )
    done

    printf '%s\n' "${items[@]}"
}

show_checklist() {
    local dialog_bin="$1"
    shift

    local height=20
    local width=80
    local list_height=15

    if [[ "$(basename "${dialog_bin}")" == "dialog" ]]; then
        "${dialog_bin}" \
            --stdout \
            --checklist "Select Kiro Plasma tiers to install:" \
            "${height}" "${width}" "${list_height}" \
            "$@"
    else
        "${dialog_bin}" \
            --separate-output \
            --checklist "Select Kiro Plasma tiers to install:" \
            "${height}" "${width}" "${list_height}" \
            "$@" 3>&1 1>&2 2>&3
    fi
}

parse_selected_items() {
    local dialog_bin="$1"
    local selected_raw="$2"
    local item
    local -a parsed=()

    if [[ "$(basename "${dialog_bin}")" == "dialog" ]]; then
        eval "parsed=( ${selected_raw} )"
        printf '%s\n' "${parsed[@]}"
    else
        while IFS= read -r item; do
            [[ -n "${item}" ]] && printf '%s\n' "${item}"
        done <<< "${selected_raw}"
    fi
}

expand_all_selection() {
    local item
    local -a scripts=( "$@" )
    local all_selected=false

    for item in "${scripts[@]}"; do
        if [[ "${item}" == "${ALL_OPTION}" ]]; then
            all_selected=true
            break
        fi
    done

    if [[ "${all_selected}" == true ]]; then
        collect_scripts
    else
        printf '%s\n' "${scripts[@]}"
    fi
}

run_selected_scripts() {
    local script
    for script in "$@"; do
        log_subsection "Running ${script}"
        bash "${WORKING_DIR}/${script}"
    done
}

describe_selected_scripts() {
    local script purpose
    for script in "$@"; do
        log_subsection "${script}"
        purpose="$(extract_purpose "${WORKING_DIR}/${script}")"
        if [[ -z "${purpose}" ]]; then
            printf '  (no Purpose block — read the script directly)\n'
        else
            printf '%s\n' "${purpose}" | sed 's/^/  - /'
        fi
    done
}

is_describe_selected() {
    local item
    for item in "$@"; do
        [[ "${item}" == "${DESCRIBE_OPTION}" ]] && return 0
    done
    return 1
}

filter_out_describe_and_all() {
    local item
    for item in "$@"; do
        [[ "${item}" == "${DESCRIBE_OPTION}" ]] && continue
        [[ "${item}" == "${ALL_OPTION}" ]]      && continue
        printf '%s\n' "${item}"
    done
}

main() {
    local dialog_bin selected_raw
    local -a scripts=() menu_items=() selected=() expanded_selected=()

    mapfile -t scripts < <(collect_scripts)

    dialog_bin="$(get_dialog_bin)"
    [[ -n "${dialog_bin}" ]] || { log_warn "dialog or whiptail required"; exit 1; }

    (( ${#scripts[@]} > 0 )) || { log_warn "No tier scripts found in ${WORKING_DIR}"; exit 1; }

    mapfile -t menu_items < <(build_menu_items "${scripts[@]}")

    selected_raw="$(show_checklist "${dialog_bin}" "${menu_items[@]}")" || exit 0

    mapfile -t selected < <(parse_selected_items "${dialog_bin}" "${selected_raw}")

    (( ${#selected[@]} > 0 )) || { log_warn "No tiers selected"; exit 0; }

    if is_describe_selected "${selected[@]}"; then
        local -a to_describe=()
        mapfile -t to_describe < <(filter_out_describe_and_all "${selected[@]}")
        if (( ${#to_describe[@]} == 0 )); then
            mapfile -t to_describe < <(collect_scripts)
        fi
        log_section "Describing ${#to_describe[@]} tier(s) — nothing will run"
        describe_selected_scripts "${to_describe[@]}"
        exit 0
    fi

    mapfile -t expanded_selected < <(expand_all_selection "${selected[@]}")

    (( ${#expanded_selected[@]} > 0 )) || { log_warn "No tiers selected"; exit 0; }

    run_selected_scripts "${expanded_selected[@]}"
}

main "$@"
