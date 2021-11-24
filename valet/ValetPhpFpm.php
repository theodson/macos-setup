<?php

namespace Valet;

use Illuminate\Container\Container;

/*
 * Fix some of our issues with Valet.
 * Create ValetPhpFpm class (extend Valet's PhpFpm class) and swap the instance in the container.
 * We address the following
 *
 *  1 - include  'shivammathur/extensions' for Brew
 *  2 - fix the PhpFpm->stopRunning method - use `sudo` when calling `brew services stop php@V.V`
 *  3 - include support for installing pecl extensions
 *
 */

class ValetPhpFpm extends PhpFpm
{
    var $taps = [
        'homebrew/homebrew-core',
        'shivammathur/php',
        'shivammathur/extensions',
    ];

    /**
     * Support Custom prebuilt extensions
     * keys are used for `php -m` checks, values are brew formula.
     * TODO - support custom exts - extract to BREW_EXTENSIONS similar to PECL_EXTENSIONS below
     * @var string[]
     */
    var $brewExtensions = [
        'imagick' => 'shivammathur/extensions/imagick',
        'imap' => 'shivammathur/extensions/imap',
        'xdebug' => 'shivammathur/extensions/xdebug',
    ];

    /**
     * Support Custom pecl extensions ( override bar delimited env PECL_EXTENSIONS ).
     * @var string[]
     */
    var $peclExtensions = [
    ];

    /**
     * Log file for feedback aswell as stdout - used by logit.
     */
    const LOGFILE = VALET_HOME_PATH.'/Log/valet-php-fpm.log';

    /**
     * Install and configure PhpFpm.
     *
     * @return void
     */
    function install()
    {
        $this->logit("\n".ValetPhpFpm::class."::install - Start");
        $this->peclExtensions = explode('|', getenv('PECL_EXTENSIONS') ?: 'redis');
//        $this->brewExtensions = explode('|',
//            getenv('BREW_EXTENSIONS') ?: 'shivammathur/extensions/imagick|shivammathur/extensions/imap');

        # parent block start
        parent::install();
        # parent block end

        $phpVersion = $this->brew->linkedPhp();
        $version = preg_replace('/[^\d\.]/', '', $phpVersion);
        $fpmConfig = $this->fpmConfigPath();

        $this->logit("Linked PHP is '$version', version is $version. Fpm Config $fpmConfig");

        $this->installPhpExtensions($version);
        $this->installPeclExtensions($version);
        $this->checkExtensions();
        $this->logit(ValetPhpFpm::class."::install - End");
    }

    /**
     * Only stop running php services
     */
    function stopRunning()
    {
        $this->logit(ValetPhpFpm::class."::stopRunning - Start");
        //
        // this varies from laravel valet's standard position which only stops 'running' php processes.
        // we assume issues with valet and force stop on any matching php process (as sudo).
        //
        $this->brew->stopService(
            collect(array_filter(explode(PHP_EOL, $this->cli->runAsUser(
                'sudo brew services list | grep "^php" | awk \'{ print $1; }\'',
                function ($exitCode, $errorOutput) {
                    $this->logit($errorOutput);

                    throw new DomainException('Brew was unable to check which services are running.');
                }
            ))))
                ->filter(function ($service) {
                    return substr($service, 0, 3) === 'php';
                })
                ->all()
        );
        $this->logit(ValetPhpFpm::class."::stopRunning - End");
    }

    protected function logit($message)
    {
        info($message);
        file_put_contents(ValetPhpFpm::LOGFILE, "$message\n", FILE_APPEND);
    }

