#!/usr/bin/env bash

# #########################################################
#    PHP

function composer_global_check_installation() {
    for dependency in consolidation/cgr laravel/valet laravel/installer
    do
        echo "TODO check composer install for $dependency" || true
    done
}

# helpers for ongoing issue switching to php7.0
alias switch_openssl1_0='brew switch openssl@1.0 1.0.2t && ln -snf /usr/local/Cellar/openssl@1.0/1.0.2t /usr/local/opt/openssl'
alias switch_openssl1_1='brew switch openssl@1.1 1.1.1g && ln -snf /usr/local/Cellar/openssl@1.1/1.1.1g /usr/local/opt/openssl'
alias switch_icu4c64_2='brew switch icu4c@64.2 64.2 && ln -snf /usr/local/Cellar/icu4c@64.2/64.2 /usr/local/opt/icu4c' # php@7.0 need it
alias switch_icu4c67_1='brew switch icu4c 67.1 && ln -snf /usr/local/Cellar/icu4c/67.1 /usr/local/opt/icu4c'


# these alias worked prior to 2020-09-09
alias sphp70='brew switch icu4c 64.2;brew switch openssl 1.0.2t;switch-php -v 7.0'
alias sphp72='brew switch icu4c 67.1;switch-php -v 7.2'
alias sphp74='brew switch icu4c 67.1;switch-php -v 7.4'
# new sphp as of 2020-09-09
alias sphp70='switch_icu4c64_2 && switch_openssl1_0 && switch-php -v 7.0'
alias sphp72='switch_icu4c67_1 && switch_openssl1_1 && switch-php -v 7.2'
alias sphp74='switch_icu4c67_1 && switch_openssl1_1 && switch-php -v 7.4'

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


