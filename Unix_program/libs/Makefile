host = sunqi

src = $(wildcard *.c)
objs = $(patsubst %.c, %.o, $(src))

CFLAGS = -Wall -g
CC = gcc
CLEAN_FLAGS = -rm -rf
STATIC_LINK = ar rcs

INC_PATH = /home/$(host)/github/sunqi0207/Unix_program/include/
LIB_PATH = /home/$(host)/github/sunqi0207/Unix_program/libs/
MAN_PATH = /home/$(host)/github/sunqi0207/Unix_program/src/man/

lib_name = apue

all:$(objs) link
$(objs):%.o:%.c
	$(CC) -c $< -o $@ -I$(INC_PATH)

link:
	$(STATIC_LINK) lib$(lib_name).a $(objs)
	#$(CC) main.c -L$(LIBRARY_PATH) -l $(lib_name) -o main -I$(INCLUDE_PATH)

moveman:
	mv man* $(MAN_PATH)	
clean:
	-rm -rf *.o *.a
