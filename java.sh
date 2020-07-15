#!/usr/bin/env bash

# #########################################################
#    JAVA / Maven

function showManifest() { 
  # show contents of JAR manifest
  if [ $# -eq 1 ] && [ -f $1 ]; then
    unzip -q -c "$1" "META-INF/MANIFEST.MF" | sort
  else
    echo "Purpose: view JAR files MANIFEST.MF"
    echo "Usage: $0 jarfilename"
  fi
}

# Maven and JAVA on command line
function java6 () {
  export JAVA_HOME=/Library/Java/JavaVirtualMachines/1.6.0.jdk/Contents/Home
}

function java7 () {
  export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.7/Contents/Home
}

function java8 () {
  export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8/Contents/Home
}

function switch-mvn3() {
  [ $# -ne 1 ] && echo "specify maven version to link, e.g. 3.2.5" && return 1 || true;
  if [ -e ~/tools/apache-maven-$1 ]; then
    export MVN_HOME=~/tools/apache-maven-$1
    rm -f ~/tools/apache-maven-3
    ln -nfs $MVN_HOME ~/tools/apache-maven-3 
  fi
  echo MVN_HOME=$MVN_HOME  
}


export MVN_HOME=~/tools/apache-maven
export ANT_HOME=~/tools/apache-ant-1.9.6
# this is a non standard alias to set JAVA_HOME based on jenv environment.
alias jenv_set_java_home='export JAVA_HOME="$HOME/.jenv/versions/`jenv version-name`"'

# jenv http://www.jenv.be/
export PATH="$HOME/.jenv/bin:$PATH"
[ -e ~/.jenv ] && eval "$(jenv init -)" || echo "jenv missing - try installing jenv with 'brew install jenv'"


alias mvnhome32='switch-mvn3 3.2.5'
alias mvnhome33='switch-mvn3 3.3.9'