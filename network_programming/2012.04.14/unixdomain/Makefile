CC	= gcc
CFLAGS	= -Wall -g -D_DEBUG_
LDFLAGS	= 

TARGETS	= 

.PHONY: all clean

all: $(TARGETS)
	$(MAKE) -C stream

clean:
	$(RM) $(TARGETS) *.o a.out *~
	$(MAKE) -C stream clean
