#!/usr/bin/env bash
#
# 2021-05-04
# - Valet is used to switch PHP versions
# - CGR - rely on manual control of indpendent composer installation per php version, might get around need for CGR
#
export USE_VALET_SWITCH_PHP=1
export USE_CGR=0

export COMPOSER_HOME=$HOME/.composer # $(composer global config --absolute vendor-dir)
export COMPOSER_PROCESS_TIMEOUT=900  # default is COMPOSER_PROCESS_TIMEOUT=300
export COMPOSER_MEMORY_LIMIT=2G
export VALET_HOME_PATH="${HOME}/.config/valet"
echo $PATH | grep $COMPOSER_HOME &>/dev/null && true || export PATH="$PATH:$COMPOSER_HOME/vendor/bin" # add path if missing

#
VALET_VERSION=laravel/valet:^2.15
export COMPOSER_DEPS_INSTALL="${COMPOSER_DEPS_INSTALL:-consolidation/cgr laravel/installer tightenco/takeout $VALET_VERSION jorijn/laravel-security-checker}"
export COMPOSER_DEPS_UNINSTALL="${COMPOSER_DEPS_UNINSTALL:-hirak/prestissimo deployer/deployer $COMPOSER_DEPS_INSTALL}"

# conveniences
alias easytimenow='date +%Y%m%d_%H%M_%s'
alias php_version='php -r "echo PHP_VERSION;" | cut -d. -f-2' # current php version

# switch between php versions - since 2021-05 using valet use php@n.n
alias sphp70='switch_php 7.0'
alias sphp72='switch_php 7.2'
alias sphp73='switch_php 7.3'
alias sphp74='switch_php 7.4'
alias sphp80='switch_php 8.0'

# Laravel
alias artisan='php artisan'
alias tinker='php artisan tinker'
alias sail='bash vendor/bin/sail'

# PHPDeployer - https://deployer.org
alias dep='vendor/bin/dep'                    # no global install - (composer 2 issue) - use project's vendor install.
alias prov='APP_ENV=deployer dep -f=prov.php' # custom deployer command for provisioning

# PhpUnit
alias phpspec='/usr/local/bin/phpspec'
#alias phpunit='/usr/local/bin/phpunit'
#alias phpunit='vendor/bin/phpunit --log-junit scratch/phpunit_release_report.$(date "+%Y_%m_%d.%H%M%S").xml'
#alias phpunit='vendor/bin/phpunit --testdox-xml scratch/phpunit_release_report.testdox.$(date "+%Y_%m_%d.%H%M%S").xml'

# support env var 'phpunitpart' as part of the filename
#alias phpunit='vendor/bin/phpunit --log-junit scratch/phpunit_$(echo ${phpunitpart:-report}).$(date "+%Y_%m_%d.%H%M%S").xml'
alias phpunit='vendor/bin/phpunit --log-junit $(echo ${phpunitdir:-scratch})/phpunit_$(echo ${phpunitpart:-report}).xml'

function require_composer() {
  composer -V &>/dev/null && true || {
    echo " 🎼 Install Composer for php($(php_version))"
    curl -sS https://getcomposer.org/installer | php -- --install-dir=$HOME/bin/ --filename=composer --version=2.0.13
    composer self-update
    composer global dump
    # composer global require $VALET_VERSION &>/dev/null || echo "cannot install laravel/valet"
  }
}

function require_valet() {
  # optional arg1 is PHP Version in n.n format
  require_composer

  # remove older
  /bin/rm -f $(brew --prefix)/bin/valet &>/dev/null

  # Valet::symlinkToUsersBin handles creating this, called as part of command 'valet install'.
  # Possible issue with that valet command is installed into a global space '/usr/local/bin/valet' that is symlinked to
  update_composer_global
  composer global require $VALET_VERSION || return 1
  valet trust || return 1
}

# Laravel
function clearall() {
  [ ! -e ./artisan ] && echo "no artisan" && return
  artisan cache:clear
  artisan config:clear
  artisan route:clear
  [ "$1" == 'oc' ] && artisan opcache:clear || echo -e "Skipping: artisan opcache:clear ( use argument 'oc' ) "
  artisan optimize
}

# autocomplete - PHP - Deployer - add auto-complete for our prov alias
type -t _deployer ^ >/dev/null && complete -o default -F _deployer prov

