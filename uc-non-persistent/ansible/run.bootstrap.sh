#!/bin/bash


clear
echo; echo "##############################################################################################################"
echo

  ############################################################################################################################
  # SELECT
    # logging & debug: ansible
    export ANSIBLE_LOG_PATH="./ansible.log"
    export ANSIBLE_DEBUG=False
    # logging: ansible-solace
    export ANSIBLE_SOLACE_LOG_PATH="./ansible-solace.log"
    export ANSIBLE_SOLACE_ENABLE_LOGGING=True

    inventory="./inventory/bootstrap.yml"

  # END SELECT

##############################################################################################################################
# Prepare

rm -f ./*.log

##############################################################################################################################
# Run Centos VM bootstrap

  playbook="./broker.centos.bootstrap.playbook.yml"
  privateKeyFile="../keys/azure_key"

  ansible-playbook \
                    -i $inventory \
                    --private-key $privateKeyFile \
                    $playbook \
                    # -vvv

  if [[ $? != 0 ]]; then echo ">>> ERROR. aborting."; echo; exit 1; fi

##############################################################################################################################
# Run Broker bootstrap

  playbook="./broker.pubsub.bootstrap.playbook.yml"

  ansible-playbook \
                    -i $inventory \
                    $playbook \
                    # -vvv

  if [[ $? != 0 ]]; then echo ">>> ERROR. aborting."; echo; exit 1; fi


###
# The End.
