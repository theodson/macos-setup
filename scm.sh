#!/usr/bin/env bash

# #########################################################
#    Version Control 

# Source Control Git 
alias gittree='git log --branches --remotes --tags --graph --pretty=format:"%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit --date=relative'
alias git_local_only_branches='git branch -vv | cut -c 3- | awk '"'"'$3 !~/\[/ { print $1 }'"'"'| sort -f' # Show Local Only Branches (those that dont exist in origin/remote)
alias git_tag_history='~/bin/tag_history.sh' # generate git tag history

# alias nah='git reset --hard; git clean -df' # Gone forever - Reset to last commit and remove untracked files and directories.
alias nah='try nope - nah is too dangerous'

# Recover with git reflog - Reset to last commit and remove untracked files and directories.
alias nope='git reset --hard'

function init_global_gitignore() {
    # ensure the default ignores are in place - no need to add these to each project's .gitignore
    git config --global core.excludesfile  ~/.bash/.global.gitignore
}
init_global_gitignore