#!/usr/bin/env bash

# #########################################################
#    BASH

# Auto Complete
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion || echo -e "missing bash-completion, try\n\tbrew install bash-completion"
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

# Get VSCode extensions
alias codeextensions='code --list-extensions | xargs -L 1 echo code --install-extension'
alias subl=code

# conveniences
alias easytimenow='date +%Y%m%d_%H%M_%s'

# Emotes
alias shrug="echo '¯\_(ツ)_/¯' | pbcopy;echo '¯\_(ツ)_/¯'";
alias fight="echo '(ง'̀-'́)ง' | pbcopy;echo '(ง'̀-'́)ง'";

# Show/Hide hidden files in Finder
alias showhidden='defaults write com.apple.finder AppleShowAllFiles TRUE && killall Finder'
alias hidehidden='defaults write com.apple.finder AppleShowAllFiles FALSE && killall Finder'

# Force empty the trash
alias forceempty='sudo rm -rf ~/.Trash; sudo rm -rf /Volumes/*/.Trashes;'

# Filesystem
alias rm='rm -i'
alias ll='ls -lGfha'
# color=always causes more grief than its worth when pipelining commands
#alias grep='grep --color=always'

alias prettyjson='python -m json.tool'
alias nospace='egrep -v "^#|^[[:space:]]*$"'
alias no_commments_space='egrep -v "^;|^#|^[[:space:]]*$"'

alias ejectdisc='drutil tray eject'

alias pwdtail='pwd | rev | cut -d/ -f1-2 | rev'

alias switch-postgres='echo no option for switch-postgres yet - just run each version on different ports!'

# Add space tile to dock
function dockspace {
  defaults write com.apple.dock persistent-apps -array-add '{"tile-type"="spacer-tile";}'
  killall Dock
}


# macOs - what app is running on a port
function what_port() {
  if [ $# -ne 1 ]; then 
    echo "need to know the port"; 
    return 1;
  fi
  searchport=":$1 "
  echo "looking for '$searchport'"
  lsof -nP -iTCP -sTCP:LISTEN | grep "${searchport}"
#   ps -Ao user,pid,command | grep -v grep | grep $(netstat -anv | grep "$searchport " | awk '{print $9}')
}
alias whatport="what_port"


# Function to open specified project in projects folder
function op {
  echo "ENV(WORKSPACE):${WORKSPACE}"
  # to override use set WORKSPACE, e.g. WORKSPACE=~/Documents/Projects op
  rootfolder="${WORKSPACE:-~/Documents}"

  found=0 # 0 = Not Found; 1 = Found
  project="$1" # Name of project given
  repo="$2" # Name of repository given
  count=0 # Array counter

  # Following is in order of preference
  if [[ $repo != "" ]]; then # Change to project repo
    directories[$count]=${rootfolder}/${project}/${repo}; ((count++));
    directories[$count]=${rootfolder}/${project}*/${repo}*; ((count++));    
    directories[$count]=${rootfolder}/${project}*/bgdevlab-${repo}; ((count++));
  fi

  # Usually webapp is the common repo if no repo was specified
  directories[$count]=${rootfolder}/${project}/webapp; ((count++));
  directories[$count]=${rootfolder}/${project}/${project}; ((count++));
  directories[$count]=${rootfolder}/${project}/scratch; ((count++));
  directories[$count]=${rootfolder}/${project}; ((count++));
  directories[$count]=${rootfolder}/${project}*; ((count++));

  # Look for possible project folders and change into it if one found.
  for dir in ${directories[@]}; do
    if [[ -d $dir ]]; then
      found=1
      pushd $dir
      echo -e "Changed directory to: $(echo_color green)'$dir'${echo_normal}"
      break
    fi
  done

  # Was folder changed?
  if [[ $found == 0 ]]; then
    echo -e "$(echo_color red)Project directory not found.${echo_normal}"
  fi
}

# #########################################################
# Allow "tr" to process non-utf8 byte sequences, read random bytes and keep only alphanumerics
function genRandom() {
  length=${1:-32}
  LC_CTYPE=C tr -dc A-Za-z0-9 < /dev/urandom | head -c$length
}

# #########################################################
#   SSH keys

alias sshgen='ssh-keygen -t rsa'
alias sshkey='pbcopy < ~/.ssh/id_rsa.pub'

function sshrem() {
    # look at ssh-keyscan -H for another option
  if [ $# -lt 1 ]; then
    echo -e "missing argument: host[s]"
    return;
  fi
  for s in $@
  do
    echo -e "\n>> removing '$s'";
    for khfile in $(find ~/.ssh -regex '.*known_hosts[0-9]*$')
    do 
      target_server="${s}"
      target_server_ip=$(dig +search +short ${target_server})
      target_server_shortname=$(echo ${target_server} | cut -d. -f1)
      echo "Scanning : ${khfile} for '${target_server}', '${target_server_ip}', '${target_server_shortname}'"
      ssh-keygen -R ${target_server} -f ${khfile} &>/dev/null && echo "success removed $target_server" || echo "problem removing $target_server"
      ssh-keygen -R ${target_server_ip} -f ${khfile} &>/dev/null && echo "success removed $target_server_ip" || echo "problem removing $target_server_ip"
      ssh-keygen -R ${target_server_shortname} -f ${khfile} &>/dev/null && echo "success removed $target_server_shortname" || echo "problem removing $target_server_shortname"
    done
  done
}

function ssh_prepare_keyexchange() {
    # allow easy remote access - authorize key for current user
    if [ $# -lt 1 ]; then
        echo "args: host [user]"
        return 1;
    fi

    target_site=$1
    user="${2:-root}"

    for khfile in $(find ~/.ssh -regex '.*known_hosts[0-9]*$')
    do
        ssh-keyscan -H ${target_site} >> ${khfile}
    done
    ssh-copy-id ${user}@${target_site}

    #target_server="${s}";
    #target_server_ip=$(dig @${dns} +search  +short ${target_server});
    #target_server_shortname=$(echo ${target_server} | cut -d. -f1);
}

# #########################################################
#   Brew

# macOs - check for expected brew installs
function brew_check_installation() {
    for formula in httpie wget gettext htop bash-completion zlib jq pkg-config tree
    do
        if [ "" = "`brew ls --versions $forumla`" ]; then
            echo "install brew install $forumla"
        else
            desc=$(brew info --json $formula | jq '.[]|.desc')
            vers=$(brew info --json $formula | jq '.[]|.linked_keg')
            echo -e "${formula}, ${vers}, ${desc}"
        fi
    done
}