#include <stdio.h>
#include "func.h"

fbscr_t fb_v;

int fb_one_pixel(int x, int y, u32_t color)
{
	*((u32_t *)fb_v.memo + x + y*fb_v.w) = color;
	return 0;
}
int fb_a_angle(int x, int y, int len, int high, u32_t color)
{
	int i, j;
	for (i = 0; i < high; i++) 
	{
		for (j = 0; j < len; j++) 
		{
			*((u32_t *)fb_v.memo + (x + j) + (y + i) * fb_v.w) = color;
		}
	}
	return 0;
}

