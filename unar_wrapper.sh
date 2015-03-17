#!/usr/bin/env bash

source "$(dirname $0)/output.sh"
source "$(dirname $0)/download.sh"

# Download and install `unar` from Google Code.
install_unar() {
    puts $(info "Installing unar")
    local url="http://theunarchiver.googlecode.com/files/unar1.5.zip"
    local archive=`basename "${url}"`

    download "unar" "${url}" "${archive}" "fbf544d1332c481d7d0f4e3433fbe53b"
    unzip -o "${archive}" || fail "Failed to extract '${archive}', unzip command returned error code $?"
    unar_exists || fail "Could not find unar"
}

# Check for the `unar` command, downloading and installing it if not found.
check_unar() {
    info "Checking for unar"
    if [ unar_exists ]
    then
        ok_status
    else
        fail_status
        if [ "${kernel}" == "Darwin" ]
        then
            install_unar
        else
            fail "Linux support requires unar (sudo apt-get install for Ubuntu/Debian)"
        fi
    fi
}

unar_exists() {
    hash unar 2>&-
}
