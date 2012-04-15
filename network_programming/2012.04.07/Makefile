CC	= $(CROSS_COMPILE)gcc
CFLAGS	= -Wall -g
LDFLAGS	= -pthread

TARGETS	= test1 incorrect correct correct2 test2 test3 test4 test5 test6 test7 \
	  test8

.PHONY: all clean

all: $(TARGETS)

clean:
	$(RM) *.o *~ a.out $(TARGETS)

# vim:tabstop=8
