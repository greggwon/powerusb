#!/bin/bash

###############################################################################################33

freePort=1       # we are not using this port for any assigned use yet
wifiPort=2       # wifi modem is on port 2
computerPort=3   # watchdog port is port #3

ping1=8.8.8.8
ping2=8.8.4.4
pingIntv=5
intv=200
pingcnt=3
resetFor=8
fails=2
maxwait=30

# We want to wait for the network test because on system startup, there may not be
# a complete network environment in place for a bit after startup.  So, we want to
# wait for (${intv}/3) * 6 seconds before checking network
waitRestart=`expr ${maxwait} - 6`
powerOffTime=10

VERBOSE= #-v
trap "POWERUSB_WAIT=1 powerusb ${VERBOSE} -S;exit 1" 2 3

opts=`getopt "vc:O:W:R:F:i:p:P:w:m:" "${@}"`
if [ "$?" -ne 0 ]; then
	echo "usage: $0 [-m maxwait] [-W interval] [-R resetPeriod] [-F failCount] [-p ping1-address] [-P ping2-address] [-O offTime] [-i pingInterval] [-w wait-restart-count] [-c ping-cnt]" >&2

	echo "`tput smso`NOTE:`tput rmso`" >&2
	echo "	Port 1: accessory or camera port" >&2
	echo "	Port 2: modem port" >&2
	echo "	Port 3: computer port" >&2
	echo "	Port 4: always on, no control for this port" >&2
	exit 2
fi
set -- $opts

export POWERUSB_WAIT=1

# set port 1 to default to on
# This is the computer port
powerusb ${VERBOSE} -p 1 -d -s on
powerusb ${VERBOSE} -p 1 -s on

# set port 2 to default to on
# This is the modem port
powerusb ${VERBOSE} -p 2 -d -s on
powerusb ${VERBOSE} -p 2 -s on

# On the watchdog powerusb this does nothing
# set port 3 to default to on
powerusb ${VERBOSE} -p 3 -d -s on
powerusb ${VERBOSE} -p 3 -s on

while [ "$#" -gt 1 ]
do
	case $1 in
		-v) VERBOSE=-v;;
		-m) maxwait=$2;shift;;
		-w) waitRestart=$2;shift;;
		-p) ping1=$2;shift;;
		-P) ping2=$2;shift;;
		-O) powerOffTime=$2;shift;;
		-i) pingIntv=$2;shift;;
		-c) pingcnt=$2;shift;;
		-W) intv=$2;shift;;
		-R) resetFor=$2;shift;;
		-F) fails=$2;shift;;
		*) echo "usage: $0 [-W interval] [-R resetPeriod] [-F failCount] [-p ping1-address] [-P ping2-address] [-O offTime] [-i pingInterval] [-w wait-restart-count] [-c ping-cnt]" >&2;exit 2;;
	esac
	shift
done
set -x
exec -- >/tmp/powerusb.trace$$ 2>&1

# on system shutdown, pet the dog one last time before exit
trap "powerusb ${VERBOSE} -R ${resetFor} -W `echo ${intv} / ${fails} | bc` -F ${fails};exit 0" 1 15

logger -t powerusb -p local3.info "Watchdog starting up"
sleepintv=`echo ${intv} / 3 | bc`
if [ "$sleepintv" -eq 0 ]; then
	sleepintv=1
fi

while :
do
	# restart/pet the watchdog
	powerusb ${VERBOSE} -R ${resetFor} -W `echo ${intv} / ${fails} | bc` -F ${fails}

	# Check that networking is working
	if ping -c ${pingcnt} -i ${pingIntv} ${ping1} >/dev/null; then
		err=$?
	else
		err=$?
		logger -t powerusb -p local3.info "Network ping failed to ping1=${ping1}: $err: wait=$waitRestart of ${maxwait}"
		# restart/pet the watchdog
		powerusb ${VERBOSE} -R ${resetFor} -W `echo ${intv} / ${fails} | bc` -F ${fails}
		# try the ping one more time
		ping -c ${pingcnt} -i ${pingIntv} ${ping2} >/dev/null
		err=$?
	fi
	# Check if ping actually worked
	if [ "$err" -ne 0 ]; then
		logger -t powerusb -p local3.info "Network ping failed to ping2=${ping2}: $err: wait=$waitRestart of ${maxwait}"

		# Ping failed if we've failed before, or time again, power cycle network port #2
		if [ "${waitRestart}" -eq ${maxwait} -o "${waitRestart}" -eq 0 ]; then
			# set the time for the collective time of sleeping to power-cycle the network and the watchdog interval
			powerusb ${VERBOSE} -R $(expr ${resetFor} + ${powerOffTime}) -W `echo ${intv} / ${fails} | bc` -F ${fails} && \
			logger -t powerusb -p local3.info "Power Cycling port #2 for ${powerOffTime}"
			# Turn off port #2
			powerusb ${VERBOSE} -p 2 -s off
			# keep it off for appropriate time
			sleep ${powerOffTime}
			# Touch watchdog again
			powerusb ${VERBOSE} -R ${resetFor} -W `echo ${intv} / ${fails} | bc` -F ${fails} && \
			# Turn the port on again
			powerusb ${VERBOSE} -p ${wifiPort} -s on
			logger -t powerusb -p local3.info "Power back on port #2"

			# Reset countdown to ${maxwait} times before we do this again
			if [ "${waitRestart}" -eq 0 ]; then
				waitRestart=${maxwait}
			fi
		fi
		# decrement the counter by one so that we won't power cycle for waitRestart*intv
		(((waitRestart=waitRestart-1)))
		logger -t powerusb -p local3.info "Network reset waiting=${waitRestart} more intervals=$sleepintv seconds"
	else
		if [ "$waitRestart" -lt ${maxwait} ]; then
			logger -t powerusb -p local3.info "Network access restored at ${waitRestart} intervals remaining"
		fi

		# reset to ${maxwait} so we will restart on next fail
		waitRestart=${maxwait}
	fi

	# Touch the watchdog again
	powerusb ${VERBOSE} -R ${resetFor} -W `echo ${intv} / ${fails} | bc` -F ${fails} && \

	# wait for next interval. 
	sleep $sleepintv
done
