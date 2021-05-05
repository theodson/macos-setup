#!/usr/bin/env bash

# #########################################################
#    JS Node NPM

alias fixjs='rm -rf node_modules/;npm cache clear --force && npm install'
alias ng='npm list -g --depth=0'
alias nl='npm list --depth=0'

# yarn 
export PATH="$HOME/.yarn/bin:$PATH"

# nvm - node version manager
export NVM_DIR="$HOME/.nvm"
[ -e $NVM_DIR ] || echo "NVM is not installed - try 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash'"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"
[ -s "/usr/local/opt/nvm/etc/bash_completion" ] && . "/usr/local/opt/nvm/etc/bash_completion"

alias switch-js='nvm'

function js_env_install() {
    type -p node || brew install node
    type -p yarn || brew install yarn
    type -p nvm || curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
    nvm use stable || nvm install stable

    nvm use stable && npm install twilio-cli -g
}