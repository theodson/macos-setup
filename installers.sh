#!/usr/bin/env bash

function install_postgres_hashlib() {
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
    psql -d postgres -c "create extension hashlib" && \
    [ $(psql -U postgres -t -c"select encode(hash128_string('abcdefg', 'murmur3'), 'hex');" | head -1 | awk '{print $1}') == '069b3c88000000000000000000000000' ] && echo 'pghashlib installed correctly' || 'pghashlib not installed correctly'

}
