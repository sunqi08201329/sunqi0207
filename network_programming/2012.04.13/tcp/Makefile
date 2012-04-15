CC	= gcc
CFLAGS	= -Wall -g -D_DEBUG_
LDFLAGS	= -pthread -lrt

TARGETS	= server server1 server2 server3 server3.new

.PHONY: all clean

all: $(TARGETS)

clean:
	$(RM) -f $(TARGETS) *.o a.out *~
