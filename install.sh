#!/usr/bin/env bash

# Caution is a virtue.
set -o nounset
set -o errtrace
set -o errexit
set -o pipefail

source "$(dirname $0)/output.sh"
source "$(dirname $0)/library.sh"
source "$(dirname $0)/virtualbox_wrapper.sh"
source "$(dirname $0)/unar_wrapper.sh"

EXIT_CODE=0

show_help() {
  cat << HelpDoc

	Usage: ievms install [versions] [options]

			--reuse-xp     Reuse a single Windows XP VM for browser installs.
		 --no-reuse-xp     Disable reusing the Windows XP VM.
		  --reuse-win7     Reuse a single Windows 7 VM for browser installs.
	   --no-reuse-win7     Disable reusing the Windows 7 VM.
HelpDoc
  exit $EXIT_CODE
}

build() {

}

install() {
	IFS=', ' read -a versions <<< "$1"
	local sleep_wait=$2
	local reuse_xp=$3
	local reuse_win7=$4
	local guest_user=$5
	local guest_pass=$6

	ensure_home
	check_system
	check_virtualbox
	check_unar

	for version in "${versions[@]}"; do
		build $version
	done
}

# Check for a supported host system (Linux/OS X).
check_system() {
	kernel=`uname -s`
	case $kernel in
		Darwin|Linux) ;;
		*) fail "Sorry, $kernel is not supported." ;;
	esac
}

main() {
	local args=${1:-""}
	local reuse_xp=${REUSE_XP:-true} # Reuse XP virtual machines for IE versions that are supported.
	local reuse_win7=${REUSE_WIN7:-true} # Reuse Win7 virtual machines for IE versions that are supported.
	local sleep_wait="5" # Timeout interval to wait between checks for various states.
	local guest_user="IEUser" # The VM user to use for guest control.
	local guest_pass="Passw0rd!" # The VM user password to use for guest control.

	# Pull install versions off the stack
	local versions="$args"
	shift

	# Parse options
	while [[ $# > 0 ]]; do
		key="$args"
		shift

		case $key in
			--reuse-xp)
				reuse_xp=true
				shift
			;;
			--no-reuse-xp)
				reuse_xp=false
				shift
			;;
			--reuse-win7)
				reuse_win7=false
				shift
			;;
			--no-reuse-win7)
				reuse_win7=false
				shift
			;;
			--h|--help)
				shift
			;;
			*)
				error "Unsupported option for install: '$args'"
				EXIT_CODE=1
				show_help
			;;
		esac
	done

	install $versions $sleep_wait $reuse_xp $reuse_win7 $guest_user $guest_pass
}

main "$@"
