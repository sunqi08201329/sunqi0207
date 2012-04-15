CC	= gcc
CFLAGS	= -Wall -g
LDFLAGS	= -pthread

TARGETS	= test1 test2 test3 deadlock datarace

.PHONY: all clean

all: $(TARGETS)

clean:
	$(RM) -f $(TARGETS) *.o a.out *~
