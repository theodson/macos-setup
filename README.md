# macos-setup

### Last updated `2022-01` for `12.1` Monterey

Moving setup to DotFile https://github.com/theodson/dotfiles

### Last updated `2021-05` for BigSur

> **Note**: Ensure macOS is on at least `11.3`


For my macOs dev environment setup whilst using `java, maven, ant, node, nvm, npm,  php, laravel, composer, docker, vagrant, vmware`. 

This repo contains a variety of shell scripts, some of which contain **helper install** functions to maintain a consistent development environment ( they are not fully tested).

> **Tip**: Reading through the helper functions is sometimes required as macOs versions change and break these scripts.


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
cp ~/.bash/templates/.bash_profile ~/.bash_profile

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

brew install httpie wget htop bash-completion gettext tmux coreutils
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
install_composer_global
```

### php 

Installing multiple versions of php from `7.0`,`7.2`, `7.4` and `8.0` has become significantly easier on BigSur with the 
help of `shivammathur/php` and `shivammathur/extensions`. 
 
> Since: 2021-05-01
> 
> PHP installation relies more and more on `laravel/valet`'s `use php@n.n` and `install` commands.  
> A customised `valet/ValetPhpFpm.php` is installed into the laravel home `$HOME/.config/valet/Extensions` and overrides
> some methods to better support our custom install (_and fixes a few issues - in time these may disappear with each valet release._)
> 
> The `switch-php` __npm package__ is no longer used.
 
Two helper functions exist to support installation and re-installation, see `php.sh`

```
# to re-install try this - this sequence may need to be rerun
# this will install php 7.0, 7.2, 7.4 and 8.0
  
uninstall_php
install_php
sphp72
sphp74
sphp80
```

On initial setup a default brew recipe for the `latest php` and `php@7.0` is installed. 
After that use the `sphp<nn>` aliases ( see notes below ) to install new versions, e.g
```
# to install php 7.4
sphp74 
```

Review the contents of `templates/adhoc.sh` as you may need to adjust your own `adhoc.sh` file.

- removal `_switch_php_pre_tasks` or `_switch_php_post_tasks` 
- introduce `PECL_EXTENSIONS` for automatic installation during `valet use|install` tasks.
- introduce `BREW_EXTENSIONS` for automatic installation during `valet use|install` tasks.


```
mv ~/.bash/adhoc.sh ~/.bash/adhoc.sh.pre_big_sur
cp ~/.bash/templates/adhoc.sh ~/.bash/adhoc.sh
```

### Switching php version

The aliases `sphp70, sphp72, sphp74, sphp80` exist to switch version. 

A macOs task bar tool called Php Monitor is also installed during `php_install` - see `nicoverbruggen/homebrew-cask`.

```
brew tap nicoverbruggen/homebrew-cask
brew install --cask phpmon
```
> __Note__: the "Php Monitor" toolbar should only be used ONCE each version has been installed via the `sphp<nn>` commands.

### Postgres 9.5
Install Postgres with hashlib
```angular2html
install_postgres 9.5
```
which does the following
```sh
brew reinstall postgresql@9.5
brew services start postgresql@9.5

# follow recommendations outputed, you can be reminded on these with the `info` command
brew info postgresql@9.5

```
and then hashlib

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

