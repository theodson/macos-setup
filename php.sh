#!/usr/bin/env bash

# #########################################################
#    PHP
# new sphp as of 2021-01-28 and using tap from shivammathur
alias sphp70='switch-php -v 7.0'
alias sphp72='switch-php -v 7.2'
alias sphp73='switch-php -v 7.3'
alias sphp74='switch-php -v 7.4'
alias sphp80='switch-php -v 8.0'

alias php-versions='brew ls --versions php@5{0..7} php@7.{0..5} php@8.{0..5}'

# Laravel Artisan 
alias artisan='php artisan'
alias tinker='php artisan tinker'

# PHPDeployer - https://deployer.org
alias dep='vendor/bin/dep' # no global install - (composer 2 issue) - use project's vendor install.
alias prov='APP_ENV=deployer dep -f=prov.php' # custom deployer command for provisioning

# PhpUnit
alias phpspec='/usr/local/bin/phpspec'
#alias phpunit='/usr/local/bin/phpunit'
#alias phpunit='vendor/bin/phpunit --log-junit scratch/phpunit_release_report.$(date "+%Y_%m_%d.%H%M%S").xml'
#alias phpunit='vendor/bin/phpunit --testdox-xml scratch/phpunit_release_report.testdox.$(date "+%Y_%m_%d.%H%M%S").xml'

# support env var 'phpunitpart' as part of the filename
#alias phpunit='vendor/bin/phpunit --log-junit scratch/phpunit_$(echo ${phpunitpart:-report}).$(date "+%Y_%m_%d.%H%M%S").xml'
alias phpunit='vendor/bin/phpunit --log-junit $(echo ${phpunitdir:-scratch})/phpunit_$(echo ${phpunitpart:-report}).xml'


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
type -t _deployer ^>/dev/null && complete -o default -F _deployer prov

# autocomplete - Laravel - Artisan - https://gist.github.com/jhoff/8fbe4116d74931751ecc9e8203dfb7c4
_artisan()
{
	COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
	COMMANDS=`php artisan --raw --no-ansi list | sed "s/[[:space:]].*//g"`
	COMPREPLY=(`compgen -W "$COMMANDS" -- "${COMP_WORDS[COMP_CWORD]}"`)
	return 0
}
complete -F _artisan art
complete -F _artisan artisan
 
