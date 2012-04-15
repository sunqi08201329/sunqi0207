CC	= gcc
CFLAGS	= -Wall -g
LDFLAGS	= 

TARGETS	= test1 test2 test3 test4 test5

.PHONY: all clean

all: $(TARGETS)
	$(MAKE) -C tcp

clean:
	$(RM) -f $(TARGETS) *.o a.out *~
	$(MAKE) -C tcp clean