    /**
     * Support PeclExtension installation
     * @param $version
     */
    protected function installPeclExtensions($version)
    {
        $this->logit(ValetPhpFpm::class."::installPeclExtensions ($version) - Start");

        collect($this->peclExtensions)
            ->reject(function ($pecl) use ($version) { # reject already loaded pecls
                // Require existing PECL extensions area available
                $extensionLoaded = $this->requirePeclExtension($pecl, $version);

                return $extensionLoaded;
            })
            ->map(function ($pecl) use ($version) {
                // Install PECL extensions
                $this->logit(ValetPhpFpm::class."::installPeclExtensions ($version) - pecl install $pecl ");
                $result = $this->cli->runAsUser("printf \"\n\" | pecl install $pecl &>/dev/null",
                    function ($exitCode, $errorOutput) use ($pecl) {
                        $this->logit($errorOutput);

                        throw new DomainException('Pecl was unable to install ['.$pecl.'].');
                    });
                $extensionLoaded = $this->requirePeclExtension($pecl, $version);

                return $pecl;
            });

        $this->logit(ValetPhpFpm::class."::installPeclExtensions ($version) - End");
    }


    /**
     * Support PhpExtension installation
     * @param $version
     */
    protected function installPhpExtensions($version)
    {
        $this->logit(ValetPhpFpm::class."::installPhpExtensions ($version) - Start");

        collect($this->brewExtensions)
            ->map(function ($formula, $name) use ($version) {
                return sprintf("%s@%s", $formula, $version); # redis to redis@7.2
            })->each(function ($formula) {
                if (!$this->brew->installed($formula)) {
                    $this->logit("PHP dependency missing .... $formula");
                    $this->brew->installOrFail($formula, [], $this->taps);
                } else {
                    $this->logit("PHP dependency exists ..... $formula");
                }
            });
        $this->logit(ValetPhpFpm::class."::installPhpExtensions ($version) - End");
    }

    function checkExtensions()
    {
        $modules = collect($this->brewExtensions)->keys()->merge($this->peclExtensions);
        $this->logit("Extensions check ".$modules->implode('|'));
        $result = $this->cli->runAsUser("php -m | egrep '".$modules->implode('|')."' | wc -l",
            function ($exitCode, $errorOutput) {
                $this->logit($errorOutput);

                throw new DomainException('Unable to check extensions.');
            });
        $this->logit($result == $modules->count() ? 'All extensions loaded' : '🤞 Some extensions not loaded !!');
    }

    /**
     * @param $pecl
     * @param $version
     * @return bool
     */
    protected function requirePeclExtension($pecl, $version)
    {
        // 1 : is extension installed
        $peclInstalled = trim($this->cli->runAsUser("pecl info $pecl &>/dev/null && echo true || echo false;")) == 'true';

        // 2 : is it loaded
        $extensionLoaded = trim($this->cli->runAsUser('[ "$(php -m | egrep -e \'^'.$pecl.'\' | wc -l)" -eq 1 ] && echo true || echo false;')) == 'true';

        $this->logit(ValetPhpFpm::class."::installPeclExtensions ($version) - pecl '$pecl' ".
            ($peclInstalled ? 'exists' : 'is missing')." and is ".($extensionLoaded ? 'loaded' : 'NOT loaded'));

        if ($peclInstalled == true && $extensionLoaded == false) {
            // its installed lets try fixing the loading via the INI file.
            $extensionIniPath = "/usr/local/etc/php/$version/conf.d/$pecl.ini";
            $extensionLibPath = trim($this->cli->runAsUser('find $(php-config --extension-dir) -name "*'.$pecl.'.so" || echo \'\';'));

            $this->logit(ValetPhpFpm::class." fix Pecl module - add the missing INI file '$extensionIniPath'");
            $this->files->putAsUser($extensionIniPath, "[$pecl]".PHP_EOL."extension='$extensionLibPath'".PHP_EOL);

            $extensionLoaded = (boolean) $this->cli->runAsUser('[ "$(php -m | egrep -e \'^'.$pecl.'\' | wc -l)" -eq 1 ] && echo true || echo false;');

            $this->logit(ValetPhpFpm::class."::installPeclExtensions ($version) - pecl '$pecl' ".
                ($peclInstalled ? 'exists' : 'is missing')." and is ".($extensionLoaded ? 'loaded' : 'NOT loaded'));
        }

        return $extensionLoaded;
    }
}

/*
 * Swap the containers PhpFpm instance used in any valet calls with out custom Class.
 */
swap(PhpFpm::class, (Container::getInstance())->make('Valet\\ValetPhpFpm'));
