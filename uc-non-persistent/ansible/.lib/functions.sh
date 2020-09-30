#!/bin/bash
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
    echo ">>> ERR: file='$file' does not exist. aborting." > /dev/tty
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

# function getDeployments() {
#     local deployments
#     if [[ $# != 1 ]]; then
#       echo "ERR>>> Usage: deployments='\$(getDeployments "deployment-file-pattern")'" 1>&2
#       return 1
#     fi
#     local deploymentFilePattern=$1
#
#     deployments=$(ls $deploymentFilePattern | grep -v "template.deployment.json$")
#
#     if [[ $? != 0 ]]; then
#         echo "ERR>>> cannot find files with pattern=$deploymentFilePattern." 1>&2
#         return 1
#     fi
#     echo $deployments
#     return 0
# }
#
# function chooseDeployment() {
#   if [[ $# != 1 ]]; then
#       echo "ERR>>> Usage: deploymentFile='\$(chooseDeployment "deployment-file-pattern")'" 1>&2
#       return 1
#   fi
#   deploymentFilePattern=$1
#   deployments=$(getDeployments "$deploymentFilePattern")
#   if [[ $? != 0 ]]; then exit 1; fi
#   echo 1>&2
#   echo "Choose a deployment: " 1>&2
#   echo 1>&2
#   counter=0
#   for deployment in $deployments ; do
#     local d="${deployment##$1/}"
#     echo "($counter): $d" 1>&2
#     let counter=$counter+1
#   done
#   echo 1>&2
#   let numDeployments=$counter-1
#
#   if [ $counter -lt 1 ]; then echo "ERR >>> no deployments found." 1>&2; exit 1; fi
#
#   read -p "Enter 0-$numDeployments: " choice
#
#   if [[ ! "$choice" =~ ^[0-9]+$ ]] || [ ! "$choice" -ge 0 ] || [ ! "$choice" -le "$numDeployments" ]; then
#     echo "Choose 0-$numDeployments, your choice:$choice is not valid" 1>&2
#     return 2
#   fi
#
#   # doesn't look like deployments is an array
#   #echo "your choice=${deployments[$choice]}" 1>&2
#
#   counter=0;
#   for chosenDeployment in $deployments ; do
#     if [ "$counter" -eq "$choice" ]; then break; fi
#     let counter=$counter+1
#   done
#
#   echo $chosenDeployment
#   return 0
#
# }
#
###
# The End.
