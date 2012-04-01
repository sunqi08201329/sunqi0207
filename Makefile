src = $(wildcard *.c)
target = $(patsubst %.c, %, $(src))

CFLAGS = -Wall -g
CC = gcc
CLEAN_FLAGS = -rm -rf
MACRO = 

all:$(target) tags

$(target):%:%.c
	$(CC) $(CFLAGS) $< -o $@
tags:
	ctags -R *
clean:
	$(CLEAN_FLAGS) $(target)
cp:
	cp ~/github/sunqi0207/Unix_envirement_programming/apue.h ./apue.h 
cpback_github:
	cp ./Makefile ~/github/sunqi0207/Unix_envirement_programming/Makefile
	cp ./apue.h ~/github/sunqi0207/Unix_envirement_programming/apue.h
update_github:
	git status
	git add .
	git commit -a -m "master"
ping_github:
	ssh -T git@github.com
search_macro:
	grep -i $(MACRO) -nr /usr/include
.PHONY:all clean
