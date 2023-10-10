#!/bin/bash

set -x
path=${1:-/usr/local}

enable=disable
echo $0: `tput smso`powerusb service is ${enable}d by default`tput rmso`

sudo cp bin/watchdog ${path}/bin/watchdog
sudo mkdir -p ${path}/man/man5
sudo cp man/powerusb.service.5 ${path}/man/man5/powerusb.service.5

sudo cp svc/powerusb.service /etc/systemd/system/powerusb.service
sudo systemctl daemon-reload
sudo systemctl ${enable} powerusb
sudo systemctl status powerusb
sudo systemctl restart rsyslog
