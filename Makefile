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
cp:
	cp ~/github/sunqi0207/Unix_envirement_programming/apue.h ./apue.h 
cpback_github:
	cp ./Makefile ~/github/sunqi0207/Unix_envirement_programming/Makefile
	cp ./apue.h ~/github/sunqi0207/Unix_envirement_programming/apue.h
update_github:
	git add .
	git commit -a -m "master"
	git push
ping_github:
	ssh -T git@github.com
.PHONY:all clean
