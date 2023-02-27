# Powerusb command line
The pwrusb-20230227.tgz archive contains the library, command line tool, and manpage as well as an install.sh script to run to install
the powerusb command line tool and man page.

# Watchdog service
The watchdog-20230227.tgz archive contains the powerusb.service, powerusb.service.5, and watchdog as well as an install.sh script
to run to install the watchdog service and manpage.  This service will run the watchdog script under systemctl when it is enabled.
By default, the service is disabled on install.  It can then be enabled once all of the system details are finished up.

# Installation
For each of the two tar archives, use these commands to unpack them

	tar xvf pwrusb-*.tgz
	tar xvf watchdog-*.tgz

next, you need use to install.sh in each created subdirectory, with su privs, to perform the installation of each part.

	(cd pwrusb; sudo sh install.sh)
	(cd watchdog; sudo sh install.sh)

This will install all the pieces ready for use.  Since the watchdog service (powerusb.service) is disabled, it will not function,
until it is enabled.  To see the port mappings, use:

	/usr/local/bin/watchdog --help
	usage: /usr/local/bin/watchdog [-W interval] [-R resetPeriod] [-F failCount] [-p ping1-address]
			[-P ping2-address] [-O offTime] [-i pingInterval] [-w wait-restart-count]
			[-c ping-cnt]
	NOTE:
	port 1: computer port
	port 2: modem port
	port 3: accessory port
	port 4: always on, no control port

