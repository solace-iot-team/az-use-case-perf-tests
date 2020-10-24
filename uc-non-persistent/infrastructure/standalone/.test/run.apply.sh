#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

scriptDir=$(cd $(dirname "$0") && pwd);
scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));
projectHome=${scriptDir%/uc-non-persistent/*}
usecaseHome=$projectHome/uc-non-persistent

infrastructureId="test1"

cloudProviders=(
  "azure"
  "aws"
)

for cloudProvider in ${cloudProviders[@]}; do
  echo ">>> Standup $infrastructureId on $cloudProvider ..."

    export TERRAFORM_DIR="$scriptDir/../$cloudProvider"
    export TERRAFORM_VAR_FILE="$scriptDir/$infrastructureId.$cloudProvider.variables.tf"
    export TERRAFORM_STATE_FILE="$infrastructureId.$cloudProvider.terraform.tfstate"

    nohup ../_run.apply.sh > ./logs/$infrastructureId.$cloudProvider.$scriptName.out 2>&1 &

done


###
# The End.
