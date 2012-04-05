src = $(wildcard *.c)
target = $(patsubst %.c, %, $(src))

CFLAGS = -Wall -g
CC = gcc
CLEAN_FLAGS = -rm -rf

all:$(target)

$(target):%:%.c
	$(CC) $(CFLAGS) $< -o $@
clean:
	$(CLEAN_FLAGS) $(target)
.PHONY:all clean
