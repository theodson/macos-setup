#!/usr/bin/env bash
# #########################################################
# Ad Hoc script - not under version control - useful for private settings.

# Overrides Workspace location - used in 'op' command
export WORKSPACE=~/Workspace

alias vagrant="HOMESTEADVM='centos' vagrant"

function _switch_php_pre_tasks() {
    [ $# -lt 1 ] && return 1
    phpver=$1
    verbose="${2:-0}"

    if [ "${phpver}" = 'php@7.0' ]; then
        [ "${verbose}" -eq 1 ] && echo " 🚩  Dyld fixing at (icu4c 64.2, openssl 1.0.2) for ${phpver}.";
        switch_icu4c64_2 &>/dev/null || echo " 🚩 - icu4c 64.2 missing - brew extract --version 64.2 -v -d --force icu4c bgdevlab/deprecated && HOMEBREW_NO_INSTALL_CLEANUP=true brew reinstall icu4c@64.2"
        switch_openssl1_0 &>/dev/null || echo " 🚩 - openssl 1.0.2 missing - brew extract --version 1.0 -v -d --force openssl bgdevlab/deprecated && HOMEBREW_NO_INSTALL_CLEANUP=true brew reinstall openssl@1.0"
    else
        [ "${verbose}" -eq 1 ] && echo " 🚩  Dyld reverting to (icu4c 67.1) for ${phpver}.";
        switch_icu4c67_1 &>/dev/null || echo " 🚩 - icu4c 67.1 missing - brew install icu4c -v"
    fi

}
export -f _switch_php_pre_tasks

function _switch_php_post_tasks() {
    [ $# -lt 1 ] && return 1
    phpver=$1
    verbose="${2:-0}"

    if [ "${phpver}" = 'php@7.0' ]; then
        [ "${verbose}" -eq 1 ] && echo " 🚩  Dyld fixing at (icu4c 64.2, openssl 1.0.2) for ${phpver}.";
        switch_icu4c64_2 &>/dev/null || echo " 🚩 - icu4c 64.2 missing - brew extract --version 64.2 -v -d --force icu4c bgdevlab/deprecated && HOMEBREW_NO_INSTALL_CLEANUP=true brew reinstall icu4c@64.2"
        switch_openssl1_0 &>/dev/null || echo " 🚩 - openssl 1.0.2 missing - brew extract --version 1.0 -v -d --force openssl bgdevlab/deprecated && HOMEBREW_NO_INSTALL_CLEANUP=true brew reinstall openssl@1.0"
        type -p nvm &>/dev/null && nvm use default
    else
        [ "${verbose}" -eq 1 ] && echo " 🚩  Dyld reverting to (icu4c 67.1) for ${phpver}.";
        switch_icu4c67_1 &>/dev/null || echo " 🚩 - icu4c 67.1 missing - brew install icu4c -v"
        type -p nvm &>/dev/null && nvm use stable && nvm
    fi
}
export -f _switch_php_post_tasks
