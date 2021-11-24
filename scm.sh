#!/usr/bin/env bash

# #########################################################
#    Version Control 

# Source Control Git
alias git_tree='git log --branches --remotes --tags --graph --pretty=format:"%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit --date=relative'
alias git_local_only_branches='git branch -vv | cut -c 3- | awk '"'"'$3 !~/\[/ { print $1 }'"'"'| sort -f' # Show Local Only Branches (those that dont exist in origin/remote)
alias git_credentials_show='echo -e "\n# git credentials (helper)";git credentials.helper;echo -e "\n# git credentials (global)";git credentials.global;echo -e "\n# git credentials (local)";git credentials.local'

alias git_find_branches_for_hash='git branch -a --contains'


# alias nah='git reset --hard; git clean -df' # Gone forever - Reset to last commit and remove untracked files and directories.
alias nah='try nope - nah is too dangerous'

# Recover with git reflog - Reset to last commit and remove untracked files and directories.
alias nope='git reset --hard'

# git alias
git config --global alias.logline "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
git config --global alias.credentials.helper "config --get-all --show-origin credential.helper"
git config --global alias.credentials.local "config --show-origin --local --get-regexp user.*"
git config --global alias.credentials.global "config --show-origin --global --get-regexp user.*"

# working with submodules - https://medium.com/@porteneuve/mastering-git-submodules-34c65e940407
git config --global status.submoduleSummary true
git config --global diff.submodule log

# debug git
alias git_debug="GIT_TRACE=true \
GIT_CURL_VERBOSE=true \
GIT_SSH_COMMAND=\"ssh -vvv\" \
GIT_TRACE_PACK_ACCESS=true \
GIT_TRACE_PACKET=true \
GIT_TRACE_PACKFILE=true \
GIT_TRACE_PERFORMANCE=true \
GIT_TRACE_SETUP=true \
GIT_TRACE_SHALLOW=true \
git $@"

# Git Credentials - Useful Articles for macOs
# https://coolaj86.com/articles/vanilla-devops-git-credentials-cheatsheet/
# https://git-scm.com/book/en/v2/Git-Tools-Credential-Storage
# https://www.shellhacks.com/git-config-username-password-store-credentials/
#
# https://opensource.apple.com/source/Git/Git-33/src/git/contrib/credential/osxkeychain/git-credential-osxkeychain.c.auto.html

function init_global_gitignore() {
    # ensure the default ignores are in place - no need to add these to each project's .gitignore
    git config --global core.excludesfile  ~/.bash/.global.gitignore
}
init_global_gitignore

function git_add_to_osxkeychain() {
    # https://opensource.apple.com/source/Git/Git-33/src/git/contrib/credential/osxkeychain/git-credential-osxkeychain.c.auto.html
    [ $# -lt 3 ] && { echo 'Usage: host username password'; return 1; }
    printf "protocol=https\nhost=%s\nusername=%s\npassword=%s\n" "$host" "$username" "$credential" | git "credential-osxkeychain" store
}

# alias git_tag_history='~/bin/tag_history.sh' # generate git tag history


function git_tag_relases_with_recent_commits() {
    # TODO _ THIS NEEDS WORK - duplicates appearing
    lastn="${1:-5}" # default to last 5 commits before TAG
    git for-each-ref --sort=creatordate --shell --format="ref=%(refname:short)
	obj=%(objectname:short)
	subj=%(*subject)" refs/tags | while read entry; do
    eval $entry;
    echo "

## $ref

**Released:** `git log -1 --date=format:'%Y %h %d' --format="%cd" $obj` ($obj)

$(git log -$lastn --date=format:'%Y %h %d' --format="  - %s" $obj)
"
done

}


function git_tag_relases() {
    git for-each-ref --sort=-creatordate --format '## %(refname)

**Released:**  %(creatordate) %(object:short) - %(*objectname:short)

   -  %(*subject)

' refs/tags | sed -e 's-refs/tags/--'

}

function git_tag_date_hash() {
    # git_tag_date_hash
     git for-each-ref --sort=creatordate --shell --format="ref=%(refname:short)
     obj=%(objectname:short)" refs/tags | while read entry;do eval $entry;echo "$ref,`git log -1 --date=format:'%Y %h %d' --format="%cd" $obj` ($obj)"| column -t -x -s ','; done
}

function git_tag_history() {
    [ $# -ne 2 ] && { echo "Usage: TAG_FROM TAG_TO"; return 1; }
    # show log entries between two tags
    git log ${1}...${2} --date=format:'%Y %h %d' --format="  - %s
    %an - %cd
"
}

function git_files_largest() {
    # https://gist.github.com/nk9/b150542ef72abc7974cb#gistcomment-3715010
    # requires 'brew install coreutils'
    git rev-list --objects --all | \
    git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | \
    sed -n 's/^blob //p' | \
    sort --numeric-sort --key=2 | \
    cut -c 1-12,41- | \
    $(command -v gnumfmt || echo numfmt) --field=2 --to=iec-i --suffix=B --padding=7 --round=nearest
}

function git_find_branches_for_file() {
    local search=$(printf "**/%s*" $1)
    echo "looking for $search"
    # echo $(git log --all -- $(printf "**/%s*" $1) | grep '^commit ')
    for hsh in $(git log --all -- $search | grep '^commit ' | awk '{print $2}'); do 
        git branch -a --contains $hsh; 
    done | sort | uniq
}
