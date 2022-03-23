PowerUSB - http://www.powerusb.com command line and library interface

This project is a rewrite and rework of the powerusb library and command line tool example that the PowerUSB company makes available for use on linux based systems.

There were numerous issues with the sourcecode structure and that I worked through to create a new version of both.

----------

To install and use the library and/or command line application, pull down this repo and then use "sudo make install" to install the shared libraries and the application.  If you perform just "sudo make", you will get all the auxillary libraries installed, but the application will just be built.

DEPENDENCIES:
There are several things that need to be installed to support the use of the HID interface, USB and the build out of the associated tools.  At a minumum, most linux environments where the GNU tools for C and C++ may already be installed, the build should just work.  But, to help that be more likely, the following APT targets on Ubuntu can be installed using the following command:

# sudo apt-get install cmake libudev1 libudev-dev libusb-1.0-0 libusb-1.0-0-dev gcc g++ make

If there are additional tools that show up as dependencies outside of these, you can install them with "apt-get install."  The "apt-cache search <name>" command line can be used to find out what the actual package name is for something that you don't have installed but which is needed.
