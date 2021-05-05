#!/usr/bin/env bash
# #########################################################
# Ad Hoc script - not under version control - useful for private settings.

# Overrides Workspace location - used in 'op' command
export WORKSPACE=$HOME/Workspace

# As used in valet/ValetPhpFpm.php
export BREW_EXTENSIONS=''
export PECL_EXTENSIONS='redis|apcu|memcached'

alias vagrant="HOMESTEADVM='centos' vagrant"
