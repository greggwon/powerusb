#  PowerUSB Makefile
#
#  This Makefile needs to have some variation around the ncurses versions available and the hidapi
#  library build being needed.
#
#  Linux Ford 4.4.0-42-generic #62-Ubuntu SMP Fri Oct 7 23:11:45 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux
#     VERS=5
#     VERSDEV=5
#     BUILD_HID=
#     sudo make VERS=5 VERSDEV=5 BUILD_HID=
#
#######################################################################################################

VERS=6
VERS=5

VERSDEV=
VERSDEV=5

BUILD_HID=hidapi
BUILD_HID=

TOOLPKGS=\
	libncurses${VERS} \
	libncurses${VERSDEV}-dev \
	pkg-config \
	libudev1 \
	libudev-dev \
	libusb-1.0-0 \
	libusb-1.0-0-dev \
	cmake \
	gcc \
	g++ \
	make

LIBDIR=/usr/local/lib

.PHONY: all
all: cmd
	mkdir -p pwrusb/lib pwrusb/bin pwrusb/man
	cp cmd/powerusb.1 pwrusb/man/powerusb.1
	cp cmd/powerusb pwrusb/bin/powerusb
	cp libpwrusb/libpowerusb.so pwrusb/lib/libpowerusb.so
	cp install.sh pwrusb/install.sh

dist: all
	tar zcvf pwrusb-"`date +%Y%m%d`".tgz pwrusb
	cd watchdog;make dist
	mkdir -p dist/powerusb
	cp pwrusb-"`date +%Y%m%d`".tgz dist/powerusb
	cp watchdog/watchdog-"`date +%Y%m%d`".tgz dist/powerusb
	cp DIST.md dist/powerusb/README.md
	cd dist; tar cvf ../powerusb-"`date +%Y%m%d`".tgz powerusb


.PHONY: clean
clean:
	if [ -d "$(BUILD_HID)" ]; then rm -rf $(BUILD_HID) ;fi
	cd libpwrusb; make clean
	cd cmd;       make clean
	rm -f .checkusb .checkudev .checkhid
	rm -f powerusb-*.tgz
	rm -f pwrusb-*.tgz
	cd watchdog;make clean

.PHONY: install
install: cmd
	if [ -d "$(BUILD_HID)" ]; then cd $(BUILD_HID); make install;fi
	cd libpwrusb;   make install
	cd cmd;         make install
	cd watchdog;    make install

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
cmd: tools $(BUILD_HID) libpwrusb .checkusb .checkudev .checkhid
	@if [ ! -z "$(BUILD_HID)" ] ; then git submodule update --recursive --init;fi
	cd cmd; make

.PHONY: libpwrusb
libpwrusb:  tools
	cd libpwrusb; make install
	# make sure library is visible
	ldconfig -l $(LIBDIR)/libpowerusb.so
	ldconfig

.PHONY: hidapi
hidapi: $(BUILD_HID)/CMakeCache.txt tools
	cd $(BUILD_HID);make install || (rm CMakeCache.txt ; cmake . && make install)

$(BUILD_HID)/CMakeCache.txt: .checkusb .checkudev .checkhid $(BUILD_HID)/.git
	cd $(BUILD_HID);cmake . 

$(BUILD_HID)/.git: 
	git submodule update --recursive --init

.checkhid:
	apt-get install -y libhidapi-hidraw0 libhidapi-libusb0 libhidapi-dev && touch .checkhid

.checkudev:
	( (dpkg -s libudev1 >/dev/null && dpkg -s libudev-dev >/dev/null) || apt-get install libudev1 libudev-dev ) && touch .checkudev

.checkusb:
	( (dpkg -s libusb-1.0-0 >/dev/null && dpkg -s libusb-1.0-0-dev >/dev/null) || apt-get install libusb-1.0-0 libusb-1.0-0-dev ) && touch .checkusb

cleanup:	
	for p in nginx-common nginx nginx-core ngnix-full nginx-light nginx-extras cups-browsed;do sudo apt-get remove -y -f $$p;done