#
# autocomplete - Laravel - Artisan - https://gist.github.com/jhoff/8fbe4116d74931751ecc9e8203dfb7c4
#
_artisan() {
  COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
  COMMANDS=$(php artisan --raw --no-ansi list | sed "s/[[:space:]].*//g")
  COMPREPLY=($(compgen -W "$COMMANDS" -- "${COMP_WORDS[COMP_CWORD]}"))
  return 0
}
complete -F _artisan art
complete -F _artisan artisan

#
# provision autocomplete
#
_prov() {
  COMP_WORDBREAKS=${COMP_WORDBREAKS//:/}
  COMMANDS=$(dep -f=prov.php --raw --no-ansi list | sed "s/[[:space:]].*//g")
  COMPREPLY=($(compgen -W "$COMMANDS" -- "${COMP_WORDS[COMP_CWORD]}"))
  return 0
}
complete -F _prov prov

#
# test
#
function imagick_test() {

  if [ $# -ne 1 ]; then
    echo "usage: ${FUNCNAME[0]} filename"
    return 1
  fi
  outputfile=$1
  php <<"IMAGICK_TEST" >$outputfile
<?php
$im = new Imagick();
$im->newPseudoImage(650, 250, "gradient:red-black");
$im->setImageFormat('png');
header("Content-Type: image/png");
echo $im;
IMAGICK_TEST
  file $outputfile | grep 'PNG image data'
  return $?
}

function backup_valet_config() {
  # backup any existing composer global definitions.
  backup_config="$HOME/backup_composer_and_valet_config.$(easytimenow).tar.gz"
  tar -czf $backup_config $(composer global config --absolute home 2>/dev/null)/config.json $HOME/.valet $HOME/.config/valet &>/dev/null
  [ -e "$backup_config" ] && {
    echo "👍 backup of composer and valet configuration completed - see $backup_config"
  } || {
    echo "👎 backup of composer and valet configuration ($backup_config) FAILED"
  }
}

#
# uninstall_valet valet_uninstall
#
function uninstall_valet() {
  echo "start:  ${FUNCNAME[0]}"

  backup_valet_config

  echo "🤞 uninstall valet"
  type -p valet &>/dev/null && valet uninstall --force --no-interaction

  composer global remove laravel/valet &>/dev/null || echo 'valet not installed via composer global'
  cgr remove laravel/valet &>/dev/null || echo 'valet not installed with cgr'

  echo "🤞 uninstall brew services"
  for formula in dnsmasq nginx; do
    sudo brew services stop $formula &>/dev/null
    sudo brew uninstall --force --ignore-dependencies "$formula" &>/dev/null || sudo rm -rf /usr/local/Cellar/$formula
    brew uninstall --force --ignore-dependencies "$formula" &>/dev/null || sudo rm -rf /usr/local/Cellar/$formula
  done

  echo "🤞 force tidyup of empty brew formula directories"
  find /usr/local/Cellar -type d -empty -maxdepth 1 -exec rm -rf {} \;

  [ -d ~/.valet ] && sudo rm -r ~/.valet &>/dev/null
  [ -d ~/.config/valet ] && sudo rm -r ~/.config/valet &>/dev/null

  echo "🤞 force tidyup of php / pecl / pear directories"
  sudo rm -rf /usr/local/etc/php/* /private/tmp/pear/* /usr/local/lib/php/* /usr/local/share/php* /usr/local/share/pear* &>/dev/null
  sudo rm -rf /private/tmp/pear/ &>/dev/null

  brew cleanup -q &>/dev/null
  echo "finish: ${FUNCNAME[0]}"
}

#
# uninstall_php php_uninstall
#
function uninstall_php() {
  echo "start:  ${FUNCNAME[0]}"
  brew untap -q bgdevlab/php-ext &>/dev/null             # remove conflicting tap
  brew untap -q bgdevlab/homebrew-deprecated &>/dev/null # remove conflicting tap

  # all php versions will be uninstalled when running valet uninstall --force
  uninstall_valet

  for formula in $(brew ls --formula -1 | egrep '^php|^imap@|^imagick'); do
    brew uninstall --force --ignore-dependencies "$formula"
  done

  for formula in $(brew services list | grep '^php' | cut -d' ' -f1); do
    brew services stop $formula &>/dev/null
    brew services remove $formula &>/dev/null
    sudo brew services stop $formula &>/dev/null
    sudo brew services remove $formula &>/dev/null
  done

  # force tidyup of empty brew formula directories
  find /usr/local/Cellar -type d -empty -maxdepth 1 -exec rm -rf {} \;

  sudo rm -rf /usr/local/Cellar/php@* /usr/local/Cellar/php

  sudo /bin/rm -f $(brew --prefix)/bin/valet &>/dev/null

  brew cleanup -q &>/dev/null

  uninstall_composer_global $COMPOSER_DEPS_UNINSTALL

  echo "finish: ${FUNCNAME[0]}"

}

function cleanup_valet_phpfpm() {
  echo " 🚕 valet php-fpm - brew services cleanup"
  phpversion=$1 # in php@7.1 format
  # look for 2 or more php-fpm, favour the one running as root (as valet runs as root).

  # valet runs php-fpm as root checks
  launchdaemon="/Library/LaunchDaemons/homebrew.mxcl.${phpversion}.plist"
  sudo launchctl list homebrew.mxcl.${phpversion} && echo "👍 valet runs php-fpm as root - check SUCCESS " || echo "👎 valet runs php-fpm as root - check FAILED"
  [ -e "$launchdaemon" ] && true || echo "👎 cannot find launchd control file for (system) php-fpm $launchdaemon"

  # report on any user specific valet checks
  launchagent=~/Library/LaunchAgents/homebrew.mxcl.${phpversion}.plist
  launchctl list homebrew.mxcl.${phpversion} && echo "👎 valet runs php-fpm as root - you have a (user) specific LaunchAgent " || true
  [ -e $launchagent ] && {
    echo "👎 found launchd control file for (user)  php-fpm $launchagent"
    cp $launchagent ~/.${launchagent}.backup &>/dev/null && echo -e "\narchived php-fpm (user) specific launchagent to ~/.${launchagent}.backup\n"
  } || true

  # remove user specific php-fpm ONLY if system launchdaemon of same name-version exists ( e.g. can't have two php-fpm@7.0 running )
  sudo launchctl list homebrew.mxcl.${phpversion} &>/dev/null && {
    launchctl list homebrew.mxcl.${phpversion} &>/dev/null && launchctl remove homebrew.mxcl.${phpversion} && echo "👍 removed (user) specific launchagent" || false
  } || true

}

#
#
#
function install_composer_global() {
  require_composer

  # show existing root components
  printf "🎼 existing composer global components\n"
  composer global show -D

  [ $# -gt 0 ] && _components="$@" || _components="$COMPOSER_DEPS_INSTALL" # default if no args passed.
  for tidyfile in vendor/composer/platform_check.php composer.json composer.lock; do
    # switching between PHPVersions impacts platform dependent 'platform_check.php' settings and related version resolution
    # for the composer global composer.json file, remove the generated files and rerun is safest approach.
    rm -f $COMPOSER_HOME/$tidyfile &>/dev/null
  done
  composer global dump &>/dev/null # dump autoloader to generate 'platform_check.php'

  printf "🎼 installing composer global components\n"
  for component_version in $_components; do
    local component=$(echo "$component_version" | cut -d: -f1)
    local version=$(echo "$component_version" | cut -d: -f2)
    [ "${component}" = "${version}" ] && version='' || version=":$version" # fix version info

    if [[ "${USE_CGR}" -eq 1 ]]; then
      cgr update "${component}" &>/dev/null || cgr "${component}${version}"
    else
      composer global require --with-all-dependencies "${component}${version}" 2>/dev/null && {
        echo -e "composer global require (SUCCESS) : ${component}${version}"
      } || {
        echo -e "composer global require (FAIL)    : ${component}${version}"
      }
    fi
  done
  echo -e "🎼 composer global components"
  composer global show -D
  #
  #  # php 7.2+ only - above script lets it silently fail if not compatible.
  #  (($(echo "$(php_version) >= 7.2" | bc -l))) && {
  #    composer global show tightenco/takeout || composer global require tightenco/takeout
  #  }

}

#
#
#
function cleanup_composer_global() {

  backup_valet_config

  composer -V &>/dev/null || require_composer # we need composer to remove the packages passed to the function

  while [ $# -gt 0 ]; do
    component_version="$1"
    shift
    local component=$(echo "$component_version" | cut -d: -f1)
    local version=$(echo "$component_version" | cut -d: -f2)               # we'll disregard this
    [ "${component}" = "${version}" ] && version='' || version=":$version" # remove : if empty version info

    echo -e "Composer dependency remove  : $component_version"
    if [[ "${USE_CGR}" -eq 1 ]]; then
      composer global show -q consolidation/cgr &>/dev/null || composer global require consolidation/cgr -vvv
      cgr remove "${component}" &>/dev/null || true
    else
      composer global remove "${component}" &>/dev/null || true
    fi
  done

}

function uninstall_composer_global() {
  cleanup_composer_global $@
  find $HOME -type d -name '.composer' -maxdepth 1 -exec /bin/rm -rf {} \;
  rm -f $HOME/bin/composer &>/dev/null
  echo -e "Composer binary removed"
}

function update_composer_global() {
  # echo "🎼 Composer Global Update"
  #  rm -f $COMPOSER_HOME/vendor/composer/platform_check.php && echo "Removing platform_check.php" || true
  composer global update -q 2>/dev/null || true
}

function install_valet_overrides() {

  mkdir -p "${VALET_HOME_PATH}/Extensions/" &>/dev/null
  ln -nf "$(scriptdir)/valet/ValetPhpFpm.php" "${VALET_HOME_PATH}/Extensions/" && {
    echo "👍 Custom Valet PhpFpm class installed - this will override the default valet PhpFpm behaviour. See ${VALET_HOME_PATH}/Extensions/"
  } || {
    echo "👎 Custom Valet PhpFpm class failed to install at ${VALET_HOME_PATH}/Extensions/"
  }
}

function switch_php() {
  # https://laracasts.com/discuss/channels/general-discussion/issues-with-laravel-valet-when-installing-old-php-version
  # https://freek.dev/1185-easily-switch-php-versions-in-laravel-valet

  local phpversion=$1 # n.n format
  [[ $# -ne 1 ]] && {
    echo "function ${FUNCNAME}(php_version) - required use n.n style"
    return 1
  }
  # First, for our version of php in use prior to switching install valet and our customisations.
  require_valet
  install_valet_overrides

  # Next, we now have a default valet installed, we can use it to switch versions
  valetScript="$COMPOSER_HOME/vendor/laravel/valet/valet"
  echo "🚕  Switching php versions using valet : php@${phpversion}"
  [ -e "$valetScript" ] && {
    # Next - global update and install
    update_composer_global
    ${valetScript} install # this will likely install the most recent version of php before the requested one.
    #    ${valetScript} install &>/dev/null || echo "👎 Valet install failed"
    ${valetScript} use php@${phpversion} --force
  } || {
    echo "👎 composer require for valet failed to install at ${valetScript}"
  }

  # Next - global update and re-install as possible php version conflicts with existing global packages.
  install_composer_global

  # Next - add valet for the php version switched to
  require_valet # install valet if its missing.

  # Next - install valet
  [ -e $COMPOSER_HOME/laravel/valet/valet ] && $COMPOSER_HOME/laravel/valet/valet install

  # read -p "Press enter to continue ( about to run Valet Restart )"
  echo "🚕 Valet Restart"
  valet restart
  sudo brew services list

}

#
# php_install - run this once on new machine then switch_php v.v should be sufficient
#
function install_php() {
  echo "start:  ${FUNCNAME[0]}"
  # `2021-01-28 BigSur 11.1`
  # https://getgrav.org/blog/macos-catalina-apache-multiple-php-versions
  # https://github.com/shivammathur/homebrew-php
  # https://github.com/shivammathur/homebrew-extensions
  export VALET_HOME_PATH="${HOME}/.config/valet"

  brew untap -q bgdevlab/php-ext &>/dev/null             # remove conflicting tap
  brew untap -q bgdevlab/homebrew-deprecated &>/dev/null # remove conflicting tap

  # prepare for install
  # TEMP DISABLE - brew reinstall -q zlib libmemcached openldap libiconv jq pkg-config openssl icu4c | egrep '🍺|=>'
  # Valet and our ValetPhpFpm.php class now handle 'shivammathur/core', 'shivammathur/extensions' and PECL installations.

  install_composer_global $COMPOSER_DEPS_INSTALL

  # Next, install via valet via switch_php
  # Php installation should be handled by 'valet use' and 'valet install' command since laravel/valet:^2.15
  switch_php 7.0

  brew install -q openssl | egrep '🍺|=>' # pecl required refresh of certificates

  sudo rm -rf /private/tmp/pear/ &>/dev/null

  # macos valet and php switcher (not sure of conflicts with switch-php, if any)
  brew tap nicoverbruggen/homebrew-cask | egrep '🍺|=>'
  brew install --cask phpmon

  imagick_test /private/tmp/imagick_test.php${phpVer}.png && echo "imagick correctly installed - see /private/tmp/imagick_test.php${phpVer}.png" || echo 'imagick issue exists'

  echo "finish: ${FUNCNAME[0]}"
}
