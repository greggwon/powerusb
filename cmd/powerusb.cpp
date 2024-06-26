#include "powerusb.h"
#include "LinuxPowerUSB.hpp"

#include <curses.h>

const int numinput = 7;
static bool debugging = false;

template <typename T, typename... Args>
static void debug( T fmt, Args... args ) {
	int len = std::snprintf( nullptr, 0, fmt, args... );
	char buf[len+100];
	std::snprintf( buf, sizeof(buf), fmt, args... );
	if( debugging ) {
		fprintf( stdout, "%s\n", buf );
		fflush(stdout);
	}
}

void usage(char **argv) {
	fprintf( stderr, "Usage: %s [-devDfm] -p port [-s state]\n", argv[0]);
	fprintf( stderr, "       %s -r [-D] <reset-for>\n", argv[0] );
	fprintf( stderr, "       %s -w [-D]\n", argv[0] );
	fprintf( stderr, "       %s -R watchDogResetInv [-L] [-D] [-W watchdogInv] [-F watchdogFailCount]\n", argv[0] );
	fprintf( stderr, "       %s -S\n", argv[0] );
}

static bool verbose = false;

class ActionHandler {
	bool defState;
	bool useexit;
	int port, input, output;
	char *state;
	bool windowing;
	bool inputs;
	bool outputs;
	int watchdogFail;
	int watchdog;
	int reset;
	int watchdogReset;
	bool watchdogLoop;
	bool setWatchDog;
	bool stopWatchDog;
	bool getModel;
	bool getFirmware;
	int toggleOn, toggleOff;
	bool setupToggle;
	public:
	LinuxPowerUSB *lp;
	ActionHandler( LinuxPowerUSB *lpp ) {
		this->lp = lpp;
		defState = false;
		useexit = false;
		port = 0, input=0, output=0;
		state = NULL;
		windowing = false;
		setupToggle = false;
		toggleOn = 24*3600;
		toggleOff = 5*60;
		inputs = false;
		outputs = false;
		watchdogFail = 1;
		getFirmware = false;
		getModel = false;
		watchdog = 10;
		verbose = false;
		reset = 0;
		watchdogReset = 5;
		stopWatchDog = false;
		setWatchDog = false;
		watchdogLoop = false;
	}
	~ActionHandler() {
		if( state != NULL ) {
			free(state);
			state = NULL;
		}
	}

