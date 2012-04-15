CC	= gcc
CFLAGS	= -Wall -g -D_DEBUG_
LDFLAGS	= 

TARGETS	= 

.PHONY: all clean

all: $(TARGETS)
	$(MAKE) -C unixdomain
	$(MAKE) -C io-multiplexing

clean:
	$(RM) $(TARGETS) *.o a.out *~
	$(MAKE) -C unixdomain clean
	$(MAKE) -C io-multiplexing clean
