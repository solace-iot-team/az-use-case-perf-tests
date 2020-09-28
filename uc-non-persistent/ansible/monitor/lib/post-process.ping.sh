#!/bin/bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

# usage:
# cat ping.log | prost-process.ping.sh ping-template.json {timestamp-string}
# stdout: the json
# stderr: any errors

if [ ! -p /dev/stdin ]; then echo "no ping log input received" >>/dev/stderr; exit 1; fi
if [[ ! -f "$1" ]]; then echo "template file: '$1' not found." >>/dev/stderr; exit 1; fi
if [ -z "$2" ]; then echo "no timestamp string received" >>/dev/stderr; exit 1; fi

export timestamp=$2

pingJson=$(cat $1 | jq -r .)
pingJson=$( echo $pingJson | jq -r '.timestamp=env.timestamp' )

# If we want to read the input line by line
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
        pingJson=$( echo $pingJson | jq -r '.metrics.rtt_min={"value":env.val|tonumber, "unit":env.unit}')
        # delete min_val
        export rtt_values=${rtt_values#$val/}
      # pingJson=$( echo $pingJson | jq -r '.metrics.rtt_values_no_min=env.rtt_values')
      # avg_val
        export val=$(expr "$rtt_values" : '\(.[0-9]*\..[0-9]*\)')
        pingJson=$( echo $pingJson | jq -r '.metrics.rtt_avg={"value":env.val|tonumber, "unit":env.unit}')
        # delete avg_val
        export rtt_values=${rtt_values#$val/}
      # pingJson=$( echo $pingJson | jq -r '.metrics.rtt_values_no_avg=env.rtt_values')
      # max_val
        export val=$(expr "$rtt_values" : '\(.[0-9]*\..[0-9]*\)')
        pingJson=$( echo $pingJson | jq -r '.metrics.rtt_max={"value":env.val|tonumber, "unit":env.unit}')
        # delete max_val
        export rtt_values=${rtt_values#$val/}
      # mdev_val
        export val=$(expr "$rtt_values" : '\(.[0-9]*\..[0-9]*\)')
        pingJson=$( echo $pingJson | jq -r '.metrics.rtt_mdev={"value":env.val|tonumber, "unit":env.unit}')
        # delete max_val
        # export rtt_values=${rtt_values#$val/}
  fi
  ((lineCount++))
done

echo $pingJson

###
# The End.