function brew_php_install() {
    # `2020-06 Catalina 10.5.5`
    # https://getgrav.org/blog/macos-catalina-apache-multiple-php-versions

    # On the first install we need to be based on php70 for composer global installs

    # tap required repos for php70 and extensions
    brew tap bgdevlab/php-ext # we need php70 imap
    brew tap bgdevlab/homebrew-deprecated # php-70

    # php70 requires openssl-1.0.0
    # brew reinstall https://raw.githubusercontent.com/Homebrew/homebrew-core/8b9d6d688f483a0f33fcfc93d433de501b9c3513/Formula/openssl.rb # cant do it this way anymore 20200910
    # brew switch openssl 1.0.2t # brew cleanup may remove this

    # idea-1: brew tap bgdevlab/homebrew-deprecated && pushd $(brew --repo bgdevlab/deprecated) git checkout develop # this branch has openssl@1.0
    # brew extract recommended as brew reinstall from github URL not supported anymore 20200910
    brew extract --version 1.0 -v -d --force openssl bgdevlab/deprecated && HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_INSTALL_CLEANUP=1 brew reinstall openssl@1.0

    # php70 requires icu4 64 - it changed from 64 to 67 in 10.5.5 - fix that
    # https://gist.github.com/berkedel/d1fc6d13651c16002f64653096d1fded
    # brew reinstall https://raw.githubusercontent.com/Homebrew/homebrew-core/a806a621ed3722fb580a58000fb274a2f2d86a6d/Formula/icu4c.rb # cant do it this way anymore 20200910
    brew extract --version 64.2 -v -d --force icu4c bgdevlab/deprecated && HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_INSTALL_CLEANUP=1 brew reinstall icu4c@64.2

    switch_icu4c64_2 # brew cleanup may remove this

    # prepare for install
    brew reinstall zlib libmemcached openldap libiconv jq pkg-config
    HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_INSTALL_CLEANUP=1 brew reinstall php@7.0 php@7.0-imap imagemagick

    # install the latest switch-php
    type -p nvm &>/dev/null && nvm use default && npm install --global https://github.com/bgdevlab/switch-php#bgdevlab
    type -p nvm &>/dev/null && nvm use stable && npm install --global https://github.com/bgdevlab/switch-php#bgdevlab


    # switch_openssl1_0 && switch_icu4c64_2 && echo "prepared for php@7.0" && switch-php 7.0
    sphp70

    # ensure composer packages are ready
    type -p composer &>/dev/null || brew install composer

    # plugins are an issue in Composer v2 - prestissimo likely not needed due to perf improvements
    # composer global show -q hirak/prestissimo &>/dev/null || composer global require hirak/prestissimo -vvv
    composer global show -q consolidation/cgr &>/dev/null || composer global require consolidation/cgr -vvv

    # this we need to install php7.0 first on a new box!
    cgr laravel/valet
    valet install  --no-interaction -vvv
    valet trust
    brew services list

    sudo rm -rf /private/tmp/pear/

    phpver=7.0
    # brew reinstall php@7.0 php@7.0-imap imagemagick
    # switch_openssl1_0 && switch_icu4c64_2 && echo "prepared for php@7.0" && switch-php 7.0
    sphp70

    switch-php $phpver
    # ensure /usr/local/bin is before /usr/bin if you want to favour brew's bins

    # pecl install extensions
    printf "\n" | pecl uninstall redis imagick apcu
    printf "\n" | pecl install redis imagick apcu
    echo $(pkg-config libmemcached --variable=prefix) | pecl install memcached # !! --with-zlib-dir=/usr/local/Cellar/zlib/1.2.11

    # remove pecl extension from php.ini
    sed -i'' -e '/^extension="redis.so"/d' /usr/local/etc/php/${phpver}/php.ini /usr/local/etc/php/${phpver}/conf.d/ext-redis.ini &>/dev/null
    sed -i'' -e '/^extension="imagick.so"/d' /usr/local/etc/php/${phpver}/php.ini /usr/local/etc/php/${phpver}/conf.d/ext-imagick.ini &>/dev/null
    sed -i'' -e '/^extension="apcu.so"/d' /usr/local/etc/php/${phpver}/php.ini /usr/local/etc/php/${phpver}/conf.d/ext-apcu.ini &>/dev/null
    sed -i'' -e '/^extension="memcached.so"/d' /usr/local/etc/php/${phpver}/php.ini /usr/local/etc/php/${phpver}/conf.d/ext-apcu.ini &>/dev/null
    # add pecl extension to separate ini file
    echo -e "[redis]\nextension=\"redis.so\"" > /usr/local/etc/php/${phpver}/conf.d/ext-redis.ini
    echo -e "[imagick]\nextension=\"imagick.so\"" > /usr/local/etc/php/${phpver}/conf.d/ext-imagick.ini
    echo -e "[apcu]\nextension=\"apcu.so\"" > /usr/local/etc/php/${phpver}/conf.d/ext-apcu.ini
    echo -e "[memcached]\nextension=\"memcached.so\"" > /usr/local/etc/php/${phpver}/conf.d/ext-memcached.ini


    imagick_test /private/tmp/imagick_test.php${phpver}.png && echo "imagick correctly installed - see /private/tmp/imagick_test.php${phpver}.png" || echo 'imagick issue exists'

    latest_php='7.4'
    for phpver in $phpversions
    do
        switch_icu4c67_1
        # brew switch openssl 1.1.0 ?? not sure if this can be done/needed.

        # this install php@$version also
        HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_INSTALL_CLEANUP=1 brew reinstall php@$phpver imagemagick

        # php-imap
        [ $phpver == $latest_php ] && brew install php-imap || brew install php@${phpver}-imap

        switch-php -v $phpver

        printf "\n" | pecl install redis imagick apcu
        echo $(pkg-config libmemcached --variable=prefix) | pecl install memcached # !! --with-zlib-dir=/usr/local/Cellar/zlib/1.2.11

        # remove pecl extension from php.ini
        sed -i'' -e '/^extension="redis.so"/d' /usr/local/etc/php/${phpver}/php.ini /usr/local/etc/php/${phpver}/conf.d/ext-redis.ini &>/dev/null
        sed -i'' -e '/^extension="imagick.so"/d' /usr/local/etc/php/${phpver}/php.ini /usr/local/etc/php/${phpver}/conf.d/ext-imagick.ini &>/dev/null
        sed -i'' -e '/^extension="apcu.so"/d' /usr/local/etc/php/${phpver}/php.ini /usr/local/etc/php/${phpver}/conf.d/ext-apcu.ini &>/dev/null
        sed -i'' -e '/^extension="memcached.so"/d' /usr/local/etc/php/${phpver}/php.ini /usr/local/etc/php/${phpver}/conf.d/ext-apcu.ini &>/dev/null
        # add pecl extension to separate ini file
        echo -e "[redis]\nextension=\"redis.so\"" > /usr/local/etc/php/${phpver}/conf.d/ext-redis.ini
        echo -e "[imagick]\nextension=\"imagick.so\"" > /usr/local/etc/php/${phpver}/conf.d/ext-imagick.ini
        echo -e "[apcu]\nextension=\"apcu.so\"" > /usr/local/etc/php/${phpver}/conf.d/ext-apcu.ini
        echo -e "[memcached]\nextension=\"memcached.so\"" > /usr/local/etc/php/${phpver}/conf.d/ext-memcached.ini

        imagick_test /private/tmp/imagick_test.php${phpver}.png && echo "imagick correctly installed - see /private/tmp/imagick_test.php${phpver}.png" || echo 'imagick issue exists'
    done


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

function valet_uninstall() {
    [ -e $HOME/.composer/composer.json ] && composer global remove laravel/valet || echo 'composer global is missing'

    for formula in dnsmasq nginx
    do
        brew services stop $formula
        brew uninstall --force  --ignore-dependencies $formula
    done

    valet uninstall --force --no-interaction

    for phpversion in $(php-versions | tr ' ' ':')
    do
        atver=$(echo $phpversion | cut -d ':' -f1)
        ver=$(echo $phpversion | cut -d ':' -f2 | tr -d . | cut -c 1,2)
        if [ "$(echo $atver | grep '@' &>/dev/null && echo 0 || echo 1)" -eq 1 ]; then
            # this is the default php (latest version in macOs) to continue without removing it.
            echo -e "Looks like $phpversion is the latest brew supported php version."
            #continue
        fi
        brew services stop $formula &>/dev/null
        brew uninstall --force --ignore-dependencies php${ver}-xdebug php${ver}-imagick $atver php${ver} ${atver}-imap || true

        # force tidyup of empty brew formula directories
        for dir in /usr/local/Cellar/{php$ver-xdebug,php$ver-imagick,$atver,php$ver,$atver-imap};
        do
            [ -e $dir ] && rm -rf "${dir}"
        done
    done

    [ -e  ~/.valet ]  && sudo rm -r ~/.valet

    brew cleanup
    rm -rf /usr/local/etc/php/* /private/tmp/pear/* /usr/local/lib/php/* /usr/local/share/php* /usr/local/share/pear*
    # todo - consider tidying /Library/LaunchDaemons/homebrew.mxcl*.plist
    # todo - consider tidying ~/Library/LaunchAgents/homebrew.mxcl*.plist

    echo "recommend re-installing php versions"
}

function composer_global_install() {

    type -p composer &>/dev/null || brew install composer
    # composer global show -q hirak/prestissimo &>/dev/null || composer global require hirak/prestissimo -vvv
    composer global remove hirak/prestissimo || true
    composer global show -q consolidation/cgr &>/dev/null || composer global require consolidation/cgr -vvv

    sphp70
    # use php70 as base dependency for these tools.
    # if using later versions of php when installing via composer/cgr then dependencies are matched there, hence when
    # switching back to lower version of php we encounter vender package issues.

    cgr update laravel/installer &>/dev/null || cgr laravel/installer
    cgr update laravel/valet &>/dev/null || cgr laravel/valet
    # cgr update deployer/deployer &>/dev/null || cgr deployer/deployer # cgr remove deployer/deployer    
    alias dep='vendor/bin/dep'

    # php 7.2+ only
    # cgr update tightenco/takeout &>/dev/null || cgr tightenco/takeout

}