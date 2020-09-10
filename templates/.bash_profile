#!/usr/bin/env bash
export phpversions="7.2 7.4"

# Read ~/.profile as ~/.bash_profile makes ~/.profile obsolete and ignores it
[ -f ~/.credentials ] && source ~/.credentials
[ -f ~/.profile ] && source ~/.profile
[ -f ~/.bash/includes.sh ] && source ~/.bash/includes.sh
[ -f ~/.bash/adhoc.sh ] && source ~/.bash/adhoc.sh

export PATH="${PATH}:~/bin:/usr/local/bin:/usr/local/sbin" # keep me at the end of scripts
