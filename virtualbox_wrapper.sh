#!/usr/bin/env bash

source "$(dirname $0)/output.sh"
source "$(dirname $0)/download.sh"

# Ensure VirtualBox is installed and `VBoxManage` is on the `PATH`.
check_virtualbox() {
    info "Checking for VirtualBox"
    hash VBoxManage 2>&- || fail "VirtualBox command line utilities are not installed, please (re)install! (http://virtualbox.org)"
    ok_status
    check_virtualbox_extensions
}

# Check for the VirtualBox Extension Pack and install if not found.
check_virtualbox_extensions() {
    info "Checking for Oracle VM VirtualBox Extension Pack"

    if [[ ! "$(VBoxManage list extpacks)" =~ "Oracle VM VirtualBox Extension Pack" ]];
    then
        check_version
        local archive="Oracle_VM_VirtualBox_Extension_Pack-${major_minor_release}.vbox-extpack"
        local url="http://download.virtualbox.org/virtualbox/${major_minor_release}/${archive}"
        local md5s="https://www.virtualbox.org/download/hashes/${major_minor_release}/MD5SUMS"
        local md5=`curl -L "${md5s}" | grep "${archive}" | cut -c-32`

        download "Oracle VM VirtualBox Extension Pack" "${url}" "${archive}" "${md5}"

        info "Installing Oracle VM VirtualBox Extension Pack from ${ievms_home}/${archive}"
        VBoxManage extpack install "${archive}" || fail "Failed to install Oracle VM VirtualBox Extension Pack from ${ievms_home}/${archive}, error code ($?)"
    else
        ok_status
    fi
}

# Determine the VirtualBox version details, querying the download page to ensure
# validity.
check_version() {
    local version=`VBoxManage -v`
    major_minor_release="${version%%[-_r]*}"
    local major_minor="${version%.*}"
    local dl_page=`curl ${curl_opts} -L "http://download.virtualbox.org/virtualbox/" 2>/dev/null`

    if [[ "$version" == *"kernel module is not loaded"* ]]; then
        fail "$version"
    fi

    for (( release="${major_minor_release#*.*.}"; release >= 0; release-- ))
    do
        major_minor_release="${major_minor}.${release}"
        if echo $dl_page | grep "${major_minor_release}/" &>/dev/null
        then
            info "Virtualbox version ${major_minor_release} found."
            break
        else
            info "Virtualbox version ${major_minor_release} not found, skipping."
        fi
    done
}

# Pause execution until the virtual machine with a given name shuts down.
wait_for_shutdown() {
    while true ; do
        info "Waiting for ${1} to shutdown..."
        sleep "${sleep_wait}"
        VBoxManage showvminfo "${1}" | grep "State:" | grep -q "powered off" && return 0 || true
    done
}

# Pause execution until guest control is available for a virtual machine.
wait_for_guestcontrol() {
    while true ; do
        info "Waiting for ${1} to be available for guestcontrol..."
        sleep "${sleep_wait}"
        VBoxManage showvminfo "${1}" | grep 'Additions run level:' | grep -q "3" && return 0 || true
    done
}

# Attach a dvd image to the virtual machine.
attach() {
    info "Attaching ${3}"
    VBoxManage storageattach "${1}" --storagectl "IDE Controller" --port 1 \
        --device 0 --type dvddrive --medium "${2}"
}

# Eject the dvd image from the virtual machine.
eject() {
    info "Ejecting ${2}"
    VBoxManage modifyvm "${1}" --dvd none
}
