############################################################################
#
# Makefile for installing powerusb watchdog service.
#
############################################################################

BASEDIR=/

DIRS= \
	${BASEDIR}usr/local/bin \
	${BASEDIR}etc/systemd/system \
	${BASEDIR}usr/local/man/man5 \
	${BASEDIR}etc/logrotate.d \
	${BASEDIR}etc/rsyslog.d

all:
	@echo "The 'install' target will install watchdog.sh into /usr/local/bin"
	@echo "and install watchdog.service for systemd to use and requires sudo."
	@echo ""
	@echo "The 'dist' target will create a tar file named"
	@echo "  watchdog-`date +%Y%m%d`.tgz"
	@echo "which contains all the pieces from the watchdog service"
dist:
	mkdir -p watchdog/bin watchdog/man watchdog/svc
	cp powerusb.service.5 watchdog/man/powerusb.service.5
	cp watchdog.service watchdog/svc/powerusb.service 
	cp watchdog.sh watchdog/bin/watchdog
	cp install.sh watchdog
	tar cf watchdog-`date +%Y%m%d`.tgz watchdog
	@echo "`tput smso`NOTE: created output file:`tput rmso`"
	@ls -ltra watchdog-`date +%Y%m%d`.tgz

.PHONY: install
install: ${DIRS} \
	${BASEDIR}etc/systemd/system/powerusb.service \
	${BASEDIR}usr/local/man/man5/powerusb.service.5 \
	${BASEDIR}etc/rsyslog.d/51-powerusb.conf \
	${BASEDIR}etc/logrotate.d/powerusb \
	${BASEDIR}usr/local/bin/watchdog

dirs: ${DIRS}

${BASEDIR}etc/rsyslog.d/51-powerusb.conf : powerusb.syslog
	cp powerusb.syslog $@
	@echo `tput smso`NOTE: restarting rsyslog to read powerusb.syslog config file`tput rmso`
	service rsyslog restart

${BASEDIR}etc/logrotate.d/powerusb : powerusb.rotate
	@echo `tput smso`NOTE: logrotate runs out of cron, next run will see this file`tput rmso`
	cp powerusb.rotate $@

${BASEDIR}usr/local/man/man5/powerusb.service.5: powerusb.service.5 ${BASEDIR}usr/local/man/man5
	cp powerusb.service.5 ${BASEDIR}usr/local/man/man5/powerusb.service.5

${DIRS}:
	mkdir -p $@


${BASEDIR}usr/local/bin/watchdog: watchdog.sh
	cp watchdog.sh ${BASEDIR}usr/local/bin/watchdog

${BASEDIR}etc/systemd/system/powerusb.service: watchdog.service
	cp watchdog.service ${BASEDIR}etc/systemd/system/powerusb.service
	systemctl daemon-reload

clean:
	rm -rf watchdog-*.tgz watchdog
