#include <stdio.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include "func.h"

extern fbscr_t fb_v;

void init_snake(snake_t snakes, int *cnt)
{
	memset(snakes, 0, sizeof(snake_t));
	*cnt = 0;
}
void grew(snake_t snakes, int *cnt, int x, int y)
{
	snakes[*cnt].x = x;
	snakes[*cnt].y = y;
	*cnt += 1;
}
	
int move_one_step(snake_t snakes, int *cnt, int o_x, int o_y)
{
	int i = 0;
	if((snakes[0].x < fb_v.w - LEN) && (snakes[0].y < fb_v.h - HIGH) && (snakes[0].x >= 0) && (snakes[0].y >= 0))
		fb_a_angle(snakes[*cnt - 1].x, snakes[*cnt - 1].y, LEN, HIGH, BLACK);
	else 
		return -1;

	for (i = 1; i < *cnt; i++) 
	{
		snakes[i].x = snakes[i - 1].x;
		snakes[i].y = snakes[i - 1].y;
	}
	//grew(snakes, cnt, snakes[*cnt-1].x, snakes[*cnt - 1].y);
	snakes[0].x += o_x;
	snakes[0].y += o_y;
	if((snakes[0].x < fb_v.w - LEN) && (snakes[0].y < fb_v.h - HIGH) && (snakes[0].x >= 0) && (snakes[0].y >= 0))
		fb_a_angle( snakes[0].x, snakes[0].y, LEN, HIGH, RED);
	else
		return -1;

	usleep(10000*2*5);
	return 1;
}

int hitkey(void)
{
	int i = 0;
	ioctl(STDIN_FILENO, FIONREAD, &i);
	return i;
}

char get_key(void)
{
	if(hitkey() > 0){	
		return getchar();	
	}
	return 0;	
}
void print_snakes(snake_t snakes, int cnt)
{
	int i = 0;
	for (i = 0; i < 4; i++) 
	{
		printf("cnt = %d,x = %d,y = %d\n", cnt, snakes[i].x, snakes[i].y);
	}
}

int snake_move(void)
{
	int cnt = 0;
	snake_t snakes;
	int step = 10;
	int x_offset = step;
	int y_offset = 0;
	int sx = 100;
	int sy = 100;
	char flags = 0;
	//memset(fb_v.memo, 0, fb_v.w*fb_v.h*fb_v.bpp/8);
	init_snake(snakes, &cnt);
	grew(snakes, &cnt, sx, sy);
	//grew(snakes, &cnt, snakes[cnt - 1].x + 10, snakes[cnt - 1].y + 10);
	print_snakes(snakes, cnt);
	char dict = 0;//, new_dict = 0;
	puts("oprate press is w/a/s/d");
	system("stty raw -echo");
	while(1){
		if(move_one_step(snakes, &cnt, x_offset, y_offset) < 0){
			puts("Game over\ncontinue?(y/n)");
			while(1){
				if((flags = getchar()) == 'y'){
					x_offset = step;
					y_offset = 0;
					init_snake(snakes, &cnt);
					grew(snakes, &cnt, sx, sy);
					break;
				}else if(flags == 'n')
					break;
			}
			if(flags == 'n')
				break;

		}
		//new_dict = get_key();
		//switch(new_dict){
			//case 'a':
				//if(dict != 'd') dict = new_dict;break;
			//case 'd':
				//if(dict != 'a') dict = new_dict;break;
			//case 'w':
				//if(dict != 's') dict = new_dict;break;
			//case 's':
				//if(dict != 'w') dict = new_dict;break;
			//case 'q':
				//dict = new_dict;
			//default:break;
		//}

		//print_snakes(snakes, cnt);
		//return 0;
	grew(snakes, &cnt, snakes[cnt - 1].x + 10, snakes[cnt - 1].y + 10);
		dict = get_key();
		switch(dict){
			case 'a':
				x_offset = -step;
				y_offset = 0;
				continue;
			case 'd':
				x_offset = step;
				y_offset = 0;
				continue;
			case 'w':
				x_offset = 0;
				y_offset = -step;
				continue;
			case 's':
				x_offset = 0;
				y_offset = step;
				continue;
			case 'q':
				break;
			default:continue;
		}
		break;
	}
	system("stty cooked echo");
	return 0;
}
