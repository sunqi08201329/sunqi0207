#include <stdio.h>
#include "func.h"

extern fbscr_t fb_v;

int main(int argc, const char *argv[])
{
	init_data();
	snake_move();
	return 0;
}

