#!/usr/bin/env bash

# Read ~/.profile as ~/.bash_profile makes ~/.profile obsolete and ignores it
[ -f ~/.credentials ] && source ~/.credentials
[ -f ~/.profile ] && source ~/.profile
[ -f ~/.bash/includes.sh ] && source ~/.bash/includes.sh
[ -f ~/.bash/adhoc.sh ] && source ~/.bash/adhoc.sh

for binpath in ~/bin /usr/local/bin /usr/local/sbin;
do
  echo $PATH | grep $binpath &>/dev/null && true || export PATH="$PATH:$binpath" # add path if missing
done

