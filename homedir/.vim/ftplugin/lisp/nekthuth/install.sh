#!/bin/bash

[ -z $NEKTHUTH_HOME ] && NEKTHUTH_HOME=$HOME/.nekthuth/
[ -e $NEKTHUTH_HOME ] || mkdir $NEKTHUTH_HOME
[ -e $NEKTHUTH_HOME/vim ] || mkdir $NEKTHUTH_HOME/vim
[ -e $NEKTHUTH_HOME/lisp ] || mkdir $NEKTHUTH_HOME/lisp

pluginname=${1/.nek/}

lisp() {
  cat > $NEKTHUTH_HOME/lisp/$pluginname.lisp
}

vim() {
  cat > $NEKTHUTH_HOME/vim/$pluginname.vim
}

source $1
