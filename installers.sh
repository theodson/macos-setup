#!/usr/bin/env bash

function install_postgres_hashlib() {
    echo 'masOs hashlib installer'

    # As of macos 11.2.1 BigSur update -
    # for postgresql-9.5 to build it relies on MacOSX11.0 (possibly make / build overrides available - didnt look into that)
    # see /usr/local/Cellar/postgresql@9.5/9.5.24/lib/pgxs/src/Makefile.global
    # But for now, I do have SDK MacOSX11.1.sdk installed but not the required MacOSX11.0.sdk.
    # So lets assume similiar .h files between the two and create a symlink to satisfy make.
    [ -e /Library/Developer/CommandLineTools/SDKs/MacOSX11.1.sdk ] && \
      sudo ln -snf /Library/Developer/CommandLineTools/SDKs/MacOSX11.1.sdk /Library/Developer/CommandLineTools/SDKs/MacOSX11.0.sdk || \
      echo -e "Need to get MacOSX11.0.sdk or MacOSX11.1.sdk - try \nxcode-select --install"


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
    psql -c "drop extension hashlib" || true;
    psql -c "create extension hashlib" || true;
    [ $(psql -U postgres -t -c"select encode(hash128_string('abcdefg', 'murmur3'), 'hex');" | head -1 | awk '{print $1}') == '069b3c88000000000000000000000000' ] && echo 'pghashlib installed correctly' || 'pghashlib not installed correctly'

}
