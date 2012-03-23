#ifndef _FUNC_H_
#define _FUNC_H
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>

#define RED 0x00ff0000
#define GREEN 0x0000ff00
#define BLUE 0x000000ff
#define WHITE 0x00ffffff
#define BLACK 0x00000000
#define STAET_X 0
#define STAET_Y 0
#define LEN 10 
#define HIGH 10
#define MAXSIZE_SNAKE 10240


typedef unsigned char u8_t;
typedef unsigned int u32_t;

typedef struct{
	int w;
	int h;
	int bpp;
	void *memo;
}fbscr_t;

struct snake_one{
	int x;
	int y;
};
typedef struct snake_one snake_t[MAXSIZE_SNAKE];
extern int init_data(void);
extern void init_snake(snake_t snakes, int *cnt);
extern int fb_one_pixel(int x, int y, u32_t color);
extern int fb_a_angle(int x, int y, int len, int high, u32_t color);
extern int hitkey(void);
extern char get_key(void);
extern int snake_move(void);
extern int move_one_step(snake_t snakes, int *cnt, int o_x, int o_y);
extern void grew_by_time(snake_t snakes, int *cnt, int x, int y);


static inline int open_r(char *filepath, int flags)
{
	int fd = open(filepath, flags);
	if(fd < 0){
		perror(filepath);
		exit(1);
	}
	return fd;
}
static inline void* mmap_r(void *p, size_t t,int port, int flags, int fd, off_t f)
{
	void * ptr = mmap(p, t, port, flags, fd, f);
	if(p == MAP_FAILED){
		perror("mmap");
		exit(1);
	}
	return ptr;

}

#endif

