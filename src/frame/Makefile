#this is for feame

src = main.c init.c  basic_shapes.c snake.c func.h
para = -o main -Wall 
all: main tags
main:$(src)
	gcc $(src) $(para)
tags:
	ctags -R *	
open:
	vim *.c *.h Makefile
chmod:
	sudo chmod 666 /dev/fb0
.PHONY:open
