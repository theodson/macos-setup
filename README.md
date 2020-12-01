# macos-setup

###### Last updated `2020-06`

Note for my macOs dev environment setup whilst using `java, maven, ant, node, nvm, npm,  php, laravel, composer, docker, vagrant, vmware`. 

This repo contains a variety of shell scripts, some of which contain **helper install** functions to maintain a consistent development environment ( they are not fully tested).



> **Tip**: Reading through the helper functions is sometimes required as macOs versions change and break these scripts.

> **Note**: Ensure macOS is on at least `10.14.2` , may NOT WORK with BigSur 11.x ?

The old readme notes can be found in `NOTES.md`  




# Install 

Clone into `~/.bash`
```
[ ! -e ~/.bash ] && git clone https://github.com/theodson/macos-setup .bash || echo 'already installed - or choose another install location'

```
You can manually add `~/.bash/includes.sh` and `~/.bash/adhoc.sh` to your `.bash_profile` or `.bashrc` (adjust path as required) or use the quick start templates.



## Quick start templates

A common setup for a quick start is found in the `templates` folder, run the following

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



### brew / bash utilities 

```
brew_check_installation
```



### vagrant

```sh
brew cask install vagrant
brew cask install vagrant-manager
brew install vagrant-completion
```


### node + NVM

```
# js helper script - js.sh
js_env_install
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

### postgres extension - hashlib

```
install_postgres_hashlib
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

