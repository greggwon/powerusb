############################################################################
#
# Makefile for installing powerusb watchdog service.
#
############################################################################

all:
	@echo "The install target will install watchdog.sh into /usr/local/bin"
	@echo "and install watchdog.service for systemd to use."

install: /usr/local/bin/watchdog \
	/etc/systemd/system/powerusb.service \
	/usr/local/man/man5/powerusb.service.5


/usr/local/man/man5/powerusb.service.5: powerusb.service.5 /usr/local/man/man5
	cp powerusb.service.5 /usr/local/man/man5/powerusb.service.5

/usr/local/man/man5:
	mkdir $@


/usr/local/bin/watchdog: watchdog.sh
	cp watchdog.sh /usr/local/bin/watchdog

/etc/systemd/system/powerusb.service: watchdog.service
	cp watchdog.service /etc/systemd/system/powerusb.service
	systemctl daemon-reload
