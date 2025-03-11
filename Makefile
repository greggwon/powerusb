BIN=/usr/local/bin

powerusb: nothing

nothing:
	@echo "use 'sudo make install' to install into ${BIN}"

install: ${BIN}/powerusb

${BIN}/powerusb: powerusb
	cp $< $@
	chmod +x $@

BASEDIR=/
OLDFILES=\
	${BASEDIR}etc/rsyslog.d/51-powerusb.conf \
	${BASEDIR}etc/logrotate.d/powerusb \
	${BASEDIR}usr/local/man/man5/powerusb.service.5 \
	${BASEDIR}usr/local/bin/watchdog \
	${BASEDIR}etc/systemd/system/powerusb.service

removeold:
	rm -f ${OLDFILES}
	service rsyslog restart
	systemctl daemon-reload