_prov()
{
COMP_WORDBREAKS=${COMP_WORDBREAKS//:}
COMMANDS=`dep -f=prov.php --raw --no-ansi list | sed "s/[[:space:]].*//g"`
COMPREPLY=(`compgen -W "$COMMANDS" -- "${COMP_WORDS[COMP_CWORD]}"`)
return 0
}
complete -F _prov prov

# Ensure Composer Global is in the path
# consider using https://github.com/consolidation/cgr
export PATH="~/.composer/vendor/bin:$PATH"

# default is COMPOSER_PROCESS_TIMEOUT=300
export COMPOSER_PROCESS_TIMEOUT=900
export COMPOSER_MEMORY_LIMIT=2G


function composer_global_check_installation() {
    for dependency in consolidation/cgr laravel/valet laravel/installer
    do
        echo "TODO check composer install for $dependency" || true
    done
}

function imagick_test() {

    if [ $# -ne 1 ]; then
        echo "usage: ${FUNCNAME[0]} filename"
        return 1
    fi
    outputfile=$1
    php <<"IMAGICK_TEST" > $outputfile
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


function composer_global_install() {

    type -p composer &>/dev/null || brew install composer
    # composer global show -q hirak/prestissimo &>/dev/null || composer global require hirak/prestissimo -vvv
    composer global remove hirak/prestissimo || true
    composer global show -q consolidation/cgr &>/dev/null || composer global require consolidation/cgr -vvv

    # if they exist as global installs remove them as CGR will install them
    composer global remove deployer/deployer --ignore-platform-reqs &>/dev/null || true
    composer global remove laravel/valet --ignore-platform-reqs &>/dev/null || true
    composer global remove laravel/installer --ignore-platform-reqs &>/dev/null || true

    sphp70
    # use php70 as base dependency for these tools.
    # if using later versions of php when installing via composer/cgr then dependencies are matched there, hence when
    # switching back to lower version of php we encounter vender package issues.

    cgr update laravel/installer &>/dev/null || cgr laravel/installer
    cgr update laravel/valet &>/dev/null || cgr laravel/valet
    alias dep='vendor/bin/dep'

    # php 7.2+ only
    # cgr update tightenco/takeout &>/dev/null || cgr tightenco/takeout
}


function php_uninstall() {
  echo "start:  ${FUNCNAME[0]}"
  for formula in $(brew ls --formula -1 | egrep '^php|^imap@|^imagick'); do
    brew uninstall --force --ignore-dependencies "$formula"
  done

  for formula in $(brew services list | grep '^php' | cut -d' ' -f1); do
    brew services stop $formula &> /tmp/php_uninstall
    brew services remove $formula &> /tmp/php_uninstall
  done

  # force tidyup of empty brew formula directories
  find /usr/local/Cellar -type d -empty -maxdepth 1 -exec rm -rf {} \;

  sudo rm -rf /usr/local/Cellar/php@*

  brew cleanup
  echo "finish: ${FUNCNAME[0]}"
}


function valet_uninstall() {
  echo "start:  ${FUNCNAME[0]}"
  php_uninstall

  [ -e $HOME/.composer/composer.json ] && composer global remove laravel/valet || echo 'valet not installed via composer global'
  [ -e $HOME/.composer/global/laravel/valet/composer.json ] && cgr remove laravel/valet || echo 'valet not installed with cgr'

  for formula in dnsmasq nginx; do
      brew services stop $formula || sudo brew services stop $formula
      brew uninstall --force --ignore-dependencies "$formula" || sudo rm -rf /usr/local/Cellar/$formula
  done

  type -p valet &>/dev/null && valet uninstall --force --no-interaction &>/dev/null

  # force tidyup of empty brew formula directories
  find /usr/local/Cellar -type d -empty -maxdepth 1 -exec rm -rf {} \;

  [ -e  ~/.valet ] && sudo rm -r ~/.valet

  rm -rf /usr/local/etc/php/* /private/tmp/pear/* /usr/local/lib/php/* /usr/local/share/php* /usr/local/share/pear*
  sudo rm -rf /private/tmp/pear/ &>/dev/null
  brew cleanup

  # todo - consider tidying /Library/LaunchDaemons/homebrew.mxcl*.plist
  # todo - consider tidying ~/Library/LaunchAgents/homebrew.mxcl*.plist

  echo "recommend re-installing php versions"
  echo "finish: ${FUNCNAME[0]}"
}

function valet_install() {
    echo "start:  ${FUNCNAME[0]}"
    # for valet we need to be using php7.0 first on a new box!
    switch-php 7.0
    cgr laravel/valet
    valet install --no-interaction -vvv
    valet trust
    brew services list
    echo "finish: ${FUNCNAME[0]}"
}

function php_install() {
    echo "start:  ${FUNCNAME[0]}"
    # `2021-01-28 BigSur 11.1`
    # https://getgrav.org/blog/macos-catalina-apache-multiple-php-versions
    # https://github.com/shivammathur/homebrew-php
    # https://github.com/shivammathur/homebrew-extensions

    # On the first install we need to be based on php70 for composer global installs
    brew tap shivammathur/php
    brew tap shivammathur/extensions

    # prepare for install
    brew reinstall zlib libmemcached openldap libiconv jq pkg-config openssl icu4c

    # install the latest switch-php
    type -p nvm &>/dev/null && nvm use default && npm install --global https://github.com/bgdevlab/switch-php#bgdevlab
    type -p nvm &>/dev/null && nvm use stable && npm install --global https://github.com/bgdevlab/switch-php#bgdevlab

    # ensure composer packages are ready
    type -p composer &>/dev/null || brew install composer

    # plugins are an issue in Composer v2 - prestissimo likely not needed due to perf improvements
    composer global show -q consolidation/cgr &>/dev/null || composer global require consolidation/cgr -vvv
    brew reinstall openssl # pecl required refresh of certificates

    for phpVer in 7.0 7.2 7.4 8.0; do
      echo -e "\n=========== install php-$phpVer ============\n";
      brew install shivammathur/php/php@$phpVer;
      brew link --overwrite --force php@$phpVer;

      brew install shivammathur/extensions/imagick@$phpVer;
      brew install shivammathur/extensions/imap@$phpVer;

      rm -f /usr/local/etc/php/${phpVer}/conf.d/{redis,apcu,memcached}.ini &>/dev/null

      for PHPEXT in redis apcu memcached; do
        printf "\n" | pecl install $PHPEXT | egrep '^Installing|completed|downloading|fail|already'
        [ "$(php -m | egrep -e "^$PHPEXT" | wc -l)" -eq 1 ] && \
          echo "module $PHPEXT loaded" || \
          echo -e "[$PHPEXT]\nextension=\"$(find $(php-config --extension-dir) -name *$PHPEXT.so)\"" > /usr/local/etc/php/${phpVer}/conf.d/$PHPEXT.ini
      done

      [ "$(php -m | egrep -e '^apcu|^redis|^memcache' | wc -l)" -eq 3 ] && echo 'php modules installed' || echo 'php modules missing'
      imagick_test /private/tmp/imagick_test.php${phpVer}.png && echo "imagick correctly installed - see /private/tmp/imagick_test.php${phpVer}.png" || echo 'imagick issue exists'
    done

    sudo rm -rf /private/tmp/pear/ &>/dev/null
    echo "finish: ${FUNCNAME[0]}"
}


function valet_help() {

cat << 'HELP' > /dev/stdout
NGINX
=====
tail -n 100 -f $HOME/.config/valet/Log/nginx-error.log

PHP-FPM
=======
tail -n 100 -f /usr/local/var/log/php-fpm.log
HELP

}

