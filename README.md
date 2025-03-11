## POWER Control with Ambery power strip

	AMBERY - https://www.ambery.com/ip-p2.html

# Testing
You can use the following commands to see that everything is installed as required:

	powerusb -p 1 -s on  # Turn on port #1
	powerusb -p 1 -s off # Turn off port #1

The IP address is set to 192.168.55.10 by default.  The -a argument can be used to specify a different IP address if needed.

If you can see and/or hear the port#1 go on and then off with these two commands, then the rest of the application should work as needed.

# Installtion
To install and use the powerusb script, use the "make install" command to install the script into the /usr/local/bin directory.  Use BIN=/dir on the make command line to install it into 
another directory.

# Setup
The power strip has a web interface that should be used to setup the watchdog functionality.  Open a web browser and go to the IP address of the powerstrip to set it up.

There are instructions on the https://www.ambery.com/ip-p2.html web page that specify how to setup the watchdog features.
