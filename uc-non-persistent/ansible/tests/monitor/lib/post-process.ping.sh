#!/bin/bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

# check inputs
if [ -z "$PING_OUTPUT" ]; then echo "no PING_OUTPUT env var found" >>/dev/stderr; exit 1; fi
if [ -z "$TEMPLATE_FILE" ]; then echo "no TEMPLATE_FILE env var found" >>/dev/stderr; exit 1; fi
  if [[ ! -f "$TEMPLATE_FILE" ]]; then echo "template file: '$TEMPLATE_FILE' not found." >>/dev/stderr; exit 1; fi
if [ -z "$START_TIMESTAMP_STR" ]; then echo "no START_TIMESTAMP_STR env var found" >>/dev/stderr; exit 1; fi
if [ -z "$RUN_ID" ]; then echo "no RUN_ID env var found" >>/dev/stderr; exit 1; fi
if [ -z "$SAMPLE_NUM" ]; then echo "no SAMPLE_NUM env var found" >>/dev/stderr; exit 1; fi

pingJson=$( cat $TEMPLATE_FILE | jq -r .) || exit
pingJson=$( echo $pingJson | jq -r '.sample_start_timestamp=env.START_TIMESTAMP_STR' )
pingJson=$( echo $pingJson | jq -r '.run_id=env.RUN_ID')
pingJson=$( echo $pingJson | jq -r '.sample_num=env.SAMPLE_NUM')
pingJson=$( echo $pingJson | jq -r '.sample_corr_id=env.RUN_ID + "." + env.SAMPLE_NUM')

lineCount=0
while IFS= read line; do
  export lineCount
  export line
  pingJson=$( echo $pingJson | jq -r '.meta.log_file[env.lineCount|tonumber]=env.line' )

  #  test matching
  export rtt_match=$(expr "$line" : "rtt")
  # pingJson=$( echo $pingJson | jq -r '.meta.matches[env.lineCount|tonumber]=env.rtt_match')
  if [ $rtt_match -gt 0 ]; then
      # parse rtt line
      # get the values
      export rtt_values=${line#rtt min/avg/max/mdev = }
      # pingJson=$( echo $pingJson | jq -r '.metrics.rtt_values=env.rtt_values')
      # get the unit
        export unit=$(expr "$rtt_values" : '.*\([a-z].*[a-z]\)')
      # min_val
        export val=$(expr "$rtt_values" : '\(.[0-9]*\..[0-9]*\)')
        pingJson=$( echo $pingJson | jq -r '.metrics.ping.rtt_min={"value":env.val|tonumber, "unit":env.unit}')
        # delete min_val
        export rtt_values=${rtt_values#$val/}
      # pingJson=$( echo $pingJson | jq -r '.metrics.rtt_values_no_min=env.rtt_values')
      # avg_val
        export val=$(expr "$rtt_values" : '\(.[0-9]*\..[0-9]*\)')
        pingJson=$( echo $pingJson | jq -r '.metrics.ping.rtt_avg={"value":env.val|tonumber, "unit":env.unit}')
        # delete avg_val
        export rtt_values=${rtt_values#$val/}
      # pingJson=$( echo $pingJson | jq -r '.metrics.rtt_values_no_avg=env.rtt_values')
      # max_val
        export val=$(expr "$rtt_values" : '\(.[0-9]*\..[0-9]*\)')
        pingJson=$( echo $pingJson | jq -r '.metrics.ping.rtt_max={"value":env.val|tonumber, "unit":env.unit}')
        # delete max_val
        export rtt_values=${rtt_values#$val/}
      # mdev_val
        export val=$(expr "$rtt_values" : '\(.[0-9]*\..[0-9]*\)')
        pingJson=$( echo $pingJson | jq -r '.metrics.ping.rtt_mdev={"value":env.val|tonumber, "unit":env.unit}')
        # delete max_val
        # export rtt_values=${rtt_values#$val/}
  fi
  ((lineCount++))
done < <(printf '%s\n' "$PING_OUTPUT")

echo $pingJson

###
# The End.
