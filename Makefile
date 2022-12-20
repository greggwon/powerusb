#######################################################################################################
#
#
#
#
#
#
#######################################################################################################

TOOLPKGS=libncurses6 libncurses-dev cmake pkg-config libudev1 libudev-dev libusb-1.0-0 libusb-1.0-0-dev
LIBDIR=/usr/local/lib
.PHONY: all
all: cmd

.PHONY: clean
clean:
	rm -rf hidapi
	cd libpwrusb; make clean
	cd cmd;       make clean
	rm -f .checkusb .checkudev

.PHONY: install
install: cmd
	git submodule update --recursive --init
	cd hidapi;    make install
	cd libpwrusb; make install
	cd cmd;       make install
	cd watchdog;  make install

.PHONY: tools
tools: .tools

.tools: Makefile
	@for j in $(TOOLPKGS) \
	;do \
		if dpkg -s $$j >/dev/null; then \
			echo `tput smul`$$j is installed`tput rmul`;\
			dpkg -s $$j | egrep 'Version|Package|Status';\
		else \
			echo `tput smso`installing $$j`tput rmso`;\
			if apt-get install $$j ; then \
				:;\
			else \
				echo `tput smso` $$j cannot be installed `tput rmso`;\
				exit 1 ;\
			fi; \
		fi; \
	done && touch .tools
 
.PHONY: cmd
cmd: tools hidapi libpwrusb
	cd cmd; make

.PHONY: libpwrusb
libpwrusb:  tools
	cd libpwrusb; make install
	# make sure library is visible
	ldconfig -l $(LIBDIR)/libpowerusb.so
	ldconfig

.PHONY: hidapi
hidapi: hidapi/CMakeCache.txt tools
	cd hidapi;make install || (rm CMakeCache.txt ; cmake . && make install)

hidapi/CMakeCache.txt: .checkusb .checkudev hidapi/.git
	cd hidapi;cmake . 

hidapi/.git: 
	git submodule update --recursive --init

.checkudev:
	( (dpkg -s libudev1 >/dev/null && dpkg -s libudev-dev >/dev/null) || apt-get install libudev1 libudev-dev ) && touch .checkudev

.checkusb:
	( (dpkg -s libusb-1.0-0 >/dev/null && dpkg -s libusb-1.0-0-dev >/dev/null) || apt-get install libusb-1.0-0 libusb-1.0-0-dev ) && touch .checkusb
