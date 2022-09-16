#!/usr/bin/env bash

# Based off lib/core.sh `fetch_stage3_archive_name()`
# Fetch latest portage snapshot archive name/type, returns exit signal 3 if no archive could be found
function fetch_portage_archive_name() {
    __fetch_portage_archive_name=
    local portage_url portage_regex remote_files remote_line remote_date remote_file_type max_cap
    portage_url="http://distfiles.gentoo.org/snapshots/"
    readarray -t remote_files <<< "$(wget -qO- "${portage_url}")"
    remote_date=0
    get_stage3_archive_regex "portage"
    # shellcheck disable=SC2154
    portage_regex="$__get_stage3_archive_regex"
    for remote_line in "${remote_files[@]}"; do
        if [[ "${remote_line}" =~ href=\"${portage_regex}\" ]]; then
            max_cap="${#BASH_REMATCH[@]}"
            is_newer_stage3_date "${remote_date}" "${BASH_REMATCH[$((max_cap-3))]}${BASH_REMATCH[$((max_cap-2))]}" \
                && { remote_date="${BASH_REMATCH[$((max_cap-3))]}${BASH_REMATCH[$((max_cap-2))]}";
                     remote_file_type="${BASH_REMATCH[$((max_cap-1))]}"; }
	    # We keep going to find the latest rather than the first
        fi
    done
    [[ "${remote_date//[!0-9]/}" -eq 0 ]] && return 3
    #__fetch_portage_archive_name="portage-${remote_date}.tar.${remote_file_type}"
    __fetch_portage_archive_name="${remote_date}"
}

function main() {
    #echo "kubler dir: ${_KUBLER_DIR}"
    #echo "current namespace: ${_NAMESPACE_DIR}"

    #echo "Finding latest portage"
    # We are abusing `fetch_stage3_archive_name()`
    ## shellcheck disable=SC2034
    #STAGE3_BASE="portage"
    ## shellcheck disable=SC2034
    #ARCH_URL="http://distfiles.gentoo.org/snapshots/"
    ## This will find the first
    #fetch_stage3_archive_name
    ## shellcheck disable=SC2154
    #echo "$__fetch_stage3_archive_name"

    # This will find the latest
    fetch_portage_archive_name
    echo "$__fetch_portage_archive_name"
}

main "$@"
