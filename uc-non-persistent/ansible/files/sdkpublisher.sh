#!/bin/bash
# Performance test script to spin up a couple of publishers to be used with sdkconsumers.sh
# The script takes the following arguments:
# ./${name}.sh <timeout> <max_msg_rate> <number_of_clients> <message_number> <topic> <add_args>
# with timeout            = the time in seconds for how long to run the test
#      max_msg_rate       = the rate to achieve across all publishers on this host
#      number_of_clients  = how many client processes to run
#      message_number     = how many messages to publish
#      topic              = the base topic prefix to subscribe to
#      add_args           = any additional arguments to pass to sdkperf
# 
#
#Adjust the following according to your needs and infrastructure
#number of cores to distribute your processes across - used by taskset to pin publishers to cores. 
#Should match the number of cores on the perf host running the publishers.
no_cores=8

#set cleanup to false, if you need to debug something and look at the output
cleanup_at_end="false"

#Change the following constants only,if you really have to
name=sdkpublishers

#Parameters to control connect and reconnect behaviour of the clients
epl="SOLCLIENT_SESSION_PROP_CONNECT_TIMEOUT_MS,500,\
SOLCLIENT_SESSION_PROP_CONNECT_RETRIES,-1,\
SOLCLIENT_SESSION_PROP_RECONNECT_RETRIES,-1,\
SOLCLIENT_SESSION_PROP_RECONNECT_RETRY_WAIT_MS,200,\
SOLCLIENT_SESSION_PROP_CONNECT_RETRIES_PER_HOST,1"
rc=100

#return code
returncode=0

#Trap control-c to graciously shut down the clients and give chance to collect stats...
trap 'killallp' INT

killallp() {
    trap '' INT TERM     # ignore INT and TERM while shutting down
    echo " "
    echo "**** Shutting down... ****"     # added double quotes
    killall -2 sdkperf_c     # use when running script directly
    sleep 3
    killall -15 sdkperf_c      # use when running from ansible
    sleep 3
    killall -9 sdkperf_c      # use when running from ansible
    wait
}
#wait for background processes to finish
waitall() {
  while [ $# -gt 0 ]; do
    wait $1 2>/dev/null
    #wait $1
    shift
  done
}
#remove temporary files
cleanup() {
  rm -f result.txt
  rm -f ${name}_stats2.txt
  rm -f ${name}_stats3.txt

  rm -f result_pub.txt
  rm -f ${name}_stats_*.txt
  rm -f ${name}_stats-r1.txt
  rm -f ${name}_stats-r2.txt
}

#####################
####### main ########
#####################
#check input arguments
if [ $# -eq 0 ]; then
  echo "usage: ./${name}.sh <timeout> <max_msg_rate> <number_of_clients> <message_number> <topic> <add_args>"
  exit 1
fi
if ! [ $1 -eq $1 2>/dev/null ]; then
  echo " timeout needs to be an integer"
  exit 1
fi
if ! [ $2 -eq $2 2>/dev/null ]; then
  echo " max_msg_rate needs to be an integer"
  exit 1
fi
if ! [ $3 -eq $3 2>/dev/null ]; then
  echo " number_of_clients needs to be an integer"
  exit 1
fi
if ! [ $4 -eq $4 2>/dev/null ]; then
  echo " message_number needs to be an integer"
  exit 1
fi

timeout=$1
max_msg_rate=$2
number_of_clients=$3
mn=$4
topic=$5
add_args=${@:6}
export rate=$((${max_msg_rate}/${number_of_clients}))
export mn=$((${mn}/${number_of_clients}))

#cleanup files and environment
unset pids pid
cleanup

echo "Starting ${number_of_clients} clients..."
#j controls the core the task will be pinned to
j=1
for i in `seq 1 ${number_of_clients}`; do
  if [[ j -gt no_cores ]]; then
    #if j gets greater than the cores available, restart at 1
    j=1
  fi
  #cores are actually numbered starting from 0, so use c for core number
  c=$((${j}-1))
  #start process in background
  echo "sdkperf_c -apw=255 -epl=${epl} -rc=${rc} -mr=${rate} -mn=${mn} -ptl=${topic}_${i} -psm -nagle ${add_args}"
  taskset -c ${c} ./sdkperf_c -apw=255 -epl=${epl} -rc=${rc} -mr=${rate} -mn=${mn} -ptl=${topic}_${i} -psm -nagle ${add_args} &> ${name}_stats_${i}.txt &
  pid=$!
  pids="${pids} ${pid}"
  j=$((${j}+1))
done
echo "Running..."
echo "[Press Ctrl+C or wait ${timeout}s to end...]"
sleep ${timeout}

killallp
#wait for last process to finish
waitall $pids
echo "Done, checking results and gathering stats...!"
sleep 2
echo " "
if grep -q 'Exception\|Error' ${name}_stats_*.txt; then
  echo "Errors occured during run:" | tee result_pub.txt
  cat ${name}_stats_*.txt | grep "Exception\|Error" | tee -a result_pub.txt
else
  echo "Computing results"
  cat ${name}_stats_*.txt | grep "Computed publish" > ${name}_stats-r1.txt
  awk 'BEGIN { FS= " " } ; { print $6 }' ${name}_stats-r1.txt > ${name}_stats-r2.txt
  sum=`cat ${name}_stats-r2.txt | awk '{ sum += $1; } END { print sum; }'`
  echo "Sum across publishers: ${sum} (msg/sec)" | tee result_pub.txt
fi
if [[ "${cleanup_at_end}" = "true" ]]; then
  cleanup
fi
