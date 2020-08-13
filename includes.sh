#!/usr/bin/env bash

[ -f ~/.bash/ps1.sh ] && source ~/.bash/ps1.sh || true # start aware prompt
[ -f ~/.bash/bash.sh ] && source ~/.bash/bash.sh || true
[ -f ~/.bash/java.sh ] && source ~/.bash/java.sh || true
[ -f ~/.bash/php.sh ] && source ~/.bash/php.sh || true
[ -f ~/.bash/js.sh ] && source ~/.bash/js.sh || true
[ -f ~/.bash/virtualize.sh ] && source ~/.bash/virtualize.sh || true
[ -f ~/.bash/apps.sh ] && source ~/.bash/apps.sh || true
[ -f ~/.bash/scm.sh ] && source ~/.bash/scm.sh || true

export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
export HISTTIMEFORMAT='%F %T '

# align to linux and connect as postgres by default
export PGHOST=localhost
export PGUSER=postgres
export PGDATABASE=postgres
export PGVERSION=9.5 # this is not a standard PG ENV VAR
[ -e /usr/local/opt/postgresql${PGVERSION} ] && export PATH="/usr/local/opt/postgresql${PGVERSION}/bin:$PATH"
[ -e /usr/local/opt/postgresql${PGVERSION} ] && export LDFLAGS="-L/usr/local/opt/postgresql${PGVERSION}/lib"
[ -e /usr/local/opt/postgresql${PGVERSION} ] && export CPPFLAGS="-I/usr/local/opt/postgresql${PGVERSION}/include"

export PATH="/usr/local/opt/postgresql@$PGVERSION/bin:${PATH}"

