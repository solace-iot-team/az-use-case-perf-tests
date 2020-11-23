#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

scriptDir=$(cd $(dirname "$0") && pwd);
scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));


# try 5 times with a wait
sleepBetweenTriesSecs=60
count=0
code=1

until [[ $count -gt 4 || $code -eq 0 ]]; do

  echo ">>> INFO: ssh to controller, try: $count"

  ssh controller "

    touch ssh_connect_SUCCESS.log

    echo "successfully connected to controller via ssh"

  "

  code=$?

  if [[ $code != 0 ]]; then
    echo ">>> WARNING - try:$count - code=$code - $scriptName - sleep(secs):$sleepBetweenTriesSecs";
    sleep $sleepBetweenTriesSecs;
  fi
  ((count=count+1))
done

if [[ $code != 0 ]]; then
  echo ">>> ERROR - tries:$count, code=$code - $scriptName"; exit 1;
else
  echo ">>> SUCCESS - tries:$count, code=$code - $scriptName";
fi



###
# The End.
