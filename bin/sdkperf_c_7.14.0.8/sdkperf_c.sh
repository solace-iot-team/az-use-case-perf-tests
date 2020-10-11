#!/usr/bin/env bash

basedir=`dirname $0`

cd $basedir

LD_LIBRARY_PATH=$LD_LIBRARY_PATH:solclient/lib ./sdkperf_c $*

###
# The End.
