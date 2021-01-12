# macos-setup

Legacy Notes. See README.md for current.



> Ensure macOS is on at least `10.14.2`

### brew

```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew doctor

sudo mkdir -p /usr/local/sbin
sudo chown -R $(whoami) /usr/local/sbin

sudo mkdir -p /usr/local/var/homebrew/linked
sudo chown -R $(whoami) /usr/local/var/homebrew/linked

brew install httpie wget htop bash-completion gettext
```

### xcode
```
xcode-select --install
```

### setup functions

> These convenience functions are a little bit "WIP" - but here are the commands to reduce manual steps (as documented below further below).
>
> These steps are the historic notes originally recorded for posterity and reference. They have largely been superseded by  the common install functions found within the collection of shell scripts.

These are the variants that have evolved over releases to try and control the php brew installations.  



### setup functions

> These convenience functions are a little bit "WIP" - but here are the commands to reduce manual steps (as documented below further below).
>
> These steps are the historic notes originally recorded for posterity and reference. They have largely been superseded by  the common install functions found within the collection of shell scripts.



```
brew_check_installation 
```



### bash `auto complete`

> now part of `brew_check_installation`

```
# brew install bash-autocomplete
brew install bash-completion
```



### vagrant

```sh
brew cask install vagrant
brew cask install vagrant-manager
brew install vagrant-completion
```



### composer

> now part of `brew_php_install` and `composer_global_install`

```sh
brew install composer
# consider ComposerGlobalInstll - https://github.com/consolidation/cgr

composer global require laravel/valet

composer global require laravel/installer

# ensure composer tools are in the PATH
echo 'export PATH="~/.composer/vendor/bin/:$PATH"' >> ~/.bash_profile 
chmod +x ~/.bash_profile

```



### php 

Installing and maintaining multiple versions of php from `7.0`-`7.4` has become a tricky endeavour on macOs, the function `brew_php_install` attempts to address the issues.

```
brew_php_install
```

Section PHP Varaints shows the historic notes on the manual steps to setup php.




### php deployer/deployer

```sh
composer global require deployer/deployer
dep autocomplete --install > $(brew --prefix)/etc/bash_completion.d/deployer

```




 ##### php-imap has been removed

If you need imap

> Kevin Abel is providing some of the PHP extensions removed from Homebrew/core. You can install the IMAP extension with:
>
> ```
> brew tap kabel/php-ext
> 
> for version in 7.0 7.1
> do
> 	# 7.2
> 	switch-php -v $version
> 	brew install php@${version}-imap
> 
> done
> ```



### Postgres 9.5

```sh
brew reinstall postgresql@9.5
brew services start postgresql@9.5

# follow recommendations outputed, you can be reminded on these with the `info` command
brew info postgresql@9.5

```



> The following postgres env section is redundant as its included in the automatically loaded `includes.sh`

Add to you bash environment for convenience

```bash
# align to linux and connect as postgres by defualt
export PGUSER=postgres
export PGDATABASE=postgres
export PGVERSION=9.5 # this is not a standard PG ENV VAR

[ -e /usr/local/opt/postgresql${PGVERSION} ] && export PATH="/usr/local/opt/postgresql${PGVERSION}/bin:$PATH"
[ -e /usr/local/opt/postgresql${PGVERSION} ] && export LDFLAGS="-L/usr/local/opt/postgresql${PGVERSION}/lib"
[ -e /usr/local/opt/postgresql${PGVERSION} ] && export CPPFLAGS="-I/usr/local/opt/postgresql${PGVERSION}/include"
```



### node + NVM

> now part of `js_env_install`

```brew install node
brew install node

# install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
nvm use stable
```



### redis

```
brew install redis
brew services start redis
```



### IDEs

```
brew cask install visual-studio-code postman
```



#### TWILIO install

https://www.twilio.com/docs/twilio-cli/quickstart

> now part of `js_env_install`



> If you have installed Node.js version 10 or higher on your Mac, you can avoid potential Node.js version conflicts by installing the CLI using npm:

```
brew uninstall twilio 

# use nvm node version manager
nvm use stable || nvm install stable
nvm use stable && npm install twilio-cli -g

```



### postgres extension - hashlib

now part of `install_postgres_hashlib`



