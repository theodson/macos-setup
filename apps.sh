#!/usr/bin/env bash

# #########################################################
#    Apps / Brew

# https://www.jetbrains.com/help/phpstorm/10.0/working-with-phpstorm-features-from-command-line.html
# see 'Install Command Link Launcher from within the app itself.' /usr/local/bin/pstorm

alias pstorm='phpstorm'
alias diff_with_phpstorm='phpstorm diff'

alias smartgit="launchSmartGit $1"


function launchSmartGit() {

  if [ $1 ]; then
    dir="$1"
  else 
    #echo -e "$(echo_color red)You need to supply a directory argument.${echo_normal}"
    #return
    dir=`pwd`
  fi

  if [ ! -d ${dir} ]; then
    echo -e "$(echo_color red)'${dir}' is not a valid directory.${echo_normal}"
    return
  fi

  pushd "$dir" 1>/dev/null
  git rev-parse --is-inside-work-tree &>/dev/null
  if [ $? -eq 0 ]; then
    local app="/Applications/SmartGit.app/Contents/MacOS/SmartGit"
    echo nohup "${app}" --log "${1}"
    nohup "${app}" --log "${1}" &>/dev/null &
  else
    echo -e "$(echo_color red)'${dir}' is not a GIT directory.${echo_normal}"
  fi
  popd 1>/dev/null
  
}