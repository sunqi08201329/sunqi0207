CC	= g++
CFLAGS	= -Wall -g
LDFLAGS	=

TARGETS	=

.PHONY: all clean

all: $(TARGETS)
	$(MAKE) -C io-multiplexing
	$(MAKE) -C dns

clean:
	$(RM) *.o *~ a.out $(TARGETS)
	$(MAKE) -C io-multiplexing clean
	$(MAKE) -C dns clean