```bash
echo 'masOs hashlib installer'

# prepare of macOs Mojave Oct 2019 - commandline-tools installed 10.15.sdk not 10.14!
# some macOs versions may not have the MacOSX10.14.sdk as required by brew's postgresql@9.5
# postgresql@9.5 was built against 10.14.sdk as can be seen with `pg_config` - without this link header files are missing.
pushd /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/ && \
[ ! -e MacOSX10.14.sdk ] && \
[ -e MacOSX.sdk ] && \
sudo ln -snf MacOSX.sdk MacOSX10.14.sdk


cd /tmp && \
wget --quiet https://github.com/markokr/pghashlib/archive/master.zip -O pghashlib.zip && \
unzip pghashlib.zip && \
pushd pghashlib-master && \
[[ -f hashlib.html ]] || cp README.rst hashlib.html && \
make && \
make install && \
popd && \
rm -rf pghashlib-master && \
rm -f pghashlib.zip

# based on the pghashlib src/test we can check for succesful installation.
psql -d postgres -c "create extension hashlib"
[ $(psql -U postgres -t -c"select encode(hash128_string('abcdefg', 'murmur3'), 'hex');" | head -1 | awk '{print $1}') == '069b3c88000000000000000000000000' ] && echo 'pghashlib installed correctly' || 'pghashlib not installed correctly'


```



### java & jenv

multiple java environments

http://davidcai.github.io/blog/posts/install-multiple-jdk-on-mac/

```
brew install jenv
# this install openJdk - not Oracle's

brew tap homebrew/cask-versions
brew cask install java
brew cask install java8

jenv add /Library/Java/JavaVirtualMachines/jdk1.8.0_192.jdk/Contents/Home/
jenv add /Library/Java/JavaVirtualMachines/openjdk-11.0.1.jdk/Contents/Home/
jenv versions

```



### mysql

```
brew update
brew install mysql
brew services start mysql
mysql -uroot
```

#### Set root password

```
mysqladmin -u root password 'password'
```

#### Test access

```
mysql -uroot -ppassword
```

#### SequelPro Access

SequelPro does not support latest encryption system, so use the older authentication mechanism.

> <u>As an aside</u>, an alternative client tool `TablePlus` does support latest encryption mechanisms used by default. As

```
# set the password using the older encryption mechanism - to allow SequelPro Access.
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';
```





## macOs Catalina 10.5.5 - PHP

As of `2020-06 Catalina 10.5.5`

https://getgrav.org/blog/macos-catalina-apache-multiple-php-versions

