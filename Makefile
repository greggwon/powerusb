BIN=/usr/local/bin

powerusb: nothing

nothing:
	@echo "use 'sudo make install' to install into ${BIN}"

install: ${BIN}/powerusb

${BIN}/powerusb: powerusb
	cp $< $@
	chmod +x $@
