src = $(wildcard *.c)
objs = $(wildcard *.o)

CFLAGS = -Wall -g
CC = gcc
CLEAN_FLAGS = -rm -rf
STATIC_LINK = ar rcs

INCLUDE_PATH = /home/akaedu/project/include
LIBRARY_PATH = /home/akaedu/project/library
BACKUP_PATH = /home/akaedu/project/backup
OBJS_PATH = /home/akaedu/project/objs
SRC_PATH = /home/akaedu/project/src

lib_name = math
obj_dir = 1
src_dir = 1

all:$(objs)
$(objs):%.o:%.c
	$(CC) $(CFLAGS) $< -o $@
	
clean:
	$(CLEAN_FLAGS) $(objs)
move:
	mkdir $(OBJS_PATH)/$(obj_dir)
	mkdir $(SRC_PATH)/$(src_dir)
	mv $(src) $(OBJ_PATH)/$(obj_dir)
	mv $(objs) $(SRC_PATH)/$(src_dir)
.PHONY:all clean