```bash

# target macOs Catalina 10.15.5 2020-06-01

# prepare for install
brew install zlib libmemcached
brew install openldap libiconv
#export PKG_CONFIG_PATH=/usr/local/opt/zlib/lib/pkgconfig
#zlib_path=$(pkg-config libmemcached --variable=prefix) #/usr/local/Cellar/zlib/1.2.11

sudo chmod 777 /private/tmp/*
# 
brew remove --force --ignore-dependencies httpd
brew remove --force --ignore-dependencies php70-xdebug php71-xdebug php72-xdebug php73-xdebug
brew remove --force --ignore-dependencies php70-imagick php71-imagick php72-imagick php73-imagick
brew remove --force --ignore-dependencies php@7.0-imap php@7.1-imap php@7.2-imap php@7.3-imap 
brew remove --force --ignore-dependencies php70 php71 php72 php73 php@7.0 php@7.1 php@7.2 php@7.3
brew cleanup
rm -rf /usr/local/etc/php/* /private/tmp/pear/* /usr/local/lib/php/* /usr/local/share/php* /usr/local/share/pear*

# install the latest switch-php
nvm use stable && npm install --global jalendport/switch-php#master

#  pecl config-show 


# to deal with removal of php70 we need to adjust and reintroduce.

# brew tap kabel/php-ext # make php-imap installable via kabel
brew tap bgdevlab/php-ext # we need php70 imap
brew tap bgdevlab/homebrew-deprecated # php-70

# possible php70 useful
# https://github.com/eXolnet/homebrew-deprecated/issues/26
# https://github.com/eXolnet/homebrew-deprecated/issues/14
# https://github.com/kelaberetiv/TagUI/issues/86#issuecomment-532462565
    
# OpenSSL 1.0.0
# brew reinstall https://github.com/tebelorg/Tump/releases/download/v1.0.0/openssl.rb
# brew reinstall https://raw.githubusercontent.com/bgdevlab/homebrew-tap/master/openssl.rb
#sudo ln -s /usr/local/Cellar/openssl/1.0.2t/lib/libcrypto.1.0.0.dylib /usr/local/opt/openssl/lib/libcrypto.1.0.0.dylib
#sudo ln -s /usr/local/Cellar/openssl/1.0.2t/lib/libssl.1.0.0.dylib /usr/local/opt/openssl/lib/libssl.1.0.0.dylib

# use the brew repo for older libraries - the above are copies of this file.
brew reinstall https://raw.githubusercontent.com/Homebrew/homebrew-core/8b9d6d688f483a0f33fcfc93d433de501b9c3513/Formula/openssl.rb
# fix libcrypto issue dyld: Library not loaded: /usr/local/opt/openssl/lib/libcrypto.1.0.0.dylib
#brew switch openssl 1.0.2s
#brew switch openssl 1.0.2t
brew link --overwrite -f -q openssl@1.0;ln -snf /usr/local/Cellar/openssl@1.0/1.0.2t /usr/local/opt/openssl


# icu4 changed from 64 to 67 in 10.5.5 - fix that
# https://gist.github.com/berkedel/d1fc6d13651c16002f64653096d1fded
# brew reinstall https://raw.githubusercontent.com/Homebrew/homebrew-core/c179a064276d698d66953898ff9e02d6e0664b2a/Formula/icu4c.rb
# brew switch icu4c 62.1
brew reinstall https://raw.githubusercontent.com/Homebrew/homebrew-core/a806a621ed3722fb580a58000fb274a2f2d86a6d/Formula/icu4c.rb
#brew switch icu4c 64.2
brew link --overwrite -f -q icu4c@64.2 64.2;ln -snf /usr/local/Cellar/icu4c@64.2/64.2 /usr/local/opt/icu4c

brew reinstall php@7.0 php@7.0-imap imagemagick

# check versions
php -v;
fpm-php -v

pecl install redis imagick apcu 
#pecl install xdebug 
echo $(pkg-config libmemcached --variable=prefix) | pecl install memcached # !! --with-zlib-dir=/usr/local/Cellar/zlib/1.2.11

php -m | egrep 'redis|imagick|apcu|xdebug|memcached'
php-fpm -m | egrep 'redis|imagick|apcu|xdebug|memcached'
pecl list -a | egrep 'redis|imagick|apcu|xdebug|memcached'

alias sphp70='switch_icu4c64_2 && switch_openssl1_0 && switch-php -v 7.0'
echo "alias sphp70='switch_icu4c64_2 && switch_openssl1_0 && switch-php -v 7.0'" >> ~/.bash/adhoc.sh

export phpversions="7.2 7.4"

latest_php='7.4'
for version in $phpversions
do
  #brew switch icu4c 67.1
  brew link --overwrite -f -q icu4c 67.1;ln -snf /usr/local/Cellar/icu4c/67.1 /usr/local/opt/icu4c
  # brew switch openssl 1.1.0
    
  # this install php@$version also
  brew reinstall php@$version imagemagick

  # php-imap
  [ $version == $latest_php ] && brew install php-imap || brew install php@${version}-imap

  switch-php -v $version
  #brew switch icu4c 67.1

  pecl install redis imagick apcu xdebug 
  echo $(pkg-config libmemcached --variable=prefix) | pecl install memcached # !! --with-zlib-dir=/usr/local/Cellar/zlib/1.2.11

  # check versions
  php -v;
  fpm-php -v

  # check ext
  php -m | egrep 'redis|imagick|apcu|xdebug|memcached'
  pecl list -a | egrep 'redis|imagick|apcu|xdebug|memcached'

done

echo "alias sphp72='switch_icu4c67_1 && switch_openssl1_1 && switch-php -v 7.2'" >> ~/.bash/adhoc.sh
echo "alias sphp74='switch_icu4c67_1 && switch_openssl1_1 && switch-php -v 7.4'" >> ~/.bash/adhoc.sh

# use php70 as base dependency for these tools.
# if using later versions of php when installing via composer/cgr then dependencies are matched there, hence when
# switching back to lower version of php we encounter vender package issues.
sphp70 

  
# install valet
# composer global require laravel/valet
cgr update laravel/valet &>/dev/null || cgr laravel/valet # prefer CGR for isolation of vendor deps

# if you get symphony errors run
composer global update

```



## macOs Mojave 10.14.1 - PHP