	int handleRequest( int argc, char* argv[])
	{
		LinuxPowerUSB &lp = *this->lp;
		int c;
		while( (c = getopt(argc, argv, "s:p:I:devwmfioDLO:r:R:SW:F:T:t:")) != -1 ) {
			debug("Processing argument: -%c", c );
			switch( c ) {
				case 'T': toggleOn = atoi(optarg); setupToggle = true; break;
				case 't': toggleOff = atoi(optarg); setupToggle = true; break;
				case 'F': watchdogFail = atoi(optarg); setWatchDog = true; break;
				case 'W': watchdog = atoi(optarg); setWatchDog = true; break;
				case 'S': stopWatchDog = true; break;
				case 'R': watchdogReset = atoi(optarg); setWatchDog = true; break;
				case 'D': debugging = true; break;
				case 'L': watchdogLoop = true; break;
				case 'f': getFirmware = true; break;
				case 'm': getModel = true; break;
				case 'r': reset = atoi(optarg); break;
				case 'O': output = atoi(optarg); break;
				case 'I': input = atoi(optarg); break;
				case 'i': inputs = true; break;
				case 'o': outputs = true; break;
				case 'v': verbose = true; break;
				case 'w': windowing = true; break;
				case 'd': defState = true; break;
				case 'p': port = atoi(optarg); break;
				case 's': state = strdup(optarg); break;
				case 'e': useexit = true; break;
				case -1: break;
				default:
					throw LinuxPowerUSBError( "bad argument: '%d'", c);
			}
		}
		PowerUSB::debugging = verbose;
		debug("...Set verbose=%d", verbose);
		if( windowing ) return 5;

		lp.Setup();
		if( input == 0 && output == 0 && port == 0 && !inputs && reset == 0 && !setWatchDog && !stopWatchDog && !getFirmware && !getModel ) {
			throw LinuxPowerUSBError( "missing port #: -p N required");
		}

		bool how = false;
		if( state != NULL ) {
			how = strcasecmp( state, "on") == 0;
		}
		debug("...Checking reset=%d", reset);
		if( reset > 0 ) { 
			debug("Resetting PowerUSB Board");
			lp.powerCycleIn(reset);
			debug("Closing all ports");
			lp.Disconnect();
			for( int i = 0; i < reset; ++i ) {
				try {
					debug("trying setup again to detect recovery");
					if(lp.Setup() ) {
						debug("checking status");
						if( lp.checkStatus() ) {
							debug("checkStatus recovery indicated");
							break;
						}
					}
				} catch( LinuxPowerUSBError &ex ) {
					lp.error( "%s: %s\n", argv[0], ex.what() );
				}
				sleep(1);
			}
		}
		if( getFirmware ) {
			int vers = lp.getVersion();
			printf( "%d\n", vers );
		}
		if( getModel ) {
			std::string mod = lp.getModelName();
			printf( "%s\n", mod.c_str() );
		}

		debug("...Checking port=%d", port);
		if( port > 0 ) {
			if( setupToggle ) {
				debug("setup port=%d toggle: on=%d, off=%d", port, toggleOn, toggleOff );
				int v = lp.setupPortToggle( port, toggleOn, toggleOff );
				debug("setupPortToggle: %d", v );
				sleep(60);
			} else {
				if( defState ) {
					if( state == NULL )
						if( useexit ) return(lp.getPortDefaultState(port));
						else lp.reportDefault(lp.getPortDefaultState(port), port, verbose);
					else
						lp.setPortDefaultState( port, how );

				} else {
					if( state == NULL )
						if( useexit ) return(lp.getPortState(port));
						else lp.reportStatus(lp.getPortState(port), port, verbose);
					else
						lp.setPortState( port, how );
				}
			}
		}

		debug("...Checking output=%d", output);
		if( output > 0 ) {
			int st[numinput] = {0};
			if( output < 0 || output >= numinput ) {
				throw new LinuxPowerUSBArgsError( "Bad output #%d", input );
			}

			if( state !=  NULL ) {
				st[output] = how;
				lp.setOutputState( st );
			} else {
				lp.getOutputStates( st );
				if( verbose ) {
					lp.report("Output #%d = %d\n", output, st[output-1] );
				} else {
					exit( st[output-1] );
				}
			}
		}

		debug("...Checking input=%d", input);
		if( input > 0 ) {
			int st[numinput];
			if( input >= numinput ) {
				throw new LinuxPowerUSBArgsError( "Bad input #%d", input );
			}
			lp.getInputStates(st);
			if( verbose ) {
				lp.report("input #%d = %d\n", input, st[input-1] );
			} else {
				exit(st[input-1]);
			}
		}
		debug("...Checking inputs=0x%02x", inputs);
		if( inputs ) {
			int st[8];
			lp.getInputStates(st);
			lp.report("Inputs: ");
			for( int i = 0; i < numinput; ++i ) {
				lp.report("%d=%d", i+1, st[i] );
				if( i < 6 ) lp.report(", ");
			}
			lp.report("\n");
		}
		debug("...Checking outputs=0x%02x", outputs);
		if( outputs ) {
			int st[8];
			lp.getOutputStates(st);
			lp.report("Outputs: ");
			for( int i = 0; i < numinput; ++i ) {
				lp.report("%d=%d", i+1, st[i] );
				if( i < 6 ) lp.report(", ");
			}
			lp.report("\n");
		}

		debug("...Checking setWatchDog=%d", setWatchDog );
		if( setWatchDog ) {
			debug("watchdog status: %d, looping=%s", lp.getWatchdogStatus(), watchdogLoop ? "yes" : "no" );
			debug("Sending initial heartbeat");
			lp.sendHeartBeat();
			debug("Setting up watchdog=%d, fail=%d, reset=%d",watchdog, watchdogFail, watchdogReset );
			lp.setWatchDogInterval( watchdog, watchdogFail, watchdogReset );
			while( watchdogLoop ) {
				debug("watchdog status: %d", lp.getWatchdogStatus() );
				debug("sending watchdog heartbeat...");
				lp.sendHeartBeat();
				debug("sleeping after heartbeat: %d", watchdog/2 );
				sleep( watchdog/2 > 0 ? watchdog/2 : watchdog );
			}
		}
		if( stopWatchDog ) {
			debug("watchdog status: %d", lp.getWatchdogStatus());
			debug("stopping watchdog...");
			lp.stopWatchDog();
			debug("stopped watchdog status: %d", lp.getWatchdogStatus());
		}
		return 0;
	}
};

