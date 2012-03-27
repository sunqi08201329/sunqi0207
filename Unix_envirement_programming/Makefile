src = $(wildcard *.c)
target = $(patsubst %.c, %, $(src))

CFLAGS = -Wall -g
CC = gcc
CLEAN_FLAGS = -rm -rf

all:$(target) tags

$(target):%:%.c
	$(CC) $(CFLAGS) $< -o $@
tags:
	ctags -R *
clean:
	$(CLEAN_FLAGS) $(target)
.PHONY:all clean
