CC	= gcc
CFLAGS	= -Wall -g
LDFLAGS	= 

TARGETS	= 

.PHONY: all clean

all: $(TARGETS)
	$(MAKE) -C mutex
	$(MAKE) -C cond

clean:
	$(RM) -f $(TARGETS) *.o a.out *~
	$(MAKE) -C mutex clean
	$(MAKE) -C cond clean
