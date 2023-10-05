# POWERUSB Refactor

	PowerUSB - http://www.powerusb.com command line and library interface

This project is a rewrite and rework of the powerusb library and command line tool example that the PowerUSB company makes available for use on linux based systems.

There were numerous issues with the sourcecode structure which I worked through to create this new version.

# Building
Pull down this repo into an appropriate direcctory. In order to build the powerusb library and the commandline tool, the USBHID libraries need to built and installed. The makefile will clone and build the http://github.com/libusb/hidapi.git repository when the 'all' target (the default) is built.  An admin priviledge level is required to install these needed libraries into system directories.  If you perform just "sudo make", you will get all the auxillary libraries installed, but the application will just be built in place, in the 'cmd' subdirectory.

# Testing
You can use the following commands to see that everything is installed as required:

	powerusb -p 1 -s on  # Turn on port #1
	powerusb -p 1 -s off # Turn off port #1

If you can see and/or hear the port#1 go on and then off with these two commands, then the rest of the application should work as needed.

# Installtion
To install and use the library and/or command line application, use the update.sh script first, to fixup the environment and install any needed packages.  Next use "sudo make install" to install the shared libraries and the application.

# Dependencies
There are several things that need to be installed to support the use of the HID interface, USB and the build out of the associated tools.  The above mentioned update.sh script will do these tasks for you without demanding 'make' or other tools to already be installed.  At a minumum, most linux environments where the GNU tools for C and C++ may already be installed, the build should just work.  But, to help that be more likely, the following APT targets on Ubuntu can be installed using the following command:

	sudo apt-get install cmake libudev1 libudev-dev libusb-1.0-0 libusb-1.0-0-dev gcc g++ make

If there are additional tools that show up as dependencies outside of these, you can install them with "apt-get install <toolname>" in general.  The "apt-cache search <name>" command line can be used to find out what the actual package name is for something that you don't have installed but which is needed.
