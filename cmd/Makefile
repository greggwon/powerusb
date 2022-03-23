CXXFLAGS=-fPIC -Wall -g -c -I../libpwrusb -Llib/64bit `pkg-config libusb-1.0 --cflags` -Wno-format-security -std=gnu++11
LDFLAGS=-Wall -L/usr/local/lib/ -Llib/64bit -g -Xlinker '-u libusb_init' -lhidapi-libusb -lhidapi-hidraw -ldl `pkg-config libusb-1.0 --libs` -lusb-1.0 -lhidapi-libusb -lpowerusb -lusb-1.0 -lpthread -u libusb_init  -lcurses -lhidapi-hidraw

CMD=powerusb
MAN=powerusb.1
MANPATH=/usr/local/man/man1

$(CMD): powerusb.o
	g++ powerusb.o ${LDFLAGS} -o $@

powerusb.o: LinuxPowerUSB.hpp

clean:
	rm -f $(CMD) powerusb.o

install: $(CMD) $(MAN)
	cp $(CMD) /usr/local/bin
	mkdir -p $(MANPATH)
	cp $(MAN) $(MANPATH)/$(CMD).1
