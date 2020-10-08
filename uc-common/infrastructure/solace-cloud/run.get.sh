#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------
clear

scriptDir=$(cd $(dirname "$0") && pwd);
scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
projectHome=${scriptDir%%/uc-common/*}

echo;
echo "##############################################################################################################"
echo "# Script: $scriptName"

source ./.lib/functions.sh

##############################################################################################################################
# Settings

    # logging & debug: ansible
    ansibleLogFile="./tmp/ansible.log"
    export ANSIBLE_LOG_PATH="$ansibleLogFile"
    export ANSIBLE_DEBUG=False
    export ANSIBLE_VERBOSITY=3
    # logging: ansible-solace
    export ANSIBLE_SOLACE_LOG_PATH="./tmp/ansible-solace.log"
    export ANSIBLE_SOLACE_ENABLE_LOGGING=True

    generatedSrcDir="./tmp/generated"
    generatedDestDirs=(
      "$projectHome/uc-non-persistent/shared-setup"
    )

##############################################################################################################################
# Prepare

mkdir ./tmp > /dev/null 2>&1
rm -f ./tmp/* > /dev/null 2>&1

##############################################################################################################################
# Run
  # select inventory
  inventory=$(assertFile "./tmp/generated/inventory.sc-service.az_use_case_perf_tests.json") || exit
  # select account(s) inside inventory
  accounts="all"
  playbook="./playbook.get.yml"
  ansible-playbook -i $inventory \
                    $playbook \
                    --extra-vars "SOLACE_CLOUD_ACCOUNTS=$accounts"
  if [[ $? != 0 ]]; then echo ">>> ERROR ..."; echo; exit 1; fi

##############################################################################################################################
# Copy
echo "# generated files:"
ls -la $generatedSrcDir/*
echo "# copied to:"
for destDir in ${generatedDestDirs[@]}; do
  [ ! -d $destDir ] && (echo ">>> ERROR: directory $destDir DOES NOT exists."; exit)
  cp -r $generatedSrcDir/*.json $destDir
  ls -la $generatedSrcDir/*.json
done




###
# The End.
