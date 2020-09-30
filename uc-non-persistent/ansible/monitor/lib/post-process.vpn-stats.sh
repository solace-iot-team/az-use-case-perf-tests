#!/bin/bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

# usage:
# post-process.vpn-stats.sh vpn-stats.json vpn-stats-template.json {timestamp-string}
# ./post-process.vpn-stats.sh ../tmp/vpn-stats/vpn-stats.current.json './vpn-stats.template.json' '2020-09-28 18:09:02.049631'
# stdout: the json
# stderr: any errors

if [[ ! -f "$1" ]]; then echo "vpn-stats file: '$1' not found." >>/dev/stderr; exit 1; fi
if [[ ! -f "$2" ]]; then echo "template file: '$1' not found." >>/dev/stderr; exit 1; fi
if [ -z "$3" ]; then echo "no timestamp string received" >>/dev/stderr; exit 1; fi
if [ -z "$RUN_ID" ]; then echo "no RUN_ID env var received" >>/dev/stderr; exit 1; fi
vpnInputStatsFile=$1
vpnTemplateStatsFile=$2
export timestamp=$3
export vpnInputStatsJson=$(cat $vpnInputStatsFile | jq -r .) || exit
vpnStatsJson=$(cat $vpnTemplateStatsFile | jq -r .) || exit
vpnStatsJson=$( echo $vpnStatsJson | jq -r '.timestamp=env.timestamp' )
vpnStatsJson=$( echo $vpnStatsJson | jq -r '.run_id=env.RUN_ID')
vpnStatsJson=$(echo $vpnStatsJson | jq -r '.metrics=(env.vpnInputStatsJson | fromjson)')

echo $vpnStatsJson

###
# The End.
