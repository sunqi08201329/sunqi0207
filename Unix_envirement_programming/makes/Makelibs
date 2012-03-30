src = $(wildcard *.c)
objs = $(wildcard *.o)

CFLAGS = -Wall -g
CC = gcc
CLEAN_FLAGS = -rm -rf
STATIC_LINK = ar rcs

INCLUDE_PATH = /home/akaedu/project/include
LIBRARY_PATH = /home/akaedu/project/library
BACKUP_PATH = /home/akaedu/project/backup

lib_name = math

all:
	$(STATIC_LINK) $(LIBRARY_PATH)/lib$(lib_name).a $(objs)
	#$(CC) main.c -L$(LIBRARY_PATH) -l $(lib_name) -o main -I$(INCLUDE_PATH)
