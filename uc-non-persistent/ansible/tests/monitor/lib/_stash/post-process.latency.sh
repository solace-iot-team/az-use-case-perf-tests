#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

# check inputs
if [ -z "$LATENCY_OUTPUT" ]; then echo "no LATENCY_OUTPUT env var found" >>/dev/stderr; exit 1; fi
if [ -z "$TEMPLATE_FILE" ]; then echo "no TEMPLATE_FILE env var found" >>/dev/stderr; exit 1; fi
  if [[ ! -f "$TEMPLATE_FILE" ]]; then echo "template file: '$TEMPLATE_FILE' not found." >>/dev/stderr; exit 1; fi
if [ -z "$START_TIMESTAMP_STR" ]; then echo "no START_TIMESTAMP_STR env var found" >>/dev/stderr; exit 1; fi
if [ -z "$RUN_ID" ]; then echo "no RUN_ID env var found" >>/dev/stderr; exit 1; fi
if [ -z "$SAMPLE_NUM" ]; then echo "no SAMPLE_NUM env var found" >>/dev/stderr; exit 1; fi
if [ -z "$SDKPERF_COMMAND" ]; then echo "no SDKPERF_COMMAND env var found" >>/dev/stderr; exit 1; fi
if [ -z "$SDKPERF_PARAMS_JSON" ]; then echo "no SDKPERF_PARAMS_JSON env var found" >>/dev/stderr; exit 1; fi
if [ -z "$STATS_NAME" ]; then echo "no STATS_NAME env var found" >>/dev/stderr; exit 1; fi
if [ -z "$INVENTORY_HOST" ]; then echo "no INVENTORY_HOST env var found" >>/dev/stderr; exit 1; fi

latencyJson=$(cat $TEMPLATE_FILE | jq -r .) || exit
latencyJson=$( echo $latencyJson | jq -r '.sample_start_timestamp=env.START_TIMESTAMP_STR' )
latencyJson=$( echo $latencyJson | jq -r '.run_id=env.RUN_ID')
latencyJson=$( echo $latencyJson | jq -r '.sample_num=env.SAMPLE_NUM')
latencyJson=$( echo $latencyJson | jq -r '.sample_corr_id=env.RUN_ID + "." + env.SAMPLE_NUM')
latencyJson=$( echo $latencyJson | jq -r '.meta.stats_name=env.STATS_NAME' )
latencyJson=$( echo $latencyJson | jq -r '.meta.host=env.INVENTORY_HOST' )
latencyJson=$( echo $latencyJson | jq -r '.meta.sdkperf.command=env.SDKPERF_COMMAND' )
latencyJson=$( echo $latencyJson | jq -r '.meta.sdkperf.params=(env.SDKPERF_PARAMS_JSON | fromjson)' )

# input:
#  - two JSON objects
#  1) lpm
#  2) stats

# read input line by line
lineCount=0
lpmString=""
lpm_start_match=0
lpm_end_match=0
statsString=""
stats_start_match=0
while IFS= read line; do
  # echo "(begin $lineCount)lpm_start_match=$lpm_start_match, lpm_end_match=$lpm_end_match, stats_start_match=$stats_start_match, line=$line"
  export lineCount
  export line
  # record the original line
  # latencyJson=$( echo $latencyJson | jq -r '.meta.log_file[env.lineCount|tonumber]=env.line' )
  # lpm json
  if [[ $lpm_start_match -eq 0 && $lpm_end_match -eq 0 ]]; then lpm_start_match=$(expr "$line" : "{"); fi
  if [ $lpm_start_match -gt 0 ]; then
    lpmString+=$line
    if [[ $line =~ "}" ]]; then lpm_end_match=1; lpm_start_match=0; fi
  fi
  # stats json
  if [[ $lpm_end_match -eq 1 && $stats_start_match -eq 0 ]]; then stats_start_match=$(expr "$line" : "{"); fi
  if [ $stats_start_match -gt 0 ]; then
    statsString+=$line
  fi
  # echo "(end $lineCount)lpm_start_match=$lpm_start_match, lpm_end_match=$lpm_end_match, stats_start_match=$stats_start_match, line=$line"
  ((lineCount++))
done < <(printf '%s\n' "$LATENCY_OUTPUT")

# # create with msg numbers
# msg_num=0
# lpmListJson=$(echo "{}" | jq -r '.latency_per_message_list=[]')
# for lpm in $(echo $lpmString | jq '.latency_per_message_in_usec[]'); do
#   export lpm
#   export msg_num
#   lpmListJson=$(echo $lpmListJson | jq '.latency_per_message_list+=[{"msg_num":env.msg_num, "lat_usec":env.lpm}]')
#   ((msg_num++))
# done

export lpmString
export statsJson=$(echo $statsString | jq -r .)
latencyJson=$( echo $latencyJson | jq -r '.metrics[env.STATS_NAME]=(env.statsJson | fromjson)')
latencyJson=$( echo $latencyJson | jq -r '.metrics[env.STATS_NAME]+=(env.lpmString | fromjson)')

echo $latencyJson

###
# The End.
