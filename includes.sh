#!/usr/bin/env bash

#
# get the folder the 'current' script (as called from) is working under, https://stackoverflow.com/questions/59895
#
function scriptdir() {
  echo "$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
}

[ -f $(scriptdir)/ps1.sh ] && source $(scriptdir)/ps1.sh || true # start aware prompt
[ -f $(scriptdir)/bash.sh ] && source $(scriptdir)/bash.sh || true
[ -f $(scriptdir)/java.sh ] && source $(scriptdir)/java.sh || true
[ -f $(scriptdir)/php.sh ] && source $(scriptdir)/php.sh || true
[ -f $(scriptdir)/js.sh ] && source $(scriptdir)/js.sh || true
[ -f $(scriptdir)/virtualize.sh ] && source $(scriptdir)/virtualize.sh || true
[ -f $(scriptdir)/apps.sh ] && source $(scriptdir)/apps.sh || true
[ -f $(scriptdir)/scm.sh ] && source $(scriptdir)/scm.sh || true

export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
export HISTTIMEFORMAT='%F %T '

# align to linux and connect as postgres by default
export PGHOST=localhost
export PGUSER=postgres
export PGDATABASE=postgres
export PGVERSION=9.5 # this is not a standard PG ENV VAR
[ -e /usr/local/opt/postgresql@${PGVERSION} ] && export PATH="/usr/local/opt/postgresql@${PGVERSION}/bin:$PATH"
[ -e /usr/local/opt/postgresql@${PGVERSION} ] && export LDFLAGS="-L/usr/local/opt/postgresql@${PGVERSION}/lib"
[ -e /usr/local/opt/postgresql@${PGVERSION} ] && export CPPFLAGS="-I/usr/local/opt/postgresql@${PGVERSION}/include"

