src = $(wildcard *.c)
objs = $(wildcard *.o)

INCLUDE_PATH = /home/akaedu/project/include
LIBRARY_PATH = /home/akaedu/project/library
BACKUP_PATH = /home/akaedu/project/backup
OBJS_PATH = /home/akaedu/project/objs
SRC_PATH = /home/akaedu/project/src

main_name = main.c
inc_name = head.h

open_inc:
	vim $(INCLUDE_PATH)/$(inc_name)
backup:
	mv $(main_name) $(BACKUP_PATH)

make_app:
	make -f Make_lib_inc_main
