#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com).
# All rights reserved.
# Licensed under the MIT License.
# ---------------------------------------------------------------------------------------------

function assertFile() {
  if [[ $# -lt 1 ]]; then
      echo "Usage: fileVar='\$(assertFile {full-path/filename})'" 1>&2
      return 1
  fi
  local file=$1
  if [[ ! -f "$file" ]]; then
    echo ">>> ERROR: file='$file' does not exist. aborting." > /dev/tty
    echo > /dev/tty
    return 1;
  fi
  echo $file
  return 0
}
function wait4Key() {
  read -n 1 -p "press space to continue, CTRL-C to exit ..." x
  echo "$x" > /dev/tty
  return 0
}

# note: do not use cut, too many different versions
_getChildrenPids() {
  echo $1
  # for p in $(ps -o pid=,ppid= | grep $1$ | cut -f1 -d' '); do
  for p in $(ps -o pid=,ppid= | grep $1$ | awk -F" " '{print $1}'); do
    _getChildrenPids $p
  done
}
# usage: _pidList=$(getChildrenPids $pid)
getChildrenPids() {
  for p in $(ps -o pid=,ppid= | grep $1$ | awk -F" " '{print $1}'); do
    _getChildrenPids $p
  done
}
##############################################################################################################################
###
# The End.
