#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

# check inputs
if [ -z "$RUN_ID" ]; then echo "no RUN_ID env var found" >>/dev/stderr; exit 1; fi
if [ -z "$SAMPLE_NUM" ]; then echo "no SAMPLE_NUM env var found" >>/dev/stderr; exit 1; fi
if [ -z "$TEMPLATE_FILE" ]; then echo "no TEMPLATE_FILE env var found" >>/dev/stderr; exit 1; fi
  if [[ ! -f "$TEMPLATE_FILE" ]]; then echo "template file: '$TEMPLATE_FILE' not found." >>/dev/stderr; exit 1; fi
if [ -z "$START_TIMESTAMP_STR" ]; then echo "no START_TIMESTAMP_STR env var found" >>/dev/stderr; exit 1; fi
if [ -z "$STATS_INPUT" ]; then echo "no STATS_INPUT env var found" >>/dev/stderr; exit 1; fi
if [ -z "$STATS_NAME" ]; then echo "no STATS_NAME env var found" >>/dev/stderr; exit 1; fi

vpnStatsJson=$( cat $TEMPLATE_FILE | jq -r .) || exit
vpnStatsJson=$( echo $vpnStatsJson | jq -r '.sample_start_timestamp=env.START_TIMESTAMP_STR' )
vpnStatsJson=$( echo $vpnStatsJson | jq -r '.run_id=env.RUN_ID')
vpnStatsJson=$( echo $vpnStatsJson | jq -r '.sample_num=env.SAMPLE_NUM')
vpnStatsJson=$( echo $vpnStatsJson | jq -r '.sample_corr_id=env.RUN_ID + "." + env.SAMPLE_NUM')
vpnStatsJson=$( echo $vpnStatsJson | jq -r '.meta.stats_name=env.STATS_NAME' )
vpnStatsJson=$( echo $vpnStatsJson | jq -r '.metrics=(env.STATS_INPUT | fromjson)')

echo $vpnStatsJson

###
# The End.
