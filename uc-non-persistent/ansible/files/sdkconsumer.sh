#!/bin/bash
# Performance test script to spin up a couple of consumers to be used with sdkpublishers.sh
# The script takes the following arguments:
# ./${name}.sh <timeout> <number_of_clients> <topic> <fanout> <add_args>
# with timeout            = the time in seconds for how long to run the test
#      number_of_clients  = how many client processes to run
#      topic              = the base topic prefix to subscribe to
#      fanout             = the number of consumers on each topic
#      add_args           = any additional arguments to pass to sdkperf
#
#Adjust the following according to your needs and infrastructure
#number of cores to distribute your processes across - used by taskset to pin consumers to cores.
#Should match the number of cores on the perf host running the consumers.
no_cores=4

#set cleanup to false, if you need to debug something and look at the output
cleanup_at_end="true"

#Change the following constants only,if you really have to
name=sdkconsumers

#Parameters to control connect and reconnect behaviour of the clients
epl="SOLCLIENT_SESSION_PROP_CONNECT_TIMEOUT_MS,500,\
SOLCLIENT_SESSION_PROP_CONNECT_RETRIES,-1,\
SOLCLIENT_SESSION_PROP_RECONNECT_RETRIES,-1,\
SOLCLIENT_SESSION_PROP_RECONNECT_RETRY_WAIT_MS,200,\
SOLCLIENT_SESSION_PROP_CONNECT_RETRIES_PER_HOST,1"
rc=100

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
    wait
}

#wait for background processes to finish
waitall() {
  while [ $# -gt 0 ]; do
    wait $1 2>/dev/null
    shift
  done
}

#remove temporary files
cleanup() {
  rm -f result.txt
  rm -f ${name}_stats2.txt
  rm -f ${name}_stats3.txt

  rm -f result_sub.txt
  rm -f ${name}_stats_*.txt
  rm -f ${name}_stats-r1.txt
  rm -f ${name}_stats-r2.txt
}

#####################
####### main ########
#####################
#check input arguments
if [ $# -eq 0 ]; then
  echo "usage: ./${name}.sh <timeout> <number_of_clients> <topic> <fanout> <add_args>"
  exit 1
fi
if ! [ $1 -eq $1 2>/dev/null ]; then
  echo " number_of_clients needs to be an integer"
  exit 1
fi
timeout=$1
number_of_clients=$2
topic=$3
fanout=$4
add_args=${@:5}
unset pids
cleanup

echo "Starting ${number_of_clients} clients... (fanout: ${fanout})"
#j controls the core the task will be pinned to
j=1
for i in `seq 1 ${number_of_clients}`; do
  if [[ j -gt no_cores ]]; then
    #if j gets greater than the cores available, restart at 1
    j=1
  fi
  #cores are actually numbered starting from 0, so use c for core number
  c=$((${j}-1))
  for ((f=1; f<=${fanout}; f++)); do
    echo "fanout:${f}/${fanout}"
    if [[ ${add_args} == *"persistent"* ]]; then
      taskset -c ${c} ./sdkperf_c -asw=255 -epl=${epl} -rc=${rc} -tte=1 -stl=${topic}_${i} -pe -pea=0 -nagle ${add_args} &> ${name}_stats_${i}_${f}.txt &
      echo
    else
      taskset -c ${c} ./sdkperf_c -asw=255 -epl=${epl} -rc=${rc} -stl=${topic}_${i} -pe -pea=0 -nagle ${add_args} &> ${name}_stats_${i}_${f}.txt &
    fi
    pid=$!
    pids="${pids} ${pid}"
  done
  j=$((${j}+1))
done
echo "Running..."
#echo "Pids: ${pids}"
echo "[Press Ctrl+C or wait ${timeout}s to end...]"

sleep ${timeout}

killallp
#wait for last process to finish
waitall $pids
sleep 2
echo "Done, gathering stats...!"
echo " "
if grep -q 'Exception\|Error' ${name}_stats_*.txt; then
  echo "Errors occured during run:" | tee result_sub.txt
  cat ${name}_stats_*.txt | grep 'Exception\|Error' | tee -a result_sub.txt
else
  echo "Computing results"
  cat ${name}_stats_*.txt | grep "Computed receive" > ${name}_stats-r1.txt
  awk 'BEGIN { FS= " " } ; { print $7 }' ${name}_stats-r1.txt > ${name}_stats-r2.txt
  sum=`cat ${name}_stats-r2.txt | awk '{ sum += $1; } END { print sum; }'`
  echo "Sum across consumers: ${sum} (msg/sec)" | tee result_sub.txt
fi
if [[ "${cleanup_at_end}" = "true" ]]; then
  cleanup
fi
