#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

scriptDir=$(cd $(dirname "$0") && pwd);
scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
projectHome=${scriptDir%/uc-non-persistent/*}
usecaseHome=$projectHome/uc-non-persistent

infrastructureId="1-auto"

cloudProviders=(
  "azure"
  "aws"
)

export TF_LOG=INFO

rm -f "$scriptDir/logs/$scriptName.out"
touch "$scriptDir/logs/$scriptName.out"

scriptPids=""
for cloudProvider in ${cloudProviders[@]}; do
  echo ">>> Standup $infrastructureId on $cloudProvider ..." >> $scriptDir/logs/$scriptName.out

    export TERRAFORM_DIR="$scriptDir/../$cloudProvider"
    export TERRAFORM_VAR_FILE="$scriptDir/$infrastructureId.$cloudProvider.tfvars.json"
    export TERRAFORM_STATE_FILE="$infrastructureId.$cloudProvider.terraform.tfstate"
    export TF_LOG_PATH="$scriptDir/logs/$infrastructureId.$cloudProvider.$scriptName.terraform.log"
    rm -f $TF_LOG_PATH

    callScript=_run.apply.sh
    nohup ../$callScript > $scriptDir/logs/$infrastructureId.$cloudProvider.$callScript.out 2>&1 &
    scriptPids+=" $!"
    # ../_run.apply.sh

done


##############################################################################################################################
# monitor if 1 has failed
FAILED=0
while true; do
  wait -n || {
    code="$?"
    if [ $code = "127" ]; then
      # 127:
      # last background job has exited successfully
      # or: command was not found
      FAILED=0
    else
      FAILED=1
    fi
    break
  }
done;

if [ "$FAILED" -gt 0 ]; then
  echo ">>> FINISHED:FAILED - $scriptName" >> $scriptDir/logs/$scriptName.out
else
  echo ">>> FINISHED:SUCCESS - $scriptName" >> $scriptDir/logs/$scriptName.out
fi

###
# The End.