```sh
# target macOs Mojave 10.14.1

# prepare for install
brew install zlib libmemcached
#export PKG_CONFIG_PATH=/usr/local/opt/zlib/lib/pkgconfig
#zlib_path=$(pkg-config libmemcached --variable=prefix) #/usr/local/Cellar/zlib/1.2.11

sudo chmod 777 /private/tmp/*

# 

brew remove --force --ignore-dependencies httpd
brew remove --force --ignore-dependencies php70-xdebug php71-xdebug php72-xdebug php73-xdebug
brew remove --force --ignore-dependencies php70-imagick php71-imagick php72-imagick php73-imagick
brew remove --force --ignore-dependencies php@7.0-imap php@7.1-imap php@7.2-imap php@7.3-imap 
brew remove --force --ignore-dependencies php70 php71 php72 php73 php@7.0 php@7.1 php@7.2 php@7.3
brew cleanup
rm -rf /usr/local/etc/php/* /private/tmp/pear/* /usr/local/lib/php/* /usr/local/share/php* /usr/local/share/pear*

npm install --global switch-php

#  pecl config-show 


# to deal with removal of php70 we need to adjust and reintroduce.

# brew tap kabel/php-ext # make php-imap installable via kabel
brew tap bgdevlab/php-ext # we need php70 imap
brew tap exolnet/homebrew-deprecated # php-70

latest_php='7.4'
for version in 7.0 7.1 7.2 7.3 7.4
do

  brew reinstall php@$version

  # php-imap
  [ $version == $latest_php ] && brew install php-imap || brew install php@${version}-imap

  # imagick
  brew install imagemagick --with-hdri --with-librsvg --with-liblqr --with-libheif --with-openexr --with-ghostscript 
  switch-php -v $version
  pecl install redis imagick apcu xdebug 
  echo $(pkg-config libmemcached --variable=prefix) | pecl install memcached # !! --with-zlib-dir=/usr/local/Cellar/zlib/1.2.11

  # check versions
  php -v;
  fpm-php -v

  # check ext
  php -m | egrep 'redis|imagick|apcu|xdebug|memcached'
  pecl list -a | egrep 'redis|imagick|apcu|xdebug|memcached'

done

# install valet
composer global require laravel/valet

# if you get symphony errors run
composer global update
```


