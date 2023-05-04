#!/bin/bash

###############################################################################################33


computerPort=3 # watchdog port is port #3
wifiPort=2
freePort=1 # we are not using this port for any assigned use yet

ping1=8.8.8.8
ping2=8.8.4.4
pingIntv=7
intv=200
pingcnt=4
resetFor=8
fails=2
waitRestart=10
powerOffTime=10

VERBOSE= #-v
trap "POWERUSB_WAIT=1 powerusb ${VERBOSE} -S;exit 1" 2 3

opts=`getopt "vc:O:W:R:F:i:p:P:w:" "${@}"`
if [ "$?" -ne 0 ]; then
	echo "usage: $0 [-W interval] [-R resetPeriod] [-F failCount] [-p ping1-address] [-P ping2-address] [-O offTime] [-i pingInterval] [-w wait-restart-count] [-c ping-cnt]" >&2

	echo "`tput smso`NOTE:`tput rmso`" >&2
	echo "	Port 1: computer port" >&2
	echo "	Port 2: modem port" >&2
	echo "	Port 3: accessory port" >&2
	echo "	Port 4: always on, no control port" >&2
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

# set port 3 to default to on
powerusb ${VERBOSE} -p 3 -d -s on
powerusb ${VERBOSE} -p 3 -s on

while [ "$#" -gt 1 ]
do
	case $1 in
		-v) VERBOSE=-v;;
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

# on system shutdown, pet the dog one last time before exit
trap "powerusb ${VERBOSE} -R ${resetFor} -W `echo ${intv} / ${fails} | bc` -F ${fails};exit 0" 1 15

while :
do
	powerusb ${VERBOSE} -R ${resetFor} -W `echo ${intv} / ${fails} | bc` -F ${fails}

	if ping -c ${pingcnt} -i ${pingIntv} ${ping1} >/dev/null; then
		:
	else
		powerusb ${VERBOSE} -R ${resetFor} -W `echo ${intv} / ${fails} | bc` -F ${fails}
		ping -c ${pingcnt} -i ${pingIntv} ${ping2} >/dev/null
	fi
	if [ "$?" -ne 0 ]; then
		if [ "${waitRestart}" -eq 10 -o "${waitRestart}" -eq 0 ]; then
			# set the time for the collective time of sleeping to power-cycle the network and the watchdog interval
			powerusb ${VERBOSE} -R $(expr ${resetFor} + ${powerOffTime}) -W `echo ${intv} / ${fails} | bc` -F ${fails} && \
			powerusb ${VERBOSE} -p 2 -s off
			sleep ${powerOffTime}
			powerusb ${VERBOSE} -R ${resetFor} -W `echo ${intv} / ${fails} | bc` -F ${fails} && \
			powerusb ${VERBOSE} -p ${wifiPort} -s on
			if [ "${waitRestart}" -eq 0 ]; then
				waitRestart=10
			fi
		fi
		(((waitRestart=waitRestart-1)))
	else
		waitRestart=10
	fi
	powerusb ${VERBOSE} -R ${resetFor} -W `echo ${intv} / ${fails} | bc` -F ${fails} && \
	sleep `echo ${intv} / 3 | bc`
done
