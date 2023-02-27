#!/bin/bash

path=${1:-/ur/local}
set -x
sudo cp dist/bin/powerusb ${path}/bin
sudo cp dist/lib/libpowerusb.so ${path}/lib
sudo cp dist/man/powerusb.1 ${path}/man/man1/powerusb.1
