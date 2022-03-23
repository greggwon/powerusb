#######################################################################################################
#
#
#
#
#
#
#######################################################################################################
.PHONY: all
all: cmd

.PHONY: clean
clean:
	rm -rf hidapi
	cd libpwrusb; make clean
	cd cmd;       make clean

.PHONY: install
install: cmd
	cd hidapi;    make install
	cd libpwrusb; make install
	cd cmd;       make install

.PHONY: cmd
cmd : hidapi libpwrusb
	cd cmd; make

.PHONY: libpwrusb
libpwrusb : 
	cd libpwrusb; make

.PHONY: hidapi
hidapi: hidapi/CMakeCache.txt
	cd hidapi;make install

hidapi/CMakeCache.txt: .checkusb .checkudev hidapi/.git
	cd hidapi;cmake . 

hidapi/.git: 
	git clone http://github.com/libusb/hidapi.git

.checkudev:
	( dpkg -s libudev1 >/dev/null || apt-get install libudev1 libudev-dev ) && touch .checkudev

.checkusb:
	( dpkg -s libusb-1.0-0 >/dev/null || apt-get install libusb-1.0-0 ) && touch .checkusb