php70 install resulted in
```sh
==> apr
apr is keg-only, which means it was not symlinked into /usr/local,
because Apple's CLT package contains apr.

If you need to have apr first in your PATH run:
  echo 'export PATH="/usr/local/opt/apr/bin:$PATH"' >> ~/.bash_profile

==> apr-util
apr-util is keg-only, which means it was not symlinked into /usr/local,
because Apple's CLT package contains apr.

If you need to have apr-util first in your PATH run:
  echo 'export PATH="/usr/local/opt/apr-util/bin:$PATH"' >> ~/.bash_profile

==> aspell
Installation of the 'is' (Icelandic) and 'nb' (Norwegian) dictionaries is
currently broken. They can be installed manually.

See: https://github.com/Homebrew/homebrew-core/issues/28074
==> autoconf
Emacs Lisp files have been installed to:
  /usr/local/share/emacs/site-lisp/autoconf
==> openldap
openldap is keg-only, which means it was not symlinked into /usr/local,
because macOS already provides this software and installing another version in
parallel can cause all kinds of trouble.

If you need to have openldap first in your PATH run:
  echo 'export PATH="/usr/local/opt/openldap/bin:$PATH"' >> ~/.bash_profile
  echo 'export PATH="/usr/local/opt/openldap/sbin:$PATH"' >> ~/.bash_profile

For compilers to find openldap you may need to set:
  export LDFLAGS="-L/usr/local/opt/openldap/lib"
  export CPPFLAGS="-I/usr/local/opt/openldap/include"

==> curl-openssl
curl-openssl is keg-only, which means it was not symlinked into /usr/local,
because macOS already provides this software and installing another version in
parallel can cause all kinds of trouble.

If you need to have curl-openssl first in your PATH run:
  echo 'export PATH="/usr/local/opt/curl-openssl/bin:$PATH"' >> ~/.bash_profile

For compilers to find curl-openssl you may need to set:
  export LDFLAGS="-L/usr/local/opt/curl-openssl/lib"
  export CPPFLAGS="-I/usr/local/opt/curl-openssl/include"

For pkg-config to find curl-openssl you may need to set:
  export PKG_CONFIG_PATH="/usr/local/opt/curl-openssl/lib/pkgconfig"

==> libtool
In order to prevent conflicts with Apple's own libtool we have prepended a "g"
so, you have instead: glibtool and glibtoolize.
==> libffi
libffi is keg-only, which means it was not symlinked into /usr/local,
because some formulae require a newer version of libffi.

For compilers to find libffi you may need to set:
  export LDFLAGS="-L/usr/local/opt/libffi/lib"

For pkg-config to find libffi you may need to set:
  export PKG_CONFIG_PATH="/usr/local/opt/libffi/lib/pkgconfig"

==> libpq
libpq is keg-only, which means it was not symlinked into /usr/local,
because conflicts with postgres formula.

If you need to have libpq first in your PATH run:
  echo 'export PATH="/usr/local/opt/libpq/bin:$PATH"' >> ~/.bash_profile

For compilers to find libpq you may need to set:
  export LDFLAGS="-L/usr/local/opt/libpq/lib"
  export CPPFLAGS="-I/usr/local/opt/libpq/include"

For pkg-config to find libpq you may need to set:
  export PKG_CONFIG_PATH="/usr/local/opt/libpq/lib/pkgconfig"

==> php@7.0
To enable PHP in Apache add the following to httpd.conf and restart Apache:
    LoadModule php7_module /usr/local/opt/php@7.0/lib/httpd/modules/libphp7.so

    <FilesMatch \.php$>
        SetHandler application/x-httpd-php
    </FilesMatch>

Finally, check DirectoryIndex includes index.php
    DirectoryIndex index.php index.html

The php.ini and php-fpm.ini file can be found in:
    /usr/local/etc/php/7.0/

php@7.0 is keg-only, which means it was not symlinked into /usr/local,
because this is an alternate version of another formula.

If you need to have php@7.0 first in your PATH run:
  echo 'export PATH="/usr/local/opt/php@7.0/bin:$PATH"' >> ~/.bash_profile
  echo 'export PATH="/usr/local/opt/php@7.0/sbin:$PATH"' >> ~/.bash_profile

For compilers to find php@7.0 you may need to set:
  export LDFLAGS="-L/usr/local/opt/php@7.0/lib"
  export CPPFLAGS="-I/usr/local/opt/php@7.0/include"


To have launchd start exolnet/deprecated/php@7.0 now and restart at login:
  brew services start exolnet/deprecated/php@7.0
Or, if you don't want/need a background service you can just run:
  php-fpm
Error: No available formula with the name "php@7.0-imap" 
==> Searching for a previously deleted formula (in the last month)...
Warning: homebrew/core is shallow clone. To get complete history run:
  git -C "$(brew --repo homebrew/core)" fetch --unshallow

Error: No previously deleted formula found.
==> Searching for similarly named formulae...
Error: No similarly named formulae found.
==> Searching taps...
==> Searching taps on GitHub...
Error: No formulae found in taps.
```



# Notes from Installations 

## Brew

```
brew list --full-name --versions

ack 2.18
apr 1.6.5 1.6.3
apr-util 1.6.1_1
argon2 20171227
aspell 0.60.6.1_1
autoconf 2.69
bash-completion 1.3_3
boost 1.67.0_1
cairo 1.14.12
coreutils 8.29
cscope 15.8b
dnsmasq 2.77_3
docutils 0.14
fontconfig 2.13.0
freetds 1.00.91 1.00.104 1.00.92
freetype 2.9.1
gdbm 1.13
gettext 0.19.8.1
git 2.19.1
git-lfs 2.3.4
glib 2.58.1 2.56.1
gmp 6.1.2_2
heroku 7.7.4
heroku-node 10.6.0
htop 2.0.2_2
icu4c 62.1
imagemagick 7.0.7-4 7.0.7-33 7.0.7-7
imap-uw 2007f
jenv 0.4.4
jpeg 9c
libdvdcss 1.4.0
libevent 2.1.8
libffi 3.2.1
libiconv 1.15
libmemcached 1.0.18_2
libpng 1.6.34 1.6.35 1.6.32
libpq 10.4 11.0
libsodium 1.0.16
libssh2 1.8.0
libtiff 4.0.9_4
libtool 2.4.6_1
libxml2 2.9.7
libzip 1.5.1
links 2.14_1
little-cms2 2.9
mcrypt 2.6.8
memcached 1.5.8
mhash 0.9.9.9
nginx 1.12.1
nmap 7.60
node 10.6.0 8.5.0 9.11.1
openjpeg 2.3.0
openldap 2.4.46
openssl 1.0.2p
openssl@1.1 1.1.0f
packer 1.2.4
pandoc 1.19.2.4
pcre 8.42
pcre2 10.32
php 7.2.7 7.2.6
php@7.0 7.0.30_1
php@7.1 7.1.19 7.1.23
php@7.1-imap 7.1.23
pixman 0.34.0_1
pkg-config 0.29.2
poppler 0.67.0
postgresql 9.6.5
python 2.7.14
readline 7.0.3_1
redis 4.0.2
rsync 3.1.3_1
shfmt 2.1.0
sqlite 3.21.0 3.20.1
supervisor 3.3.3
telnet 54.50.1
terminal-notifier 1.8.0
tree 1.7.0
unixodbc 2.3.6 2.3.7 2.3.4
webp 1.0.0
wget 1.19.1_1
xz 5.2.4
yarn 1.7.0 1.6.0
```


