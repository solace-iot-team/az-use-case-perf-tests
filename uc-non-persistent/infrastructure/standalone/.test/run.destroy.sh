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
  echo ">>> Destroy $infrastructureId on $cloudProvider ..."

    export TERRAFORM_DIR="$scriptDir/../$cloudProvider"
    export TERRAFORM_STATE_FILE="$infrastructureId.$cloudProvider.terraform.tfstate"

    nohup ../_run.destroy.sh > ./logs/$infrastructureId.$cloudProvider.$scriptName.out 2>&1 &

done


###
# The End.
