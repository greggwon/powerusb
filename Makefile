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
	cd hidapi;    make clean
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

hidapi/CMakeCache.txt: hidapi/.git
	cd hidapi;cmake . 

hidapi/.git:
	git clone http://github.com/libusb/hidapi.git
