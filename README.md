# macos-setup
Note for my macOs dev environment setup whilst using `java, maven, ant, node, nvm, npm,  php, laravel, composer, docker, vagrant, vmware`. 

This repo contains a variety of shell scripts, some of which contain **helper install** functions to maintain a consistent development environment.



###### Last updated `2020-06`

> Ensure macOS is on at least `10.14.2` , may NOT WORK with BigSur 11.x ?

The old readme notes can be found in `NOTES.md` 

 


# Install 

Clone into `~/.bash`
```
[ ! -e ~/.bash ] && git clone https://github.com/theodson/macos-setup .bash || echo 'already installed - or choose another install location'

```
You can manually add `~/.bash/includes.sh` and `~/.bash/adhoc.sh` to your `.bash_profile` or `.bashrc` (adjust path as required) or use the quick start templates.



## Quick start templates

A common setup is stored for a quick start they are stored in the `templates` folder

- templates/.bash_profile
- templates/adhoc.sh

```
# backup 
mv ~/.bash/adhoc.sh ~/.bash/adhoc.sh.old
mv ~/.bash_profile ~/.bash_profile.old

# use new templates as starting point
cp ~/.bash/templates/adhoc.sh ~/.bash/adhoc.sh
cp ~/.bash/templates/bash_profile ~/.bash_profile

```

### `adhoc.sh` 	

Add `adhoc.sh` can be used for un-versioned / private settings if you like.

Once cloned into `.bash` follow these common steps to install the required dependencies, some of which may already be installed on your system.



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



### bash `auto complete`

```
`brew_check_installation`
```



### vagrant

```sh
brew cask install vagrant
brew cask install vagrant-manager
brew install vagrant-completion
```



### composer

```
# php helper script - php.sh
composer_global_install
```



### php 

Installing and maintaining multiple versions of php from `7.0`-`7.4` has become a tricky endeavour on macOs, the function `brew_php_install` attempts to address the issues.

```
# php helper script - php.sh
brew_php_install
```



Note: `valet_uninstall` exists to remove valet completely if it is causing issues.




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



### node + NVM

```
# js helper script - js.sh
js_env_install
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

