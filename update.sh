#!/bin/bash

echo "Updating apt sources" >&2
sleep 1
sudo apt-get update
echo "Removing unneeded/corrupt packages" >&2

sleep 1
for p in nginx-common nginx nginx-core ngnix-full nginx-light nginx-extras cups-browsed
do
	sudo apt-get remove -y -f $p
done

echo "Installing base packages for PWRUSB HID support" >&2
sleep 1
sudo apt-get install libudev1 libudev-dev libusb-1.0-0 libusb-1.0-0-dev gcc g++ make cmake
