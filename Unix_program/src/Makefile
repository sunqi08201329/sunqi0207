#include ../libs/Makefile

host = sunqi

src = $(wildcard *.c)
target = $(patsubst %.c, %, $(src))

CFLAGS = -Wall -g
CC = gcc
CLEAN_FLAGS = -rm -rf
MACRO = 

INC_PATH = /home/$(host)/github/sunqi0207/Unix_program/include/
LIB_PATH = /home/$(host)/github/sunqi0207/Unix_program/libs/
MAN_PATH = /home/$(host)/github/sunqi0207/Unix_program/src/man/

lib_name = apue

all:$(target) tags

$(target):%:%.c
	$(CC) $(CFLAGS) $< -L$(LIB_PATH) -l$(lib_name) -o $@ -I$(INC_PATH)
tags:
	ctags -R *
clean:
	$(CLEAN_FLAGS) $(target)

makelib:
	make -C $(LIB_PATH)

vimlib:
	vim $(LIB_PATH)*.c

viminc:
	vim $(INC_PATH)*.h
movetxt:
	mv man_* $(MAN_PATH)
.PHONY:all clean makelib
