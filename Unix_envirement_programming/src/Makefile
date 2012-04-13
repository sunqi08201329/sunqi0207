src = $(wildcard *.c)
target = $(patsubst %.c, %, $(src))

CFLAGS = -Wall -g
CC = gcc
CLEAN_FLAGS = -rm -rf
MACRO = 

INC_PATH = /home/akaedu/github/sunqi0207/Unix_envirement_programming/include/
LIB_PATH = /home/akaedu/github/sunqi0207/Unix_envirement_programming/libs/
MAN_PATH = /home/akaedu/github/sunqi0207/Unix_envirement_programming/src/man

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
	mv *.txt $(MAN_PATH)
.PHONY:all clean makelib
