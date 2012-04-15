CC	= gcc
CFLAGS	= -Wall -g -D_DEBUG_
LDFLAGS	= 

TARGETS	= 

.PHONY: all clean

all: $(TARGETS)
	$(MAKE) -C tcp
	$(MAKE) -C udp
	$(MAKE) -C broadcast
	$(MAKE) -C multicast

clean:
	$(RM) $(TARGETS) *.o a.out *~
	$(MAKE) -C tcp clean
	$(MAKE) -C udp clean
	$(MAKE) -C broadcast clean
	$(MAKE) -C multicast clean
