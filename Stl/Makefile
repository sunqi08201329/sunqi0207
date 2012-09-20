src = $(wildcard *.cpp)
target = $(patsubst %.cpp, %, $(src))

CFLAGS = -Wall -g
CC = g++
CLEAN_FLAGS = -rm -rf

all:$(target)

$(target):%:%.cpp
	$(CC) $(CFLAGS) $< -o $@
clean:
	$(CLEAN_FLAGS) $(target)
.PHONY:all clean
