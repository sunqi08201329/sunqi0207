all:
	gcc -Wall -g -c queue.c
	ar rcs queue.a queue.o
	gcc testmain.c queue.a -o testmain -I./
