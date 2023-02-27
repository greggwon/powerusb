#!/bin/bash

set -x
path=${1:-/usr/local}

# This should install all of the tooling and library dependencies needed for deployment and build
sudo apt-get install libudev1 libudev-dev libusb-1.0-0 libusb-1.0-0-dev libhidapi-hidraw0 libhidapi-libusb0

sudo cp bin/powerusb ${path}/bin
sudo cp lib/libpowerusb.so ${path}/lib
sudo cp man/powerusb.1 ${path}/man/man1/powerusb.1
