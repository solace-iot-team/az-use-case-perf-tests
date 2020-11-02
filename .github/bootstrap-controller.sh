#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

#####################################################################################
# settings

    scriptDir=$(cd $(dirname "$0") && pwd);
    scriptName=$(basename $(test -L "$0" && readlink "$0" || echo "$0"));

# TODO:
# use apt-get and apt-cache instead of apt

#####################################################################################
# Update apt
CMD="sudo apt update";
echo ">>> cmd: $CMD"; $CMD; if [[ $? != 0 ]]; then echo ">>> ERROR: $scriptName:$CMD."; exit 1; fi

CMD="sudo apt -y upgrade";
echo ">>> cmd: $CMD"; $CMD; if [[ $? != 0 ]]; then echo ">>> ERROR: $scriptName:$CMD."; exit 1; fi

CMD="sudo apt install software-properties-common";
echo ">>> cmd: $CMD"; $CMD; if [[ $? != 0 ]]; then echo ">>> ERROR: $scriptName:$CMD."; exit 1; fi

CMD="sudo add-apt-repository ppa:deadsnakes/ppa -y";
echo ">>> cmd: $CMD"; $CMD; if [[ $? != 0 ]]; then echo ">>> ERROR: $scriptName:$CMD."; exit 1; fi

CMD="sudo apt update";
echo ">>> cmd: $CMD"; $CMD; if [[ $? != 0 ]]; then echo ">>> ERROR: $scriptName:$CMD."; exit 1; fi

#####################################################################################
# Python 3

CMD="sudo apt install python3";
echo ">>> cmd: $CMD"; $CMD; if [[ $? != 0 ]]; then echo ">>> ERROR: $scriptName:$CMD."; exit 1; fi

CMD="sudo apt install python3-pip -y";
echo ">>> cmd: $CMD"; $CMD; if [[ $? != 0 ]]; then echo ">>> ERROR: $scriptName:$CMD."; exit 1; fi

#####################################################################################
# Ansible & Ansible-Solace

CMD="sudo -H python3 -m pip install 'ansible>=2.9.11,<2.10.0'";
echo ">>> cmd: $CMD";
sudo -H python3 -m pip install 'ansible>=2.9.11,<2.10.0'
if [[ $? != 0 ]]; then echo ">>> ERROR: $scriptName:$CMD."; exit 1; fi

CMD="sudo -H python3 -m pip install ansible-solace";
echo ">>> cmd: $CMD"; $CMD; if [[ $? != 0 ]]; then echo ">>> ERROR: $scriptName:$CMD."; exit 1; fi

CMD="echo 'export ANSIBLE_PYTHON_INTERPRETER=/usr/bin/python3' > ~/.bash_profile";
echo ">>> cmd: $CMD";
echo 'export ANSIBLE_PYTHON_INTERPRETER=/usr/bin/python3' >> ~/.bash_profile
if [[ $? != 0 ]]; then echo ">>> ERROR: $scriptName:$CMD."; exit 1; fi

#####################################################################################
# Misc Tools

CMD="sudo apt install jq -y";
echo ">>> cmd: $CMD"; $CMD; if [[ $? != 0 ]]; then echo ">>> ERROR: $scriptName:$CMD."; exit 1; fi

CMD="sudo -H python3 -m pip install yq";
echo ">>> cmd: $CMD"; $CMD; if [[ $? != 0 ]]; then echo ">>> ERROR: $scriptName:$CMD."; exit 1; fi

CMD="sudo apt install unzip";
echo ">>> cmd: $CMD"; $CMD; if [[ $? != 0 ]]; then echo ">>> ERROR: $scriptName:$CMD."; exit 1; fi


#####################################################################################
# Switch to downloads directory
mkdir ~/downloads > /dev/null 2>&1
cd ~/downloads

#####################################################################################
# Azure CLI

CMD="curl -sL https://aka.ms/InstallAzureCLIDeb -o ./installcli.sh";
echo ">>> cmd: $CMD";
curl -sL https://aka.ms/InstallAzureCLIDeb -o ./installcli.sh
if [[ $? != 0 ]]; then echo ">>> ERROR: $scriptName:$CMD."; exit 1; fi

CMD="chmod u+x ./installcli.sh";
echo ">>> cmd: $CMD";
chmod u+x ./installcli.sh
 if [[ $? != 0 ]]; then echo ">>> ERROR: $scriptName:$CMD."; exit 1; fi

CMD="sudo ~/installcli.sh";
echo ">>> cmd: $CMD";
sudo ./installcli.sh
if [[ $? != 0 ]]; then echo ">>> ERROR: $scriptName:$CMD."; exit 1; fi

#####################################################################################
# Terraform

# https://releases.hashicorp.com/terraform/0.13.4/terraform_0.13.4_linux_amd64.zip
CMD="sudo wget -O ./terraform.zip https://releases.hashicorp.com/terraform/0.13.3/terraform_0.13.3_linux_amd64.zip";
echo ">>> cmd: $CMD"; $CMD; if [[ $? != 0 ]]; then echo ">>> ERROR: $scriptName:$CMD."; exit 1; fi

CMD="sudo unzip -o ./terraform.zip -d /usr/local/bin";
echo ">>> cmd: $CMD"; $CMD; if [[ $? != 0 ]]; then echo ">>> ERROR: $scriptName:$CMD."; exit 1; fi

#####################################################################################
# Solace Docker Image

CMD="sudo wget -O solace-pubsub-evaluation-docker.tar.gz https://products.solace.com/download/PUBSUB_DOCKER_EVAL";
echo ">>> cmd: $CMD"; $CMD; if [[ $? != 0 ]]; then echo ">>> ERROR: $scriptName:$CMD."; exit 1; fi

echo ">>> SUCCESS: bootstrapping VM."

###
# The End.
