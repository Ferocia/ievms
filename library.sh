#!/usr/bin/env bash

# Caution is a virtue.
set -o nounset
set -o errtrace
set -o errexit
set -o pipefail

source "$(dirname $0)/output.sh"

export IEVMS_INSTALL_PATH="${HOME}/.ievms"

# Create the ievms home folder and `cd` into it.
ensure_home() {
    info "Ensuring ievms install directory exists"
    if [ -d "$IEVMS_INSTALL_PATH" ]; then
      ok_status
    else
      fail_status
      puts $(info "Creating ievms install directory")
      mkdir -p "${IEVMS_INSTALL_PATH}"
      cd "${IEVMS_INSTALL_PATH}"
      PATH="${PATH}:${IEVMS_INSTALL_PATH}"
      # Move ovas and zips from a very old installation into place.
      mv -f ./ova/IE*/IE*.{ova,zip} "${IEVMS_INSTALL_PATH}/" 2>/dev/null || true
      puts $(info "Created ievms install directory at '${IEVMS_INSTALL_PATH}'")
    fi
}
