src = $(wildcard *.c)
objs = $(patsubst %.c, %.o, $(src))

CFLAGS = -Wall -g
CC = gcc
CLEAN_FLAGS = -rm -rf
STATIC_LINK = ar rcs

lib_name = apue

all:$(objs) link
$(objs):%.o:%.c
	$(CC) $(CFLAGS) $< -o $@

link:
	$(STATIC_LINK) lib$(lib_name).a $(objs)
	#$(CC) main.c -L$(LIBRARY_PATH) -l $(lib_name) -o main -I$(INCLUDE_PATH)
