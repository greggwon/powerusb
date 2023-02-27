#!/bin/bash

path=${1:-/usr/local}
set -x
sudo cp bin/powerusb ${path}/bin
sudo cp lib/libpowerusb.so ${path}/lib
sudo cp man/powerusb.1 ${path}/man/man1/powerusb.1