## NPM Global

```
npm ls --global --depth=0
/usr/local/lib
├── @squarespace/server@1.1.1
├── @vue/cli@3.0.0-rc.3
├── bower@1.8.0
├── bower-migrate@0.0.2
├── generator-aspnet@0.3.1
├── gtop@0.1.5
├── gulp@3.9.1
├── gulp-cli@1.2.2
├── j2m@1.0.0
├── npm@6.1.0
├── npx@10.2.0
├── puppeteer@1.5.0
├── tldr@3.1.1
├── ws@1.1.1
├── wscat2@1.1.0
├── yarn@0.16.1
└── yo@1.8.5
```

## Composer Global

```
php -v
PHP 7.2.31 (cli) (built: May 29 2020 02:00:47) ( NTS )
Copyright (c) 1997-2018 The PHP Group
Zend Engine v3.2.0, Copyright (c) 1998-2018 Zend Technologies


cat ~/.composer/composer.json

{
    "require": {
        "laravel/valet": "^2.11",
        "laravel/installer": "^2.1",
        "deployer/deployer": "^6.5",
        "beyondcode/expose": "^1.0"
    }
}

```


```

composer global show

Changed current directory to /Users/developer/.composer
consolidation/cgr         1.3.0   Safer alternative to 'composer global require'.
deployer/deployer         v6.3.0  Deployment Tool
deployer/phar-update      v2.1.0  Integrates Phar Update to Symfony Console.
doctrine/inflector        v1.3.0  Common String Manipulations with regard to casing and singular/plural rules.
guzzlehttp/guzzle         6.3.3   Guzzle is a PHP HTTP client library
guzzlehttp/promises       v1.3.1  Guzzle promises library
guzzlehttp/psr7           1.4.2   PSR-7 message implementation that also provides common utility methods
hirak/prestissimo         0.3.8   composer parallel install plugin
illuminate/container      v5.7.10 The Illuminate Container package.
illuminate/contracts      v5.7.10 The Illuminate Contracts package.
illuminate/support        v5.7.10 The Illuminate Support package.
laravel/envoy             v1.4.1  Elegant SSH tasks for PHP.
laravel/installer         v1.5.0  Laravel application installer.
laravel/valet             v2.1.1  A more enjoyable local development experience for Mac.
mnapoli/silly             1.7.0   Silly CLI micro-framework based on Symfony Console
nategood/httpful          0.2.20  A Readable, Chainable, REST friendly, PHP HTTP Client
nesbot/carbon             1.34.0  A simple API extension for DateTime.
php-di/invoker            2.0.0   Generic and extensible callable invoker
pimple/pimple             v3.2.3  Pimple, a simple Dependency Injection Container
psr/container             1.0.0   Common Container Interface (PHP FIG PSR-11)
psr/http-message          1.0.1   Common interface for HTTP messages
psr/simple-cache          1.0.1   Common interfaces for simple caching
symfony/console           v4.1.6  Symfony Console Component
symfony/filesystem        v4.1.6  Symfony Filesystem Component
symfony/polyfill-ctype    v1.9.0  Symfony polyfill for ctype functions
symfony/polyfill-mbstring v1.9.0  Symfony polyfill for the Mbstring extension
symfony/polyfill-php72    v1.9.0  Symfony polyfill backporting some PHP 7.2+ features to lower PHP versions
symfony/process           v4.1.6  Symfony Process Component
symfony/translation       v4.1.6  Symfony Translation Component
symfony/var-dumper        v4.1.6  Symfony mechanism for exploring and dumping PHP variables
symfony/yaml              v4.1.6  Symfony Yaml Component
tightenco/collect         v5.7.9  Collect - Illuminate Collections as a separate package.
tightenco/lambo           v0.4.3  Super-powered 'laravel new' with Laravel and Valet.
```


