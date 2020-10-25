#!/usr/bin/env bash
# ---------------------------------------------------------------------------------------------
# MIT License
# Copyright (c) 2020, Solace Corporation, Ricardo Gomez-Ulmke (ricardo.gomez-ulmke@solace.com)
# ---------------------------------------------------------------------------------------------

############################################################################################################################
# Check env vars

  if [ -z "$LOG_DIR" ]; then echo ">>> ERROR: missing env var 'LOG_DIR'"; exit 1; fi

##############################################################################################################################
# Check for errors in the logs
echo ">>> Scan logs for errors";
errors=$(grep -n -e "ERROR" $LOG_DIR/*.log);
if [ -z "$errors" ]; then
  echo ">>> SUCCESS: found no errors in log files";
  exit;
else
  echo ">>> WARNING: found errors in log files";
  errCount=0;
  while IFS= read line; do
    ((errCount++));
    echo $line;
  done < <(printf '%s\n' "$errors");
  exit 1;
fi;


###
# The End.
