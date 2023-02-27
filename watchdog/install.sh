#!/bin/bash

path=${1:-/usr/local}
sudo cp bin/watchdog ${path}/bin/watchdog
sudo mkdir -p ${path}/man/man5
sudo cp man/powerusb.service.5 ${path}/man/man5/powerusb.service.5

sudo cp svc/powerusb.service /etc/systemd/system/powerusb.service
sudo systemctl daemon-reload