static void moveDeviceBy( LinuxPowerUSB &p, int inc ) {
	int cur = p.getCurrentDevice();
	p.setCurrentDevice(cur+inc);
	if( cur == p.getCurrentDevice() ) beep();
}
#define PLUG_ROW	1
#define DEFAULT_ROW	2
#define IO_ROW		3
#define INPUT_ROW	4
#define OUTPUT_ROW	5
#define BOX_ROWS	7
#define DEVICE_ROW	7
#define STATE_ROW	8
#define STATUS_ROW	9
#define ERROR_ROW	14


int main(int argc, char* argv[])
{
	int ret = -1;
	LinuxPowerUSB p;
	try {
		const int spc = 8;
		const int plugs = 3;
		const int cw =4;
		debug("setup PowerUSB");
		debug("processing arguments");
		ActionHandler ah(&p);
		ret = ah.handleRequest( argc, argv);
		if( ret == 5 ) {
			WINDOW *win = NULL;
			bool quit = false;
			initscr();
			cbreak();
			noecho();
			//nonl();
			//intrflush( stdscr, FALSE );
			keypad( stdscr, TRUE );
			nodelay( stdscr, TRUE );
			win = subwin( stdscr, BOX_ROWS, std::max(spc * plugs + 7, numinput * cw + 8), 0, 0 );
			move( STATUS_ROW, 0 );
			printw("------------------------------------------------------------\n");
			move( STATUS_ROW+1, 0 );
			printw("SPC/CR=toggle, [1-%d]=Sel, q=quit, TAB/SHFT-TAB=switch ports\n", plugs);
			move( STATUS_ROW+2, 0 );
			printw("d=toggle default state\n");
			int idx = 0;
			while(!quit) {
				debug("settingup debug");
				p.setDebug(false);
				while( true ) {
					move(ERROR_ROW, 0);
					try {
						p.Disconnect();
						p.Setup();
						clrtoeol();
						break;
					} catch( LinuxPowerUSBError &ex ) {
						p.Disconnect();
						printw( "%s: %s", argv[0], ex.what() );
						clrtoeol();
						sleep(1);
					}
				}
				move( DEVICE_ROW, 0 );
				printw("Device #%d: %s: v%d.0", p.getCurrentDevice(),
					p.getModelName().c_str(), p.getVersion());
				move( PLUG_ROW, 1 );
				printw("Plg:");
				move( DEFAULT_ROW, 1 );
				printw("Def:");
				for( int i = 0; i < plugs; ++i ) {
					bool st = p.getPortState( i+1 );
					move( PLUG_ROW, (i*spc)+7 );
					if( p.getModel() == 3 &&  i == 2 ) {
						st = p.getWatchdogStatus();
						printw("WD=" );
					} else {
						if( i == idx ) {
							standout();
						}
						printw("%d", i+1 );
						if( i == idx ) {
							standend();
						}
						addch('=');
					}
					wattron( stdscr, st ? A_BOLD : A_DIM );
					printw("%s", st ? "on" : "off");
					wattroff( stdscr, st ? A_BOLD : A_DIM );
					clrtoeol();
				

					move( DEFAULT_ROW, (i*spc)+7 );
					if( p.getModel() == 3 &&  i == 2 ) {
						//st = p.getWatchdogStatus();
						//printw("WD=" );
					} else {
						st = p.getPortDefaultState( i+1 );
						if( i == idx ) {
							standout();
						}
						printw("%d", i+1);
						if( i == idx ) {
							standend();
						}
						addch('=');
						wattron( stdscr, st ? A_BOLD : A_DIM );
						printw("%s", st ? "on" : "off");
						wattroff( stdscr, st ? A_BOLD : A_DIM );
					}
					clrtoeol();

				}
				box( win, '|', '-');
				int ch = getch();

				int sts[numinput];
				int osts[numinput];
				p.getInputStates( sts );
				p.getOutputStates( osts );
				move( IO_ROW, 1 );
				printw("I/O:");
				move( INPUT_ROW, 1 );
				printw("Inp:");
				move( OUTPUT_ROW, 1 );
				printw("Out:");
				for( int i = 0; i < numinput; ++i ) {
					move( IO_ROW, 5+(i*cw)+2 );
					printw ("%d",i+plugs+1) ;

					move( INPUT_ROW, 5+(i*cw)+1 );
					wattron( stdscr, sts[i] ? A_BOLD : A_DIM );
					printw("%3s", sts[i] ? "on" : "off" );
					wattroff( stdscr, sts[i] ? A_BOLD : A_DIM );

					move( OUTPUT_ROW, 5+(i*cw)+1 );
					wattron( stdscr, osts[i] ? A_BOLD : A_DIM );
					printw("%3s", osts[i] ? "on" : "off" );
					wattroff( stdscr, osts[i] ? A_BOLD : A_DIM );
				}

				wrefresh(win);
				//refresh();
				if( ch != ERR ) {
					move(STATE_ROW, 0);
					clrtoeol();
				}
				switch( ch ) {
					case 'q': quit = true; break;
					case '\r':
					case '\n':
					case ' ': {
						if( idx <plugs ) {
							bool st = p.getPortState( idx+1 );
							p.setPortState( idx+1, !st );
						} else if( idx >=plugs && idx < plugs+numinput ) {
							//p.setInput
						}
						}
						continue;

					case KEY_BTAB:
						idx = ((idx - 1 ) + plugs+numinput) % (plugs+numinput);
						break;
					case '\t':
						idx = (idx + 1 ) % (plugs + numinput);
						break;
					case ERR:
						break;
					case '+': moveDeviceBy(p,1); break;
					case '-': moveDeviceBy(p,-1); break;
					case 'd': p.setPortDefaultState( idx+1, !p.getPortDefaultState(idx+1)); break;
					case '1':
					case '2':
					case '3':
					case '4': case '5': case '6': case '7': case '8': case '9': case '0':
					{
					    int nidx = ch - '1';
					    if( ch == '0' ) nidx = 9;
					    if( nidx < plugs+numinput ) idx = nidx;
					}
					default:
						move(STATE_ROW, 0);
						if( verbose ) printw("key=%d    ", ch );
						break;
				}
				if( idx < plugs )
					move( PLUG_ROW, (idx*spc)+7 );
				else if( idx < numinput+plugs && idx >= plugs )
					move( INPUT_ROW, 5+(cw*(idx-plugs))+2 );
				refresh();
				p.Disconnect();
				usleep( 50000 );
			}
			endwin();
		}
	} catch( LinuxPowerUSBError &ex ) {
		if( ret == 5 ) endwin();
		p.error( "%s: %s\n", argv[0], ex.what() );
		usage( argv );
		return 1; // error to get exceptions, so exit non-zero
	}
	debug("Closing all...");
	p.closeAll();
	//return 2;
}
