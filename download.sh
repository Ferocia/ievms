#!/usr/bin/env bash

source "$(dirname $0)/output.sh"

# Download a URL to a local file. Accepts a name, URL and file.
download() { # name url path md5
    local attempt=${5:-"0"}
    local max=${6:-"3"}

    let attempt+=1

    if [[ -f "${3}" ]]
    then
        info "Found '${1}' at '${3}' - skipping download" && echo
        check_md5 "${3}" "${4}" && return 0
        info "MD5 check failed - redownloading '${1}'" && echo
        rm -f "${3}"
    fi

    info "Downloading ${1} from ${2} to ${3} (attempt ${attempt} of ${max})" && echo
    curl --progress-bar -L "${2}" -o "${3}" || fail "Failed to download ${2} to ${ievms_home}/${3} using 'curl', error code ($?)"
    check_md5 "${3}" "${4}" && return 0

    if [ "${attempt}" == "${max}" ]
    then
        fail "Failed to download ${2} to ${ievms_home}/${3} (attempt ${attempt} of ${max})"
    fi

    info "Redownloading ${1}" && echo
    download "${1}" "${2}" "${3}" "${4}" "${attempt}" "${max}"
}

check_md5() {
    local md5

    case $kernel in
        Darwin) md5=`md5 "${1}" | rev | cut -c-32 | rev` ;;
        Linux) md5=`md5sum "${1}" | cut -c-32` ;;
    esac

    if [ "${md5}" != "${2}" ]
    then
        warn "MD5 check failed for '${1}' (wanted '${2}', got '${md5}')" && echo
        return 1
    fi

    info "MD5 check succeeded for ${1}" && echo
}
