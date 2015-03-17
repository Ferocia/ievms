#!/usr/bin/env bash

red=`tput setaf 1`
yellow=`tput setaf 3`
green=`tput setaf 2`
reset=`tput sgr0`

puts() {
  echo -e "$@"
}

print() {
  printf "$@"
}

info() {
  print "[ievms][INFO] $@"
}

warn() {
  print "${yellow}[ievms][WARN] $@${reset}"
}

error() {
  print "${red}[ievms][ERROR] $@${reset}"
}

fail() {
  echo ""
  puts $(error "$@")
  exit 1
}

ok_status() {
  puts " [ ${green}OK${reset} ]"
}

fail_status() {
  puts " [ ${red}FAIL${reset} ]"
}
