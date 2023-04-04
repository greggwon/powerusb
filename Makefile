#######################################################################################################
#
#
#
#
#
#
#######################################################################################################

TOOLPKGS=\
	libncurses6 \
	libncurses-dev \
	cmake \
	pkg-config \
	libudev1 \
	libudev-dev \
	libusb-1.0-0 \
	libusb-1.0-0-dev \
	libhidapi-dev \
	libhidapi-hidraw0 \
	libhidapi-libusb0 \
	gcc \
	g++ \
	make

BUILDHID=hidapi
BUILDHID=

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
	if [ -d "${BUILDHID}" ]; then rm -rf ${BUILDHID} ;fi
	cd libpwrusb; make clean
	cd cmd;       make clean
	rm -f .checkusb .checkudev
	rm -f powerusb-*.tgz
	rm -f pwrusb-*.tgz
	cd watchdog;make clean

.PHONY: install
install: cmd
	if [ -d ${BUILDHID} ]; then cd ${BUILDHID}; make install;fi
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
cmd: tools ${BUILDHID} libpwrusb
	git submodule update --recursive --init
	cd cmd; make

.PHONY: libpwrusb
libpwrusb:  tools
	cd libpwrusb; make install
	# make sure library is visible
	ldconfig -l $(LIBDIR)/libpowerusb.so
	ldconfig

.PHONY: hidapi
hidapi: ${BUILDHID}/CMakeCache.txt tools
	cd ${BUILDHID};make install || (rm CMakeCache.txt ; cmake . && make install)

${BUILDHID}/CMakeCache.txt: .checkusb .checkudev ${BUILDHID}/.git
	cd ${BUILDHID};cmake . 

${BUILDHID}/.git: 
	git submodule update --recursive --init

.checkudev:
	( (dpkg -s libudev1 >/dev/null && dpkg -s libudev-dev >/dev/null) || apt-get install libudev1 libudev-dev ) && touch .checkudev

.checkusb:
	( (dpkg -s libusb-1.0-0 >/dev/null && dpkg -s libusb-1.0-0-dev >/dev/null) || apt-get install libusb-1.0-0 libusb-1.0-0-dev ) && touch .checkusb

clean:	
